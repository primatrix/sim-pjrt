"""Read measured device events and retain one coherent invocation for replay."""

import hashlib
import re


TRACKS = ("XLA Modules", "XLA Ops", "Async XLA Ops", "XLA TraceMe")


def read_xplane(path):
    # Trace Viewer's converter caps large captures for browser rendering. Import
    # the original events instead; metadata strings remain shared in memory.
    from sim_pjrt.profiling.xplane_pb2 import XSpace

    data = path.read_bytes()
    space = XSpace.FromString(data)
    if space.errors:
        raise ValueError("XProf capture errors: " + "; ".join(space.errors))
    trace = {"traceEvents": [], "capture_key": hashlib.sha256(data).hexdigest(),
             "capture_warnings": list(space.warnings)}
    planes = [p for p in space.planes if re.fullmatch(r"/device:TPU:\d+", p.name)]
    epoch = min((line.timestamp_ns for p in planes for line in p.lines), default=0)
    wanted = {"program_id", "run_id", "queue_id", "replica_id", "hlo_category",
              "tf_op", "source", "source_stack", "model_flops", "bytes_accessed",
              "raw_bytes_accessed", "clock_domain"}
    for plane in planes:
        def stats(values):
            result = {}
            for stat in values:
                name = plane.stat_metadata[stat.metadata_id].name
                kind = stat.WhichOneof("value")
                if name in wanted and kind:
                    result[name] = (plane.stat_metadata[stat.ref_value].name
                                    if kind == "ref_value" else getattr(stat, kind))
            return result

        metadata = {key: (m.display_name or m.name, dict(stats(m.stats), long_name=m.name))
                    for key, m in plane.event_metadata.items()}
        events = trace["traceEvents"]
        events.append({"ph": "M", "name": "process_name", "pid": plane.id,
                       "args": {"name": plane.name}})
        for line in plane.lines:
            if line.name not in TRACKS:
                continue
            events.append({"ph": "M", "name": "thread_name", "pid": plane.id,
                           "tid": line.id, "args": {"name": line.name}})
            for event in line.events:
                if event.WhichOneof("data") != "offset_ps":
                    continue
                name, args = metadata[event.metadata_id]
                events.append({"ph": "X", "name": name, "pid": plane.id, "tid": line.id,
                               "ts": (line.timestamp_ns - epoch) / 1000 + event.offset_ps / 1e6,
                               "dur": event.duration_ps / 1e6,
                               "args": args | stats(event.stats)})
    return trace


def attach_timelines(executables, attributed):
    """Choose a real invocation nearest the median, never mix per-op medians."""
    selected = {}
    for key, record in executables.items():
        invocation = min((s for s in record["invocations"] if s["retained"]),
                         key=lambda s: abs(s["duration_ns"] - record["median_ns"]))
        members = {(s["program_key"], s["invocation"]): s for s in record["observations"]}
        group = [members[tuple(ref)] for ref in invocation["observations"]]
        group.sort(key=lambda s: int(s["device"].rsplit(":", 1)[1]))
        timeline = []
        record["replay_timeline"] = {"timestamp_us": invocation["timestamp_us"],
                                     "duration_ns": invocation["duration_ns"],
                                     "activity_timeline": timeline}
        for index, sample in enumerate(group):
            start = round((sample["timestamp_us"] - invocation["timestamp_us"]) * 1000)
            timeline.append({"name": record["name"], "track": "XLA Modules",
                             "device_index": index, "start_ns": start,
                             "end_ns": min(invocation["duration_ns"], start + sample["duration_ns"]),
                             "bytes": -1, "detail": "tpu_replay", "cost_gap": ""})
            selected[sample["program_key"], sample["invocation"]] = (
                record, index, invocation["timestamp_us"])
    for event, _, program, invocation, track in attributed:
        match = selected.get((program, invocation))
        if match is None:
            continue
        record, index, origin = match
        args = event.get("args", {})
        end = record["replay_timeline"]["duration_ns"]
        activity = {"name": event["name"], "track": track, "device_index": index,
                    "start_ns": max(0, round((event["ts"] - origin) * 1000)),
                    "end_ns": min(end, round((event["ts"] + event["dur"] - origin) * 1000)),
                    "bytes": -1, "detail": "tpu_replay", "cost_gap": ""}
        for target, source in (("hlo_text", "long_name"), ("tf_op", "tf_op"),
                               ("source", "source"), ("source_stack", "source_stack")):
            if args.get(source):
                activity[target] = args[source]
        record["replay_timeline"]["activity_timeline"].append(activity)
    for record in executables.values():
        timeline = record["replay_timeline"]["activity_timeline"]
        modules = {e["device_index"] for e in timeline if e["track"] == "XLA Modules"}
        ops = {e["device_index"] for e in timeline if e["track"] == "XLA Ops"}
        if modules != ops:
            # Legacy/module-only captures still supply duration predictions.
            del record["replay_timeline"]
