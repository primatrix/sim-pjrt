"""MXU throughput constraints, separate from scheduled result latencies.

GF reservation resource 3, cross-checked against libtpu 0.0.46.1.
See docs/bundle-timing.md for provenance and the limits of this model.
"""

from functools import lru_cache
import re


# MatmulDataFormat 1 is F32, 2 is BF16, 9/10 are native FP8.
# These are minimum issue intervals, NOT the 211/204-cycle result latency.
_GF_MATMUL = {"f32": 4, "bf16": 8, "f8e5m2": 8, "f8e4m3fn": 8}
_MODIFIERS = {"mubr", "msk", "high", "low", "vlgmr", "msra", "msrb", "gmra", "gmrb"}


@lru_cache(maxsize=4096)
def matmul_throughput(mnemonic):
    """Return (resource, hold cycles), or None for an unsupported GF form.

    The unit suffix follows mrb[N] in Final LLO, so the parser's abbreviated
    opcode alone is insufficient. Do not guess a unit or a dtype on a miss.
    """
    match = re.fullmatch(r"vmatmul\.([\w.]+)\.mrb\[\d+\]\.mxu([01])", mnemonic)
    if not match:
        return None
    parts = set(match[1].split("."))
    formats = parts & _GF_MATMUL.keys()
    if len(formats) != 1 or parts - formats - _MODIFIERS:
        return None
    dtype = next(iter(formats))
    return f"mxu{match[2]}.matmul", _GF_MATMUL[dtype]
