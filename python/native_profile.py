"""Legacy offline conversion: combine CPU observations and modeled device planes.

The live PJRT profiler no longer invokes this script.

Called automatically by the native profiler extension, not by SGLang-Jax. The
stdin JSON carries the plugin XSpace and original program snapshots; stdout is
binary XSpace for JAX to merge with its framework host tracer.
"""

import base64
import json
import os
import sys
from pathlib import Path

from replay import build_replay
from virtual_clock import simulate
from xprof_export import DEFAULT_DESCRIPTOR, build_xspace, xspace_class


def decode_stats(plane, event):
    stats = {}
    for stat in event.stats:
        name = plane.stat_metadata[stat.metadata_id].name
        field = stat.WhichOneof("value")
        value = getattr(stat, field) if field else None
        if field == "ref_value":
            value = plane.stat_metadata[value].name
        stats[name] = value
    return stats


def model_profile(space, snapshots, scenario, descriptor=DEFAULT_DESCRIPTOR):
    lines = [line for plane in space.planes for line in plane.lines]
    if not lines:
        return space
    origin_ns = min(line.timestamp_ns for line in lines)
    trace = {"traceEvents": []}
    executions = []
    for plane in space.planes:
        for line in plane.lines:
            for event in line.events:
                stats = decode_stats(plane, event)
                if stats.get("clock_domain") != "cpu_wall":
                    continue
                name = plane.event_metadata[event.metadata_id].name
                trace["traceEvents"].append(
                    {
                        "ph": "X",
                        "pid": 0,
                        "tid": line.id,
                        "name": name,
                        "ts": (line.timestamp_ns - origin_ns) / 1000
                        + event.offset_ps / 1e6,
                        "dur": event.duration_ps / 1e6,
                        "args": stats,
                    }
                )
                if name == "PJRT Execute submit":
                    executions.append(
                        {
                            "program_id": stats["program_id"],
                            "correlation_id": stats["correlation_id"],
                            "num_devices": stats["num_devices"],
                            "num_replicas": stats["num_replicas"],
                            "name": stats["detail"],
                        }
                    )
    if not trace["traceEvents"]:
        return space
    events, report = build_replay(
        trace, executions, snapshots, scenario, observed_host=True
    )
    schedule = simulate(events)
    modeled = build_xspace(schedule, descriptor)
    # Host annotations come from JAX's other profilers. Retain the plugin's real
    # host calls; modeled host service events are internal scheduling nodes only.
    next_id = max((plane.id for plane in space.planes), default=0) + 1000
    for plane in modeled.planes:
        if plane.name.endswith("Simulated host"):
            continue
        _, name = plane.name.split(" ", 1)
        plane.id = next_id
        plane.name = f"/device:CUSTOM:{next_id} {name}"
        next_id += 1
        key = max(plane.stat_metadata, default=0) + 1
        plane.stat_metadata[key].id = key
        plane.stat_metadata[key].name = "clock_alignment"
        plane.stats.add(metadata_id=key, str_value="observed_host_submissions")
        for line in plane.lines:
            line.timestamp_ns = origin_ns
            for event in line.events:
                event.stats.add(metadata_id=key, str_value="observed_host_submissions")
        space.planes.add().CopyFrom(plane)
    space.warnings.extend(modeled.warnings)
    space.warnings.append(
        "Simulated device costs are anchored to observed CPU host submissions. "
        "The framework is still CPU-driven; these are conditional estimates. "
        f"{report['executions_with_cost_gaps']}/{report['executions']} executions have cost gaps."
    )
    return space


def main():
    request = json.load(sys.stdin)
    descriptor = os.environ.get("PJRT_SIM_PROFILE_DESCRIPTOR", DEFAULT_DESCRIPTOR)
    space = xspace_class(descriptor).FromString(
        base64.b64decode(request["profile"], validate=True)
    )
    snapshots = {int(id): snapshot for id, snapshot in request["programs"].items()}
    scenario_path = Path(
        os.environ.get(
            "PJRT_SIM_PROFILE_SCENARIO",
            (Path(__file__).resolve().parents[1] / "configs/replay_scenario.json"),
        )
    )
    scenario = json.loads(scenario_path.read_text())
    result = model_profile(space, snapshots, scenario, descriptor)
    sys.stdout.buffer.write(result.SerializeToString(deterministic=True))


if __name__ == "__main__":
    main()
