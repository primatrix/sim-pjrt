"""Convert execution work traces into an explicitly uncalibrated scenario.

This does not use CPU wall time or claim a serving latency prediction. Each trace
file is an independent process stream; unknown kernels remain visible.
"""

import argparse
import json
import math
from pathlib import Path


def positive(value, name, *, allow_zero=False):
    if not isinstance(value, (int, float)) or not math.isfinite(value):
        raise ValueError(f"{name} must be finite")
    if value < 0 or (value == 0 and not allow_zero):
        raise ValueError(
            f"{name} must be {'nonnegative' if allow_zero else 'positive'}"
        )
    return value


def build_report(records, hardware):
    compute = positive(hardware["bf16_flops_per_second"], "compute rate")
    bandwidth = positive(hardware["hbm_bytes_per_second"], "bandwidth")
    for name in ("compute_utilization", "bandwidth_utilization"):
        if positive(hardware[name], name) > 1:
            raise ValueError(f"{name} must be at most 1")
    compute *= hardware["compute_utilization"]
    bandwidth *= hardware["bandwidth_utilization"]
    launch = positive(hardware["launch_seconds"], "launch overhead", allow_zero=True)
    time = 0.0
    events = []
    for record in records:
        flops = positive(record["dot_flops"], "dot FLOPs", allow_zero=True)
        traffic = positive(record["logical_bytes"], "logical bytes", allow_zero=True)
        compute_seconds = flops / compute
        memory_seconds = traffic / bandwidth
        seconds = launch + max(compute_seconds, memory_seconds)
        # Pre-partition HLO mixes global shapes and shard_map local shapes.
        # Dividing this work by device count would invent a scaling prediction.
        multi_device = record.get("num_devices", 1) > 1
        if multi_device:
            seconds = None
        events.append(
            {
                **record,
                "modeled_start_seconds": time,
                "modeled_duration_seconds": seconds,
                "dominant_modeled_resource": None
                if multi_device
                else ("compute" if compute_seconds > memory_seconds else "memory"),
            }
        )
        time = time + seconds if time is not None and seconds is not None else None
    return {
        "schema_version": 2,
        "calibrated": False,
        "complete_latency_prediction": False,
        "hardware": hardware,
        "modeled_component_seconds": time,
        "unmodeled_ops": sum(record["unmodeled_ops"] for record in records),
        "untimed_multi_device_executions": sum(
            record.get("num_devices", 1) > 1 for record in records
        ),
        "limitations": [
            "Multi-device durations and subsequent timeline positions are null: "
            "per-shard work and communication timing are not modeled.",
            "Opaque Pallas kernels and dynamic iteration counts are not timed.",
            "Vector compute, fusion, layout, transfers, communication "
            "and host scheduling are not timed.",
            "Events describe accepted executions; "
            "asynchronous execution failures are not encoded.",
            "The timeline covers modeled components only, "
            "not end-to-end TTFT or token latency.",
        ],
        "events": events,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("trace", type=Path)
    parser.add_argument(
        "--hardware", type=Path, default=(Path(__file__).resolve().parents[1] / "configs/v7x.json")
    )
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    records = [
        json.loads(line) for line in args.trace.read_text().splitlines() if line.strip()
    ]
    if not records:
        parser.error("trace has no executions")
    report = build_report(records, json.loads(args.hardware.read_text()))
    args.output.write_text(json.dumps(report, indent=2, allow_nan=False) + "\n")
    print(f"{len(records)} executions; {report['unmodeled_ops']} unmodeled operations")


if __name__ == "__main__":
    main()
