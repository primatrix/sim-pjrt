"""Per-device work accounting for the represented HLO and communication scenario."""

from collections import Counter, defaultdict


def summarize_device_load(events):
    devices = defaultdict(
        lambda: {
            "estimated_dot_flops_by_dtype": Counter(),
            "estimated_hlo_read_bytes": 0,
            "estimated_hlo_write_bytes": 0,
            "estimated_kernel_flops": 0,
            "estimated_kernel_transcendentals": 0,
            "estimated_kernel_bytes_accessed": 0,
            "estimated_hlo_duration_ns": 0,
            "hlo_cost_status_counts": Counter(),
            "hlo_cost_gap_counts": Counter(),
            "h2d_bytes": 0,
            "d2h_bytes": 0,
            "local_copy_bytes": 0,
            "device_send_bytes": 0,
            "device_receive_bytes": 0,
            "collective_count": 0,
        }
    )
    operations = defaultdict(dict)
    links = Counter()
    for event in events:
        metadata = event.metadata
        device = metadata.get("device")
        if "cost_status" in metadata:
            row = devices[device]
            status = metadata["cost_status"]
            row["hlo_cost_status_counts"][status] += 1
            if status == "unknown":
                row["hlo_cost_gap_counts"][metadata["cost_gap"]] += 1
            elif status == "estimated":
                flops = metadata["dot_flops"]
                read, write = (
                    metadata["logical_read_bytes"],
                    metadata["logical_write_bytes"],
                )
                if metadata["opcode"] == "dot":
                    row["estimated_dot_flops_by_dtype"][metadata["dtype"]] += flops
                row["estimated_hlo_read_bytes"] += read
                row["estimated_hlo_write_bytes"] += write
                row["estimated_kernel_flops"] += metadata.get("kernel_flops", 0)
                row["estimated_kernel_transcendentals"] += metadata.get(
                    "transcendentals", 0
                )
                row["estimated_kernel_bytes_accessed"] += metadata.get(
                    "kernel_bytes_accessed", 0
                )
                row["estimated_hlo_duration_ns"] += event.duration_ns
                key = (metadata.get("program_id"), metadata["hlo_id"])
                operation = operations[device].setdefault(
                    key,
                    {
                        "program_id": key[0],
                        "hlo_id": key[1],
                        "name": event.name,
                        "opcode": metadata["opcode"],
                        "dtype": metadata["dtype"],
                        "occurrences": 0,
                        "dot_flops": 0,
                        "logical_bytes": 0,
                    },
                )
                operation["occurrences"] += 1
                operation["dot_flops"] += flops
                operation["logical_bytes"] += (
                    read + write + metadata.get("kernel_bytes_accessed", 0)
                )
        transfer = metadata.get("transfer_kind")
        if transfer in ("h2d", "d2h", "local_copy"):
            devices[device][transfer + "_bytes"] += metadata["bytes"]
        elif transfer == "device":
            # Account once per logical transfer, not once per routed hop.
            devices[metadata["source"]]["device_send_bytes"] += metadata["bytes"]
            devices[metadata["target"]]["device_receive_bytes"] += metadata["bytes"]
        if "link" in metadata:
            links[metadata["link"]] += metadata["bytes"]
        if "participants" in metadata:
            for participant in metadata["participants"]:
                devices[participant]["collective_count"] += 1
    for device, row in devices.items():
        values = list(operations[device].values())
        for metric in ("dot_flops", "logical_bytes"):
            row["top_hlo_by_" + metric] = sorted(
                (op for op in values if op[metric]),
                key=lambda op: (-op[metric], str(op["program_id"]), op["hlo_id"]),
            )[:10]
    return {
        "schema_version": 1,
        "scope": "represented HLO work and configured communication algorithm",
        "complete_work_estimate": False,
        "devices": {str(d): row for d, row in sorted(devices.items())},
        "routed_link_bytes": dict(sorted(links.items())),
        "limitations": [
            "Counts cover supported HLO only; cost gaps are not zero actual workload.",
            "Logical bytes are operand reads and output writes before fusion; not physical HBM traffic or memory capacity.",
            "Dot FLOPs are grouped by output dtype. Author-declared Pallas costs have separate totals; kernel bytes have no read/write split and are not measured traffic.",
            "Communication bytes depend on the configured collective algorithm and routes; reduction arithmetic is excluded.",
            "Estimated durations and resource reservations are scenario results, not measured TPU utilization.",
        ],
    }


def main():
    import argparse
    import json
    from pathlib import Path

    from communication import Communication
    from workload import Workload

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "snapshot", type=Path, help="Original program JSON captured by the plugin"
    )
    parser.add_argument("--devices", type=int, required=True)
    parser.add_argument(
        "--scenario",
        type=Path,
        default=(Path(__file__).resolve().parents[1] / "configs/replay_scenario.json"),
    )
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    if args.devices < 1:
        parser.error("--devices must be positive")
    scenario = json.loads(args.scenario.read_text())
    snapshot = json.loads(args.snapshot.read_text())
    model = Workload(
        snapshot,
        range(args.devices),
        scenario,
        Communication(scenario["communication"]),
    )
    report = summarize_device_load(model.lower())
    report.update(
        {
            "program": snapshot["hlo"].get("name"),
            "program_invocations": 1,
            "scenario": scenario,
            "program_cost_gaps": model.gaps,
        }
    )
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
