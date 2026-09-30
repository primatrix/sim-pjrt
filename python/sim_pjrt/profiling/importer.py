"""Offline import of real TPU profiles, with optional HLO and replay identities.

The parser neither runs a workload nor hooks JAX compilation. Ordinary XProf
captures are sufficient for timings; missing compiler metadata stays unknown.
"""

from bisect import bisect_right
from collections import defaultdict
import gzip
import json
import math
from pathlib import Path
import re
import statistics

from sim_pjrt.profiling.hlo import expression_metadata, fingerprint, parse_hlo, read_hlo, shape_size
from sim_pjrt.prediction import SCHEMA_VERSION


def load_profile(path):
    """Return Trace Viewer events and, when available, their original XPlane."""
    path = Path(path)
    if path.is_file() and path.name.endswith((".json", ".json.gz")):
        text = gzip.decompress(path.read_bytes()) if path.suffix == ".gz" else path.read_bytes()
        trace = json.loads(text)
        if not isinstance(trace, dict) or not isinstance(trace.get("traceEvents"), list):
            raise ValueError("Expected Trace Viewer JSON with traceEvents")
        return trace, None
    paths = [path] if path.name.endswith(".xplane.pb") else sorted(path.rglob("*.xplane.pb"))
    if len(paths) != 1 or not paths[0].is_file():
        raise ValueError("Select one capture containing one process .xplane.pb file")
    try:
        from xprof.convert.raw_to_tool_data import xspace_to_tool_data
    except ImportError as error:
        raise ValueError("XPlane conversion requires sim-pjrt[collect]") from error
    data, content_type = xspace_to_tool_data(
        [str(paths[0])], "trace_viewer", {"use_saved_result": False})
    if content_type != "application/json" or data is None:
        raise ValueError("XProf did not return Trace Viewer JSON")
    return json.loads(data), paths[0]


def event_program(event):
    name = event.get("name", "")
    match = re.search(r"\((\d+)\)$", name)
    program = event.get("args", {}).get("program_id")
    return (name[:match.start()] if match else name,
            str(program) if program is not None else match[1] if match else None)


def real_events(trace):
    processes, tracks = {}, {}
    for event in trace.get("traceEvents", []):
        if event.get("ph") == "M":
            if event.get("name") == "process_name":
                processes[event["pid"]] = event.get("args", {}).get("name", "")
            elif event.get("name") == "thread_name":
                tracks[event["pid"], event["tid"]] = event.get("args", {}).get("name", "")
    events = []
    for event in trace.get("traceEvents", []):
        device = processes.get(event.get("pid"), "")
        track = tracks.get((event.get("pid"), event.get("tid")))
        if (event.get("ph") != "X" or "TPU" not in device or "Sparse" in device
                or track not in ("XLA Modules", "XLA Ops")
                or event.get("args", {}).get("clock_domain") in ("simulated", "cpu_wall")):
            continue
        if any(type(event.get(k)) not in (int, float) or not math.isfinite(event[k])
               for k in ("ts", "dur")) or event["dur"] <= 0:
            continue
        events.append((event, device, track))
    return events


def statistics_ns(samples):
    return {"samples_ns": samples, "sample_count": len(samples),
            "median_ns": statistics.median(samples) if samples else None,
            "min_ns": min(samples) if samples else None,
            "max_ns": max(samples) if samples else None}


def operation_kind(opcode):
    if any(word in opcode for word in (
            "all-reduce", "all-gather", "reduce-scatter", "all-to-all",
            "collective-permute", "collective-broadcast", "ragged-all-to-all")):
        return "collective"
    if opcode in ("send", "send-done", "recv", "recv-done"):
        return "communication"
    if opcode.startswith(("copy", "infeed", "outfeed")):
        return "transfer"
    return "compute"


def operation_metadata(event, hlo):
    args = event.get("args", {})
    name = event.get("name", "")
    expression = args.get("long_name") or args.get("hlo_text")
    record = {"name": name, "opcode": args.get("hlo_category", name),
              "input_shapes": None, "output_shape": None, "attributes": {},
              "shape_source": None, "structure_complete": False}
    if isinstance(expression, str):
        try:
            record.update(expression_metadata(expression))
        except ValueError:
            record["hlo_text"] = expression
    if hlo:
        instruction = hlo["operations"].get(record["name"])
        if instruction:
            record.update(instruction)
    record["kind"] = operation_kind(record["opcode"])
    if record["opcode"].startswith(("call-", "async-")):
        contained = {operation_kind(opcode) for opcode in record.get("contained_opcodes", [])}
        if "collective" in contained:
            record["kind"] = "collective"
        elif "communication" in contained:
            record["kind"] = "communication"
    # Keep compiler statistics distinct from bytes transmitted on the network.
    record["compiler_metrics"] = {key: args[key] for key in (
        "model_flops", "bytes_accessed", "raw_bytes_accessed") if key in args}
    record["framework_op"] = args.get("tf_op")
    record["features"] = {
        "inputs": [shape_size(s) for s in record["input_shapes"]] if record["input_shapes"] is not None else None,
        "output": shape_size(record["output_shape"]), "size_kind": "logical_unpadded"}
    attrs = record["attributes"]
    if record["kind"] in ("communication", "collective"):
        nested = record.get("contained_communication", [])
        if not any(k in attrs for k in ("replica_groups", "source_target_pairs")) and len(nested) == 1:
            attrs = nested[0]["attributes"]
            record["communication_source"] = "called_computation"
        record["communication"] = {
            key: attrs.get(key) for key in ("replica_groups", "channel_id",
                                          "source_target_pairs", "use_global_device_ids")}
        record["communication"]["wire_bytes"] = None
        groups = attrs.get("replica_groups", "")
        if re.fullmatch(r"\{(?:\{[\d, ]+\},?)+\}", groups):
            sizes = [len(part.split(",")) for part in re.findall(r"\{([\d, ]+)\}", groups)]
            record["communication"]["replica_group_count"] = len(sizes)
            record["communication"]["participants_per_group"] = sorted(set(sizes))
        elif match := re.match(r"\[(\d+),(\d+)\]<=", groups):
            record["communication"]["replica_group_count"] = int(match[1])
            record["communication"]["participants_per_group"] = [int(match[2])]
        elif match := re.fullmatch(r"mesh\[(.*?)\]\s*\{(.*?)\}", groups):
            axes = {name: int(size) for name, size in re.findall(r"'([^']+)'\s*=\s*(\d+)", match[1])}
            selected = re.findall(r"'([^']+)'", match[2])
            if selected and all(name in axes for name in selected):
                participants = math.prod(axes[name] for name in selected)
                record["communication"]["replica_group_count"] = math.prod(axes.values()) // participants
                record["communication"]["participants_per_group"] = [participants]
    if record["opcode"].endswith(("-start", "-update", "-done")):
        record["async_phase"] = record["opcode"].rsplit("-", 1)[1]
    return record


def compatible_hlo(hlo, expressions):
    """Disambiguate same-name dumps using observed instruction signatures.

    This only enriches a capture with static metadata; it is not a cross-run
    replay identity or proof that two programs compute the same function.
    """
    matched = 0
    for expression in expressions:
        try:
            observed = expression_metadata(expression)
        except ValueError:
            continue
        candidate = hlo["operations"].get(observed["name"])
        if candidate is None:
            return False
        def normalized_opcode(opcode):
            return "async-" + opcode[5:] if opcode.startswith("call-") else opcode
        if normalized_opcode(candidate["opcode"]) != normalized_opcode(observed["opcode"]):
            return False
        for field in ("input_shapes", "output_shape"):
            if candidate.get(field) != observed.get(field):
                return False
        # XProf omits some compiler attributes, notably backend_config. Every
        # attribute it does expose must agree; omitted values are not evidence.
        ignored = {"calls", "to_apply"} if normalized_opcode(observed["opcode"]).startswith("async-") else set()
        if any(candidate["attributes"].get(k) != v for k, v in observed["attributes"].items()
               if k not in ignored):
            return False
        matched += 1
    return matched > 0


def load_hlo_catalog(paths, records=None):
    catalog, errors = [], []
    for path in paths:
        path = Path(path)
        files = ([path] if path.is_file() else sorted(
            p for p in path.rglob("*") if p.suffix in (".txt", ".hlo", ".pb")))
        if not files:
            raise ValueError(f"No HLO files at {path}")
        for file in files:
            try:
                if file.suffix != ".pb" and not file.read_text().lstrip().startswith("HloModule"):
                    continue
                catalog.append(read_hlo(file))
            except Exception as error:
                errors.append({"source": str(file), "reason": str(error)})
    for record in (records or {}).values():
        for module in record.get("modules", []):
            if module.get("hlo_text"):
                try:
                    catalog.append(parse_hlo(module["hlo_text"], source="compile_identity"))
                except Exception as error:
                    errors.append({"source": module.get("name"), "reason": str(error)})
    return catalog, errors


def embedded_hlo(xplane, modules):
    """Use the same HLO materialization path as XProf's Graph Viewer UI."""
    if xplane is None:
        return [], []
    from xprof.convert.raw_to_tool_data import xspace_to_tool_data, xspace_to_tool_names
    result, errors = [], []
    try:
        # Trace conversion alone does not create the Graph Viewer sidecars.
        xspace_to_tool_names([str(xplane)])
    except Exception as error:
        return [], [{"source": "xprof_embedded_hlo", "reason": str(error)}]
    names = {name for name, _ in modules}
    paths = sorted(xplane.parent.glob("*.hlo_proto.pb"))
    if not paths:
        return [], [{"source": "xprof_embedded_hlo", "reason": "No embedded HLO modules available"}]
    for path in paths:
        name = path.name.removesuffix(".hlo_proto.pb")
        module_name = re.sub(r"\(\d+\)$", "", name)
        if module_name not in names:
            continue
        try:
            data, _ = xspace_to_tool_data([str(xplane)], "graph_viewer", {
                "use_saved_result": False,
                "graph_viewer_options": {"type": "long_txt", "module_name": name}})
            if isinstance(data, bytes):
                data = data.decode()
            if not data or not data.lstrip().startswith("HloModule"):
                raise ValueError("No embedded HLO module")
            metadata = parse_hlo(data, source="xprof_embedded_hlo:" + name)
            # Filename IDs are XProf module IDs, not TPU runtime fingerprints.
            # Match using module names and observed instruction signatures.
            result.append(metadata)
        except Exception as error:
            errors.append({"source": "xprof_embedded_hlo", "module": name,
                           "reason": str(error)})
    return result, errors


def attribute_operations(events, programs, lanes):
    """Bind each operation to one containing invocation on the same device lane."""
    unmatched = []
    lane_index = {}
    for pid, intervals in lanes.items():
        maximum, ends = -math.inf, []
        for _, end, _, _ in intervals:
            maximum = max(maximum, end)
            ends.append(maximum)
        lane_index[pid] = ([span[0] for span in intervals], ends)
    attributed = []
    for event, device, track in events:
        if track != "XLA Ops":
            continue
        intervals = lanes[event["pid"]]
        starts, ends = lane_index.get(event["pid"], ([], []))
        begin, end = event["ts"], event["ts"] + event["dur"]
        index = bisect_right(starts, begin + .001) - 1
        candidates = []
        while index >= 0 and ends[index] + .001 >= end:
            start, stop, key, invocation = intervals[index]
            args = event.get("args", {})
            explicit_id = args.get("program_id")
            runtime = programs[key]["observations"][invocation]["runtime"]
            if (start <= begin + .001 and stop + .001 >= end
                    and (explicit_id is None or str(explicit_id) == programs[key]["program_id"])
                    and all(k not in args or k not in runtime or str(args[k]) == str(runtime[k])
                            for k in ("queue_id", "run_id", "replica_id"))):
                candidates.append((key, invocation))
            index -= 1
        if len(candidates) != 1:
            unmatched.append({"track": track, "name": event.get("name"), "device": device,
                              "timestamp_us": begin,
                              "reason": "No unique containing executable invocation"})
            continue
        key, invocation = candidates[0]
        attributed.append((event, device, key, invocation))
    return attributed, unmatched


def match_hlo(programs, attributed, hlo_catalog):
    """Prefer runtime identity; use observed signatures to disambiguate names."""
    catalog, expressions, selected = defaultdict(dict), defaultdict(set), {}
    for hlo in hlo_catalog:
        catalog[hlo["name"]][hlo["hlo_fingerprint"]] = hlo
    for event, _, key, _ in attributed:
        text = event.get("args", {}).get("long_name")
        if text:
            expressions[key].add(text)
    for key, program in programs.items():
        program_id = program["program_id"]
        exact = {h["hlo_fingerprint"]: h for h in hlo_catalog
                 if program_id is not None and h.get("runtime_program_id") == program_id}
        candidates = exact or catalog.get(program["name"], {})
        if len(candidates) == 1:
            hlo = next(iter(candidates.values()))
            if not expressions[key] or compatible_hlo(hlo, expressions[key]):
                selected[key] = hlo
                program["hlo_fingerprint"] = hlo["hlo_fingerprint"]
                continue
            program["hlo_match_error"] = "HLO contradicts observed operation signatures; metadata not applied"
        elif candidates:
            program["hlo_match_error"] = "Ambiguous HLO module name; metadata not guessed"
        candidates = [h for h in catalog.get(program["name"], {}).values()
                      if compatible_hlo(h, expressions[key])]
        # XProf strips some compiler details. Prefer its own capture metadata
        # when otherwise compatible sources have different text fingerprints.
        embedded = [h for h in candidates if h["source"].startswith("xprof_embedded_hlo:")]
        candidates = embedded or candidates
        if len(candidates) == 1:
            selected[key] = candidates[0]
            program["hlo_fingerprint"] = candidates[0]["hlo_fingerprint"]
            program["hlo_match_method"] = "module_name_and_observed_signatures"
            program.pop("hlo_match_error", None)
    return selected


def build_database(trace, records=None, *, skip_first=1, hlo_catalog=(), context=None):
    if type(skip_first) is not int or skip_first < 0:
        raise ValueError("skip_first must be a nonnegative integer")
    records = records or {}
    events = real_events(trace)
    # Capture-local IDs are never presented as stable cross-run replay keys.
    capture_key = fingerprint(trace)
    programs, lanes = {}, defaultdict(list)
    for event, device, track in sorted(events, key=lambda item: item[0]["ts"]):
        if track != "XLA Modules":
            continue
        name, program_id = event_program(event)
        key = fingerprint([capture_key, program_id, name])
        if key not in programs:
            programs[key] = {"name": name, "program_id": program_id,
                             "identity_scope": "capture", "context": context or {},
                             "observations": [], "devices": {}, "operations": {}}
        program = programs[key]
        invocation = len(program["observations"])
        observation = {"device": device, "pid": event["pid"], "timestamp_us": event["ts"],
                       "duration_ns": math.ceil(event["dur"] * 1000), "invocation": invocation,
                       "runtime": {k: v for k, v in event.get("args", {}).items()
                                   if k in ("run_id", "queue_id", "replica_id", "program_id")}}
        program["observations"].append(observation)
        lanes[event["pid"]].append((event["ts"], event["ts"] + event["dur"], key, invocation))
    for program in programs.values():
        grouped = defaultdict(list)
        for observation in program["observations"]:
            grouped[observation["device"]].append(observation)
        for device, observations in grouped.items():
            for index, observation in enumerate(observations):
                observation["retained"] = index >= skip_first
            program["devices"][device] = statistics_ns(
                [s["duration_ns"] for s in observations if s["retained"]])
    attributed, unmatched = attribute_operations(events, programs, lanes)
    selected_hlo = match_hlo(programs, attributed, hlo_catalog)
    for event, device, key, invocation in attributed:
        begin = event["ts"]
        program = programs[key]
        metadata = operation_metadata(event, selected_hlo.get(key))
        op_key = fingerprint([metadata["name"], metadata.get("hlo_text")])
        operation = program["operations"].setdefault(op_key, dict(metadata, observations=[], devices={}))
        parent = program["observations"][invocation]
        operation["observations"].append({
            "device": device, "invocation": invocation, "timestamp_us": begin,
            "offset_ns": round((begin - parent["timestamp_us"]) * 1000),
            "duration_ns": math.ceil(event["dur"] * 1000), "retained": parent["retained"]})
    for program in programs.values():
        names = defaultdict(list)
        for op_key, operation in program["operations"].items():
            names[operation["name"]].append(op_key)
        program["async_dependencies"] = []
        for operation in program["operations"].values():
            for device in {s["device"] for s in operation["observations"]}:
                operation["devices"][device] = statistics_ns([
                    s["duration_ns"] for s in operation["observations"]
                    if s["device"] == device and s["retained"]])
        for op_key, operation in program["operations"].items():
            if operation.get("async_phase") not in ("update", "done"):
                continue
            for name in operation.get("input_names", []):
                targets = names.get(name, [])
                if len(targets) == 1:
                    start_key = targets[0]
                    if program["operations"][start_key].get("async_phase") in ("start", "update"):
                        if "communication" in operation:
                            for attr, value in program["operations"][start_key].get("communication", {}).items():
                                if operation["communication"].get(attr) is None:
                                    operation["communication"][attr] = value
                            operation["communication"]["parameters_from_start"] = True
                        program["async_dependencies"].append({
                            "start_operation_key": start_key, "done_operation_key": op_key,
                            "source": "hlo_operand", "invocation_pairing": "not_inferred"})
    executables, excluded, binding_errors = bind_identities(programs, records)
    groups = aggregate_operations(programs, capture_key)
    return {"schema_version": SCHEMA_VERSION, "measurement": "tpu_xprof_module_duration",
            "operation_measurement": "tpu_xprof_operation_duration",
            "capture_key": capture_key, "programs": programs, "executables": executables,
            "operation_groups": groups, "excluded": excluded,
            "unmatched_events": unmatched + binding_errors,
            "hlo_modules": {h["hlo_fingerprint"]: h for h in selected_hlo.values()},
            "limitations": ["Program IDs are capture-local; exact replay requires compile identities",
                            "Per-device observations; multi-device invocation alignment is not inferred",
                            "Operation spans can overlap or nest; do not sum them into module latency",
                            "Async start/done spans are separate, not a measured end-to-end communication time",
                            "Missing shapes, communication parameters, and computation bodies remain unknown",
                            "Runtime values and data-dependent execution paths are not keyed",
                            "Operation groups are fitting inputs, not fitted predictors or extrapolation guarantees"]}


def bind_identities(programs, records):
    """Optional bridge into the existing exact StableHLO replay predictor."""
    by_id, by_name = defaultdict(set), defaultdict(set)
    for key, record in records.items():
        for module in record["modules"]:
            by_id[str(module["program_id"])].add(key)
            by_name[module["name"]].add(key)
    observations, sources, errors = defaultdict(list), defaultdict(list), []
    for program_key, program in programs.items():
        if not records:
            continue
        name, program_id = program["name"], program["program_id"]
        if "__spjrt_" in name:
            candidates = by_name.get(name, set())
        else:
            candidates = by_id.get(program_id, set()) if program_id is not None else by_name.get(name, set())
        if len(candidates) != 1:
            errors.append({"track": "XLA Modules", "name": name, "program_id": program_id,
                           "reason": "unmatched or ambiguous executable"})
            continue
        key = next(iter(candidates))
        observations[key].extend(program["observations"])
        sources[key].append(program_key)
        program["execution_key"] = key
        if not program["context"] and records[key].get("context"):
            program["context"] = records[key]["context"]
    executables, excluded = {}, {}
    for key, record in records.items():
        samples = sorted(observations[key], key=lambda s: s["timestamp_us"])
        if (record.get("num_replicas", 1) * record.get("num_partitions", 1) != 1
                or len({s["device"] for s in samples}) > 1):
            excluded[key] = "Multi-device execution requires invocation alignment (not supported yet)"
            continue
        retained = [s["duration_ns"] for s in samples if s["retained"]]
        if not retained:
            excluded[key] = "No device samples after warmup exclusion"
            continue
        executables[key] = dict(record, observations=samples, program_keys=sources[key],
                               skipped_samples=sum(not s["retained"] for s in samples),
                               **statistics_ns(retained))
    return executables, excluded, errors


def aggregate_operations(programs, capture_key):
    """Keep dtype, compiler target, layout, and communication attributes separate.

    Shape dimensions are features; incomplete computation bodies never get a
    cross-shape family identity merely because their display names agree.
    """
    groups = {}
    for program_key, program in programs.items():
        context = program.get("context") or {"capture_scope": capture_key}
        for op_key, operation in program["operations"].items():
            if not operation.get("structure_complete"):
                continue
            group_key = fingerprint([operation["structure_key"], operation["dtype_key"], context])
            group = groups.setdefault(group_key, {
                "kind": operation["kind"], "opcode": operation["opcode"],
                "structure_key": operation["structure_key"], "dtype_key": operation["dtype_key"],
                "context": context, "points": []})
            for device, stats in operation["devices"].items():
                group["points"].append({"program_key": program_key, "operation_key": op_key,
                                        "device": device, "input_shapes": operation["input_shapes"],
                                        "output_shape": operation["output_shape"],
                                        "implementation_key": operation.get("implementation_key"),
                                        "backend_config": operation["attributes"].get("backend_config"),
                                        "features": operation["features"], **stats})
    return groups


def import_profile(profile, output, *, hlo=(), identities=None, context=None, skip_first=1):
    output = Path(output)
    if output.exists():
        raise ValueError(f"Output already exists: {output}")
    records = json.loads(Path(identities).read_text()) if identities else {}
    if not isinstance(records, dict):
        raise ValueError("Expected compile identity mapping")
    if isinstance(context, (str, Path)):
        context = json.loads(Path(context).read_text())
    if context is not None and not isinstance(context, dict):
        raise ValueError("Expected a context JSON object")
    trace, xplane = load_profile(profile)
    catalog, errors = load_hlo_catalog(hlo, records)
    # Prefer profile-owned metadata over matching external module names.
    embedded, embedded_errors = embedded_hlo(
        xplane, {event_program(e) for e, _, track in real_events(trace) if track == "XLA Modules"})
    database = build_database(trace, records, skip_first=skip_first,
                              hlo_catalog=[*embedded, *catalog], context=context)
    database["metadata_errors"] = errors + embedded_errors
    database["source"] = str(Path(profile).resolve())
    if not database["programs"]:
        raise ValueError("No real TPU XLA Modules intervals found in this profile")
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open("x") as stream:
        json.dump(database, stream, indent=2)
        stream.write("\n")
    count = sum(len(p["operations"]) for p in database["programs"].values())
    print(f"sim-pjrt: imported {len(database['programs'])} programs, {count} operations, "
          f"{len(database['executables'])} replay identities into {output}")
    return database
