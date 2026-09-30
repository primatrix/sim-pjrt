"""Capture on real TPU, then pass the artifacts to the offline importer."""

import json
from pathlib import Path

from sim_pjrt.profiling.importer import import_profile
from sim_pjrt.workload import run_python


def collect(output, command, skip_first=1):
    import jax
    from sim_pjrt.profiling.identity import compilation_observer, hardware_context

    try:
        from xprof.convert.raw_to_tool_data import xspace_to_tool_data  # noqa: F401
    except ImportError as error:
        raise ValueError("Collection requires XProf; install sim-pjrt[collect]") from error
    output = Path(output)
    output.mkdir(parents=True, exist_ok=False)
    devices = jax.devices()
    if jax.process_count() != 1 or any(d.platform != "tpu" for d in devices):
        raise ValueError("Collection requires a single-process real TPU backend")
    context = hardware_context(jax._src.xla_bridge.get_backend("tpu"))
    (output / "context.json").write_text(json.dumps(context, indent=2) + "\n")
    records = {}
    with compilation_observer(records):
        with jax.profiler.trace(str(output / "profile")):
            run_python(command)
            for array in jax.live_arrays():
                array.block_until_ready()
            jax.effects_barrier()
    identities = output / "executables.json"
    identities.write_text(json.dumps(records, indent=2) + "\n")
    return import_profile(output / "profile", output / "timings.json",
                          identities=identities, context=context, skip_first=skip_first)
