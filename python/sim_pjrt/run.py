"""Run with optional measured predictions and a per-run coverage report."""

import json
from pathlib import Path

from sim_pjrt.profiling.identity import compilation_observer
from sim_pjrt.prediction import CompilationPredictor
from sim_pjrt.report import summarize
from sim_pjrt.workload import run_python


def run(command, predictor="llo", database=None, replay_miss="error", report=None):
    selected = CompilationPredictor(predictor, database, replay_miss)
    status = "failed"
    memory = None
    try:
        with compilation_observer({}, selected):
            run_python(command)
            import jax
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
