"""Extract the audited GF classifier's direct map without executing private code.

Only this SHA is supported. Modifier-dependent switch arms remain explicit misses.
ELF string pointers are resolved through R_X86_64_RELATIVE relocations.
"""
import argparse
import hashlib
import json
import mmap
from pathlib import Path
import struct
import subprocess

SHA256 = '13fe4b883a085db3bce929eea75d0c93dab8ad245694e2d4598826765dbdb951'


def extract(binary, output, evidence_dir):
    with binary.open('rb') as f:
        if hashlib.file_digest(f, 'sha256').hexdigest() != SHA256:
            raise ValueError('unaudited libtpu binary')
        with mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ) as elf:
            header = struct.unpack_from('<16sHHIQQQIHHHHHH', elf)
            segments = [struct.unpack_from('<IIQQQQQQ', elf, header[5] + i * header[9])
                        for i in range(header[10])]

            def offset(address):
                for p in segments:
                    if p[0] == 1 and p[3] <= address < p[3] + p[5]:
                        return address - p[3] + p[2]
                raise ValueError('address outside ELF load segments')

            def array(address, count, fmt):
                return struct.unpack_from('<' + fmt * count, elf, offset(address))

            relocations = {}
            for i in range(header[12]):
                section = struct.unpack_from('<IIQQQQIIQQ', elf, header[6] + i * header[11])
                if section[1] != 4:
                    continue
                for pos in range(section[4], section[4] + section[5], section[9]):
                    address, info, addend = struct.unpack_from('<QQq', elf, pos)
                    if any(base <= address < base + 462 * 8 for base in (0x1e2e9d70, 0x1e2eba50)):
                        if info & 0xffffffff != 8:
                            raise ValueError('unexpected string relocation')
                        relocations[address] = addend

            def strings(base):
                result = []
                for i in range(462):
                    pos = offset(relocations[base + i * 8])
                    result.append(elf[pos:elf.find(b'\0', pos)].decode())
                return result

            names, mnemonics = strings(0x1e2e9d70), strings(0x1e2eba50)
            latch_rows = []
            for mode in (0, 1, 10, 11, 48, 49, 50, 51):
                branch = 0x9bc357c + array(0x9bc357c + mode * 4, 1, 'i')[0]
                if elf[offset(branch):offset(branch) + 3] != bytes.fromhex('488d35'):
                    raise ValueError('latch mode string switch changed')
                string_at = offset(branch + 7 + array(branch + 3, 1, 'i')[0])
                latch_rows.append(dict(mode=mode,
                    name=elf[string_at:elf.find(b'\0', string_at)].decode(),
                    unmasked_id=array(0x9818a00 + 2 * mode, 1, 'H')[0],
                    masked_id=array(0x9818a68 + 2 * mode, 1, 'H')[0]))
            # Literal stores in the audited BF16 non-transpose matpush row.
            if elf[offset(0x19361701):offset(0x19361701) + 4] != bytes.fromhex('c6459008'):
                raise ValueError('matpush throughput resource changed')
            if elf[offset(0x19361705):offset(0x19361705) + 3] != bytes.fromhex('c74594'):
                raise ValueError('matpush throughput store changed')
            bf16_push_issue = array(0x19361708, 1, 'I')[0]
            if elf[offset(0x1936175f):offset(0x1936175f) + 4] != bytes.fromhex('c6459008'):
                raise ValueError('transpose matpush throughput resource changed')
            bf16_xpose_issue = array(0x19361766, 1, 'I')[0]
            # Explicit builder opcodes disambiguate identical display prefixes.
            aliases = {}
            for mnemonic, opcode, address in [
                    ('vpack.c.b16', 294, 0x199aa55a),
                    ('vpack.i.b16', 294, 0x1999ea37),
                    ('vunpack.c.l.s4', 265, 0x199b5da9),
                    ('vunpack.c.0.s8', 265, 0x199b4f10),
                    ('vweird.f32', 173, 0x1991d8ad)]:
                if elf[offset(address):offset(address)+5] != b'\xbf' + struct.pack('<I', opcode):
                    raise ValueError('builder opcode changed: ' + mnemonic)
                aliases[mnemonic] = dict(llo_opcode=opcode, source_address=hex(address))
            for mnemonic, address in [('vunpack.c.l.bf16', 0x199f6230),
                                      ('vunpack.c.h.bf16', 0x199f6270)]:
                if elf[offset(address):offset(address)+6] != bytes.fromhex('66817f1a0901'):
                    raise ValueError('unpack predicate opcode changed')
                aliases[mnemonic] = dict(llo_opcode=265, source_address=hex(address))
            for opcode in (245, 246, 247, 248, 249, 253, 254, 255, 256, 257, 335):
                for unit in (0, 1):
                    aliases[mnemonics[opcode] + '.xlu' + str(unit)] = dict(
                        llo_opcode=opcode, execution_unit='xlu' + str(unit),
                        source_address='0x267517a', note='XLU unit suffix; raw mnemonic table')
            # These classifier branches ignore order for scalar comparisons.
            # Vector candidates are kept as equivalence classes, not guessed IDs.
            vector_compare = {}
            for dtype, primitive, branch, candidates in [
                    ('s32.totalorder', 4, 0x19360ae9, array(0x9818b00, 6, 'B')),
                    ('u32.totalorder', 8, 0x19360b44, array(0x9818b06, 6, 'B')),
                    ('f32.partialorder', 11, 0x19360ac6, array(0x9818af4, 6, 'B')),
                    ('f32.totalorder', 11, 0x19360ac6, (230, 231))]:
                if 0x9818930 + array(0x9818930 + (primitive-3)*4, 1, 'i')[0] != branch:
                    raise ValueError('vector comparison dtype switch changed')
                vector_compare[dtype] = dict(performance_ids=sorted(set(candidates)),
                                            source_address=hex(branch))
            # Raw IAR 0 / 1 select 435 / 436, as opposed to lane/sublane setters.
            if elf[offset(0x19360961):offset(0x19360961)+11] != bytes.fromhex('83f80166b8b4016683d800'):
                raise ValueError('raw IAR classifier changed')
            if (elf[offset(0x193601a4):offset(0x193601a4)+10] != bytes.fromhex('48b9e100000000150000')
                    or elf[offset(0x193601bb):offset(0x193601bb)+5] != bytes.fromhex('be1b000000')
                    or elf[offset(0x193602cf):offset(0x193602cf)+5] != bytes.fromhex('be1b000000')
                    or elf[offset(0x193602d9):offset(0x193602d9)+2] != bytes.fromhex('01c0')):
                raise ValueError('GF pseudo latency rules changed')
            if elf[offset(0x199b2e1a):offset(0x199b2e1a)+5] != bytes.fromhex('bf26010000'):
                raise ValueError('BF16 pack raw opcode changed')
            pairs = [array(0x267517a + i * 4, 2, 'H') for i in range(274)]
            if pairs != sorted(pairs) or len(dict(pairs)) != 274 or max(v for _, v in pairs) != 464:
                raise ValueError('GF classifier map shape changed')
            rules = []
            for resource, relative in enumerate(array(0x9817fa8, 32, 'i')):
                same = 0x9817fa8 + relative
                different = 0x9817f28 + array(0x9817f28 + resource * 4, 1, 'i')[0]
                rule = ('global_nonzero_intersection' if same == 0x19360430 and different == 0x19360550
                        else 'same_unit_nonzero_intersection' if same == 0x19360430 and different == 0x1936055f
                        else 'specialized')
                rules.append({'resource': resource, 'rule': rule,
                              'same_unit_branch': hex(same), 'different_unit_branch': hex(different)})
            result = dict(schema_version=1, target='gf', binary_sha256=SHA256,
                          classifier_address='0x19360660', direct_table_address='0x267517a',
                          owner_constructor_address='0x1935f8a0',
                          resource_pair_function='0x19360330',
                          matpush_latch_rows=latch_rows,
                          bf16_matpush_nontranspose_issue_cycles=bf16_push_issue,
                          bf16_matpush_transpose_issue_cycles=bf16_xpose_issue,
                          exact_mnemonics=aliases,
                          vector_compare_cost_equivalence=vector_compare,
                          raw_iar_performance_ids={'0': 435, '1': 436},
                          pseudo_mnemonics={
                              'scalar_parameter_address': dict(llo_opcode=44, performance_id=27,
                                  latency_multiplier=1, source_address='0x193601a4'),
                              'scalar_select': dict(llo_opcode=136, performance_id=27,
                                  latency_multiplier=2, source_address='0x193602c8',
                                  limitation='scalar_select assembly issue expansion is not modeled')},
                          consumer_disambiguation={'vsyncmov': {'spop': 11, 'vpop.sfrf': 15}},
                          matpush_latency_rule='nontranspose ceil(table_latency/2), transpose table_latency; 0x19360000',
                          pack_mnemonics={'vpack.c.bf16': {'llo_opcode': 294,
                              'builder_address': '0x199b2de0', 'opcode_store_address': '0x199b2e1a'}},
                          matmul_format_rows={
                              'unmasked': {str(i): array(0x98189d8, 10, 'H')[i - 1]
                                           for i in (1, 2, 9, 10)},
                              'masked': {str(i): array(0x98189ec, 10, 'H')[i - 1]
                                         for i in (1, 2, 9, 10)},
                              'enum_names': {'f32': 1, 'bf16': 2, 'f8e5m2': 9, 'f8e4m3fn': 10},
                              'enum_name_provenance': 'llo/mxu.py; checked on 0.0.46.1; retained assumption for 0.0.48',
                              'source_addresses': ['0x1936082e', '0x1936085a']},
                          scalar_compare_cost_equivalence={
                              'llo_opcode': 363,
                              'performance_ids': sorted(set(array(0x9818ad0, 6, 'H')
                                                            + array(0x9818adc, 6, 'H')
                                                            + array(0x9818ae8, 6, 'H'))),
                              'source_addresses': ['0x19360902', '0x19360a7d', '0x19360a94'],
                              'note': 'Scalar compare switch variants; only use if every candidate has identical costs.'},
                          rows=[dict(llo_opcode=o, opcode_name=names[o], mnemonic=mnemonics[o],
                                     performance_id=i) for o, i in pairs], resource_rules=rules,
                          limitations=['Direct classifier entries only; modifiers and pseudo-ops need separate handling.',
                                       'Specialized resources, MXU modifier tables and runtime memory remain separate.'])
    output.write_text(json.dumps(result, indent=2) + '\n')
    evidence_dir.mkdir(parents=True, exist_ok=True)
    for name, start, end in [('gf-classifier', 0x19360660, 0x19360df0),
                             ('gf-owner', 0x1935f8a0, 0x19360000),
                             ('gf-latch-latency', 0x19360000, 0x19360070),
                             ('gf-pseudo-latency', 0x19360070, 0x19360330),
                             ('gf-latency-internal', 0x19360ef0, 0x19361480),
                             ('gf-scalar-select-emitter', 0x1578c0d0, 0x1578c420),
                             ('gf-latch-names', 0x19e68cb0, 0x19e68f50),
                             ('gf-pack-bf16', 0x199b2d90, 0x199b2ec0),
                             ('gf-pack-b16-builders', 0x199aa520, 0x199aa640),
                             ('gf-pack-i16-builder', 0x1999ea00, 0x1999eb00),
                             ('gf-unpack-s4-builder', 0x199b5d70, 0x199b5e50),
                             ('gf-unpack-s8-builder', 0x199b4ed0, 0x199b5010),
                             ('gf-unpack-bf16-predicates', 0x199f6230, 0x199f62b0),
                             ('gf-weird-f32-builder', 0x1999fbf0, 0x1999fc40),
                             ('gf-weird-create', 0x1991d850, 0x1991d8e0),
                             ('gf-matpush-constructor', 0x193615b0, 0x19361bf3),
                             ('gf-resource-pairs', 0x19360330, 0x19360660)]:
        assembly = subprocess.check_output(['objdump', '-d', '-Mintel',
                    f'--start-address={start}', f'--stop-address={end}', str(binary)], text=True)
        (evidence_dir / (name + '.asm')).write_text(assembly)
    print(json.dumps({'direct_mappings': len(pairs), 'output': str(output)}))


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('binary', type=Path)
    p.add_argument('output', type=Path)
    p.add_argument('--evidence-dir', type=Path, required=True)
    args = p.parse_args()
    extract(args.binary, args.output, args.evidence_dir)
