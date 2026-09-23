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
    pending = [e for e in events if e["name"] == "Execute submit-to-ready"]
    assert {int(e["args"]["device_id"]) for e in pending} == {d.id for d in devices}
    submissions = {
        e["args"]["correlation_id"]
        for e in events
        if e["name"] == "PJRT Execute submit"
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
        if e["name"] == "PJRT Execute submit"
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
