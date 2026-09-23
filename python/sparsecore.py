"""SparseCore metadata and measured-operation dependency scheduling."""

from collections import Counter
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


def dependency_metadata(text):
    """Read operand links only; all TensorCore costs remain from Final LLO."""
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
            node = dict(opcode=operation[1], inputs=re.findall(r'%([\w.-]+)', operation[2]),
                        computation=computation, entry=entry, root=bool(match[1]))
            if operation[1] == 'parameter':
                node['parameter'] = int(operation[2])
                node['scalar_predicate'] = match[3].startswith('pred[]')
            branches = re.search(r'branch_computations=\{([^}]+)\}', line)
            if branches:
                node['branches'] = re.findall(r'%([\w.-]+)', branches[1])
            index = re.search(r'\bindex=(\d+)', line)
            if index:
                node['index'] = int(index[1])
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


def align_offloads(report, calls, nodes, metadata, calibration):
    """Schedule calibrated SC operations against existing LLO scope dependencies.

    Calibration is opt-in and hardware-specific. It represents measured operation
    latency, not an ISA simulation. Missing or ambiguous dependencies stay gaps.
    """
    import math
    from copy import deepcopy

    timeline = deepcopy(report['activity_timeline'])
    scopes = [e for e in timeline if e['track'] == 'XLA Ops']
    counts = Counter(e['name'] for e in scopes)
    unique = {e['name'] for e in scopes if counts[e['name']] == 1}
    by_call = {c['call']: c for c in calls}
    done = {}
    for name, node in nodes.items():
        if node['opcode'] not in ('call-done', 'async-done') or not node['inputs']:
            continue
        update = nodes.get(node['inputs'][0], {})
        launch = update.get('inputs', [None])[0] if update.get('inputs') else None
        if launch in by_call:
            done[name] = launch
            by_call[launch] = dict(by_call[launch], inputs=update['inputs'][1:])

    def anchors(name, visiting=()):
        if name in visiting:
            raise ValueError('cyclic compiler dependencies')
        if name in done:
            return {done[name]}
        if name in unique:
            return {name}
        if name in counts:
            raise ValueError(f'ambiguous repeated LLO scope {name}')
        node = nodes.get(name)
        if not node:
            raise ValueError(f'missing dependency {name}')
        if node['opcode'] == 'parameter' and not node.get('entry', True):
            raise ValueError(f'unbound branch parameter {name}')
        if node['opcode'] in ('parameter', 'constant', 'iota'):
            return set()
        # These are aliases / transfer boundaries; no HLO cost is assigned.
        if node['opcode'] not in ('get-tuple-element', 'tuple', 'bitcast', 'reshape',
                                  'copy-start', 'copy-done', 'after-all'):
            raise ValueError(f'no LLO scope for dependency {name}')
        result = set()
        for operand in node['inputs']:
            result.update(anchors(operand, visiting + (name,)))
        return result

    jobs, missing = {}, []
    for call in by_call.values():
        try:
            if not call.get('entry'):
                raise ValueError('SparseCore call in nested/control-flow computation needs an execution path')
            if 'inputs' not in call or not call['core_ids']:
                raise ValueError('missing update/done chain or core IDs')
            key = operation_key(call, metadata)
            sample = calibration.get(key, {})
            duration = sample.get('duration_ns')
            if isinstance(duration, bool) or not isinstance(duration, (float, int)) or not math.isfinite(duration) or duration <= 0:
                raise ValueError('no matching measured operation duration')
            deps = set()
            for operand in call['inputs']:
                deps.update(anchors(operand))
            jobs[call['call']] = dict(call, deps=deps, duration=math.ceil(duration), calibration_key=key)
        except ValueError as error:
            missing.append({'call': call['call'], 'reason': str(error)})
    # Unknown paths cannot be filled by assuming completion at cycle zero.
    for job in list(jobs.values()):
        if any(d in by_call and d not in jobs for d in job['deps']):
            missing.append({'call': job['call'], 'reason': 'unmodeled SparseCore predecessor'})
            del jobs[job['call']]

    if not jobs:
        report['sparsecore'].update(status='unmodeled', aligned_calls=0,
                                  missing=missing, added_critical_path_ns=0)
        return

    needs_cache = {}
    def needs_sc(name, visiting=()):
        if name in done:
            return True
        if name in unique or name in visiting:
            return False
        if name not in needs_cache:
            needs_cache[name] = any(needs_sc(x, visiting + (name,))
                                    for x in nodes.get(name, {}).get('inputs', []))
        return needs_cache[name]

    ready, cores, scheduled = {}, {}, []
    def launch_ready():
        changed = True
        while changed:
            changed = False
            for name, job in jobs.items():
                if name in ready or not job['deps'] <= ready.keys():
                    continue
                start = max([0, *(ready[d] for d in job['deps']),
                             *(cores.get(c, 0) for c in job['core_ids'])])
                end = start + job['duration']
                ready[name] = end
                for core in job['core_ids']:
                    cores[core] = end
                    event = dict(name=job['op'], track='Sparse Core Ops',
                                 start_ns=start, end_ns=end, bytes=-1, sparse_core=core,
                                 detail=f"call={name}; timing_source=measured_operation; calibration_key={job['calibration_key']}",
                                 cost_gap='calibrated operation latency; launch and contention approximated')
                    event.update(metadata.get(job['op'], {}))
                    scheduled.append(event)
                    scheduled.append(dict(event, track='SparseCore Offload Type', name=job['offload_type'], hlo_text=''))
                changed = True
    shift = 0
    launch_ready()
    for event in sorted(timeline, key=lambda e: (e['start_ns'], e['end_ns'])):
        original_start = event['start_ns']
        if event['track'] == 'XLA Ops':
            try:
                deps = set()
                for operand in nodes.get(event['name'], {}).get('inputs', []):
                    if needs_sc(operand):
                        deps.update(anchors(operand))
                waits = [ready[d] for d in deps if d in by_call and d in ready]
                if any(d in by_call and d not in ready for d in deps):
                    raise ValueError('unresolved SparseCore completion before consumer')
                shift = max(shift, max(waits, default=0) - original_start)
            except ValueError as error:
                missing.append({'consumer': event['name'], 'reason': str(error)})
        event['start_ns'] += shift
        event['end_ns'] += shift
        if event['name'] in unique and event['track'] == 'XLA Ops':
            ready[event['name']] = event['end_ns']
            launch_ready()
    for name in jobs.keys() - ready.keys():
        missing.append({'call': name, 'reason': 'dependency not reached in LLO timeline'})
    report['tensorcore_base_modeled_seconds'] = report['modeled_seconds']
    report['events_clock'] = 'tensorcore_base_cycles_before_sparsecore_waits'
    old_end = math.ceil(report['modeled_seconds'] * 1e9)
    new_end = max([old_end + shift, *(e['end_ns'] for e in scheduled)])
    report['activity_timeline'] = timeline + scheduled
    report['modeled_seconds'] = new_end / 1e9
    report['modeled_cycles'] = report['modeled_seconds'] * report['profile']['frequency_hz']
    report['sparsecore'].update(status='calibrated_partial', aligned_calls=sum(n in ready for n in jobs),
                              missing=missing, added_critical_path_ns=new_end - old_end)
    report['assumptions'].append('SparseCore uses measured operation durations with input-ready release and per-core serialization; launch overhead and cross-device contention are not modeled.')


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


def branch_variants(report, calls, nodes, metadata, calibration):
    """Compile bounded timing cases for entry scalar-boolean conditionals.

    The runtime selects using actual replicated PJRT inputs. There is no
    reference-profile path replay or default choice for an unknown predicate.
    """
    import math
    from copy import deepcopy

    def parameter(name, seen=()):
        if name in seen:
            return None
        node = nodes.get(name, {})
        if node.get('entry') and node.get('scalar_predicate'):
            return node['parameter']
        if node.get('opcode') in ('copy', 'convert', 'bitcast', 'reshape') and len(node['inputs']) == 1:
            return parameter(node['inputs'][0], seen + (name,))
        return None

    selectors = {name: parameter(n['inputs'][0]) for name, n in nodes.items()
                 if n.get('entry') and n.get('opcode') == 'conditional' and len(n.get('branches', [])) == 2}
    selectors = {name: index for name, index in selectors.items() if index is not None}
    branch_uses = Counter(target for node in nodes.values()
                          for target in node.get('branches', []))
    selectors = {name: index for name, index in selectors.items()
                 if all(branch_uses[target] == 1 for target in nodes[name]['branches'])}
    parameters = sorted(set(selectors.values()))
    # Bound compiler-time case expansion; unsupported selectors remain gaps.
    if not parameters or len(parameters) > 4 or not any(not c['entry'] for c in calls):
        return
    roots = {n['computation']: name for name, n in nodes.items() if n.get('root')}
    known_branches = {target for name in selectors for target in nodes[name]['branches']}
    cases = []
    for mask in range(1 << len(parameters)):
        bound = deepcopy(nodes)
        active = {n['computation'] for n in nodes.values() if n.get('entry')}
        for name, index in selectors.items():
            choice = (mask >> parameters.index(index)) & 1
            node = nodes[name]
            target = node['branches'][choice]
            active.add(target)
            if target not in roots or len(node['inputs']) != 3:
                raise ValueError('malformed conditional branch metadata')
            for param in bound.values():
                if param.get('computation') == target and param['opcode'] == 'parameter':
                    if param['parameter'] != 0:
                        raise ValueError('conditional branch expects one parameter')
                    param.update(opcode='bitcast', inputs=[node['inputs'][choice + 1]])
            bound[name] = dict(node, opcode='bitcast', inputs=[roots[target]])
        # Resolve tuple projections precisely, rather than waiting for siblings.
        for node in bound.values():
            if node['opcode'] == 'get-tuple-element' and node.get('inputs'):
                base, seen = node['inputs'][0], set()
                while base not in seen and bound.get(base, {}).get('opcode') == 'bitcast':
                    seen.add(base)
                    base = bound[base]['inputs'][0]
                parent = bound.get(base, {})
                if parent.get('opcode') == 'tuple' and node.get('index', -1) in range(len(parent['inputs'])):
                    node.update(opcode='bitcast', inputs=[parent['inputs'][node['index']]])
        selected = [dict(c, entry=c['computation'] in active) for c in calls
                    if c['computation'] in active or c['computation'] not in known_branches]
        case = dict(profile=report['profile'], modeled_seconds=report['modeled_seconds'],
                    activity_timeline=report['activity_timeline'], gaps=[], assumptions=[])
        mark_unmodeled(case, selected, report.get('sparsecore_bundle_files', []))
        # Even an inactive SC branch retains the TensorCore partial estimate.
        case.setdefault('sparsecore', {})
        align_offloads(case, selected, bound, metadata, calibration)
        cases.append(dict(duration_ns=math.ceil(case['modeled_seconds'] * 1e9),
                          cost_gaps=len(report['gaps']) + len(case['sparsecore'].get('missing', [])),
                          activity_timeline=case['activity_timeline'],
                          sparsecore=case['sparsecore']))
    report['branch_parameters'] = parameters
    report['branch_cases'] = cases
