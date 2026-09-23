"""Capture real PJRT operations and validate them with XProf's own converter."""

import argparse
from pathlib import Path

import jax
import numpy as np
from jax.sharding import Mesh, NamedSharding
from jax.sharding import PartitionSpec as P
from profile_report import load_trace, simulator_events


def capture(output):
    devices = jax.devices()
    assert len(devices) >= 2, "At least two simulator devices are required"
    mesh = Mesh(np.array(devices), ("tensor",))
    sharding = NamedSharding(mesh, P("tensor"))
    step = jax.jit(lambda x: x + 1, donate_argnums=(0,))
    with jax.profiler.trace(str(output)):
        x = jax.device_put(np.arange(64, dtype=np.int32), devices[0])
        x.block_until_ready()
        y = jax.device_put(x, devices[1])
        y.block_until_ready()
        value = jax.device_put(np.arange(len(devices) * 8, dtype=np.int32), sharding)
        for _ in range(8):
            value = step(value)
        value.block_until_ready()
        value.copy_to_host_async()
        np.testing.assert_array_equal(
            jax.device_get(value), np.arange(len(devices) * 8) + 8
        )
        value.delete()
        x.delete()
        y.delete()
    trace = load_trace(output)
    process_names = {e["pid"]: e["args"]["name"] for e in trace["traceEvents"]
                     if e.get("name") == "process_name"}
    expected = {"XLA Modules", "XLA Ops", "XLA TraceMe",
                "Framework Name Scope", "Framework Ops", "Source code"}
    for device in devices:
        pid = next(pid for pid, name in process_names.items()
                   if name == f"/device:TPU:{device.id}")
        tracks = {e["args"]["name"] for e in trace["traceEvents"]
                  if e.get("name") == "thread_name" and e["pid"] == pid}
        assert expected <= tracks, (device.id, tracks)
        assert not {"Bundles", "Kernels", "Communication", "Completion", "DMA", "Launch"} & tracks
    # The browser's streaming converter has a bounded device-ID namespace.
    # Checking only trace_viewer misses its out-of-range ID clamp.
    import json
    from xprof.convert.raw_to_tool_data import xspace_to_tool_data

    pb = next(output.rglob("*.xplane.pb"))
    raw, _ = xspace_to_tool_data([str(pb)], "trace_viewer@", {"use_saved_result": False})
    streamed = json.loads(raw)["traceEvents"]
    device_pids = {e["pid"] for e in streamed if e.get("name") == "process_name"
                   and "/device:TPU:" in e["args"]["name"]}
    assert len(device_pids) == len(devices), device_pids
    for pid in device_pids:
        modules = sorted((e for e in streamed if e.get("ph") == "X"
                          and e["pid"] == pid and e.get("tid") == 2),
                         key=lambda e: e["ts"])
        assert modules
        for a, b in zip(modules, modules[1:]):
            assert a["ts"] + a["dur"] <= b["ts"] + 1e-3, (a, b)
    events = simulator_events(trace)
    for name in (
        "PJRT H2D submit",
        "H2D submit-to-ready",
        "PJRT copy submit",
        "Copy submit-to-ready",
    ):
        assert any(e["name"] == name for e in events), (name, events)
    h2d = next(e for e in events if e["name"] == "PJRT H2D submit")
    assert int(h2d["args"]["bytes"]) == 256, h2d
    assert int(h2d["args"]["buffer_id"]) > 0, h2d
    parents = {e["args"]["correlation_id"]: e for e in events
               if e["name"] == "PJRT_LoadedExecutable_Execute"}
    phases = {"PJRT execute prepare", "PJRT simulator output dispatch",
              "PJRT execution enqueue", "PJRT output association"}
    for correlation, parent in parents.items():
        children = [e for e in events if e["args"].get("correlation_id") == correlation
                    and e["name"] in phases]
        assert {e["name"] for e in children} == phases
        for child in children:
            assert (child["pid"], child["tid"]) == (parent["pid"], parent["tid"])
            assert child["ts"] >= parent["ts"] - 1e-3
            assert child["ts"] + child["dur"] <= parent["ts"] + parent["dur"] + 1e-3
    # PJRT submission must nest in the existing JAX caller's real thread.
    callers = [e for e in trace["traceEvents"] if e.get("name") == "PjRtCApiLoadedExecutable::Execute"]
    assert callers
    for parent in parents.values():
        assert any(c["pid"] == parent["pid"] and c["tid"] == parent["tid"]
                   and c["ts"] <= parent["ts"] + 1e-3
                   and c["ts"] + c["dur"] >= parent["ts"] + parent["dur"] - 1e-3
                   for c in callers), parent
    pending = [e for e in events if e["name"] == "Execute submit-to-ready"]
    assert {int(e["args"]["device_id"]) for e in pending} == {d.id for d in devices}
    submissions = {
        e["args"]["correlation_id"]
        for e in events
        if e["name"] == "PJRT_LoadedExecutable_Execute"
    }
    assert all(e["args"]["correlation_id"] in submissions for e in pending)
    assert all(int(e["args"]["incomplete"]) == 0 for e in pending)
    noisy = {
        "PJRT buffer destroy",
        "PJRT buffer ready event",
        "PJRT Event callback registration",
        "PJRT Event callback",
        "Runtime notification lag",
        "CPU readiness observation lag",
    }
    assert not any(e["name"] in noisy for e in events)
    assert any(e["name"] == "PJRT D2H submit" for e in events)
    steps = [
        e
        for e in events
        if e["name"] == "PJRT_LoadedExecutable_Execute"
        and e["args"].get("detail") == "jit__lambda"
    ]
    assert len(steps) == 8, steps
    steps.sort(key=lambda e: e["ts"])
    for previous, current in zip(steps, steps[1:]):
        assert set(previous["args"]["output_buffers"].split(",")) == set(
            current["args"]["input_buffers"].split(",")
        ), (previous, current)
    print(f"XProf verified {len(events)} simulator events in {output}")
    return {e["args"]["correlation_id"] for e in events}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    first = capture(args.output / "capture1")
    second = capture(args.output / "capture2")
    assert not first.intersection(second), "Events leaked between captures"


if __name__ == "__main__":
    main()
