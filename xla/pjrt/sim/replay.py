"""Replay a captured PJRT workload under an explicit, uncalibrated timing scenario."""

import argparse
import json
import math
from collections import Counter, defaultdict
from dataclasses import replace
from pathlib import Path

from communication import Communication
from device_load import summarize_device_load
from profile_report import load_trace, simulator_events
from virtual_clock import Event, simulate, summarize, trace_viewer
from workload import Workload
from xprof_export import DEFAULT_DESCRIPTOR, export_xprof

OPERATIONS = {
    "PJRT Execute submit",
    "PJRT H2D submit",
    "PJRT D2H submit",
    "PJRT raw D2H submit",
    "PJRT copy submit",
    "PJRT bitcast",
    "PJRT buffer external reference",
}


def buffer_ids(value):
    return tuple(str(int(id)) for id in str(value).split(",") if id)


def build_replay(
    trace, executions, snapshots, scenario, serial_dispatch=False, observed_host=False
):
    observed = simulator_events(trace)
    if not observed:
        raise ValueError("No simulator capture events")
    if any(int(e["args"].get("dropped_events", 0)) for e in observed):
        raise ValueError("Cannot replay a capture with dropped simulator events")
    if any(e["args"].get("error") for e in observed):
        raise ValueError("Cannot replay a capture with execution or transfer errors")
    communication = Communication(scenario["communication"])
    by_correlation = {}
    for row in executions:
        correlation = int(row.get("correlation_id", 0))
        if correlation:
            if correlation in by_correlation:
                raise ValueError(
                    "Duplicate execution correlation; use one process capture"
                )
            by_correlation[correlation] = row
    device_lists = defaultdict(set)
    buffer_devices = {}
    for e in observed:
        stats = e["args"]
        if e["name"] == "Execute submit-to-ready":
            device_lists[int(stats["correlation_id"])].add(int(stats["device_id"]))
        if int(stats.get("device_id", -1)) >= 0 and stats.get("buffer_id"):
            buffer_devices[str(int(stats["buffer_id"]))] = int(stats["device_id"])
    # Register ALL producers first: concurrent host calls can be timestamped
    # before their producer's wrapper has returned.
    selected = sorted(
        (e for e in observed if e["name"] in OPERATIONS),
        key=lambda e: (e["ts"], int(e["args"]["correlation_id"])),
    )
    producers = {}
    for e in selected:
        stats = e["args"]
        prefix = f"api:{int(stats['correlation_id'])}"
        outputs = buffer_ids(stats.get("output_buffers", ""))
        devices = sorted(device_lists[int(stats["correlation_id"])])
        if e["name"] == "PJRT Execute submit":
            if not devices or len(outputs) % len(devices):
                raise ValueError("Incomplete execution device/output capture")
            per_device = len(outputs) // len(devices)
            for index, buffer in enumerate(outputs):
                device = devices[index // per_device]
                producers[buffer] = f"{prefix}/done:{device}"
                buffer_devices[buffer] = device
        else:
            for buffer in outputs:
                producers[buffer] = prefix + "/ready"
    events = []
    last_host = {}
    last_device = {}
    previous_execution = None
    external = set()
    missing = Counter()
    gaps = {}
    templates = {}
    collective_count = 0
    execution_count = 0
    incomplete = 0
    for e in selected:
        stats = e["args"]
        if stats.get("error") or int(stats.get("incomplete", 0)):
            raise ValueError(f"Cannot replay failed/incomplete submission: {e['name']}")
        correlation = int(stats["correlation_id"])
        prefix = f"api:{correlation}"
        host = prefix + "/host"
        thread = f"host-thread:{e['pid']}:{e['tid']}"
        inputs = buffer_ids(stats.get("input_buffers", ""))
        if not inputs and e["name"] in (
            "PJRT D2H submit",
            "PJRT raw D2H submit",
            "PJRT buffer external reference",
        ):
            inputs = buffer_ids(stats.get("buffer_id", ""))
        input_deps = []
        for buffer in inputs:
            if buffer in producers:
                input_deps.append(producers[buffer])
            else:
                external.add(buffer)
        input_deps = tuple(dict.fromkeys(input_deps))
        host_deps = (last_host[thread],) if thread in last_host else ()
        if (
            serial_dispatch
            and previous_execution
            and e["name"] == "PJRT Execute submit"
        ):
            host_deps += (previous_execution,)
        if e["name"] == "PJRT buffer external reference":
            # CPU direct reads stand in for host-visible access barriers only.
            host_deps += input_deps
            missing["external reference has no modeled TPU D2H cost"] += 1
        events.append(
            Event(
                host,
                e["name"],
                scenario["host_submit_ns"],
                host_deps,
                (thread,),
                release_ns=round(e["ts"] * 1000) if observed_host else 0,
                metadata={
                    "correlation_id": correlation,
                    "executable_name": stats.get("detail", ""),
                },
            )
        )
        last_host[thread] = host
        deps = (host,) + input_deps
        name = e["name"]
        if name == "PJRT Execute submit":
            row = by_correlation.get(correlation)
            if row is None:
                raise ValueError(
                    f"Missing execution record for correlation {correlation}"
                )
            devices = tuple(sorted(device_lists[correlation]))
            if len(devices) != row["num_devices"]:
                raise ValueError("Incomplete per-device execution observations")
            if row.get("num_replicas", 1) != 1:
                raise ValueError("Replay currently supports one-replica SPMD programs")
            program = row["program_id"]
            key = (program, devices)
            if key not in templates:
                model = Workload(snapshots[program], devices, scenario, communication)
                templates[key] = model.lower(), model.gaps, model.inferred_collectives
            template, program_gaps, count = templates[key]
            identity = {
                "program_id": program,
                "correlation_id": correlation,
                "executable_name": row.get(
                    "name", snapshots[program]["hlo"].get("name", "program")
                ),
                "has_cost_gaps": bool(program_gaps),
            }
            gaps[str(program)] = program_gaps
            collective_count += count
            execution_count += 1
            incomplete += bool(program_gaps)
            for device in devices:
                start_deps = deps + (
                    (last_device[device],) if device in last_device else ()
                )
                events.append(
                    Event(
                        f"{prefix}/start:{device}",
                        "device launch",
                        scenario["launch_ns"],
                        start_deps,
                        (f"compute:{device}",),
                        metadata={
                            **identity,
                            "device": device,
                            "execution_boundary": "start",
                        },
                    )
                )
                last_device[device] = f"{prefix}/done:{device}"
            for event in template:
                events.append(
                    replace(
                        event,
                        id=f"{prefix}/{event.id}",
                        dependencies=tuple(f"{prefix}/{d}" for d in event.dependencies),
                        metadata={
                            **event.metadata,
                            **identity,
                        },
                    )
                )
            previous_execution = prefix + "/ready"
            events.append(
                Event(
                    previous_execution,
                    "execute complete",
                    dependencies=tuple(last_device[d] for d in devices),
                )
            )
        elif name in ("PJRT H2D submit", "PJRT D2H submit", "PJRT raw D2H submit"):
            size = int(stats.get("bytes", -1))
            device = int(stats.get("device_id", -1))
            if size < 0 or device < 0:
                raise ValueError("Missing transfer size/device")
            direction = "h2d" if name == "PJRT H2D submit" else "d2h"
            events.append(
                communication.host_transfer(
                    prefix + "/ready", device, size, direction, deps
                )
            )
        elif name == "PJRT copy submit":
            source = buffer_devices.get(inputs[0]) if len(inputs) == 1 else None
            target = int(stats.get("device_id", -1))
            size = int(stats.get("bytes", -1))
            if source is None or target < 0 or size < 0:
                raise ValueError("Missing copy source, destination or size")
            if source == target:
                # CopyToMemory is not a bitcast: local copies still consume HBM.
                duration = math.ceil(
                    2
                    * size
                    / (
                        scenario["hbm_bytes_per_second"]
                        * scenario["bandwidth_utilization"]
                    )
                    * 1e9
                )
                events.append(
                    Event(
                        prefix + "/ready",
                        "local memory copy",
                        duration,
                        deps,
                        (f"hbm:{source}",),
                        metadata={
                            "transfer_kind": "local_copy",
                            "bytes": size,
                            "device": source,
                        },
                    )
                )
            else:
                events += communication.transfer(
                    prefix + "/ready", source, target, size, deps
                )
        else:
            events.append(Event(prefix + "/ready", name, dependencies=deps))
    missing["PJRT awaits/callbacks lack complete host causality"] = sum(
        e["name"] == "PJRT Event await" for e in observed
    )
    return events, {
        "schema_version": 1,
        "calibrated": False,
        "complete_latency_prediction": False,
        "prediction_scope": "fixed captured PJRT submissions with partial HLO costs",
        "dispatch_policy": "serial" if serial_dispatch else "asynchronous",
        "executions": execution_count,
        "incomplete_cpu_observations": sum(
            int(e["args"].get("incomplete", 0)) for e in observed
        ),
        "executions_with_cost_gaps": incomplete,
        "inferred_all_reduces": collective_count,
        "program_cost_gaps": gaps,
        "buffers_assumed_ready_at_capture_start": sorted(external),
        "host_model_gaps": dict(missing),
        "scenario": scenario,
        "limitations": [
            "Unknown costs are zero-duration dependency nodes; partial makespan is not a latency estimate.",
            "Captured batches and host thread ordering are fixed; scheduler decisions are not replayed online.",
            "Input buffers conservatively gate the whole execution; outputs become ready at program completion.",
            "Serial comparison changes dispatch barriers on the same capture, not SGLang's scheduler implementation.",
            "No TPU compiler schedule, fusion, vector throughput, collective reduction or Pallas attention timing.",
            "CPU waits, wall-clock gaps and compilation times are not virtual durations.",
        ],
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "profile", type=Path, help="XProf capture directory or converted trace JSON"
    )
    parser.add_argument(
        "executions",
        type=Path,
        help="One process's execution JSONL; adjacent program snapshots required",
    )
    parser.add_argument(
        "--scenario",
        type=Path,
        default=Path(__file__).with_name("replay_scenario.json"),
    )
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--serial-dispatch", action="store_true")
    parser.add_argument("--xspace-descriptor", type=Path, default=DEFAULT_DESCRIPTOR)
    args = parser.parse_args()
    trace = (
        load_trace(args.profile)
        if args.profile.is_dir()
        else json.loads(args.profile.read_text())
    )
    executions = [json.loads(line) for line in args.executions.read_text().splitlines()]
    stem = args.executions.with_suffix("")
    snapshots = {row["program_id"]: None for row in executions}
    for program in snapshots:
        snapshots[program] = json.loads(
            Path(f"{stem}.program{program}.json").read_text()
        )
    scenario = json.loads(args.scenario.read_text())
    events, report = build_replay(
        trace, executions, snapshots, scenario, args.serial_dispatch
    )
    schedule = simulate(events)
    report.update(summarize(schedule))
    report["device_load"] = summarize_device_load(events)
    xprof_path = export_xprof(schedule, args.output / "xprof", args.xspace_descriptor)
    report["xprof_file"] = str(xprof_path.relative_to(args.output))
    # Name the partial quantity explicitly, including when every represented
    # instruction happens to be supported: compiler and host models still have gaps.
    report["partial_makespan_ns"] = report.pop("makespan_ns")
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / "report.json").write_text(json.dumps(report, indent=2) + "\n")
    (args.output / "timeline.json").write_text(
        json.dumps(trace_viewer(schedule)) + "\n"
    )
    print(
        f"{len(schedule)} virtual events; {report['inferred_all_reduces']} inferred all-reduces; "
        f"{report['executions_with_cost_gaps']}/{report['executions']} executions have cost gaps"
    )
    print(f"Simulated XProf: {xprof_path}")


if __name__ == "__main__":
    main()
