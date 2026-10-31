"""Run with optional measured predictions and a per-run coverage report."""

import json
from contextlib import nullcontext
from pathlib import Path

from sim_pjrt.profiling.identity import compilation_observer
from sim_pjrt.prediction import CompilationPredictor
from sim_pjrt.report import summarize
from sim_pjrt.workload import run_python


def run(command, predictor="llo", database=None, replay_miss="error", report=None,
        framework="jax"):
    if framework not in ("jax", "torch_tpu"):
        raise ValueError(f"Unknown workload framework: {framework}")
    if framework == "torch_tpu" and (predictor != "llo" or database):
        raise ValueError("TorchTPU supports the LLO predictor; collection/replay is JAX-only")
    selected = CompilationPredictor(predictor, database, replay_miss)
    status = "failed"
    memory = None
    try:
        if framework == "torch_tpu":
            from sim_pjrt.torch_tpu import initialize, synchronize
            initialize()
        observer = compilation_observer({}, selected) if framework == "jax" else nullcontext()
        with observer:
            run_python(command)
            if framework == "torch_tpu":
                synchronize()
            else:
                import jax
                from jax._src import xla_bridge
                # A launcher may delegate all JAX work to child processes. Reporting
                # must not initialize another backend in that otherwise idle parent.
                if xla_bridge.backends_are_initialized():
                    for array in jax.live_arrays():
                        array.block_until_ready()
                    jax.effects_barrier()
                    memory = {str(device.id): device.memory_stats() for device in jax.devices()}
        status = "complete"
    finally:
        if report:
            directory = Path(report)
            (directory / "queries.json").write_text(json.dumps(selected.queries, indent=2) + "\n")
            report = summarize(directory, selected.queries, status)
            report["device_memory"] = memory
            (directory / "summary.json").write_text(json.dumps(report, indent=2) + "\n")
