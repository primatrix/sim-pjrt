"""SparseCore metadata and conservative measured-operation costs."""

import json
import re


def offload_inventory(text):
    """Associate SparseCore async calls with their callee roots and core IDs.

    This is compiler metadata only. Calls in computations with dynamic control
    flow are listed once, not claimed to execute once.
    """
    roots, calls, computation, entry = {}, [], None, False
    for line in text.splitlines():
        header = re.match(r'^(?:ENTRY )?%([\w.-]+)\s*\(', line)
        if header:
            computation = header[1]
            entry = line.startswith("ENTRY ")
        op = re.match(r'\s*(ROOT )?%([\w.-]+) = ', line)
        if not op:
            continue
        if op[1]:
            roots[computation] = op[2]
        if 'async_execution_thread="sparsecore"' not in line:
            continue
        callee = re.search(r'\bto_apply=%([\w.-]+)', line)
        config = {}
        if 'backend_config=' in line:
            config, _ = json.JSONDecoder().raw_decode(line.split('backend_config=', 1)[1])
        sc = config.get('sparse_core_config', {})
        calls.append({
            'call': op[2], 'computation': computation, 'entry': entry,
            'callee': callee[1] if callee else None,
            'core_ids': [int(i) for i in sc.get('core_ids', [])],
            'offload_type': sc.get('offload', 'unknown'),
        })
    for call in calls:
        call['op'] = roots.get(call['callee'])
    return calls


def mark_unmodeled(report, calls, bundle_files):
    """Retain SC work as an explicit gap, never charge a static instruction sum."""
    if not calls and not bundle_files:
        return
    report['sparsecore'] = {
        'status': 'unmodeled', 'calls': calls, 'bundle_files': bundle_files,
        'reason': 'SparseCore execution paths, DMA/synchronization and TensorCore launch/completion timing are not modeled',
    }
    report['gaps'].append({'address': 'sparsecore', 'reason': report['sparsecore']['reason']})
    report['status'] = 'partial'
    report['estimated_seconds'] = None


def control_flow_metadata(text):
    """Read computation membership and conditional branches from optimized HLO."""
    nodes, computation, entry = {}, None, False
    for line in text.splitlines():
        header = re.match(r'^(?:ENTRY )?%([\w.-]+)\s*\(', line)
        if header:
            computation, entry = header[1], line.startswith('ENTRY ')
        match = re.match(r'\s*(ROOT )?%([\w.-]+) = (.*)', line)
        if not match:
            continue
        operation = re.search(r'\s([a-z][\w-]*)\(([^)]*)\)', ' ' + match[3])
        if operation:
            node = dict(opcode=operation[1], computation=computation, entry=entry)
            branches = re.search(r'branch_computations=\{([^}]+)\}', line)
            if branches:
                node['branches'] = re.findall(r'%([\w.-]+)', branches[1])
            nodes[match[2]] = node
    return nodes


def operation_key(call, metadata):
    """Exact compiler operation signature, excluding names and debug locations."""
    import hashlib

    info = metadata.get(call['op'], {})
    text = info.get('hlo_text', '')
    if not text:
        return None
    text = text.split(' = ', 1)[-1]
    text = re.split(r', (?:frontend_attributes|metadata|backend_config)=', text)[0]
    text = re.sub(r'%[\w.-]+', '%operand', text)
    text = re.sub(r', channel_id=\d+', '', text)
    payload = json.dumps([text, call['core_ids'], call['offload_type']], separators=(',', ':'))
    return hashlib.sha256(payload.encode()).hexdigest()


def calibrate_operations(calls, metadata, samples):
    """Aggregate SC Op durations from a matching executable, never Module spans.

    The caller must isolate samples by executable and hardware before calling.
    Samples are dictionaries containing op and duration_ns.
    """
    import math
    from statistics import median

    keys = {}
    for call in calls:
        key = operation_key(call, metadata)
        if key:
            keys.setdefault(call['op'], set()).add(key)
    values = {}
    for sample in samples:
        duration = sample['duration_ns']
        if isinstance(duration, bool) or not isinstance(duration, (int, float)) or not math.isfinite(duration) or duration <= 0:
            raise ValueError('invalid SparseCore observed duration')
        candidates = keys.get(sample['op'], set())
        if len(candidates) != 1:
            continue
        values.setdefault(next(iter(candidates)), []).append(duration)
    return {key: {'duration_ns': median(durations), 'sample_count': len(durations),
                  'min_ns': min(durations), 'max_ns': max(durations)}
            for key, durations in values.items()}


def bound_offloads(report, calls, nodes, metadata, calibration):
    """Add serialized calibrated SC work, taking each conditional's local max.

    TensorCore/SC overlap and correlations between separate conditionals are
    discarded. Measured durations are model parameters, not hardware WCETs.
    Unbound loop/call multiplicities remain explicit gaps.
    """
    import math

    missing, visited, segments = [], set(), []
    entries = {n['computation'] for n in nodes.values() if n.get('entry')}
    entries.update(c['computation'] for c in calls if c.get('entry'))

    def computation(name, stack=()):
        if name in stack:
            raise ValueError('SparseCore recursive computation has no finite bound')
        jobs = []
        for call in calls:
            if call['computation'] != name:
                continue
            visited.add(call['call'])
            key = operation_key(call, metadata)
            duration = calibration.get(key, {}).get('duration_ns')
            if (not call['core_ids'] or isinstance(duration, bool)
                    or not isinstance(duration, (float, int))
                    or not math.isfinite(duration) or duration <= 0):
                missing.append(dict(call=call['call'], reason='missing core IDs or measured operation duration'))
                continue
            jobs.append(dict(call, duration_ns=math.ceil(duration)))
        for label, node in nodes.items():
            if node['computation'] != name or node['opcode'] != 'conditional':
                continue
            arms = [computation(branch, stack + (name,)) for branch in node.get('branches', [])]
            if not arms:
                missing.append(dict(call=label, reason='conditional branch metadata is missing'))
                continue
            durations = [sum(j['duration_ns'] for j in arm) for arm in arms]
            selected = max(range(len(arms)), key=lambda i: durations[i])
            segments.append(dict(call=label, alternative_ns=durations, selected_alternative=selected))
            jobs.extend(arms[selected])
        return jobs

    jobs = [job for entry in sorted(entries) for job in computation(entry)]
    missing.extend(dict(call=c['call'], reason='unbound loop or call multiplicity')
                   for c in calls if c['call'] not in visited)
    report['tensorcore_base_modeled_seconds'] = report['modeled_seconds']
    report['events_clock'] = 'tensorcore_base_cycles_before_serialized_sparsecore'
    base = clock = math.ceil(report['modeled_seconds'] * 1e9)
    for job in jobs:
        end = clock + job['duration_ns']
        for core in job['core_ids']:
            event = dict(name=job['op'], track='Sparse Core Ops', start_ns=clock, end_ns=end,
                         bytes=-1, sparse_core=core, detail=f"call={job['call']}; timing_source=measured_operation",
                         cost_gap='serialized calibrated work; launch and contention are unmodeled')
            event.update(metadata.get(job['op'], {}))
            report['activity_timeline'].append(event)
            report['activity_timeline'].append(dict(event, track='SparseCore Offload Type',
                                                   name=job['offload_type'], hlo_text=''))
        clock = end
    report['modeled_seconds'] = clock / 1e9
    report['modeled_cycles'] = report['modeled_seconds'] * report['profile']['frequency_hz']
    report['sparsecore'] = dict(status='serialized_calibrated_partial', aligned_calls=len(jobs),
                              missing=missing, added_critical_path_ns=clock - base,
                              runtime_segments=segments)
    report['status'], report['estimated_seconds'] = 'partial', None
    report['assumptions'].append(
        'SparseCore local branch maxima are serialized after TensorCore work; overlap and cross-branch correlations are discarded. '
        'Calibration samples are not worst-case hardware bounds; launch and contention remain unmodeled.')
