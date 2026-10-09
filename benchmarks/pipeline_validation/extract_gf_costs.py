"""Extract GF constructor constants from one audited libtpu ELF, without loading it.

Requires GNU objdump. Addresses are pinned to the binary SHA, not just the wheel
version. Unknown binaries and changed constructor patterns fail closed. This
extracts performance-table IDs, NOT LloOpcode IDs or instruction issue footprints.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess

SHA256 = '13fe4b883a085db3bce929eea75d0c93dab8ad245694e2d4598826765dbdb951'
BUILD_ID = '3310a7c8c137cd515c7a2ba1ce2ea38c'
START, END = 0x1937a450, 0x19380a2f


def parse_constructor(assembly):
    latency, resources, evidence = {}, {}, {}
    pointer = None
    for line in assembly.splitlines():
        m = re.match(r'\s*([0-9a-f]+):\s+(?:[0-9a-f]{2} +)+\s*(.*)', line)
        if not m:
            continue
        pc = int(m[1], 16)
        instruction = m[2].split('#')[0].strip()
        if not START <= pc < END:
            continue
        if instruction == 'mov    rax,QWORD PTR [rbx]':
            pointer = ('latency', None)
            continue
        if instruction == 'mov    rax,QWORD PTR [r12]':
            pointer = ('grid', None)
            continue
        load = re.fullmatch(r'mov\s+rax,QWORD PTR \[rax(?:\+0x([0-9a-f]+))?\]', instruction)
        if load:
            offset = int(load[1] or '0', 16)
            if pointer and pointer[0] == 'grid':
                if offset % 24:
                    raise ValueError('invalid vector header stride')
                pointer = ('row', offset // 24)
            else:
                pointer = None
            continue
        store = re.fullmatch(r'mov\s+DWORD PTR \[rax(?:\+0x([0-9a-f]+))?\],0x([0-9a-f]+)', instruction)
        if store:
            offset, cycles = int(store[1] or '0', 16), int(store[2], 16)
            if not pointer or offset % 4:
                raise ValueError(f'unresolved store at {pc:#x}')
            if pointer[0] == 'latency':
                row = offset // 4
                if row in latency:
                    raise ValueError('duplicate latency store')
                latency[row] = cycles
                evidence[f'latency/{row}'] = hex(pc)
            elif pointer[0] == 'row':
                row, resource = pointer[1], offset // 4
                if resource in resources.get(row, {}):
                    raise ValueError('duplicate resource store')
                resources.setdefault(row, {})[resource] = cycles
                evidence[f'resource/{row}/{resource}'] = hex(pc)
            else:
                raise ValueError('store to unknown table')
        elif re.match(r'(mov|lea|xor|pop)\s+[er]ax\b', instruction):
            pointer = None
    if set(latency) != set(range(465)):
        raise ValueError('expected exactly 465 latency stores')
    if len(resources) != 110 or sum(map(len, resources.values())) != 303:
        raise ValueError('expected 303 resource stores across 110 rows')
    if any(not 0 <= r < 465 or not 0 <= c < 32 for r, cells in resources.items() for c in cells):
        raise ValueError('invalid table index')
    return latency, resources, evidence


def extract(binary, output, evidence_dir):
    digest = hashlib.sha256()
    with binary.open('rb') as f:
        for chunk in iter(lambda: f.read(1 << 20), b''):
            digest.update(chunk)
    if digest.hexdigest() != SHA256:
        raise ValueError('unsupported binary SHA256; audit addresses/layout before adding a new build')
    assembly = subprocess.check_output([
        'objdump', '-d', '-C', '-Mintel', f'--start-address={START}',
        f'--stop-address={END}', str(binary)], text=True)
    for marker in ('mov    edi,0x744', 'mov    edi,0x2b98', 'mov    edi,0x80'):
        if marker not in assembly:
            raise ValueError('constructor allocation shape changed')
    latency, resources, evidence = parse_constructor(assembly)
    result = {
        'schema_version': 1, 'target': 'gf', 'libtpu_version': '0.0.48',
        'binary_sha256': SHA256, 'build_id': BUILD_ID,
        'id_space': 'GF performance-table Instruction; NOT LloOpcode',
        'row_count': 465, 'resource_count': 32,
        'constructor_address': hex(START),
        'owner_constructor_address': '0x193450f0',
        'source_kind': 'static binary constructor extraction; not hardware calibration',
        'rows': [{'id': i, 'latency_cycles': latency[i],
                  'resource_values': {str(k): v for k, v in sorted(resources.get(i, {}).items())}}
                 for i in range(465)],
        'limitations': [
            'Raw LLO opcodes and mnemonic strings must not index this table directly.',
            'Resource values alone do not specify consumer issue footprints or resource scope.',
            'All 465 latencies are explicitly initialized; an uninitialized int32 memset(0xff) would be 0xffffffff, not 255.',
            'Instruction fetch, runtime memory conflicts, dynamic paths and hardware timing remain separate.',
        ],
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(result, indent=2) + '\n')
    evidence_dir.mkdir(parents=True, exist_ok=True)
    (evidence_dir / 'gf-constructor.asm').write_text(assembly)
    (evidence_dir / 'gf-store-addresses.json').write_text(json.dumps(evidence, indent=2) + '\n')
    print(json.dumps({'rows': len(latency), 'resource_stores': sum(map(len, resources.values())),
                      'resource_columns': 32, 'binary_sha256': SHA256}))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('binary', type=Path)
    parser.add_argument('output', type=Path)
    parser.add_argument('--evidence-dir', type=Path, required=True)
    args = parser.parse_args()
    extract(args.binary, args.output, args.evidence_dir)
