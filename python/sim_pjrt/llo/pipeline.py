"""Explicit resource/dependency pipeline model, independent of trace timestamps.

This model consumes an already resolved dynamic path. Its input costs
must come from a versioned target model: it does not infer latency from XProf
event widths. Reservations describe throughput; dependencies describe result
availability. Unmodeled effects must be supplied in ``gaps``.
"""

from collections import defaultdict
from dataclasses import dataclass
import math



@dataclass(frozen=True)
class Reservation:
    resource: str
    duration: float
    offset: float = 0


@dataclass(frozen=True)
class ResourceHold:
    """A producer's exclusion deadline, consulted only by explicit consumers."""
    resource: str
    cycles: float


@dataclass(frozen=True)
class CreditWait:
    counter: str
    units: int


@dataclass(frozen=True)
class CreditUpdate:
    counter: str
    units: int
    on_completion: bool = False


@dataclass(frozen=True)
class Operation:
    id: str
    name: str
    latency: float
    reservations: tuple = ()
    depends_on: tuple = ()
    resource_holds: tuple = ()
    issue_checks: tuple = ()
    credit_waits: tuple = ()
    credit_updates: tuple = ()
    service_resource: str = ""
    wait_until: float = 0


@dataclass(frozen=True)
class Bundle:
    address: str
    operations: tuple = ()
    issue_cycles: float = 1


def _finite(value, name, *, positive=False):
    if isinstance(value, bool) or not isinstance(value, (float, int)):
        raise ValueError(f'{name} must be numeric')
    if not math.isfinite(value) or value < 0 or (positive and value == 0):
        raise ValueError(f'invalid {name}: {value}')
    return value


def simulate(bundles, *, frequency_hz, gaps, model_provenance, initial_ready=None, initial_credits=None):
    """Issue whole bundles and overlap independent in-flight operations.

    Dependencies refer to prior operation IDs, not mutable register names.
    MRB/VMEM/register adapters must version their producers and explicitly
    express lifetime hazards. Initial dependencies must be declared with their
    ready cycle. A missing dependency is an error, never silently ready at zero.

    Each reservation occupies [issue+offset, issue+offset+duration). Different
    resources overlap; overlapping reservations in one bundle are invalid.
    Completion includes all issued operations and reservations. ``modeled``
    means complete *under supplied assumptions*, not hardware validated.

    Structural holds are asymmetric: A may hold resources {x,y}, while B only
    checks {x}. B waits for x, not y. A does not automatically check the same
    resources it holds. This is distinct from exclusive Reservation intervals.
    """
    _finite(frequency_hz, 'frequency_hz', positive=True)
    if not model_provenance:
        raise ValueError('model_provenance is required')
    gaps = list(gaps)
    ready = dict(initial_ready or {})
    for key, value in ready.items():
        if not isinstance(key, str) or not key:
            raise ValueError('initial producer IDs must be nonempty strings')
        _finite(value, f'initial_ready[{key}]')
    credits = dict(initial_credits or {})
    pending = defaultdict(list)
    service_ready = {}
    for counter, units in credits.items():
        if not isinstance(counter, str) or not counter or type(units) is not int or units < 0:
            raise ValueError('invalid initial credit counter')

    def credit_at(counter, cycle):
        remaining = []
        value = credits.get(counter, 0)
        for when, units in pending[counter]:
            if when <= cycle:
                value += units
            else:
                remaining.append((when, units))
        credits[counter] = value
        pending[counter] = remaining
        return value

    calendars = defaultdict(list)
    hold_ready = {}
    issue = 0
    result_end = 0
    events, timeline = [], []
    seen = set(ready)
    for visit, bundle in enumerate(bundles):
        _finite(bundle.issue_cycles, 'issue_cycles', positive=True)
        reservations = defaultdict(list)
        dependencies = []
        local_ids = set()
        holds, checks = defaultdict(list), set()
        for op in bundle.operations:
            if not isinstance(op.id, str) or not op.id or op.id in seen or op.id in local_ids:
                raise ValueError(f'duplicate/empty operation id: {op.id}')
            local_ids.add(op.id)
            _finite(op.latency, 'latency')
            _finite(op.wait_until, 'wait_until')
            for credit in (*op.credit_waits, *op.credit_updates):
                if not isinstance(credit.counter, str) or not credit.counter or type(credit.units) is not int:
                    raise ValueError('invalid credit operation')
                if isinstance(credit, CreditWait) and credit.units < 0:
                    raise ValueError('negative wait threshold')
                if isinstance(credit, CreditUpdate) and credit.on_completion and credit.units < 0:
                    raise ValueError('completion credits must be nonnegative')
            for dependency in op.depends_on:
                if dependency not in ready:
                    raise ValueError(f'{op.id}: missing prior producer {dependency}')
                dependencies.append((ready[dependency], dependency))
            for r in op.reservations:
                _finite(r.offset, 'reservation offset')
                _finite(r.duration, 'reservation duration', positive=True)
                if not isinstance(r.resource, str) or not r.resource:
                    raise ValueError('empty resource')
                reservations[r.resource].append((r.offset, r.offset + r.duration, op.id))
            for hold in op.resource_holds:
                _finite(hold.cycles, 'hold cycles')
                if not isinstance(hold.resource, str) or not hold.resource:
                    raise ValueError('empty hold resource')
                holds[hold.resource].append((op.id, hold.cycles))
            for resource in op.issue_checks:
                if not isinstance(resource, str) or not resource:
                    raise ValueError('empty issue-check resource')
                checks.add(resource)
        for op in bundle.operations:
            for resource in op.issue_checks:
                if any(producer != op.id and cycles > 0 for producer, cycles in holds[resource]):
                    raise ValueError(f'co-issued structural hazard on {resource}')
        for resource, spans in reservations.items():
            spans.sort()
            if any(b[0] < a[1] for a, b in zip(spans, spans[1:])):
                raise ValueError(f'co-issued operations conflict on {resource}')
        dependency_ready, producer = max(dependencies, default=(0, ''))
        start = max(issue, dependency_ready)
        blockers = set()
        if start > issue:
            blockers.add('dependency:' + producer)
        for resource in sorted(checks):
            deadline = hold_ready.get(resource, 0)
            if deadline > start:
                start = deadline
                blockers.add('structural:' + resource)
        release = start
        wait_ready = {}
        for op in bundle.operations:
            wait_ready[op.id] = max(start, op.wait_until)
            if op.wait_until > start:
                blockers.add('external:' + op.id)
            for wait in op.credit_waits:
                value = credit_at(wait.counter, start)
                if value >= wait.units:
                    continue
                deadline = None
                for when, units in sorted(pending[wait.counter]):
                    value += units
                    if value >= wait.units:
                        deadline = when
                        break
                if deadline is None:
                    gaps.append(f'{bundle.address}: DMA wait has unknown or partial completion credits: {wait.counter}')
                else:
                    wait_ready[op.id] = max(wait_ready[op.id], deadline)
                    blockers.add('credit:' + wait.counter)
        # Calendars rather than a single ready-time permit future-offset holds
        # without needlessly blocking an earlier non-overlapping reservation.
        while True:
            shifted = start
            for resource, spans in reservations.items():
                calendars[resource] = [s for s in calendars[resource] if s[1] > start]
                for offset, end_offset, _ in spans:
                    for left, right in calendars[resource]:
                        if start + offset < right and start + end_offset > left:
                            shifted = max(shifted, right - offset)
                            blockers.add('resource:' + resource)
            if shifted == start:
                break
            start = shifted
        if start > issue:
            timeline.append(dict(track='Bundle stalls', name=', '.join(sorted(blockers)),
                                 start_cycle=issue, end_cycle=start, address=bundle.address))
        # All co-issued waits read pre-bundle counters. Credit writes commit
        # together, after reads, so instruction print order cannot affect waits.
        updates = defaultdict(int)
        for op in bundle.operations:
            begin = max(start, service_ready.get(op.service_resource, 0)) if op.service_resource else start
            ready[op.id] = max(begin + op.latency, wait_ready[op.id])
            if op.service_resource:
                service_ready[op.service_resource] = ready[op.id]
                timeline.append(dict(track=op.service_resource, name=op.name, operation_id=op.id,
                                     start_cycle=begin, end_cycle=ready[op.id], address=bundle.address))
            for update in op.credit_updates:
                if update.on_completion:
                    pending[update.counter].append((ready[op.id], update.units))
                else:
                    updates[update.counter] += update.units
            result_end = max(result_end, ready[op.id])
            seen.add(op.id)
            timeline.append(dict(track='Results', name=op.name, operation_id=op.id,
                                 start_cycle=start, end_cycle=ready[op.id], address=bundle.address))
        for counter, units in updates.items():
            value = credit_at(counter, start) + units
            if value < 0:
                gaps.append(f'{bundle.address}: sync credit underflow: {counter}')
            else:
                credits[counter] = value
        for resource, spans in reservations.items():
            for offset, end_offset, op_id in spans:
                left, right = start + offset, start + end_offset
                calendars[resource].append((left, right))
                result_end = max(result_end, right)
                timeline.append(dict(track=resource, name=op_id, start_cycle=left,
                                     end_cycle=right, address=bundle.address))
        for resource, values in holds.items():
            for op_id, cycles in values:
                if not cycles:
                    continue
                end = start + cycles
                hold_ready[resource] = max(hold_ready.get(resource, 0), end)
                result_end = max(result_end, end)
                timeline.append(dict(track='Hold: ' + resource, name=op_id,
                                     start_cycle=start, end_cycle=end, address=bundle.address))
        release = max([start + bundle.issue_cycles, *wait_ready.values()])
        if release > start + bundle.issue_cycles:
            timeline.append(dict(track='Bundle stalls', name=', '.join(sorted(blockers)),
                start_cycle=start + bundle.issue_cycles, end_cycle=release, address=bundle.address))
        events.append(dict(visit=visit, address=bundle.address, start_cycle=start,
                           issue_end_cycle=release,
                           issue_stall_cycles=start - issue, stall_cycles=start - issue + release - start - bundle.issue_cycles, blockers=sorted(blockers)))
        issue = release
    if not events:
        raise ValueError('empty dynamic path')
    finish = max(issue, result_end)
    for counter in list(pending):
        credit_at(counter, finish)
    return dict(final_credits=credits, status='partial' if gaps else 'modeled', modeled_cycles=finish,
                modeled_seconds=finish / frequency_hz,
                estimated_seconds=None if gaps else finish / frequency_hz,
                frequency_hz=frequency_hz, completion_tail_cycles=finish - issue,
                wait_stall_cycles=sum(e['stall_cycles'] for e in events),
                gaps=gaps, model_provenance=model_provenance,
                events=events, timeline=timeline,
                assumptions=['Resolved dynamic path and versioned producer dependencies supplied.',
                             'Reservation durations and result latencies are distinct inputs.',
                             'No measured timestamps are consumed; no accuracy claim without validation.'])


def chrome_trace(report):
    """Export separate occupancy, result and wait lanes (microsecond clock)."""
    hz = report['frequency_hz']
    names = sorted({item['track'] for item in report['timeline']})
    tids = {name: i for i, name in enumerate(names)}
    events = [dict(ph='M', name='thread_name', pid=1, tid=tids[name], args={'name': name})
              for name in names]
    for item in report['timeline']:
        events.append(dict(ph='X', pid=1, tid=tids[item['track']], name=item['name'],
                           ts=item['start_cycle'] / hz * 1e6,
                           dur=(item['end_cycle'] - item['start_cycle']) / hz * 1e6,
                           args={'address': item['address'], 'provenance': 'modeled',
                                 'model': report['model_provenance'], 'status': report['status']}))
    return {'traceEvents': events, 'displayTimeUnit': 'ns'}


def main():
    """Run an explicit pipeline JSON specification and export its timeline."""
    import argparse
    import json
    from pathlib import Path

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('input', type=Path)
    parser.add_argument('--report', required=True, type=Path)
    parser.add_argument('--trace', type=Path)
    parser.add_argument('--compiler-costs', type=Path)
    args = parser.parse_args()
    spec = json.loads(args.input.read_text())
    if spec.get('schema_version') != 1:
        raise ValueError('unsupported pipeline schema')
    costs = None
    if args.compiler_costs:
        from .compiler_costs import CompilerCosts
        costs = CompilerCosts.read(args.compiler_costs, binary_sha256=spec['compiler_binary_sha256'])

    def operation(o):
        if 'performance_id' in o:
            if costs is None:
                raise ValueError('performance_id requires --compiler-costs')
            if any(k in o for k in ('latency', 'reservations', 'resource_holds', 'issue_checks')):
                raise ValueError('table-backed operations cannot override compiler costs')
            return costs.operation(o['id'], o['performance_id'],
                                   issue_footprint=o['issue_footprint'],
                                   resource_namespace=o['resource_namespace'],
                                   classification_source=o['classification_source'],
                                   depends_on=o.get('depends_on', ()))
        return Operation(o['id'], o['name'], o['latency'],
                         tuple(Reservation(**r) for r in o.get('reservations', [])),
                         tuple(o.get('depends_on', [])),
                         tuple(ResourceHold(**r) for r in o.get('resource_holds', [])),
                         tuple(o.get('issue_checks', [])),
                         tuple(CreditWait(**w) for w in o.get('credit_waits', [])),
                         tuple(CreditUpdate(**u) for u in o.get('credit_updates', [])),
                         o.get('service_resource', ''), o.get('wait_until', 0))

    bundles = [Bundle(b['address'], tuple(operation(o) for o in b['operations']),
        b.get('issue_cycles', 1)) for b in spec['bundles']]
    if costs is not None:
        spec['model_provenance'] += '; ' + costs.provenance
        spec['gaps'] = list(spec['gaps']) + [
            'Compiler table values are not hardware calibration; instruction classification and issue footprints are supplied by the caller.']
    report = simulate(bundles, frequency_hz=spec['frequency_hz'], gaps=spec['gaps'],
                      model_provenance=spec['model_provenance'],
                      initial_ready=spec.get('initial_ready'), initial_credits=spec.get('initial_credits'))
    args.report.write_text(json.dumps(report, indent=2))
    if args.trace:
        args.trace.write_text(json.dumps(chrome_trace(report)))


if __name__ == '__main__':
    main()
