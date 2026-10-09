"""Scalar values, phi aliases and allocation-relative pointer arithmetic."""

import re

_REGISTER = re.compile(r'%[sp][\w]+')


_ASSIGN = re.compile(r'^(%[sp][\w]+)\s*=\s*([\w.]+)\s*(.*)$')


_FLAG = re.compile(r'\[#allocation\d+(?:\s*\+\s*\$0x[\da-fA-F]+)?\]')
_SMEM = re.compile(r'\[smem:\[(#allocation\d+(?:_spill)?)(?:\s*\+\s*\$0x([\da-fA-F]+))?\]\]')


def _smem_slot(text, read=None):
    match = _SMEM.search(text)
    if match:
        return (match[1], int(match[2] or '0', 16))
    if read is None:
        return None
    indirect = re.search(r'\[smem:\[([^\[\]]+)\]\]', text)
    if not indirect:
        return None
    parts = [part.strip() for part in indirect[1].split('+')]
    if len(parts) > 2:
        return None
    base = (parts[0], 0) if re.fullmatch(r'#allocation\d+(?:_spill)?', parts[0]) else _address(read(parts[0]))
    offset = read(parts[1]) if len(parts) == 2 else 0
    if base and type(offset) is int:
        return base[0], base[1] + offset
    return None


def _address(value):
    """Allocation/SSA base plus offset, without inventing a physical address."""
    if isinstance(value, tuple):
        return value
    if not isinstance(value, str):
        return None
    match = re.fullmatch(r'\[(#allocation\d+)(?:\s*\+\s*\$0x([\da-fA-F]+))?\]', value)
    return (match[1], int(match[2] or '0', 16)) if match else None


def _phi_values(bundle, pc, previous, read):
    """Phi aliases read the incoming edge before co-issued hardware writes."""
    result = {}
    for ins in bundle['instructions']:
        match = _ASSIGN.match(ins['text'])
        if not match or match[2] != 'sphi':
            continue
        incoming = match[3].split(',')
        if bundle.get('loop_header'):
            if len(incoming) != 2 or previous is None:
                raise ValueError('unsupported or ambiguous loop phi predecessor')
            result[match[1]] = read(incoming[int(previous >= pc)])
        elif bundle.get('branch_join') and len(incoming) == 2 and previous is not None:
            result[match[1]] = read(incoming[int(previous == pc - 1)])
        else:
            operands = [read(operand) for operand in incoming]
            result[match[1]] = operands[0] if all(v == operands[0] for v in operands) else None
    return result


def _evaluate(opcode, args, read, memory):
    """Evaluate one scalar write using the register state before this bundle."""
    base = opcode.split('.')[0]
    value = None
    if opcode == 'scalar_lea.sflag':
        # The trailing allocation is compiler provenance, not part of the
        # numeric displacement: scalar_lea.sflag %base, 6 [#allocation6].
        args = re.sub(r'(,\s*[^,\[\]]+?)\s+\[#allocation\d+\]\s*$', r'\1', args)
    if base in ('int_to_ptr', 'ptr_to_int'):
        return read(re.sub(r'\[resolvable:\$\w+\]\s*', '', args).strip())
    select = re.fullmatch(r'\((!?%p\w+),\s*([^()]+)\),\s*(.+)', args)
    if base == 'smov' and select:
        cond = read(select[1])
        if cond is not None:
            value = read(select[3] if cond else select[2])
        else:
            choices = [read(select[2]), read(select[3])]
            if all(isinstance(v, (int, range)) for v in choices):
                lo = min(v if isinstance(v, int) else v.start for v in choices)
                hi = max(v if isinstance(v, int) else v.stop - 1 for v in choices)
                value = lo if lo == hi else range(lo, hi + 1)
    else:
        operands = [read(x) for x in args.split(',')]
        # A disabled DMA arm can contain undefined values. Boolean predicates
        # still resolve when a known operand determines the whole expression.
        if len(operands) == 2:
            if base in ('pand', 'pnand') and any(v == 0 for v in operands if isinstance(v, int)):
                return int(base == 'pnand')
            if base == 'por' and any(v != 0 for v in operands if isinstance(v, int)):
                return 1
        if (len(operands) == 2 and any(isinstance(v, range) for v in operands)
                and all(isinstance(v, (int, range)) for v in operands)
                and base in ('sadd', 'ssub', 'sshll', 'sshrl', 'sshra', 'scmp')):
            bounds = [(v, v) if isinstance(v, int) else (v.start, v.stop - 1)
                      for v in operands]
            signed = '.s32' in opcode and base != 'sshrl'
            if signed:
                if any(lo < 0x80000000 <= hi for lo, hi in bounds):
                    return None
                bounds = [(lo - (0x100000000 if lo >= 0x80000000 else 0),
                           hi - (0x100000000 if hi >= 0x80000000 else 0))
                          for lo, hi in bounds]
            (lo, hi), (blo, bhi) = bounds
            if base == 'scmp':
                relation = opcode.split('.')[1]
                if relation in ('eq', 'ne'):
                    equal = True if lo == hi == blo == bhi else False if hi < blo or bhi < lo else None
                    return equal if relation == 'eq' or equal is None else not equal
                certain, impossible = {'lt': (hi < blo, lo >= bhi), 'le': (hi <= blo, lo > bhi),
                                       'gt': (lo > bhi, hi <= blo), 'ge': (lo >= bhi, hi < blo)}[relation]
                return True if certain else False if impossible else None
            if base == 'sadd':
                lo, hi = lo + blo, hi + bhi
            elif base == 'ssub':
                lo, hi = lo - bhi, hi - blo
            elif blo == bhi and 0 <= blo < 32:
                if base == 'sshll':
                    lo, hi = lo << blo, hi << blo
                else:
                    lo, hi = lo >> blo, hi >> blo
            else:
                return None
            minimum, maximum = (-2**31, 2**31 - 1) if signed else (0, 2**32 - 1)
            if not minimum <= lo <= hi <= maximum or lo < 0 <= hi:
                return None  # A wrapping/disjoint range is not represented.
            lo, hi = lo & 0xffffffff, hi & 0xffffffff
            return lo if lo == hi else range(lo, hi + 1)
        if opcode in ('smin.u32', 'sand.u32', 'sshrl.u32') and len(operands) == 2:
            # A clamped runtime index can still prove a constant after a shift.
            # Ranges remain unknown to other operations; never pick an endpoint.
            bounds = [(v & 0xffffffff, v & 0xffffffff) if isinstance(v, int) else (v.start, v.stop - 1)
                      if isinstance(v, range) else (0, 0xffffffff) for v in operands]
            (lo, hi), (blo, bhi) = bounds
            if opcode == 'smin.u32':
                lo, hi = min(lo, blo), min(hi, bhi)
            elif opcode == 'sand.u32':
                if all(isinstance(v, int) for v in operands):
                    lo = hi = operands[0] & operands[1] & 0xffffffff
                else:
                    lo, hi = 0, min(hi, bhi)
            elif blo == bhi and 0 <= blo < 32:
                lo, hi = lo >> blo, hi >> blo
            else:
                return None
            return lo if lo == hi else range(lo, hi + 1)
        if len(operands) == 2:
            a, b = operands
            left, right = _address(a), _address(b)
            if left and right and left[0] == right[0] and base in ('ssub', 'scmp'):
                operands = [left[1], right[1]]
            elif base in ('sadd', 'ssub', 'scalar_lea') and not opcode.endswith('.sflag'):
                if base == 'sadd' and right:
                    left, b = right, a
                if left and isinstance(b, int):
                    if '.s32' in opcode:
                        b = (b & 0xffffffff) - (0x100000000 if b & 0x80000000 else 0)
                    return left[0], left[1] + (-b if base == 'ssub' else b)
        if base in ('smov', 'pmov') and len(operands) == 1:
            value = operands[0]
        elif base in ('pneg', 'pnot') and len(operands) == 1 and operands[0] is not None:
            value = int(not operands[0])
        elif base == 'sld':
            slot = _smem_slot(args, read)
            if slot:
                value = memory.get(slot)
        elif base == 'scalar_select' and len(operands) == 3 and isinstance(operands[0], int):
            value = operands[1] if operands[0] else operands[2]
        elif base == 'scalar_lea' and opcode.endswith('.sflag') and len(operands) == 2:
            flag, offset = operands
            address = _address(flag)
            if address and address[0].startswith('#allocation') and type(offset) is int:
                displacement = address[1] + offset
                if displacement >= 0:
                    value = (f'[{address[0]}]' if displacement == 0 else
                             f'[{address[0]} + $0x{displacement:x}]')
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
            elif base in ('sshll', 'sshrl', 'sshra') and 0 <= b < 32:
                value = ((a << b) if base == 'sshll' else
                         (a >> b) if base == 'sshra' else ((a & 0xffffffff) >> b)) & 0xffffffff
            elif base == 'scmp':
                relation = opcode.split('.')[1]
                value = {'eq': a==b, 'ne': a!=b, 'lt': a<b,
                         'le': a<=b, 'gt': a>b, 'ge': a>=b}.get(relation)
    return value
