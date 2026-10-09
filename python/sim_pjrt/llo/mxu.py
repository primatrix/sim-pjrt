"""Recognize supported MXU forms without supplying numeric costs.

Issue intervals and result latencies come from the active compiler table.
See docs/bundle-timing.md for provenance and the limits of this model.
"""

from functools import lru_cache
import re


# MatmulDataFormat 1 is F32, 2 is BF16, 9/10 are native FP8.
_GF_FORMATS = {"f32", "bf16", "f8e5m2", "f8e4m3fn"}
_MODIFIERS = {"mubr", "msk", "high", "low", "vlgmr", "msra", "msrb", "gmra", "gmrb"}


@lru_cache(maxsize=4096)
def matmul_resource(mnemonic):
    """Return the unit-scoped resource, or None for an unsupported GF form.

    The unit suffix follows mrb[N] in Final LLO, so the parser's abbreviated
    opcode alone is insufficient. Do not guess a unit or a dtype on a miss.
    """
    match = re.fullmatch(r"vmatmul\.([\w.]+)\.mrb\[\d+\]\.mxu([01])", mnemonic)
    if not match:
        return None
    parts = set(match[1].split("."))
    formats = parts & _GF_FORMATS
    if len(formats) != 1 or parts - formats - _MODIFIERS:
        return None
    return f"mxu{match[2]}.matmul"
