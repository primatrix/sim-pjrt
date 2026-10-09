"""Resolve known branches and bound unknown segments and counted loops."""

import re

from .scalar import _REGISTER, _ASSIGN, _FLAG, _phi_values, _evaluate, _smem_slot, _address
from .parser import dma_operands

class HaltedPath(Exception):
    """An error-halt path is not a normally completing execution."""


def _branch_joins(program, labels, default_delay):
    """Immediate postdominators: the first common continuation of both arms."""
    end = len(program)
    successors = {}
    for pc, bundle in enumerate(program):
        edges = [pc + 1]
        for ins in bundle['instructions']:
            if ins['opcode'] != 'sbr.rel':
                continue
            target = re.search(r'target = [$]region(\d+)', ins['text'])
            delay = ins.get('branch_delay_slots', default_delay)
            if target is None or target[1] not in labels or delay is None:
                raise ValueError('branch target and delay slots are required for segment bounds')
            if type(delay) is not int or delay < 0 or pc + delay >= end:
                raise ValueError('invalid or truncated branch delay window')
            edges = [labels[target[1]]]
            if re.search(r'\(!?%p\w+\)', ins['text']):
                edges.append(pc + delay + 1)
        successors[pc] = edges
    # Dominators of the reverse graph are postdominators of the original.
    predecessors = {pc: [] for pc in range(end + 1)}
    for pc, edges in successors.items():
        for target in edges:
            predecessors[target].append(pc)
    seen, postorder = {end}, []
    stack = [(end, iter(predecessors[end]))]
    while stack:
        pc, children = stack[-1]
        child = next(children, None)
        if child is None:
            postorder.append(pc)
            stack.pop()
        elif child not in seen:
            seen.add(child)
            stack.append((child, iter(predecessors[child])))
    order = postorder[::-1]
    rank = {pc: i for i, pc in enumerate(order)}
    parent = {end: end}
    changed = True
    while changed:
        changed = False
        for pc in order[1:]:
            known = [x for x in successors[pc] if x in parent]
            if not known:
                continue
            common = known[0]
            for other in known[1:]:
                while common != other:
                    if rank[common] > rank[other]:
                        common = parent[common]
                    else:
                        other = parent[other]
            if parent.get(pc) != common:
                parent[pc] = common
                changed = True
    return parent


def _counted_loops(program, labels, default_delay):
    """Recognize single-entry loops with an unconditional increasing counter."""
    definitions = {}
    branches = []
    for pc, bundle in enumerate(program):
        for ins in bundle['instructions']:
            match = _ASSIGN.match(ins['text'])
            if match:
                definitions.setdefault(match[1], []).append((pc, match[2], match[3]))
            if ins['opcode'] == 'sbr.rel':
                target = re.search(r'target = [$]region(\d+)', ins['text'])
                if target and target[1] in labels:
                    branches.append((pc, labels[target[1]], ins))

    def definition(name):
        entries = definitions.get(name, [])
        return entries[0] if len(entries) == 1 else (-1, '', '')

    loops = {}
    for latch, header, branch in branches:
        delay = branch.get('branch_delay_slots', default_delay)
        if header > latch or delay is None or latch + delay >= len(program):
            continue
        end = latch + delay + 1
        guard = re.search(r'\((!?)(%p\w+)\)', branch['text'])
        if not guard:
            continue
        compare_pc, op, args = definition(guard[2])
        relation = op.split('.')
        if len(relation) < 3 or relation[0] != 'scmp':
            continue
        relation = {'ge': 'lt', 'gt': 'le', 'eq': 'ne'}.get(relation[1]) if guard[1] else relation[1]
        operands = [x.strip() for x in args.split(',')]
        if relation not in ('lt', 'le', 'ne') or len(operands) != 2 or not operands[1].isdigit():
            continue
        update_pc, update_op, update_args = definition(operands[0])
        update = [x.strip() for x in update_args.split(',')]
        if update_op not in ('sadd.s32', 'sadd.u32') or len(update) != 2:
            continue
        if update[0].isdigit():
            update.reverse()
        counter, step = update
        phi_pc, phi_op, phi_args = definition(counter)
        incoming = [x.strip() for x in phi_args.split(',')]
        if (phi_pc != header or phi_op != 'sphi' or len(incoming) != 2
                or incoming[1] != operands[0] or not step.isdigit() or int(step) == 0
                or not header <= update_pc < compare_pc < latch):
            continue
        # No entry into the middle, early exit, second backedge, or path that
        # skips the counter update/comparison. More general loops stay explicit.
        if any((header <= pc < end and pc != latch and not header < target < end)
               or (not header <= pc < end and header < target < end)
               or (header <= pc < end and any(pc < pos < target for pos in (update_pc, compare_pc)))
               for pc, target, _ in branches):
            continue
        written = {m[1] for b in program[header:end] for i in b['instructions']
                   if (m := _ASSIGN.match(i['text']))}
        loops[header] = (latch, end, incoming[0], int(step), int(operands[1]),
                         relation, 2**31 if '.s32' in op else 2**32, written)
    backedges = {}
    for pc, target, _ in branches:
        if target <= pc:
            backedges.setdefault(target, set()).add(pc)
    return loops, backedges


def resolve_scalar_operands(program, *, max_visits=1_000_000, branch_delay_slots=None,
                            assume_peers_ready=False, scalar_inputs=(), preserve_timing_operands=True, runtime_inputs=None):
    """Return a copy with proven DMA constants, preserving unresolved operands."""
    runtime_inputs = runtime_inputs or {}
    if not isinstance(runtime_inputs, dict) or set(runtime_inputs) - {'smem', 'scalar_inputs', 'predicates', 'valid_addresses'}:
        raise ValueError('invalid runtime input fields')
    if any(not isinstance(runtime_inputs.get(field, {}), dict) for field in ('smem', 'scalar_inputs', 'predicates')):
        raise ValueError('runtime input bindings must be dictionaries')
    if type(runtime_inputs.get('valid_addresses', False)) is not bool:
        raise ValueError('valid_addresses must be a boolean assumption')
    if any(not isinstance(k, str) or not re.fullmatch(r'0|[1-9][0-9]*', k) or type(v) is not int
           for k, v in runtime_inputs.get('scalar_inputs', {}).items()):
        raise ValueError('runtime scalar inputs require integer values and argument indices')
    input_memory = {}
    for allocation, items in runtime_inputs.get('smem', {}).items():
        if not isinstance(allocation, str) or not re.fullmatch(r'#allocation\d+', allocation) or not isinstance(items, list):
            raise ValueError('invalid runtime SMEM input')
        for offset, value in enumerate(items):
            if type(value) is not int:
                raise ValueError('runtime SMEM values must be integers')
            input_memory[allocation, offset] = value
    predicates = runtime_inputs.get('predicates', {})
    if any(not isinstance(k, str) or not re.fullmatch(r'%p\w+', k) or type(v) is not bool for k, v in predicates.items()):
        raise ValueError('invalid runtime predicate assumptions')
    labels = {}
    for index, bundle in enumerate(program):
        for region in bundle.get('regions', []):
            if region in labels and labels[region] != index:
                raise ValueError(f'ambiguous LLO region {region}')
            labels[region] = index
    if branch_delay_slots is not None and (type(branch_delay_slots) is not int or branch_delay_slots < 0):
        raise ValueError('branch_delay_slots must be a nonnegative integer')
    if type(max_visits) is not int or max_visits < 1:
        raise ValueError('max_scalar_visits must be a positive integer')
    joins = None
    visits, work = {}, 0
    # Non-escaping compiler spill slots cannot alias runtime buffer pointers or
    # callee-local storage. Keep their values across calls and indirect stores.
    private_spills, escaped_spills = set(), set()
    for bundle in program:
        for ins in bundle['instructions']:
            spills = set(re.findall(r'#allocation\d+_spill', ins['text']))
            slot = _smem_slot(ins['text'])
            if ins['opcode'] in ('sld', 'sst') and slot:
                private_spills.add(slot[0])
                spills.discard(slot[0])
            escaped_spills.update(spills)
    private_spills = {name for name in private_spills
                      if name.endswith('_spill')} - escaped_spills
    loops, backedges = _counted_loops(program, labels, branch_delay_slots)
    loop_ranges = [(header, latch + next(i.get('branch_delay_slots', branch_delay_slots or 0)
                                         for i in program[latch]['instructions'] if i['opcode'] == 'sbr.rel'))
                   for header, latches in backedges.items() for latch in latches]
    ready_latches = {latch for header, latches in backedges.items() for latch in latches
                     if assume_peers_ready and program[header].get('loop_header')
                     and any(i.get('peer_wait') for i in program[header]['instructions'])}

    def walk(pc, values, memory, previous=-1, pending_branch=None, stop=None,
             loop_states=None, phi_done=False, loop_latch=None):
        nonlocal joins, work
        result = []
        loop_states = set() if loop_states is None else loop_states
        def read(token, registers=None):
            registers = values if registers is None else registers
            token = token.strip()
            if token.startswith('!'):
                value = read(token[1:], registers)
                return None if value is None else int(not value)
            if token.startswith('%'):
                return int(predicates[token]) if token in predicates else registers.get(token)
            if _FLAG.fullmatch(token):
                return token
            if re.fullmatch(r'\$?(?:0x[\da-fA-F]+|\d+)', token):
                return int(token.lstrip('$'), 16 if '0x' in token else 10)
            return None

        while pc < len(program) and pc != stop:
            if work >= max_visits:
                raise ValueError(f'scalar analysis exceeds {max_visits} visits; no finite worst-case bound established; '
                                 'max_scalar_visits is an analysis limit, not a loop bound')
            original = program[pc]
            if previous is not None and previous < pc and pc in backedges:
                # Re-entering an inner loop starts a new invocation. Its old
                # states do not prove that the enclosing loop is infinite.
                loop_states = {state for state in loop_states if state[0] not in backedges[pc]}
            summary = None
            entering = not phi_done and previous is not None and previous < pc
            if original.get('hlo_loop_bound') and entering:
                latch = original['loop_latch']
                branch = next(i for i in program[latch]['instructions'] if i['opcode'] == 'sbr.rel')
                delay = branch.get('branch_delay_slots', branch_delay_slots)
                if delay is None:
                    raise ValueError('branch delay slots are required for an HLO loop bound')
                end = latch + delay + 1
                written = {m[1] for b in program[pc:end] for i in b['instructions']
                           if (m := _ASSIGN.match(i['text']))}
                summary = (latch, end, original['hlo_loop_bound'], written, 'hlo')
            elif pc in loops and entering:
                latch, end, seed, step, bound, relation, modulus, written = loops[pc]
                start = read(seed)
                if isinstance(start, int) and 0 <= start < bound < modulus:
                    distance = bound - start + (relation == 'le')
                    count = (distance + step - 1) // step
                    # Keep exact counters while unrolling fits the budget: an
                    # inner loop may derive its bound from the outer counter.
                    if (start + count * step < modulus
                            and (relation != 'ne' or (bound - start) % step == 0)
                            and count * (end - pc) > max(10000, max_visits - work)):
                        summary = (latch, end, count, written, 'llo_counter')
            if summary is not None:
                latch, end, count, written, source = summary
                if end > len(program):
                    raise ValueError('truncated branch delay window')
                if any(i['opcode'].startswith(('sbr', 'sloop', 'scall', 'sret'))
                       for b in program[latch + 1:end] for i in b['instructions']):
                    raise ValueError('branch inside a pending branch delay window')
                # Analyze an arbitrary iteration, not just the first:
                # loop-carried scalars/spills cannot keep entry constants.
                values = {k: v for k, v in values.items() if k not in written}
                body, _ = walk(pc, dict(values), {}, previous, stop=end,
                               phi_done=True, loop_latch=latch)
                result.append(dict(address=original['address'], repeat=count, body=body,
                                   bound_source=source))
                memory.clear()
                previous, pc = end - 1, end
                continue
            bundle = dict(original, instructions=[dict(ins) for ins in original['instructions']])
            if not phi_done:
                if preserve_timing_operands:
                    selected = _phi_values(bundle, pc, previous, lambda token: token.strip())
                    for ins in bundle['instructions']:
                        match = _ASSIGN.match(ins['text'])
                        if match and match[2] == 'sphi':
                            ins['selected_phi_input'] = selected.get(match[1])
                values.update(_phi_values(bundle, pc, previous, read))
            phi_done = False
            if pc in ready_latches:
                # The compiler marks peer-readiness polls at their header. Keep
                # one protocol pass, but take the exit predicate before co-issued
                # instructions and delay slots observe it. Other loops are intact.
                for ins in bundle['instructions']:
                    guard = re.search(r'\((!?)(%p\w+)\)', ins['text'])
                    if ins['opcode'] == 'sbr.rel' and guard:
                        values[guard[2]] = int(bool(guard[1]))
            next_pc = pc + 1
            branch = None
            writes, stores = {}, {}
            unknown_store = False
            dma_destinations = set()
            # Resolve decisions before processing any co-issued instruction, so all
            # slots observe the same predicate even when a branch shares its bundle.
            guard = None
            for ins in bundle['instructions']:
                candidate = re.search(r'\((!?%p\w+)\)', ins['text'])
                if (candidate and not ins['opcode'].startswith('shalt')
                        and not (pc == loop_latch and ins['opcode'] == 'sbr.rel')
                        and read(candidate[1]) is None):
                    guard = candidate
                    break
            if guard:
                branch_pc = None
                # Predicated setup often precedes its branch. Keep the chosen
                # predicate through that branch, or merging here would erase
                # loop seeds written only on the entering arm.
                for candidate_pc in range(pc, len(program)):
                    instructions = program[candidate_pc]['instructions']
                    branches = [i for i in instructions if i['opcode'].startswith('sbr')]
                    if branches:
                        if candidate_pc == pc or any(guard[1].lstrip('!') in _REGISTER.findall(i['text']) for i in branches):
                            branch_pc = candidate_pc
                        break
                    if pending_branch is not None or any(
                            (m := _ASSIGN.match(i['text'])) and m[1] == guard[1].lstrip('!') for i in instructions):
                        break
                if branch_pc is not None:
                    if pending_branch is not None:
                        raise ValueError('branch inside a pending branch delay window')
                    if joins is None:
                        joins = _branch_joins(program, labels, branch_delay_slots)
                    join = joins.get(branch_pc)
                    if join is None:
                        raise ValueError('runtime loop has no finite worst-case bound')
                else:
                    join = pending_branch[1] if pending_branch and pending_branch[0] == 0 else pc + 1
                alternatives, states = [], []
                for choice in (False, True):
                    child_values = dict(values)
                    child_values[guard[1].lstrip('!')] = int(not choice if guard[1].startswith('!') else choice)
                    try:
                        arm, state = walk(pc, child_values, dict(memory), previous,
                                          pending_branch, join, set(loop_states), phi_done=True,
                                          loop_latch=loop_latch)
                    except HaltedPath:
                        continue
                    alternatives.append(arm)
                    states.append(state)
                if not states:
                    raise HaltedPath()
                result.append(dict(address=original['address'], alternatives=alternatives,
                                   join_address=program[join]['address'] if join < len(program) else 'exit'))
                if join < len(program) and not program[join].get('loop_header'):
                    for arm_values, _, arm_previous, _, _ in states:
                        arm_values.update(_phi_values(program[join], join, arm_previous,
                                                      lambda token: read(token, arm_values)))
                    phi_done = True
                # Retain only facts true for every arm. Differing DMA sizes
                # stay unresolved instead of taking an unsafe representative.
                values, memory, previous, pending_branch, loop_states = states[0]
                for other_values, other_memory, other_previous, other_pending, other_loops in states[1:]:
                    values = {k: v for k, v in values.items() if other_values.get(k) == v}
                    memory = {k: v for k, v in memory.items() if other_memory.get(k) == v}
                    same_edge = (previous is not None and other_previous is not None
                                 and (previous >= join) == (other_previous >= join))
                    previous = previous if same_edge else None
                    if pending_branch != other_pending:
                        raise ValueError('branches reach join with different pending jumps')
                    loop_states &= other_loops
                pc = join
                continue
            work += 1
            for ins in bundle['instructions']:
                op, text = ins['opcode'], ins['text']
                guard = re.search(r'\((!?%p\w+)\)\s*,?', text)
                predicate = read(guard[1]) if guard else 1
                summarized_backedge = pc == loop_latch and op == 'sbr.rel'
                if summarized_backedge:
                    predicate = 1  # Charge the taken branch while visiting the body once.
                if guard and predicate is not None:
                    ins['resolved_predicate'] = bool(predicate)
                if op.startswith('shalt') and predicate == 1:
                    raise HaltedPath()
                if op == 'inlined_call':
                    arguments = _REGISTER.findall(re.sub(r'\(!?%p\w+\)', '', text.split('inlined_call', 1)[1]))
                    ins['scalar_inputs'] = tuple(read(arg) if type(read(arg)) is int else None
                                                 for arg in arguments)
                if op.startswith(('sbr', 'sloop', 'scall', 'sret')):
                    if pending_branch is not None:
                        raise ValueError('branch inside a pending branch delay window')
                    delay = ins.get('branch_delay_slots', branch_delay_slots)
                    if delay is None:
                        raise ValueError('branch delay slots are not supplied by assembly or profile')
                    if type(delay) is not int or delay < 0:
                        raise ValueError('branch_delay_slots must be a nonnegative integer')
                    target = re.search(r'target = [$]region(\d+)', text)
                    if op != 'sbr.rel' or predicate is None or not target or target[1] not in labels:
                        raise ValueError(f'unresolved scalar branch at {original["address"]}')
                    if predicate and not summarized_backedge:
                        if labels[target[1]] <= pc:
                            state = (pc, tuple(sorted(values.items())), tuple(sorted(memory.items())))
                            if state in loop_states:
                                raise ValueError(f'runtime path repeats a scalar loop state at {original["address"]} '
                                                 f'to {program[labels[target[1]]]["address"]}; no finite worst-case bound')
                            loop_states.add(state)
                        branch = (delay, labels[target[1]])
                if op == 'sst':
                    slot = _smem_slot(text, read)
                    store = re.search(r'\]\]\s*(%s\w+)\s*$',
                                      re.sub(r'\(!?%p\w+\)\s*,?', '', text))
                    if slot and store:
                        if predicate != 0:
                            stores[slot] = read(store[1]) if predicate is not None else None
                    else:
                        # An unresolved store may alias an existing spill slot.
                        unknown_store |= predicate != 0
                direction = ins.get('dma_direction', op.removeprefix('dma.'))
                if op.startswith('dma.') and direction.endswith('_to_smem') and predicate != 0:
                    operands = dma_operands(text)
                    destination = _address(read(operands[2])) if len(operands) >= 3 else None
                    if destination and destination[0].startswith('#allocation'):
                        dma_destinations.add(destination[0])
                    else:
                        unknown_store = True
                if op.startswith('dma.') or op == 'vsyncadd':
                    # Do not replace destinations or unknown pointers/registers.
                    lhs, sep, rhs = text.partition('=')
                    source = rhs if sep else lhs
                    def substitute(match):
                        value = values.get(match[0])
                        if match[0].startswith('%p') or value is None or isinstance(value, (tuple, range)):
                            return match[0]
                        return str(value)
                    resolved = _REGISTER.sub(substitute, source)
                    if resolved != source:
                        if preserve_timing_operands:
                            ins['timing_operand_text'] = text
                        ins['text'] = lhs + sep + resolved if sep else resolved
                        ins['scalar_operands_resolved'] = True
                match = _ASSIGN.match(text)
                if not match:
                    continue
                dest, opcode, args = match.groups()
                base = opcode.split('.')[0]
                if base == 'sphi':
                    continue
                # A predicated write preserves its previous value when disabled.
                if guard:
                    args = re.sub(r'\((!?%p\w+)\)\s*,?', '', args).strip()
                value = _evaluate(opcode, args, read, memory)
                if opcode.startswith('inlined_call_operand.'):
                    index = re.search(r'\bindex: (\d+), kind: (?:input|output)\b', args)
                    if index and int(index[1]) < len(scalar_inputs):
                        value = scalar_inputs[int(index[1])]
                    if index and index[1] in runtime_inputs.get('scalar_inputs', {}):
                        value = runtime_inputs['scalar_inputs'][index[1]]
                        if type(value) is not int:
                            raise ValueError('runtime scalar inputs must be integers')
                if value is None and (opcode in ('scalar_lea.vmem', 'int_to_ptr.vmem', 'inlined_call_operand.vmem')
                        or (runtime_inputs.get('valid_addresses') and opcode in
                            ('scalar_lea.hbm', 'int_to_ptr.hbm', 'inlined_call_operand.hbm'))):
                    # Even an unknown VMEM base can retain a known displacement
                    # in later pointer increments and relative comparisons.
                    repeated = any(header <= pc <= end for header, end in loop_ranges)
                    value = (f'{dest}@{work}' if repeated else dest, 0)
                writes[dest] = values.get(dest) if predicate == 0 else (value if predicate is not None else None)
            # Co-issued scalar instructions read the prior bundle's register state.
            values.update(writes)
            memory.update(stores)
            if unknown_store or any(i['opcode'] == 'inlined_call' for i in bundle['instructions']):
                memory = {slot: value for slot, value in memory.items()
                          if slot[0] in private_spills}
            elif dma_destinations:
                memory = {slot: value for slot, value in memory.items()
                          if slot[0] not in dma_destinations}
                memory.update({slot: value for slot, value in input_memory.items()
                               if slot[0] in dma_destinations})
            count = visits.get(original['address'], 0)
            visits[original['address']] = count + 1
            bundle['source_address'] = original['address']
            if count:
                bundle['address'] += f'@{count}'
            bundle['scalar_path_resolved'] = True
            bundle['branch_delay_slots_resolved'] = True
            if branch is not None:
                pending_branch = branch
            if pending_branch is not None:
                remaining, target = pending_branch
                if remaining == 0:
                    next_pc, pending_branch = target, None
                else:
                    pending_branch = (remaining - 1, target)
            result.append(bundle)
            previous, pc = pc, next_pc
        if pending_branch is not None and pc == len(program):
            raise ValueError('truncated branch delay window')
        return tuple(result), (values, memory, previous, pending_branch, loop_states)

    program_result, _ = walk(0, {}, dict(input_memory))
    if program_result:
        def counts(items):
            for bundle in items:
                bundle['static_bundle_count'] = 0
                for arm in bundle.get('alternatives', []):
                    counts(arm)
                counts(bundle.get('body', []))
        counts(program_result)
        program_result[0]['static_bundle_count'] = len(program)
    return program_result
