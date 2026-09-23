"""Read a simulator profile through the same converter used by XProf Trace Viewer."""

import json
from pathlib import Path


def load_trace(directory):
    from xprof.convert.raw_to_tool_data import xspace_to_tool_data

    paths = sorted(Path(directory).rglob("*.xplane.pb"))
    if not paths:
        raise ValueError(f"No XProf files in {directory}")
    if len(paths) != 1:
        raise ValueError("Select one capture containing one process profile")
    data, content_type = xspace_to_tool_data(
        [str(paths[0])], "trace_viewer", {"use_saved_result": False}
    )
    if content_type != "application/json":
        raise ValueError(f"Unexpected XProf response: {content_type}")
    return json.loads(data)


def simulator_events(trace):
    return [
        event
        for event in trace["traceEvents"]
        if event.get("args", {}).get("clock_domain") == "cpu_wall"
    ]


def interval_union(intervals):
    """Duration covered by at least one interval, in Trace Viewer microseconds."""
    end = float("-inf")
    total = 0.0
    for start, stop in sorted(intervals):
        total += max(0.0, stop - max(start, end))
        end = max(end, stop)
    return total


def build_profile_report(trace):
    from collections import defaultdict

    events = simulator_events(trace)
    api = defaultdict(lambda: {"count": 0, "cumulative_duration_us": 0.0})
    pending = defaultdict(list)
    producers = {}
    dependencies = []
    external = set()
    errors = []
    incomplete = 0
    dropped = 0
    for event in sorted(events, key=lambda event: event["ts"]):
        name, stats = event["name"], event["args"]
        duration = event.get("dur", 0)
        api[name]["count"] += 1
        api[name]["cumulative_duration_us"] += duration
        incomplete += int(stats.get("incomplete", 0))
        dropped = max(dropped, int(stats.get("dropped_events", 0)))
        if stats.get("error"):
            errors.append({"operation": name, "error": stats["error"]})
        operation = stats["correlation_id"]
        for buffer in stats.get("input_buffers", "").split(","):
            if not buffer:
                continue
            if buffer in producers:
                dependencies.append(
                    {
                        "producer": producers[buffer],
                        "consumer": operation,
                        "buffer_id": buffer,
                    }
                )
            else:
                external.add(buffer)
        for buffer in stats.get("output_buffers", "").split(","):
            if buffer:
                producers[buffer] = operation
        if name == "Execute submit-to-ready":
            pending[int(stats["device_id"])].append(
                (event["ts"], event["ts"] + duration)
            )
    return {
        "schema_version": 1,
        "clock_domain": "cpu_wall",
        "tpu_latency_prediction": False,
        "event_count": len(events),
        "incomplete_events": incomplete,
        "dropped_events": dropped,
        "errors": errors,
        "operations": dict(sorted(api.items())),
        "devices": {
            str(device): {
                "execute_count": len(intervals),
                "execute_pending_union_us": interval_union(intervals),
            }
            for device, intervals in sorted(pending.items())
        },
        "buffer_dependency_edges": dependencies,
        "buffers_produced_outside_capture": sorted(external),
        "limitations": [
            "CPU wall-clock observations include profiler overhead; "
            "not TPU predictions.",
            "Submit-to-ready spans include submission, queues and callbacks; "
            "they are not compute duration or device utilization.",
            "Cumulative durations can overlap across threads; "
            "they are not request latency.",
            "Buffer IDs describe handles, not unique physical allocations "
            "or all aliases.",
            "XProf may truncate very large host traces; use bounded tracing options.",
        ],
    }


def main():
    import argparse

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("directory", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--trace-output", type=Path)
    args = parser.parse_args()
    trace = load_trace(args.directory)
    report = build_profile_report(trace)
    if not report["event_count"]:
        parser.error("No simulator events found in the profile")
    args.output.write_text(json.dumps(report, indent=2) + "\n")
    if args.trace_output:
        args.trace_output.write_text(json.dumps(trace) + "\n")
    print(
        f"{report['event_count']} events; "
        f"{len(report['buffer_dependency_edges'])} buffer dependencies"
    )


if __name__ == "__main__":
    main()
