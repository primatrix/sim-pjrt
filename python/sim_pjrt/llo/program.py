"""Load compiler artifacts, expand kernel calls and estimate a complete program."""

from itertools import zip_longest
from functools import cache
import json
from pathlib import Path
import re

from .parser import _HEADER, _number, parse_bundles, parse_deduplication_map
from .control_flow import HaltedPath, resolve_scalar_operands
from .runtime import estimate_bundles
from .metadata import hlo_loop_bounds

def compose_final_bundles(modules, aliases=None, root="TLP", limit=None):
    """Expand reachable calls per invocation; never sum independent dump files."""
    return tuple(iter_final_bundles(modules, aliases, root, limit))


def iter_final_bundles(modules, aliases=None, root="TLP", limit=None, *, resolve=None):
    """Stream invocations without copying the whole model's expanded loops."""
    allocations, scopes = {}, {}
    count = 0

    def visit(name, prefix, stack, scalar_inputs=()):
        nonlocal count
        label = name
        name = (aliases or {}).get(name, name)
        if name not in modules:
            raise ValueError(f"missing Final LLO callee: {name}")
        if name in stack:
            raise ValueError(f"recursive Final LLO call: {stack + (name,)}")
        renamed = {}
        program = resolve(name, scalar_inputs) if resolve else modules[name]
        yield from body(program, name, label, prefix, stack, renamed)

    def body(program, name, label, prefix, stack, renamed):
        nonlocal count
        for bundle in program:
            address = prefix + bundle["address"]
            if 'repeat' in bundle:
                yield dict(boundary='loop_start', address=address, repeat=bundle['repeat'],
                           bound_source=bundle['bound_source'],
                           static_bundle_count=bundle.get('static_bundle_count', 0))
                yield from body(bundle['body'], name, label, prefix, stack, renamed)
                yield dict(boundary='loop_end', address=address)
                continue
            if 'alternatives' in bundle:
                yield dict(boundary='start', address=address,
                           join_address=bundle['join_address'],
                           static_bundle_count=bundle.get('static_bundle_count', 0))
                for index, arm in enumerate(bundle['alternatives']):
                    if index:
                        yield dict(boundary='next', address=address)
                    yield from body(arm, name, label, prefix, stack, renamed)
                yield dict(boundary='end', address=address)
                continue
            calls = [i for i in bundle["instructions"] if i["opcode"] == "inlined_call"]
            if calls:
                if len(calls) != 1 or any(
                    i["opcode"]
                    not in {
                        "inlined_call",
                        "compiler-scheduling-barrier",
                        "inlined_call_operand",
                    }
                    for i in bundle["instructions"]
                ):
                    raise ValueError(
                        f"unsupported co-issued Final LLO call at {address}"
                    )
                if "callee" not in calls[0]:
                    raise ValueError(f"missing Final LLO call target at {address}")
                yield from visit(calls[0]["callee"], address + "/", stack + (name,),
                                 calls[0].get('scalar_inputs', ()))
                continue
            item = dict(bundle, instructions=[dict(ins) for ins in bundle['instructions']])
            item.update(
                address=address,
                module=name,
                kernel=label,
                callsite=prefix.rstrip("/"),
                source_address=bundle.get("source_address", bundle["address"]),
            )
            # Allocation names are local to each invocation. Cross-call operand
            # binding is unresolved, so do not infer false DMA dependencies.
            for instruction in item["instructions"]:

                def allocation(match):
                    key = (prefix, match[0])
                    return "#allocation" + str(
                        allocations.setdefault(key, len(allocations))
                    )

                text = instruction['text']
                if text not in renamed:
                    renamed[text] = re.sub(r"#allocation\d+", allocation, text)
                instruction['text'] = renamed[text]
                # SSA identities are invocation-local. Preserve register class
                # and physical suffix while preventing same-name callee aliases.
                def register(match):
                    value = match[0]
                    return value[:2] + '_call' + str(scopes.setdefault(prefix, len(scopes))) + '_' + value[2:]
                for field in ('text', 'timing_operand_text', 'selected_phi_input'):
                    if field in instruction:
                        value = re.sub(r'#allocation\d+', allocation, instruction[field]) if field != 'text' else instruction[field]
                        instruction[field] = re.sub(r'%[\w]+', register, value)
            count += 1
            if limit is not None and count > limit:
                raise ValueError("Final LLO call expansion exceeds limit")
            yield item

    yield from visit(root, "", ())


def annotate_branch_delays(modules, aliases, assembly, topology=""):
    """Match static Final LLO to emitted assembly before expanding loop visits.

    Explicit assembly delays account for compaction. On v5e, the operand is
    omitted: libtpu's Ghostlite TensorCore target has four fixed delay slots
    and does not support flexible delay slots.
    """
    implicit_delay = 4 if topology.partition(':')[0] == 'v5e' else None
    headers = list(_HEADER.finditer(assembly))
    originals = {name: {b['address']: b for b in bundles}
                 for name, bundles in modules.items()}
    labels = {name: {region: b['address'] for b in bundles
                    for region in b.get('regions', [])}
              for name, bundles in modules.items()}
    label_addresses = {name: set(regions.values()) for name, regions in labels.items()}
    exits = {name: bundles[-1] for name, bundles in modules.items()}
    positions, targets, missing_exits = {}, [], []
    branch_pattern = re.compile(
        r'\(pc\)\s*=\s*(sbr\.\w+)\s+(?:@(!?p\d+)\s+)?'
        r'\$[+-]?\d+(?:,\s*\$(\d+))?\s*\(=(0x[\da-fA-F]+)\)')
    for index, pair in enumerate(zip_longest(iter_final_bundles(modules, aliases), headers)):
        bundle, header = pair
        if bundle is None or header is None:
            raise ValueError('Final LLO/assembly bundle counts differ')
        end = headers[index + 1].start() if index + 1 < len(headers) else len(assembly)
        body = assembly[header.end():end]
        address = f'{header[1] or "0"}:{_number(header[2]):#x}'
        if (bundle['source_address'] in label_addresses[bundle['module']]
                or bundle['source_address'] == exits[bundle['module']]['address']):
            positions[bundle['address']] = address
        original = originals[bundle['module']][bundle['source_address']]
        branches = [ins for ins in original['instructions'] if ins['opcode'].startswith('sbr')]
        emitted = list(branch_pattern.finditer(body))
        if len(branches) != len(emitted) or ('(pc)' in body and not emitted):
            raise ValueError(f'Final LLO/assembly branch mismatch at {address}')
        for ins, match in zip(branches, emitted):
            guard = re.search(r'\((!?%p\w+)\)', ins['text'])
            predicate = None
            if guard:
                register = re.search(r'p\d+$', guard[1])
                if register is None:
                    raise ValueError(f'missing physical branch predicate at {address}')
                predicate = ('!' if guard[1].startswith('!') else '') + register[0]
            if ins['opcode'] != match[1] or predicate != match[2]:
                raise ValueError(f'Final LLO/assembly branch predicate mismatch at {address}')
            delay = int(match[3]) if match[3] is not None else implicit_delay
            if delay is not None:
                if ins.get('branch_delay_slots', delay) != delay:
                    raise ValueError(f'inconsistent branch delay across calls at {address}')
                ins['branch_delay_slots'] = delay
            target = re.search(r'target = [$]region(\d+)', ins['text'])
            # Top-level far targets can wrap in pre-overlay assembly (observed
            # on the 7B prefill). Validate kernel-local destinations here;
            # top-level execution already requires unresolved call bindings.
            if bundle['callsite'] and target and target[1] in labels[bundle['module']]:
                prefix = bundle['callsite'] + '/' if bundle['callsite'] else ''
                targets.append((prefix + labels[bundle['module']][target[1]],
                                f'{header[1] or "0"}:{int(match[4], 16):#x}'))
            elif bundle['callsite'] and target:
                # Empty exit regions can lose their diagnostic region label.
                # Recover only when assembly proves the jump lands at this
                # invocation's final bundle, including every repeated call.
                missing_exits.append((bundle['module'], target[1],
                                      bundle['callsite'] + '/' + exits[bundle['module']]['address'],
                                      f'{header[1] or "0"}:{int(match[4], 16):#x}'))
    for source, target in targets:
        # A target at an inlined call has no standalone bundle after expansion.
        if source in positions and positions[source] != target:
            raise ValueError(f'Final LLO/assembly branch target mismatch at {source}')
    for name, region, source, target in missing_exits:
        if positions.get(source) != target:
            raise ValueError(f'missing Final LLO region {region} does not target the kernel exit')
        regions = exits[name].setdefault('regions', [])
        if region not in regions:
            regions.append(region)


def annotate_loop_bounds(program, bounds):
    """Bind an HLO operation bound to a loop that must execute it every trip."""
    labels = {r: pc for pc, b in enumerate(program) for r in b.get('regions', [])}
    calls = [(pc, ins['callee']) for pc, b in enumerate(program)
             for ins in b['instructions'] if ins['opcode'] == 'inlined_call']
    for latch, bundle in enumerate(program):
        for ins in bundle['instructions']:
            target = re.search(r'target = [$]region(\d+)', ins['text'])
            if ins['opcode'] != 'sbr.rel' or not target or target[1] not in labels:
                continue
            header = labels[target[1]]
            if header >= latch:
                continue
            for call_pc, name in calls:
                if not header <= call_pc < latch or name not in bounds or sum(n == name for _, n in calls) != 1:
                    continue
                if any(i['opcode'] == 'inlined_call' and re.search(r'\(!?%p\w+\)', i['text'])
                       for i in program[call_pc]['instructions']):
                    continue
                # A branch could skip the call or repeat it in a nested loop.
                if any(i['opcode'] == 'sbr.rel' for b in program[header:latch] for i in b['instructions']):
                    continue
                program[header]['hlo_loop_bound'] = bounds[name]
                program[header]['loop_latch'] = latch


def load_final_modules(path, *, resolve_branches=True):
    """Load one compilation; align assembly when reconstructing runtime paths."""
    manifest = json.loads(path.read_text())
    files = manifest["files"]
    topology = manifest.get("topology", "")
    modules, sources, aliases, mapping_files = {}, {}, {}, []
    metadata_files, sparsecore_files, assembly_files = [], [], []
    for filename in files:
        file = Path(filename)
        if file.name.endswith('-assembly-pre-overlay.txt'):
            assembly_files.append(str(file.resolve()))
            continue
        if re.fullmatch(r".+_\d+_bundles\.txt", file.name):
            sparsecore_files.append(str(file.resolve()))
            continue
        if file.name.endswith("-TLP-hlo.txt"):
            metadata_files.append(str(file.resolve()))
            continue
        if file.name.endswith("-deduplication-map.txt"):
            mapping_files.append(str(file.resolve()))
            aliases.update(parse_deduplication_map(file.read_text()))
            continue
        match = re.fullmatch(r"\d+-(.*)-\d+-final_bundles\.txt", file.name)
        if not match:
            raise ValueError(f"not a Final LLO bundle dump: {file}")
        name = match[1]
        if name in modules:
            raise ValueError(f"ambiguous Final LLO module: {name}")
        modules[name] = parse_bundles(file.read_text())
        sources[name] = str(file.resolve())
    if len(mapping_files) != 1:
        raise ValueError("expected one libtpu deduplication map per compile")
    if len(assembly_files) > 1:
        raise ValueError('expected at most one assembly dump per compile')
    if assembly_files and resolve_branches:
        annotate_branch_delays(modules, aliases, Path(assembly_files[0]).read_text(), topology)
    bounds = {}
    for filename in metadata_files:
        bounds.update(hlo_loop_bounds(Path(filename).read_text()))
    annotate_loop_bounds(modules['TLP'], bounds)
    return modules, aliases, {
        "bundle_stage": "final_bundles",
        "topology": topology,
        "entry_file": sources["TLP"],
        "final_bundle_files": list(sources.values()),
        "deduplication_map_files": mapping_files,
        "profile_metadata_files": metadata_files,
        "sparsecore_bundle_files": sparsecore_files,
        "assembly_files": assembly_files,
        "assembly_branch_resolution_requested": resolve_branches,
    }


def estimate_final_program(modules, profile, aliases=None, *, retain_events=True,
                           finalize_report=None):
    """Compose local branch bounds, draining modeled resources at boundaries.

    Scalar facts are intersected at joins. No complete path combinations are
    built; independent branch choices can deliberately overestimate a real path.
    """
    unknown_inputs = set(profile.get('module_inputs', {})) - set(modules)
    if unknown_inputs:
        raise ValueError('runtime inputs name unknown modules: ' + ', '.join(sorted(unknown_inputs)))
    @cache
    def resolve(name, scalar_inputs):
        try:
            return resolve_scalar_operands(
                modules[name],
                scalar_inputs=scalar_inputs,
                branch_delay_slots=profile.get('branch_delay_slots'),
                assume_peers_ready=profile.get('assume_peers_ready', False),
                max_visits=profile.get('max_scalar_visits', 1_000_000),
                preserve_timing_operands=True,
                runtime_inputs=profile.get('module_inputs', {}).get(name))
        except HaltedPath:
            raise ValueError(f'no normally completing path in {name}') from None
        except ValueError as error:
            raise ValueError(f'{name}: {error}') from error
    report = estimate_bundles(iter_final_bundles(modules, aliases, resolve=resolve), profile,
                              retain_events=retain_events, resolved=True)
    if profile.get('module_inputs'):
        report['assumptions'].append('Explicit runtime SMEM inputs and predicate decisions supplied per module; timing is conditional on these values.')
    report['runtime_branch_policy'] = 'segment_bound'
    report['timing_semantics'] = 'conservative_modeled_cost'
    report['path_source'] = 'segment_bound'
    report['assumptions'].extend([
        'Each unknown branch uses its largest modeled segment cost; choices need not form a feasible input path.',
        'Modeled DMA and MXU reservations are drained before and after unknown branches; cross-segment overlap is deliberately lost.',
        'Only scalar facts common to all normally completing arms survive a join; error-halt arms are excluded.',
        'Large counted loops multiply an arbitrary iteration bound and drain modeled resources between iterations.',
        'The bound covers modeled costs only; missing costs remain gaps, not a certified hardware upper bound.',
    ])
    if finalize_report is not None:
        finalize_report(report)
    return report
