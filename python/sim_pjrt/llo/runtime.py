"""Whole-program adapter for the single Final LLO execution scheduler.

Unknown branches and summarized loops use drained segment bounds. Every segment
is scheduled by execution.build_execution and pipeline.simulate; there is no
schedule-only estimator or fallback engine.
"""
from collections import Counter
from copy import deepcopy
from functools import cache
import hashlib
import json
import math
import os
from pathlib import Path

from .compiler_costs import CompilerCosts
from .execution import GfMapping, build_execution
from .parser import expand_path
from .pipeline import simulate


@cache
def _mapping(cost_path, mapping_path):
    table = json.loads(Path(cost_path).read_text())
    costs = CompilerCosts(table, binary_sha256=table['binary_sha256'])
    return GfMapping(json.loads(Path(mapping_path).read_text()), costs)


@cache
def _binary_hash(path, size, mtime):
    with open(path, 'rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def compiler_mapping(profile):
    directory = Path(__file__).resolve().parents[1] / 'configs'
    if not directory.is_dir():
        directory = Path(__file__).resolve().parents[3] / 'configs'
    mapping = _mapping(str(profile.get('compiler_costs', directory / 'gf_costs_libtpu_0_0_48.json')),
                       str(profile.get('compiler_mapping', directory / 'gf_mapping_libtpu_0_0_48.json')))
    identity = profile.get('compiler_binary_sha256')
    library = os.environ.get('PJRT_SIM_LIBTPU_PATH')
    if library:
        stat = Path(library).stat()
        actual = _binary_hash(str(Path(library).resolve()), stat.st_size, stat.st_mtime_ns)
        if identity and actual != identity:
            raise ValueError('loaded libtpu identity differs from profile')
        identity = actual
    if identity and identity != mapping.costs.binary_sha256:
        raise ValueError('compiler binary identity does not match execution cost table')
    return mapping, ([] if identity else ['compiler identity not supplied; bundled GF table is an explicit target assumption'])


def _tree(program):
    """Decode the streaming control-flow boundaries, preserving ordinary runs."""
    root, stack = [], []
    current = root
    for item in program:
        boundary = item.get('boundary')
        if not boundary:
            current.append(item)
        elif boundary in ('start', 'loop_start'):
            node = dict(item, arms=[[]])
            current.append(node)
            stack.append((current, node))
            current = node['arms'][0]
        elif boundary == 'next':
            if not stack or stack[-1][1]['boundary'] != 'start':
                raise ValueError('invalid alternative boundary')
            node = stack[-1][1]
            node['arms'].append([])
            current = node['arms'][-1]
        elif boundary in ('end', 'loop_end'):
            if not stack:
                raise ValueError('unmatched execution boundary')
            current, node = stack.pop()
            if (boundary == 'loop_end') != (node['boundary'] == 'loop_start'):
                raise ValueError('mismatched execution boundary')
        else:
            raise ValueError('unknown execution boundary')
    if stack:
        raise ValueError('unterminated execution boundary')
    return root


def estimate_bundles(program, profile, scenario=None, *, retain_events=True, resolved=False):
    """Run the compiler-cost execution model and produce the native PJRT report."""
    scenario_supplied = scenario is not None
    scenario = deepcopy(scenario or {})
    profile = deepcopy(profile)
    if profile.get('mxu_model') not in (None, 'gf'):
        raise ValueError('unsupported mxu_model')
    mapping, identity_gaps = compiler_mapping(profile)
    program = list(program)
    scheduled = sum(b.get('static_bundle_count', 0 if 'boundary' in b else 1) for b in program)
    explicit = 'path' in scenario
    if explicit:
        lookup = {b['address']: b for b in program}
        addresses = expand_path(scenario['path'])
        if not addresses or any(a not in lookup for a in addresses):
            raise ValueError('path must contain existing bundle addresses')
        program = [lookup[a] for a in addresses]
        resolved = True
    inactive = set(scenario.get('inactive', ()))
    unused = set(inactive)
    prepared = []
    visit = 0
    for bundle in program:
        if 'boundary' in bundle:
            prepared.append(bundle)
            continue
        bundle = deepcopy(bundle)
        instructions = []
        for index, ins in enumerate(bundle['instructions']):
            key = f'{visit}:{index}'
            if key in inactive:
                unused.discard(key)
                continue
            if key in scenario.get('predicates', {}):
                decision = scenario['predicates'][key]
                if type(decision) is not bool:
                    raise ValueError('predicate decisions must be booleans')
                ins['resolved_predicate'] = decision
            if key in scenario.get('wait_until_cycles', {}):
                ins['wait_until_cycle'] = scenario['wait_until_cycles'][key]
            if ins['opcode'].startswith('shalt') and scenario.get('assume_no_faults'):
                continue
            instructions.append(ins)
        bundle['instructions'] = instructions
        if explicit:
            bundle['scalar_path_resolved'] = True
        prepared.append(bundle)
        visit += 1
    if unused:
        raise ValueError('inactive refers to nonexistent instruction visits')
    if not prepared:
        raise ValueError('empty dynamic path')
    hz = profile['frequency_hz']
    gaps = set(identity_gaps)
    events, timeline, loops, segments = [], [], [], []
    histogram = Counter()
    totals = Counter()
    credits = {}
    clock = 0

    def emit_scope(run, result, start):
        prior = None
        positions = {}
        for bundle, event in zip(run, result['events']):
            name = bundle.get('kernel', bundle.get('module', 'Final LLO'))
            track = 'XLA TraceMe' if bundle.get('module') == 'TLP' else 'XLA Ops'
            key = (name, track, bundle.get('callsite', ''))
            left = math.ceil((start + event['start_cycle'] - event['issue_stall_cycles']) / hz * 1e9)
            right = math.ceil((start + event['issue_end_cycle']) / hz * 1e9)
            source = bundle.get('source_address', bundle['address'])
            position = positions.setdefault(bundle['address'], len(positions))
            if prior and prior[0] == key and prior[1]['end_ns'] == left and position > prior[2]:
                prior[1]['end_ns'] = right
                prior = (key, prior[1], position)
            else:
                item = dict(name=name, track=track, start_ns=left, end_ns=right, bytes=-1,
                            detail=f"module={bundle.get('module', '')}; callsite={bundle.get('callsite', '')}; bundle={source}",
                            cost_gap='partial instruction execution model')
                timeline.append(item)
                prior = (key, item, position)
        for item in result['timeline']:
            if profile.get('instruction_timeline', False):
                timeline.append(dict(name=item['name'], track=item['track'],
                    start_ns=math.ceil((start + item['start_cycle']) / hz * 1e9),
                    end_ns=math.ceil((start + item['end_cycle']) / hz * 1e9), bytes=-1,
                    detail='bundle=' + item['address'], cost_gap='partial instruction execution model'))
        last = result['events'][-1]['issue_end_cycle']
        if result['modeled_cycles'] > last:
            timeline.append(dict(name='Outstanding execution resources', track='XLA TraceMe',
                start_ns=math.ceil((start + last) / hz * 1e9),
                end_ns=math.ceil((start + result['modeled_cycles']) / hz * 1e9), bytes=-1,
                detail='drain at segment boundary', cost_gap='partial instruction execution model'))

    def run_segment(run, bounded):
        nonlocal clock, credits
        if not run:
            return
        prepared_run = deepcopy(run)
        for b in prepared_run:
            for ins in b['instructions']:
                if 'wait_until_cycle' in ins:
                    ins['wait_until_cycle'] = max(0, ins['wait_until_cycle'] - clock)
        is_resolved = resolved or all(b.get('scalar_path_resolved') for b in run)
        assumed_path = scenario_supplied and not explicit and not is_resolved
        if assumed_path:
            gaps.add('scenario assumes listed bundle order; control flow is not reconstructed')
        bundles, audit = build_execution(prepared_run, mapping,
            resolved=is_resolved or assumed_path, assumed_path=assumed_path,
            branch_delay_slots=profile.get('branch_delay_slots'), memory_profile=profile,
            max_visits=profile.get('max_scalar_visits', 1_000_000), bounded=bounded)
        result = simulate(bundles, frequency_hz=hz, gaps=audit['gaps'],
                          model_provenance=mapping.provenance, initial_ready=audit['initial_ready'],
                          initial_credits=credits)
        gaps.update(result['gaps'])
        credits = result['final_credits']
        # For a raw local call, scalar resolution may expand the path here.
        source_by_address = {b['address']: b for b in run}
        metadata = [source_by_address.get(b.address, dict(address=b.address)) for b in bundles]
        emit_scope(metadata, result, clock)
        for row in audit['dependencies']:
            histogram[row['opcode']] += 1
        totals['modeled_bundle_visits'] += len(bundles)
        totals['issue_cycles'] += len(bundles) * profile.get('bundle_issue_cycles', 1)
        totals['extra_instruction_cycles'] += sum(b.issue_cycles for b in bundles) - len(bundles) * profile.get('bundle_issue_cycles', 1)
        totals['wait_stall_cycles'] += result['wait_stall_cycles']
        totals['completion_cycles'] += result['completion_tail_cycles']
        for event in result['events']:
            if retain_events:
                events.append(dict(event, kind='bundle', start_cycle=clock + event['start_cycle'],
                    end_cycle=clock + event['issue_end_cycle'], issue_end_cycle=clock + event['issue_end_cycle']))
        services = {r['operation_id']: r for r in result['timeline'] if r['track'].startswith('dma.')}
        for event in audit['dma_events']:
            totals['dma_bytes'] += event['bytes']
            totals['dma_bus_bytes'] += event['bus_bytes']
            if retain_events:
                timing = services[event['operation_id']]
                events.append(dict(event, start_cycle=clock + timing['start_cycle'], end_cycle=clock + timing['end_cycle']))
        clock += result['modeled_cycles']

    def evaluate(nodes, bounded=False):
        nonlocal clock, credits, totals, histogram
        run = []
        for node in nodes:
            if 'boundary' not in node:
                run.append(node)
                continue
            run_segment(run, bounded)
            run = []
            gaps.add('control-flow segment boundary drains resources; cross-segment SSA and memory bindings incomplete')
            start = clock
            if node['boundary'] == 'loop_start':
                count = node['repeat']
                if type(count) is not int or count < 1:
                    raise ValueError('invalid bounded loop count')
                base, hist = totals.copy(), histogram.copy()
                credits = {}
                evaluate(node['arms'][0], True)
                duration = clock - start
                loops.append(dict(address=node['address'], iterations=count, bound_source=node['bound_source'],
                                  iteration_cycles=duration, modeled_cycles=duration * count))
                totals = base + Counter({k: (v - base[k]) * count for k, v in totals.items()})
                histogram = hist + Counter({k: (v - hist[k]) * count for k, v in histogram.items()})
                end = start + duration * count
                if end > clock:
                    timeline.append(dict(name='Remaining loop iterations', track='XLA TraceMe',
                        start_ns=math.ceil(clock / hz * 1e9), end_ns=math.ceil(end / hz * 1e9), bytes=-1,
                        detail=node['address'], cost_gap='arbitrary iteration bound; no cross-iteration overlap'))
                clock, credits = end, {}
            else:
                base_totals, base_hist, base_credits = totals.copy(), histogram.copy(), credits.copy()
                arms = []
                for arm in node['arms']:
                    clock, totals, histogram, credits = start, base_totals.copy(), base_hist.copy(), base_credits.copy()
                    e, t = len(events), len(timeline)
                    evaluate(arm, True)
                    arms.append((clock, totals, histogram, credits, events[e:], timeline[t:]))
                    del events[e:]
                    del timeline[t:]
                selected = max(range(len(arms)), key=lambda i: arms[i][0])
                clock, totals, histogram, _, arm_events, arm_timeline = arms[selected]
                events.extend(arm_events)
                timeline.extend(arm_timeline)
                counters = set().union(*(a[3] for a in arms))
                credits = {k: min(a[3].get(k, 0) for a in arms) for k in counters}
                segments.append(dict(address=node['address'], join_address=node['join_address'],
                    alternative_cycles=[a[0] - start for a in arms], selected_alternative=selected,
                    modeled_cycles=clock - start))
        run_segment(run, bounded)

    tree = _tree(prepared)
    evaluate(tree, any('boundary' in b for b in prepared))
    tail = profile.get('completion_tail_cycles', 0)
    if isinstance(tail, bool) or not isinstance(tail, (int, float)) or not math.isfinite(tail) or tail < 0:
        raise ValueError('invalid completion_tail_cycles')
    if tail:
        timeline.append(dict(name='Completion tail', track='XLA TraceMe', start_ns=math.ceil(clock / hz * 1e9),
            end_ns=math.ceil((clock + tail) / hz * 1e9), bytes=-1, detail='profile supplied', cost_gap=''))
    clock += tail
    return dict(profile=profile, scenario=scenario, status='partial' if gaps else 'modeled',
        scheduled_bundle_count=scheduled, modeled_bundle_visits=totals['modeled_bundle_visits'],
        modeled_cycles=clock, modeled_seconds=clock / hz, estimated_seconds=None if gaps else clock / hz,
        issue_cycles=totals['issue_cycles'], wait_stall_cycles=totals['wait_stall_cycles'],
        extra_instruction_cycles=totals['extra_instruction_cycles'], completion_cycles=totals['completion_cycles'] + tail,
        dma_bytes=totals['dma_bytes'], dma_bus_bytes=totals['dma_bus_bytes'],
        instruction_counts=dict(histogram), runtime_loops=loops, runtime_segments=segments,
        path_source='explicit' if explicit else 'scalar_resolved',
        gaps=[dict(address='Final LLO', reason=g) for g in sorted(gaps)], events=events, activity_timeline=timeline,
        model_provenance=mapping.provenance, execution_engine='gf_instruction_pipeline',
        assumptions=['Single compiler-cost instruction execution engine; no schedule-only fallback.',
                     'DMA service queues and completion credits are modeled separately from bundle issue.',
                     'Compiler costs and supplied memory rates are not hardware calibration.']
                    + (['Empirical bundle issue floors are trace-derived and scenario-specific; they do not establish a hardware clock or causal stall model.'] if profile.get('bundle_issue_calibration') else [])
                    + (['Peers are assumed ready only for explicitly marked peer waits.'] if profile.get('assume_peers_ready') else []))
