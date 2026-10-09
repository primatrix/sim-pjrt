"""Audit raw trace lanes; never equate reconstructed spans with hardware idle.

Run through tpu-kernel-lab/lab capped (large JSON decoding, roughly 5 GiB).
Each call keeps its own origin. Call 0 is a repeatability reference; call 1 is
held out. This comparison is explicitly NOT a hardware performance predictor.
"""
import argparse
import ast
from collections import Counter, defaultdict
import gzip
import hashlib
import json
import math
from pathlib import Path
import re


def union(intervals):
    end = -math.inf
    total = 0
    for left, right in sorted(intervals):
        total += max(0, right - max(left, end))
        end = max(end, right)
    return total


def quantile(values, fraction):
    if not values:
        return None
    s = sorted(values)
    p = (len(s) - 1) * fraction
    a = int(p)
    return s[a] + (s[min(a + 1, len(s) - 1)] - s[a]) * (p - a)


def analyze(root, variant, output):
    capture = root / variant / 'capture'
    manifest = json.loads((capture / 'manifest.json').read_text())
    source = (capture / 'source.py').read_bytes()
    if hashlib.sha256(source).hexdigest() != manifest['source_sha256']:
        raise ValueError('source identity mismatch')
    ranges = {n.name: (n.lineno, n.end_lineno) for n in ast.walk(ast.parse(source))
              if isinstance(n, ast.FunctionDef) and n.name in {
                  'emit_pending_output', 'normalize_check_tile', 'normalize_output',
                  'wait_send_bo', 'wait_fetch_bkv', 'wait_fetch_bq', 'start_send_bo'}}
    path = next((capture / 'profile').rglob('*.trace.json.gz'))
    with gzip.open(path, 'rt') as f:
        data = json.load(f)
    events = data['traceEvents']
    tracks = {(e.get('pid'), e.get('tid')): e.get('args', {}).get('name', '')
              for e in events if e.get('ph') == 'M' and e.get('name') == 'thread_name'}
    track = lambda e: tracks.get((e.get('pid'), e.get('tid')), '')
    kernels = sorted([e for e in events if e.get('ph') == 'X' and track(e) == 'XLA Ops'
                      and 'varlen_attention' in e.get('name', '')], key=lambda e: e['ts'])
    if len(kernels) != 2:
        raise ValueError(f'expected two calls, got {len(kernels)}')
    calls = []
    aligned = []
    for kernel in kernels:
        lo, hi = kernel['ts'], kernel['ts'] + kernel['dur']
        seq = sorted((e for e in events if e.get('ph') == 'X'
                      and e.get('pid') == kernel.get('pid')
                      and 'Instructions' in track(e) and lo <= e['ts'] < hi), key=lambda e: e['ts'])
        lanes = defaultdict(list)
        phases = defaultdict(list)
        matrices = Counter()
        counts = Counter()
        physical = Counter()
        occurrence = Counter()
        points = {}
        bins = defaultdict(lambda: [0] * (math.ceil(kernel['dur'] / .5) + 1))
        empty = []
        end = lo
        for e in seq:
            lane, args = track(e), e.get('args', {})
            left, right = e['ts'] - lo, e['ts'] + e.get('dur', 0) - lo
            lanes[lane].append((left, right))
            bins[lane][int(left / .5)] += 1
            counts[e['name']] += 1
            if e['name'].startswith('vmatmul'):
                matrices[lane] += 1
            if e['name'].startswith(('vmatmul', 'vpop')):
                physical['mxu_events'] += 1
                physical['with_mrb_address'] += bool(re.search(r'mrb\[\d+\]', args.get('details', '')))
            base = (lane, args.get('bundle_number'), args.get('instruction_ordinal'), e['name'])
            key = base + (occurrence[base],)
            occurrence[base] += 1
            points[key] = left
            src_lines = [int(n) for n in re.findall(r'\.py:(\d+)', args.get('source', ''))]
            for name, (a, b) in ranges.items():
                if any(a <= line <= b for line in src_lines):
                    phases[name].append((left, right))
                    break
            if e['ts'] - end > .1:
                empty.append({'start_us': end - lo, 'duration_us': e['ts'] - end})
            end = max(end, e['ts'] + e.get('dur', 0))
        if hi - end > .1:
            empty.append({'start_us': end - lo, 'duration_us': hi - end})
        aligned.append(points)
        # This is a count-derived resource floor under an explicit 2.2 GHz / 8
        # cycle assumption, not the current simulator's full-kernel estimate.
        floor = max(matrices.values(), default=0) * 8 / 2200
        calls.append({
            'duration_us': kernel['dur'], 'instruction_events': len(seq),
            'matmul_counts': dict(matrices), 'physical_operand_coverage': dict(physical),
            'count_resource_floor_us': floor,
            'count_resource_floor_relative_error_percent': (floor / kernel['dur'] - 1) * 100,
            'lanes': {k: {'events': len(v), 'coverage_us': union(v),
                           'first_us': min(a for a, b in v), 'last_us': max(b for a, b in v)}
                      for k, v in lanes.items()},
            'phases': {k: {'events': len(v), 'coverage_us': union(v),
                            'first_us': min(a for a, b in v), 'last_us': max(b for a, b in v)}
                       for k, v in phases.items()},
            'blank_gaps_over_100ns_us': sum(e['duration_us'] for e in empty),
            'largest_blank_gaps': sorted(empty, key=lambda e: -e['duration_us'])[:12],
            'event_count_bins_500ns': dict(bins),
        })
    common = aligned[0].keys() & aligned[1].keys()
    errors = [abs(aligned[0][k] - aligned[1][k]) for k in common]
    residual_by_lane = defaultdict(list)
    for k in common:
        residual_by_lane[k[0]].append(abs(aligned[0][k] - aligned[1][k]))
    # Hardware counters are capture-wide: do not compare to one call's count.
    counter_path = root / variant / 'counters.json'
    counters = json.loads(counter_path.read_text()) if counter_path.exists() else {}
    selected_counters = {k: v for k, v in counters.items()
                         if any(s in k for s in ['COUNT_MATMUL', 'COUNT_IMEM_WRITES',
                                                 'COUNT_IMEM_STARVATION'])}
    coverage = {}
    for unit in (0, 1):
        lane = f'MXU{unit} Instructions'
        matching = [v for k, v in counters.items()
                    if 'DIE0_TC_' in k and k.endswith(f'COUNT_MATMUL_VREG_BF16_MXU_{unit}')]
        if len(matching) == 1 and len(matching[0]) == 1:
            hardware = int(matching[0][0]['value'])
            observed = sum(c['matmul_counts'].get(lane, 0) for c in calls)
            coverage[lane] = {'capture_counter': hardware, 'trace_both_calls': observed,
                              'relative_difference_percent': (observed / hardware - 1) * 100
                              if hardware else None}
    result = {
        'variant': variant, 'source_sha256': manifest['source_sha256'], 'calls': calls,
        'selected_hardware_counters_capture_scope': selected_counters,
        'matmul_counter_coverage': coverage,
        'same_binary_repeatability_only': {
            'reference_call': 0, 'held_out_call': 1, 'matched_events': len(common),
            'reference_events': len(aligned[0]), 'held_out_events': len(aligned[1]),
            'match_fraction_reference': len(common) / len(aligned[0]),
            'duration_error_percent': (calls[0]['duration_us'] / calls[1]['duration_us'] - 1) * 100,
            'aligned_start_abs_error_us': {'median': quantile(errors, .5),
                                          'p95': quantile(errors, .95), 'max': max(errors, default=None)},
            'lanes_p95_start_error_us': {k: quantile(v, .95) for k, v in residual_by_lane.items()},
        },
        'accuracy_status': 'not_validated_for_independent_hardware_prediction',
        'limitations': [
            'Instruction timestamps and widths are reconstructed by XProf between hardware trace points.',
            'Occurrence alignment can shift after dropped events; matched fraction does not prove completeness.',
            'Per-source and per-unit spans overlap; coverage is not additive hardware stall time.',
            'Same-binary repeatability uses call 0 timestamps and is a replay baseline, not a prediction.',
            'Count floor assumes 2.2 GHz, BF16 8-cycle issue and incomplete observed dynamic work.',
            'Full physical MRB, DMA dependencies, actual clock and matching backend schedule remain required.',
        ],
    }
    output.mkdir(parents=True, exist_ok=True)
    (output / (variant + '.json')).write_text(json.dumps(result, indent=2))
    print(json.dumps({'variant': variant, 'durations_us': [c['duration_us'] for c in calls],
                      'matmul_counts': [c['matmul_counts'] for c in calls],
                      'repeatability': result['same_binary_repeatability_only']}))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('root', type=Path)
    parser.add_argument('variant', choices=['baseline', 'single_raw', 'dual_acc'])
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    analyze(args.root, args.variant, args.output)
