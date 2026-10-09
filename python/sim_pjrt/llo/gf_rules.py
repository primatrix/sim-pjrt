"""GF scheduling rules; cycle values come from the active compiler cost table.

The 0.0.40 reverse-engineering reference describes the rule shapes (directional
XLU conflicts, FIFO data edges, and separate MXU issue/result costs). Resource
indices and all cycle values here belong to the bundled 0.0.48 model. In
particular, Performance resources and MxuResource are different namespaces.
See docs/bundle-timing.md for the reference links and remaining limitations.
"""
import re

from .pipeline import ResourceHold


def mnemonic(instruction):
    return instruction['text'].split('=', 1)[-1].strip().split()[0]


def execution_unit(instruction):
    match = re.search(r'\.(mxu[01]|xlu[01])$', mnemonic(instruction))
    return match[1] if match else None


def xlu_kind(row):
    """The supported RPU push classes in XluInstrType, not Performance IDs."""
    opcode = row.get('llo_opcode')
    if opcode is not None and 245 <= opcode <= 252:
        return 0  # kReduceB32
    if opcode is not None and 253 <= opcode <= 257:
        return 1  # kReduceB16
    if opcode in (53, 57, 58):
        return 5  # kPermuteRotateOrBroadcast
    return None


def result_fifo(instruction, row):
    """Return (family, unit, push/pop) for decoded split result operations.

    RPU reduce and permute results share a FIFO; EUP and matrix results do not.
    Unassigned XLU units cannot be merged into one fictitious global queue.
    """
    if row is None:
        return None
    opcode = row.get('llo_opcode')
    unit = execution_unit(instruction)
    if opcode is not None and 296 <= opcode <= 314:
        return 'EUP', unit or 'core', 'push'
    if opcode == 334:
        return 'EUP', unit or 'core', 'pop'
    if xlu_kind(row) is not None and unit:
        return 'RPU', unit, 'push'
    if opcode in (335, 336) and unit:
        return 'RPU', unit, 'pop'
    if opcode == 340 and unit:
        return 'TRF', unit, 'pop'
    return None


def xlu_constraints(instruction, row, costs):
    """Emit producer deadlines indexed by the *next* push's instruction kind.

    A reduce -> permute penalty is different from permute -> reduce. A single
    exclusion interval per XLU would lose that distinction. Independent XLUs
    use separate keys; RAW consumers still wait for the producer's full latency.
    The cost table stores charged values, including the setter's +1 bias.
    """
    kind = xlu_kind(row)
    if kind is None:
        return (), (), ()
    unit = execution_unit(instruction)
    if unit is None:
        return (), (), ('XLU conflict requires an assigned execution unit',)
    if not costs.xlu_conflicts:
        return (), (), ('XLU conflict cost table is missing',)
    index = int(unit[-1])
    prefix = unit + '.xlu.conflict.'
    holds = tuple(ResourceHold(prefix + str(consumer), cycles)
                  for (producer, consumer, lane), cycles in costs.xlu_conflicts.items()
                  if producer == kind and lane == index and cycles)
    return holds, (prefix + str(kind),), ()
