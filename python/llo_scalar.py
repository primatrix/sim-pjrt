"""Conservative constant propagation for scalar Final LLO DMA operands.

Only scalar-known paths are expanded. Unknown branch conditions, missing targets
and visit limits fall back to a partial straight-line estimate.
"""

from copy import deepcopy
import re

_REGISTER = re.compile(r'%[sp][\w]+')
_ASSIGN = re.compile(r'^(%[sp][\w]+)\s*=\s*([\w.]+)\s*(.*)$')
_FLAG = re.compile(r'\[#allocation\d+(?:\s*\+\s*\$0x[\da-fA-F]+)?\]')


def resolve_scalar_operands(program, *, follow_branches=True, max_visits=100000):
    """Return a copy with proven DMA constants, preserving unresolved operands."""
    values, memory, result, unknown_path = {}, {}, [], False
    labels = {}
    for index, bundle in enumerate(program):
        for region in bundle.get('regions', []):
            if region in labels and labels[region] != index:
                raise ValueError(f'ambiguous LLO region {region}')
            labels[region] = index
    def fallback(reason):
        partial = resolve_scalar_operands(program, follow_branches=False)
        if partial:
            partial[0]['scalar_path_gap'] = reason
        return partial
    pc, previous = 0, -1
    visits = {}

    def read(token):
        token = token.strip()
        if token.startswith('!'):
            value = read(token[1:])
            return None if value is None else int(not value)
        if token.startswith('%'):
            return values.get(token)
        if _FLAG.fullmatch(token):
            return token
        if re.fullmatch(r'\$?(?:0x[\da-fA-F]+|\d+)', token):
            return int(token.lstrip('$'), 16 if '0x' in token else 10)
        return None

    while pc < len(program):
        if follow_branches and len(result) >= max_visits:
            return fallback('scalar path visit limit reached')
        original = program[pc]
        bundle = deepcopy(original)
        if follow_branches:
            # Phi nodes are compiler aliases at entry, not co-issued hardware
            # writes. Resolve them simultaneously before ordinary instructions.
            phis = {}
            for ins in bundle['instructions']:
                match = _ASSIGN.match(ins['text'])
                if match and match[2] == 'sphi':
                    if not bundle.get('loop_header'):
                        return fallback('scalar phi outside a recognized loop header')
                    incoming = match[3].split(',')
                    if len(incoming) != 2:
                        return fallback('unsupported scalar phi arity')
                    operand = incoming[int(previous >= pc)]
                    phis[match[1]] = read(operand)
                    if phis[match[1]] is None:
                        return fallback(f'unresolved loop phi input {operand.strip()}')
            values.update(phis)
        next_pc = pc + 1
        if unknown_path:
            result.append(bundle)
            pc += 1
            continue
        writes, stores = {}, {}
        unknown_store = False
        control = False
        for ins in bundle['instructions']:
            op, text = ins['opcode'], ins['text']
            control |= op.startswith(('sbr', 'sloop', 'scall', 'sret')) or op == 'inlined_call'
            guard = re.search(r'\((!?%p\w+)\)\s*,?', text)
            predicate = read(guard[1]) if guard else 1
            if guard and predicate is not None:
                ins['resolved_predicate'] = bool(predicate)
            if follow_branches and op.startswith('shalt') and predicate == 1:
                return fallback('scalar path reaches a halt')
            if follow_branches and op.startswith(('sbr', 'sloop', 'scall', 'sret')):
                target = re.search(r'target = [$]region(\d+)', text)
                if op != 'sbr.rel' or predicate is None or not target or target[1] not in labels:
                    return fallback(f'unresolved scalar branch at {original["address"]}')
                if predicate:
                    next_pc = labels[target[1]]
            if follow_branches and op == 'inlined_call':
                return fallback('cross-call scalar bindings are unresolved')
            if op == 'sst':
                store = re.search(r'\[smem:(\[#allocation\d+_spill\])\]\s*(%s\w+)', text)
                if store:
                    if predicate != 0:
                        stores[store[1]] = read(store[2]) if predicate is not None else None
                else:
                    # An unresolved store may alias an existing spill slot.
                    unknown_store |= predicate != 0
            if op.startswith('dma.') or op == 'vsyncadd':
                # Do not replace destinations or unknown pointers/registers.
                lhs, sep, rhs = text.partition('=')
                source = rhs if sep else lhs
                def substitute(match):
                    value = values.get(match[0])
                    if match[0].startswith('%p') or value is None:
                        return match[0]
                    return str(value)
                resolved = _REGISTER.sub(substitute, source)
                if resolved != source:
                    ins['text'] = lhs + sep + resolved if sep else resolved
                    ins['scalar_operands_resolved'] = True
            match = _ASSIGN.match(text)
            if not match:
                continue
            dest, opcode, args = match.groups()
            base = opcode.split('.')[0]
            if base == 'sphi' and follow_branches:
                continue
            # A predicated write preserves its previous value when disabled.
            if guard:
                args = re.sub(r'\((!?%p\w+)\)\s*,?', '', args).strip()
            value = None
            select = re.fullmatch(r'\((!?%p\w+),\s*([^()]+)\),\s*(.+)', args)
            if base == 'smov' and select:
                cond = read(select[1])
                if cond is not None:
                    value = read(select[3] if cond else select[2])
            else:
                operands = [read(x) for x in args.split(',')]
                if base == 'smov' and len(operands) == 1:
                    value = operands[0]
                elif base == 'sld':
                    slot = re.fullmatch(r'\[smem:(\[#allocation\d+_spill\])\]', args)
                    if slot:
                        value = memory.get(slot[1])
                elif base == 'scalar_select' and len(operands) == 3 and isinstance(operands[0], int):
                    value = operands[1] if operands[0] else operands[2]
                elif base == 'scalar_lea' and opcode.endswith('.sflag') and len(operands) == 2:
                    flag, offset = operands
                    if isinstance(flag, str) and isinstance(offset, int) and offset >= 0:
                        m = re.fullmatch(r'\[(#allocation\d+)\]', flag)
                        if m:
                            value = flag if offset == 0 else f'[{m[1]} + $0x{offset:x}]'
                elif len(operands) == 2 and all(isinstance(x, int) for x in operands):
                    a, b = operands
                    if '.s32' in opcode:
                        a, b = ((x & 0xffffffff) - (0x100000000 if x & 0x80000000 else 0) for x in (a, b))
                    operations = {'sadd': lambda: a+b, 'ssub': lambda: a-b,
                                  'smul': lambda: a*b, 'sand': lambda: a&b,
                                  'sor': lambda: a|b, 'sxor': lambda: a^b,
                                  'pand': lambda: int(bool(a) and bool(b)),
                                  'por': lambda: int(bool(a) or bool(b)),
                                  'pnand': lambda: int(not (a and b))}
                    if base in operations:
                        value = operations[base]() & 0xffffffff
                    elif base in ('sshll', 'sshrl') and 0 <= b < 32:
                        value = ((a << b) if base == 'sshll' else ((a & 0xffffffff) >> b)) & 0xffffffff
                    elif base == 'scmp':
                        relation = opcode.split('.')[1]
                        value = {'eq': a==b, 'ne': a!=b, 'lt': a<b,
                                 'le': a<=b, 'gt': a>b, 'ge': a>=b}.get(relation)
            writes[dest] = values.get(dest) if predicate == 0 else (value if predicate is not None else None)
        # Co-issued scalar instructions read the prior bundle's register state.
        values.update(writes)
        if unknown_store:
            memory.clear()
        else:
            memory.update(stores)
        if control and not follow_branches:
            values.clear()
            # Without successor labels, assignments on one path cannot be
            # propagated into a join reached through another path.
            unknown_path = True
        if follow_branches:
            count = visits.get(original['address'], 0)
            visits[original['address']] = count + 1
            bundle['source_address'] = original['address']
            if count:
                bundle['address'] += f'@{count}'
            bundle['scalar_path_resolved'] = True
        result.append(bundle)
        previous, pc = pc, next_pc
    if follow_branches and result:
        for bundle in result:
            bundle['static_bundle_count'] = 0
        result[0]['static_bundle_count'] = len(program)
    return tuple(result)
