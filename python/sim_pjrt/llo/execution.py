"""Build the GF pipeline directly from Final LLO and a resolved scalar path.

Direct opcode mappings are binary-extracted. Unknown costs are reported, never
silently treated as calibrated. Register writes are versioned per dynamic visit;
co-issued instructions read the bundle-entry state. DMA queues and credits are
explicit; memory alias/bank hazards and service calibration remain model gaps.
"""
from collections import Counter, defaultdict, deque
from dataclasses import replace
import json
import math
from pathlib import Path
import re

from .compiler_costs import CompilerCosts
from .control_flow import resolve_scalar_operands
from .parser import parse_bundles, dma_operands
from .pipeline import (Bundle, Operation, Reservation, ResourceHold, CreditWait,
                       CreditUpdate, simulate, chrome_trace)
from .mxu import matmul_throughput

_SYNC_FLAG = r"(\[#allocation\d+(?:\s*\+\s*\$0x[\da-fA-F]+)?\])"

_REGISTER = re.compile(r'%[\w]+')
_ASSIGN = re.compile(r'^(%[\w]+)\s*=\s*(.*)$', re.S)
_GUARD = re.compile(r'\((!?%p\w+)\)')


def _physical(register):
    match = re.search(r'_([vsp]\d+)$', register or '')
    return 'physical:' + match[1] if match else None


class GfMapping:
    def __init__(self, mapping, costs):
        if (mapping.get('schema_version') != 1 or mapping.get('target') != 'gf'
                or mapping.get('binary_sha256') != costs.binary_sha256):
            raise ValueError('mapping/cost binary identity mismatch')
        self.costs = costs
        self.by_mnemonic = defaultdict(list)
        self.by_opcode = {}
        for row in mapping['rows']:
            opcode, identity = row['llo_opcode'], row['performance_id']
            if type(opcode) is not int or opcode in self.by_opcode or identity not in costs.rows:
                raise ValueError('invalid mapping row')
            self.by_opcode[opcode] = row
            self.by_mnemonic[row['mnemonic']].append(row)
        self.rules = {r['resource']: r['rule'] for r in mapping['resource_rules']}
        self.compare_ids = mapping['scalar_compare_cost_equivalence']['performance_ids']
        self.matmul_rows = mapping['matmul_format_rows']
        self.latch_rows = {r['name']: r for r in mapping['matpush_latch_rows']}
        self.pack_mnemonics = mapping['pack_mnemonics']
        self.bf16_push_issue = mapping['bf16_matpush_nontranspose_issue_cycles']
        self.bf16_xpose_issue = mapping['bf16_matpush_transpose_issue_cycles']
        self.exact_mnemonics = mapping['exact_mnemonics']
        self.vector_compare = mapping['vector_compare_cost_equivalence']
        self.raw_iar_ids = mapping['raw_iar_performance_ids']
        self.pseudo_mnemonics = mapping['pseudo_mnemonics']
        self.consumer_disambiguation = mapping['consumer_disambiguation']
        for row in self.exact_mnemonics.values():
            if row['llo_opcode'] not in self.by_opcode:
                raise ValueError('exact mnemonic references an unknown opcode')
        for row in self.vector_compare.values():
            if not row['performance_ids'] or any(i not in costs.rows for i in row['performance_ids']):
                raise ValueError('invalid vector compare equivalence class')
        if not self.compare_ids or any(i not in costs.rows for i in self.compare_ids):
            raise ValueError('invalid compare equivalence class')
        self.provenance = 'GF direct classifier 0x19360660; ' + costs.provenance

    def classify(self, instruction):
        """Do not confuse duplicate display mnemonics with unique raw opcodes."""
        if 'llo_opcode' in instruction:
            return self.by_opcode.get(instruction['llo_opcode'])
        text = instruction['text']
        assignment = _ASSIGN.match(text)
        mnemonic = (assignment[2] if assignment else text).split()[0]
        if mnemonic in self.pseudo_mnemonics:
            return self.pseudo_mnemonics[mnemonic]
        if mnemonic in self.consumer_disambiguation:
            kinds = instruction.get('result_consumer_opcodes', ())
            candidates = {self.consumer_disambiguation[mnemonic].get(k) for k in kinds}
            if len(candidates) == 1 and None not in candidates:
                return self.by_opcode[next(iter(candidates))]
        if mnemonic in self.pack_mnemonics:
            return self.by_opcode[self.pack_mnemonics[mnemonic]['llo_opcode']]
        if mnemonic in self.exact_mnemonics:
            alias = self.exact_mnemonics[mnemonic]
            return dict(self.by_opcode[alias['llo_opcode']], **{
                k: v for k, v in alias.items() if k != 'llo_opcode'})
        push = re.fullmatch(r'vmatpush[123]?\.bf16\.(xpose\.)?msr[ab]\.mxu([01])', mnemonic)
        if push:
            transpose = bool(push[1])
            row = self.latch_rows['XposePackedBf16' if transpose else 'NoXposePackedBf16']
            return {'performance_id': row['unmasked_id'], 'matpush': True,
                    'unit': push[2], 'transpose': transpose}
        iar = re.fullmatch(r'vsetiar\.raw\.iar([01])', mnemonic)
        if iar:
            return {'performance_id': self.raw_iar_ids[iar[1]]}
        compare = re.fullmatch(r'vcmp\.(eq|ne|lt|le|gt|ge)\.(.+)', mnemonic)
        if compare and compare[2] in self.vector_compare:
            return self._equivalent(self.vector_compare[compare[2]]['performance_ids'])
        if matmul_throughput(mnemonic):
            parts = set(mnemonic.split('.'))
            dtype = next(name for name in self.matmul_rows['enum_names'] if name in parts)
            kind = 'masked' if 'msk' in parts else 'unmasked'
            identity = self.matmul_rows[kind][str(self.matmul_rows['enum_names'][dtype])]
            return {'performance_id': identity, 'matmul': True}
        if re.fullmatch(r'vpop\.f32\.mrb\[\d+\]\.mxu[01]', mnemonic):
            return self.by_opcode[338]
        mnemonic = re.sub(r'\.mxu[01]$', '', mnemonic)
        # These are pointer address spaces, not different hardware operations.
        mnemonic = re.sub(r'^(scalar_lea|int_to_ptr)\.(hbm|vmem|smem|sflag)$', r'\1', mnemonic)
        mnemonic = re.sub(r'^(vmatprep\.(?:subr|mubr)(?:\.msk)?)\.(?:bf16|f32)$', r'\1', mnemonic)
        rows = self.by_mnemonic.get(mnemonic, ())
        if re.fullmatch(r'scmp\.(eq|ne|lt|le|gt|ge)\.((s32|u32)\.totalorder|f32\.(totalorder|partialorder))', mnemonic):
            return self._equivalent(self.compare_ids)
        return rows[0] if len(rows) == 1 else None

    def _equivalent(self, identities):
        if all(self.costs.rows[i] == self.costs.rows[identities[0]] for i in identities):
            return {'performance_id': identities[0], 'cost_equivalent_ids': identities}
        return None

    def operation(self, instruction, identity, dependencies):
        row = self.classify(instruction)
        name = instruction['opcode']
        if row is None:
            return Operation(identity, name, 1, depends_on=dependencies), ['unmapped cost: ' + name], None
        latency, resources = self.costs.rows[row['performance_id']]
        latency *= row.get('latency_multiplier', 1)
        holds, checks, gaps = [], [], []
        if row.get('limitation'):
            gaps.append(row['limitation'])
        reservations = ()
        if row.get('matpush'):
            if not row['transpose']:
                latency = (latency + 1) // 2
            interval = self.bf16_xpose_issue if row['transpose'] else self.bf16_push_issue
            reservations = (Reservation('mxu' + row['unit'] + '.matpush', interval),)
        if row.get('matmul'):
            mnemonic = instruction['text'].split('=', 1)[-1].strip().split()[0]
            reservations = (Reservation(*matmul_throughput(mnemonic)),)
            gaps.append('matmul dtype names/issue intervals retained from 0.0.46.1 audit; modifier occupancy incomplete')
        unit = re.search(r'\.(mxu[01]|xlu[01])(?:\s|$)', instruction['text'])
        for resource, cycles in resources.items():
            if not cycles:
                continue
            rule = self.rules.get(resource)
            if rule == 'global_nonzero_intersection':
                scope = 'core'
            elif rule == 'same_unit_nonzero_intersection' and unit:
                scope = unit[1]
            else:
                gaps.append(f'specialized resource rule missing: {resource} ({name})')
                continue
            key = f'{scope}.gf.resource.{resource}'
            holds.append(ResourceHold(key, cycles))
            checks.append(key)
        if name.startswith(('vmat', 'vxpose')):
            gaps.append('modifier-specific latency/occupancy: ' + name)
        cost_identity = row.get('cost_equivalent_ids', row['performance_id'])
        return Operation(identity, name, latency, reservations=reservations, depends_on=dependencies,
                         resource_holds=tuple(holds), issue_checks=tuple(checks)), gaps, cost_identity


def build_execution(program, mapping, *, branch_delay_slots=None, max_visits=1_000_000,
                    live_ins=(), resolved=False, bf16_result_slots=4, memory_profile=None, bounded=False):
    """Resolve loops/branches and build RAW/WAW, DMA queues and credit operations.

    Unknown predicates/alternative paths fail closed. A scalar phi aliases only
    the selected incoming producer. Unknown costs keep their operations and edges
    with an explicit one-cycle placeholder; the report stays partial.
    """
    path = program if resolved else resolve_scalar_operands(
        program, branch_delay_slots=branch_delay_slots, max_visits=max_visits,
        preserve_timing_operands=True)
    producers = {name: 'input:' + name for name in live_ins}
    initial = {producer: 0 for producer in producers.values()}
    implicit_inputs, dependencies, counts = set(), [], Counter()
    gaps = {'GF entry latencies used; consumer-specific latency adjustments incomplete',
            'IMEM, runtime memory service and specialized execution units are not calibrated'}
    output, dma_events = [], []
    profile = memory_profile or {}
    calibration = profile.get('bundle_issue_calibration')
    if calibration is not None:
        if (not isinstance(calibration, dict) or calibration.get('schema_version') != 1
                or calibration.get('kind') != 'empirical_bundle_issue_floor'):
            raise ValueError('invalid bundle issue calibration schema')
        frequency = calibration.get('frequency_hz')
        if (isinstance(frequency, bool) or not isinstance(frequency, (int, float))
                or not math.isfinite(frequency) or frequency <= 0
                or frequency != profile.get('frequency_hz')):
            raise ValueError('bundle issue calibration frequency mismatch')
        if calibration.get('compiler_binary_sha256') != mapping.costs.binary_sha256:
            raise ValueError('bundle issue calibration compiler mismatch')
        floors = calibration.get('cycles_by_signature')
        default_floor = calibration.get('default_floor_cycles')
        if not isinstance(floors, dict) or any(not isinstance(k, str) for k in floors):
            raise ValueError('invalid bundle issue calibration signatures')
        for value in [default_floor, *floors.values()]:
            if isinstance(value, bool) or not isinstance(value, (int, float)) or not math.isfinite(value) or value <= 0:
                raise ValueError('invalid bundle issue calibration cycles')
        gaps.add('empirical bundle issue calibration includes unresolved hardware/instrumentation costs; scenario-specific')
    if type(bf16_result_slots) is not int or bf16_result_slots < 1:
        raise ValueError('bf16_result_slots must be a positive integer')
    mrb, released = {}, {}
    eup = defaultdict(deque)

    def producer(register):
        if register not in producers:
            producers[register] = 'input:' + register
            initial[producers[register]] = 0
            implicit_inputs.add(register)
        return producers[register]

    for visit, bundle in enumerate(path):
        if any(key in bundle for key in ('repeat', 'alternatives', 'boundary')):
            raise ValueError('execution requires a concrete path; unresolved predicate or summarized loop')
        if bundle.get('callsite'):
            gaps.add('cross-call operand readiness and buffer bindings are not fully reconstructed')
        if visit >= max_visits:
            raise ValueError('execution path exceeds max_visits')
        operations, writes = [], {}
        issue_cycles = profile.get('bundle_issue_cycles', 1)
        extra_cycles = 0
        mrb_writes, mrb_reads = {}, {}
        eup_writes = []
        # Phi aliases exist at region entry, before any co-issued hardware op.
        aliases = {}
        for ins in bundle['instructions']:
            if ins['opcode'] == 'sphi':
                match = _ASSIGN.match(ins['text'])
                source = ins.get('selected_phi_input')
                if match is None or source is None:
                    if not bounded:
                        raise ValueError('unresolved phi predecessor')
                    gaps.add('bounded segment phi producer unresolved; entry values assumed ready after drain')
                    continue
                if _REGISTER.fullmatch(source):
                    aliases[match[1]] = producer(source)
                else:
                    key = 'constant:' + source
                    initial[key] = 0
                    aliases[match[1]] = key
        producers.update(aliases)
        for index, ins in enumerate(bundle['instructions']):
            opcode = ins['opcode']
            if opcode == 'sphi':
                continue
            text = ins.get('timing_operand_text', ins['text'])
            if _GUARD.search(text) or 'resolved_predicate' in ins:
                decision = ins.get('resolved_predicate')
                if type(decision) is not bool:
                    if not bounded:
                        raise ValueError('unresolved instruction predicate: ' + text)
                    gaps.add('bounded segment predicate assumed active: ' + text)
                    decision = True
                if not decision:
                    counts['predicate_disabled'] += 1
                    continue
            match = _ASSIGN.match(text)
            dest, rhs = (match[1], match[2]) if match else (None, text)
            op_id = f'{visit}:{index}'
            deps = {producer(reg) for reg in _REGISTER.findall(rhs)}
            mnemonic = rhs.split()[0]
            unit_match = re.search(r'\.mxu([01])$', mnemonic)
            eup_unit = unit_match[1] if unit_match else 'core'
            if mnemonic.startswith('vpop.eup'):
                if eup[eup_unit]:
                    deps.add(eup[eup_unit].popleft())
                else:
                    gaps.add('EUP result read without known producer')
                gaps.add('EUP result queue modeled FIFO; capacity/backpressure not calibrated')
            slot = re.search(r'\.mrb\[(\d+)\]\.mxu([01])$', mnemonic)
            if slot and mnemonic.startswith(('vmatmul.', 'vpop.')):
                address, unit = int(slot[1]), int(slot[2])
                if mnemonic.startswith('vmatmul.') and '.bf16.' in mnemonic:
                    gaps.add(f'BF16 MRB result width assumed {bf16_result_slots} slots; target-specific validation pending')
                    keys = [(unit, address + i) for i in range(bf16_result_slots)]
                    if any(k in mrb for k in keys):
                        raise ValueError('MRB overwritten before consumption')
                    if any(k in mrb_writes for k in keys):
                        raise ValueError('co-issued overlapping MRB writes')
                    deps.update(released[k] for k in keys if k in released)
                    for key in keys:
                        mrb_writes[key] = op_id
                elif mnemonic.startswith('vpop.f32.'):
                    key = (unit, address)
                    if key not in mrb:
                        gaps.add('MRB read without known producer: ' + mnemonic)
                    else:
                        if key in mrb_reads:
                            raise ValueError('co-issued duplicate MRB reads')
                        deps.add(mrb[key])
                        mrb_reads[key] = op_id
                else:
                    gaps.add('MRB result width unsupported: ' + mnemonic)
            if opcode.split('.')[0] in ('int_to_ptr', 'ptr_to_int') and dest:
                sources = _REGISTER.findall(rhs)
                if len(sources) == 1:
                    writes[dest] = writes.get(sources[0], producer(sources[0]))
                    continue
                gaps.add('unresolved compiler cast alias: ' + text)
            if dest in producers:
                deps.add(producers[dest])  # Conservative write-after-write lifetime.
            physical = _physical(dest)
            if physical in producers:
                deps.add(producers[physical])
            if opcode.startswith('inlined_call_operand'):
                if dest is None:
                    raise ValueError('input operand without destination')
                writes[dest] = 'input:' + dest
                initial[writes[dest]] = 0
                continue
            if opcode == 'inlined_call':
                raise ValueError('expand kernel calls before executing the pipeline')
            if opcode == 'compiler-scheduling-barrier':
                continue
            memory = opcode.startswith(('vld', 'vst', 'sld', 'sst', 'dma.', 'vwait', 'vsync'))
            if memory:
                gaps.add('memory alias/bank hazards not reconstructed; DMA synchronization uses explicit credits')
            if opcode.startswith(('scall', 'sret', 'sloop')) or (opcode.startswith('sbr') and not bundle.get('scalar_path_resolved')):
                raise ValueError('unresolved control flow')
            if dest in writes or (physical and physical in writes):
                raise ValueError('multiple co-issued writes to ' + dest)
            op, missing, performance_id = mapping.operation(ins, op_id, tuple(sorted(deps)))
            if memory_profile is not None and opcode.startswith('dma.') and opcode != 'dma.done.wait':
                operands = dma_operands(ins['text'])
                direction = ins.get('dma_direction', opcode.removeprefix('dma.'))
                config = memory_profile.get('dma', {}).get(direction)
                if config and len(operands) >= 4 and operands[1].isdigit():
                    granule = memory_profile['dma_granule_bytes']
                    transaction = memory_profile.get('dma_transaction_bytes', 1)
                    hz, bandwidth = memory_profile['frequency_hz'], config['bytes_per_second']
                    startup = config.get('latency_cycles', 0)
                    if any(isinstance(x, bool) or not isinstance(x, (int, float)) or not math.isfinite(x)
                           or x <= 0 for x in (granule, transaction, hz, bandwidth)):
                        raise ValueError('invalid DMA profile units/rate')
                    if isinstance(startup, bool) or not isinstance(startup, (int, float)) or not math.isfinite(startup) or startup < 0:
                        raise ValueError('invalid DMA startup latency')
                    if not float(granule).is_integer() or not float(transaction).is_integer():
                        raise ValueError('DMA granule/transaction must be whole bytes')
                    size = int(operands[1]) * granule
                    bus_size = math.ceil(size / transaction) * transaction
                    transfer_cycles = bus_size * hz / bandwidth
                    if 'vmem_bytes_per_second' in config and 'vmem' in direction:
                        vmem_rate = config['vmem_bytes_per_second']
                        if isinstance(vmem_rate, bool) or not isinstance(vmem_rate, (int, float)) or not math.isfinite(vmem_rate) or vmem_rate <= 0:
                            raise ValueError('invalid VMEM DMA rate')
                        transfer_cycles = max(transfer_cycles, size * hz / vmem_rate)
                    duration = startup + math.ceil(transfer_cycles) if size else 0
                    resource = 'dma.' + config.get('resource', direction)
                    op = replace(op, latency=duration, reservations=(), service_resource=resource)
                    flag = operands[3]
                    if re.fullmatch(_SYNC_FLAG, flag):
                        op = replace(op, credit_updates=(CreditUpdate(re.sub(r'\s+', '', flag), int(operands[1]), True),))
                    else:
                        gaps.add('DMA destination completion flag is unresolved')
                    dma_events.append(dict(kind='dma', operation_id=op_id, address=bundle['address'],
                        direction=direction, resource=resource, bytes=size, bus_bytes=bus_size,
                        destination_flag=flag, latency_cycles=startup, bandwidth_cycles=math.ceil(transfer_cycles)))
                    if opcode == 'dma.general':
                        gaps.add('general DMA descriptor stride/padding and source completion are not modeled')
                        if len(operands) == 8:
                            dma_events[-1].update(source_flag=operands[4], stride_descriptor=operands[5],
                                                 overrides=operands[6], second_destination_flag=operands[7])
                    missing = ['DMA uses supplied profile and aligned contiguous payload assumption; not hardware calibrated']
                    counts['dma_profile_costs'] += 1
                else:
                    missing.append('DMA service unmodeled: ' + direction)
            if opcode == 'dma.done.wait' or opcode.startswith('vsyncadd'):
                sync = re.search(_SYNC_FLAG + r",\s*(-?\d+)", ins['text'])
                if sync:
                    flag, units = re.sub(r'\s+', '', sync[1]), int(sync[2])
                    if opcode == 'dma.done.wait':
                        op = replace(op, credit_waits=(CreditWait(flag, units),))
                    else:
                        units = units - 2**32 if units >= 2**31 else units
                        op = replace(op, credit_updates=(CreditUpdate(flag, units),))
                else:
                    missing.append('sync credit operand unresolved: ' + opcode)
            if opcode.startswith(('vwait', 'sfence', 'cfence', 'barrier', 'send', 'recv', 'semaphore')):
                until = ins.get('wait_until_cycle')
                if until is not None:
                    op = replace(op, wait_until=until)
                elif not (ins.get('peer_wait') and profile.get('assume_peers_ready')):
                    missing.append('external/assembly synchronization requires a completion model: ' + opcode)
            if opcode == 'vdelay':
                delay = re.search(r'vdelay\s+\$?(0x[\da-fA-F]+|\d+)\b', ins['text'])
                mode = profile.get('vdelay_semantics')
                if delay and mode in ('additional_cycles', 'total_cycles'):
                    value = int(delay[1], 16 if delay[1].startswith('0x') else 10)
                    extra_cycles = max(extra_cycles, value if mode == 'additional_cycles' else max(0, value - issue_cycles))
                else:
                    missing.append('vdelay needs a constant operand and explicit semantics')
            extra = profile.get('instruction_extra_cycles', {}).get(opcode, 0)
            if isinstance(extra, bool) or not isinstance(extra, (int, float)) or not math.isfinite(extra) or extra < 0:
                raise ValueError('invalid instruction_extra_cycles')
            extra_cycles = max(extra_cycles, extra)
            if isinstance(performance_id, int) and 263 <= performance_id <= 277 and not (dest or '').startswith('%v'):
                eup_writes.append((eup_unit, op_id))
            operations.append(op)
            gaps.update(missing)
            counts['instructions'] += 1
            counts['mapped' if performance_id is not None else 'unmapped'] += 1
            dependencies.append(dict(id=op_id, address=bundle['address'], opcode=opcode,
                                     performance_id=performance_id, reads=sorted(set(_REGISTER.findall(rhs))),
                                     writes=dest, depends_on=list(op.depends_on)))
            if dest:
                writes[dest] = op_id
                if physical:
                    writes[physical] = op_id
        producers.update(writes)
        for key, reader in mrb_reads.items():
            del mrb[key]
            released[key] = reader
        mrb.update(mrb_writes)
        for unit, op_id in eup_writes:
            eup[unit].append(op_id)
        duration = issue_cycles + extra_cycles
        if calibration is not None:
            signature = '|'.join(sorted(op.name for op in operations))
            duration = max(duration, floors.get(signature, default_floor))
        output.append(Bundle(bundle['address'], tuple(operations), duration))
    actual = {op.id: op.depends_on for b in output for op in b.operations}
    for row in dependencies:
        row['depends_on'] = list(actual[row['id']])
    if implicit_inputs:
        gaps.add('undeclared live-ins assumed ready at entry: ' + ', '.join(sorted(implicit_inputs)))
    if mrb:
        gaps.add(f'{len(mrb)} MRB slots remain unconsumed')
    return output, dict(initial_ready=initial, gaps=sorted(gaps), counts=dict(counts),
                        dependencies=dependencies, dynamic_bundle_visits=len(output),
                        memory_profile=memory_profile, dma_events=dma_events)


def main():
    import argparse
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('llo', type=Path)
    p.add_argument('--costs', type=Path, required=True)
    p.add_argument('--mapping', type=Path, required=True)
    p.add_argument('--binary-sha256', required=True)
    p.add_argument('--frequency-hz', type=float, required=True)
    p.add_argument('--branch-delay-slots', type=int)
    p.add_argument('--max-visits', type=int, default=1_000_000)
    p.add_argument('--live-in', action='append', default=[])
    p.add_argument('--bf16-result-slots', type=int, default=4)
    p.add_argument('--memory-profile', type=Path)
    p.add_argument('--report', type=Path, required=True)
    p.add_argument('--trace', type=Path, required=True)
    args = p.parse_args()
    costs = CompilerCosts.read(args.costs, binary_sha256=args.binary_sha256)
    mapping = GfMapping(json.loads(args.mapping.read_text()), costs)
    memory_profile = json.loads(args.memory_profile.read_text()) if args.memory_profile else None
    if memory_profile is not None and memory_profile['frequency_hz'] != args.frequency_hz:
        raise ValueError('memory profile frequency must match execution frequency')
    bundles, audit = build_execution(parse_bundles(args.llo.read_text()), mapping,
                                    branch_delay_slots=args.branch_delay_slots,
                                    max_visits=args.max_visits, live_ins=args.live_in,
                                    bf16_result_slots=args.bf16_result_slots, memory_profile=memory_profile)
    report = simulate(bundles, frequency_hz=args.frequency_hz, gaps=audit['gaps'],
                      model_provenance=mapping.provenance, initial_ready=audit['initial_ready'])
    report['execution'] = audit
    args.report.write_text(json.dumps(report, indent=2) + '\n')
    args.trace.write_text(json.dumps(chrome_trace(report), indent=2) + '\n')
    print(json.dumps({k: report[k] for k in ('status', 'modeled_cycles', 'estimated_seconds')}))


if __name__ == '__main__':
    main()
