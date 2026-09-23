"""Pure parsing and scenario-based timing of libtpu final bundles/assembly.

Dump addresses are identifiers, not timestamps. Hardware timing is supplied by
an explicit profile. Missing semantics produce gaps, never an asserted latency.
Final LLO manifests expand kernel calls at their TLP call sites.
"""

import argparse
from collections import Counter
from copy import deepcopy
import json
import math
from pathlib import Path
import re

_HEADER = re.compile(
    r"^\s*(?:(\d+):)?(0x[\da-fA-F]+|\d+)\s*(?:LH|LB|LE|PB|PF|CT)?\s*:\s*[><=]*\s*\{",
    re.M,
)
_COMMENT = re.compile(r"/\*.*?\*/", re.S)

# These scheduled operations incur their bundle issue cost. Latency between
# dependent instructions is assumed to be represented by the compiler schedule.
_SCHEDULED = set(
    """sadd ssub smul sand sor sxor snot smov simm sld sst scmp seq
slt sge sle sgt sne sshll sshrl sshra scalar_lea scalar_select scalar_parameter_address
int_to_ptr ptr_to_int reloc set compiler-scheduling-barrier inlined_call_operand
vadd vsub vmul vdiv vmax vmin vand vor vxor vnot vmov vld vst vstv vsel vcmp veq
vlt vge vle vgt vne vlaneseq vshll vshrl vshra vsetiar vsettm vtrace vrng
vmatpush vmatmul vdwg vxpose cld por pand pxor pnot pnand vsyncpa vsyncadd""".split()
)


def parse_bundles(text):
    """Return immutable-by-convention dictionaries, stripping diagnostic comments.

    Accept multiline final_bundles and single-line assembly-pre-overlay. Reject
    malformed/truncated records and duplicate addresses instead of dropping work.
    """
    # Call targets are diagnostic annotations, but are needed before stripping.
    text = re.sub(
        r"(inlined_call\b[^;{}]*?)/\*\s*(.*?)\s*\*/",
        lambda m: m[1] + " __callee__" + (m[2].split("=", 1)[0].strip().lstrip("%")),
        text,
    )
    text = _COMMENT.sub("", text)
    if "/*" in text or "*/" in text:
        raise ValueError("unterminated or unmatched diagnostic comment")
    headers = list(_HEADER.finditer(text))
    candidates = re.findall(
        r"^\s*(?:(?:\d+):)?(?:0x[\da-fA-F]+|\d+)\s*[^\n{]*:\s*[^\n{]*\{", text, re.M
    )
    if len(candidates) != len(headers):
        raise ValueError("unsupported bundle record header; refusing to omit work")
    if not headers:
        raise ValueError("no bundle records found")
    result, seen = [], set()
    for i, match in enumerate(headers):
        segment = text[
            match.end() : headers[i + 1].start() if i + 1 < len(headers) else len(text)
        ]
        clean = segment
        if "}" not in clean:
            raise ValueError(f"unterminated bundle at {match.group(2)}")
        depth = 1
        for closing, char in enumerate(clean):
            depth += (char == "{") - (char == "}")
            if depth == 0:
                break
        if depth:
            raise ValueError(f"unterminated bundle at {match.group(2)}")
        body = clean[:closing].strip()
        address = f"{match.group(1) or '0'}:{int(match.group(2), 0) if match.group(2).startswith('0x') else int(match.group(2)):#x}"
        if address in seen:
            raise ValueError(
                f"duplicate address {address}; analyze each region separately"
            )
        seen.add(address)
        instructions = []
        for raw in re.split(r"\s*;;?\s*", body):
            if not raw:
                continue
            rhs = re.sub(r"^[%\w.-]+\s*=\s*", "", raw)
            opcode = re.match(r"[\w.-]+", rhs)
            if not opcode:
                raise ValueError(f"cannot parse instruction at {address}: {raw}")
            instruction = {"opcode": opcode.group(), "text": raw}
            if "__callee__" in raw:
                instruction["callee"] = raw.split("__callee__", 1)[1].strip()
                instruction["text"] = raw.split("__callee__", 1)[0].strip()
            instructions.append(instruction)
        result.append({"address": address, "instructions": instructions})
    return tuple(result)


def compose_final_bundles(modules, aliases=None, root="TLP", limit=1_000_000):
    """Expand reachable calls per invocation; never sum independent dump files."""
    result = []
    allocations = {}

    def visit(name, prefix, stack):
        label = name
        name = (aliases or {}).get(name, name)
        if name not in modules:
            raise ValueError(f"missing Final LLO callee: {name}")
        if name in stack:
            raise ValueError(f"recursive Final LLO call: {stack + (name,)}")
        for bundle in modules[name]:
            address = prefix + bundle["address"]
            calls = [i for i in bundle["instructions"] if i["opcode"] == "inlined_call"]
            if calls:
                if len(calls) != 1 or any(
                    i["opcode"]
                    not in {
                        "inlined_call",
                        "compiler-scheduling-barrier",
                        "inlined_call_operand",
                    }
                    for i in bundle["instructions"]
                ):
                    raise ValueError(
                        f"unsupported co-issued Final LLO call at {address}"
                    )
                if "callee" not in calls[0]:
                    raise ValueError(f"missing Final LLO call target at {address}")
                visit(calls[0]["callee"], address + "/", stack + (name,))
                continue
            item = deepcopy(bundle)
            item.update(
                address=address,
                module=name,
                kernel=label,
                callsite=prefix.rstrip("/"),
                source_address=bundle["address"],
            )
            # Allocation names are local to each invocation. Cross-call operand
            # binding is unresolved, so do not infer false DMA dependencies.
            for instruction in item["instructions"]:

                def allocation(match):
                    key = (prefix, match[0])
                    return "#allocation" + str(
                        allocations.setdefault(key, len(allocations))
                    )

                instruction["text"] = re.sub(
                    r"#allocation\d+", allocation, instruction["text"]
                )
            result.append(item)
            if len(result) > limit:
                raise ValueError("Final LLO call expansion exceeds limit")

    visit(root, "", ())
    return tuple(result)


def parse_deduplication_map(text):
    aliases = {}
    if not text.startswith("key:"):
        raise ValueError("missing libtpu deduplication map records")
    for block in text.split("key:")[1:]:
        lines = block.splitlines()
        name = lines[0].strip()
        if len(lines) < 3 or not re.fullmatch(r"ordinal:\d+", lines[1]):
            raise ValueError("malformed libtpu deduplication map")
        count = re.fullmatch(r"equivalent_hlos\[size=(\d+)\]:", lines[2])
        if not count or int(count[1]) != len(lines[3:]):
            raise ValueError("truncated libtpu deduplication map")
        for alias in lines[3:]:
            alias = alias.strip()
            if alias in aliases and aliases[alias] != name:
                raise ValueError(f"ambiguous libtpu alias: {alias}")
            aliases[alias] = name
    return aliases


def load_final_manifest(path):
    files = json.loads(path.read_text())["files"]
    modules, sources, aliases, mapping_files = {}, {}, {}, []
    for filename in files:
        file = Path(filename)
        if file.name.endswith("-deduplication-map.txt"):
            mapping_files.append(str(file.resolve()))
            aliases.update(parse_deduplication_map(file.read_text()))
            continue
        match = re.fullmatch(r"\d+-(.*)-\d+-final_bundles\.txt", file.name)
        if not match:
            raise ValueError(f"not a Final LLO bundle dump: {file}")
        name = match[1]
        if name in modules:
            raise ValueError(f"ambiguous Final LLO module: {name}")
        modules[name] = parse_bundles(file.read_text())
        sources[name] = str(file.resolve())
    if len(mapping_files) != 1:
        raise ValueError("expected one libtpu deduplication map per compile")
    return compose_final_bundles(modules, aliases), {
        "bundle_stage": "final_bundles",
        "entry_file": sources["TLP"],
        "final_bundle_files": list(sources.values()),
        "deduplication_map_files": mapping_files,
    }


def expand_path(items, limit=1_000_000):
    """Expand nested {repeat: N, body: [...]} execution blocks, preserving order."""
    result = []
    for item in items:
        if isinstance(item, str):
            block = [item]
        elif isinstance(item, dict) and set(item) == {"repeat", "body"}:
            count = item["repeat"]
            if type(count) is not int or count < 0:
                raise ValueError("repeat must be a nonnegative integer")
            body = expand_path(item["body"], limit) if count else ()
            if len(body) * count > limit - len(result):
                raise ValueError("execution path exceeds expansion limit")
            block = body * count
        else:
            raise ValueError("path entries must be addresses or repeat/body blocks")
        if len(result) + len(block) > limit:
            raise ValueError("execution path exceeds expansion limit")
        result.extend(block)
    return tuple(result)


def _number(text):
    return int(text, 0) if "x" in text.lower() else int(text)


def _positive(value, name, allow_zero=False):
    if (
        isinstance(value, bool)
        or not isinstance(value, (int, float))
        or not math.isfinite(value)
    ):
        raise ValueError(f"{name} must be a finite number")
    if value < 0 or (not allow_zero and value == 0):
        raise ValueError(f"invalid {name}: {value}")
    return value


def activity_timeline(program, events, hz, clock, finish, tail):
    """Project the same cost-model events into compact, non-additive XProf tracks.

    Kernels are compilation scopes. Unknown costs are markers, never invented
    transfer or synchronization durations.
    """
    by_address = {b["address"]: b for b in program}
    positions = {b["address"]: i for i, b in enumerate(program)}
    result, previous = [], {}
    run, last_position, last_callsite = 0, -1, None
    unresolved = set()

    def add(track, name, start, end, bundle=None, gap="", size=-1, merge=True):
        bundle = bundle or {}
        module = bundle.get("module", "")
        callsite = bundle.get("callsite", "")
        source = bundle.get("source_address", bundle.get("address", ""))
        # Compare cycles before rounding: sub-nanosecond gaps must not merge.
        key = (name, module, callsite, gap, run)
        prior = previous.get(track)
        if merge and prior and prior[0] == key and prior[1] == start:
            item = prior[2]
            item["end_ns"] = math.ceil(end / hz * 1e9)
            item["last_address"] = source
        else:
            item = dict(
                track=track, name=name,
                start_ns=math.ceil(start / hz * 1e9),
                end_ns=math.ceil(end / hz * 1e9),
                module=module, callsite=callsite,
                first_address=source, last_address=source,
                cost_gap=gap, bytes=size,
            )
            result.append(item)
        previous[track] = (key, end, item)

    # Bundle events determine scope boundaries. DMA can outlive its launch scope.
    for event in events:
        bundle = by_address[event["address"]]
        if event["kind"] == "dma":
            add("DMA / " + event["resource"], "dma." + event["direction"],
                event["start_cycle"], event["end_cycle"], bundle,
                size=event["bytes"], merge=False)
            continue
        position = positions[event["address"]]
        callsite = bundle.get("callsite", "")
        if callsite != last_callsite or position <= last_position:
            run += 1
        last_callsite, last_position = callsite, position
        start, end = event["start_cycle"], event["end_cycle"]
        add("Kernels", bundle.get("kernel", bundle.get("module", "Final LLO")),
            start, end, bundle)
        gap = "; ".join(event["cost_gaps"])
        ops = event["opcodes"]
        if end > event["issue_end_cycle"]:
            add("Wait", " | ".join(event["wait_ops"]) or "synchronization",
                event["issue_end_cycle"], end, bundle, gap)
        if event["delay_cycles"]:
            add("Delay", "vdelay", start + event["issue_cycles"],
                start + event["issue_cycles"] + event["delay_cycles"], bundle, gap)
        for op in ops:
            if op.startswith(("sbr", "sloop", "scall", "sret", "shalt")) or op in (
                "loop", "branch", "call", "return"
            ):
                add("Control", op, start, start, bundle, gap)
            if op.startswith(("send", "recv")):
                add("Communication", op, start, start, bundle, gap)
        for reason in event["cost_gaps"]:
            key = (run, reason)
            if key not in unresolved:
                unresolved.add(key)
                add("Unresolved", reason, start, start, bundle, reason)
    retired = finish - tail
    if retired > clock:
        add("Completion", "Outstanding DMA", clock, retired)
    if tail:
        add("Completion", "Completion tail", retired, finish)
    for item in result:
        item["detail"] = (
            f"module={item.pop('module')}; callsite={item.pop('callsite')}; "
            f"bundles={item.pop('first_address')}..{item.pop('last_address')}"
        )
    return result


def estimate_bundles(program, profile, scenario=None):
    """Estimate one execution scenario without mutating any input.

    scenario.path is an ordered list of addresses, including repeated loop
    iterations. scenario.inactive is a list of 'visit_index:instruction_index'
    to skip. scenario.predicates maps the same keys to boolean decisions.
    Unknown branch paths, waits, DMA operands and delay semantics remain gaps.
    """
    scenario = scenario or {}
    hz = _positive(profile["frequency_hz"], "frequency_hz")
    issue = _positive(profile.get("bundle_issue_cycles", 1), "bundle_issue_cycles")
    tail = _positive(
        profile.get("completion_tail_cycles", 0), "completion_tail_cycles", True
    )
    by_address = {b["address"]: b for b in program}
    path = expand_path(scenario.get("path", [b["address"] for b in program]))
    if not path or any(a not in by_address for a in path):
        raise ValueError("path must contain existing bundle addresses")
    inactive = set(scenario.get("inactive", []))
    valid = {
        f"{v}:{i}"
        for v, a in enumerate(path)
        for i in range(len(by_address[a]["instructions"]))
    }
    if inactive - valid:
        raise ValueError("inactive refers to nonexistent instruction visits")
    clock = stalls = extra = transferred = 0
    resources, flags, histogram, gaps, events = {}, {}, Counter(), [], []
    seen_gaps = set()
    visit_gaps = []

    def gap(address, reason):
        if reason not in visit_gaps:
            visit_gaps.append(reason)
        key = (address, reason)
        if key not in seen_gaps:
            seen_gaps.add(key)
            gaps.append({"address": address, "reason": reason})

    for visit, address in enumerate(path):
        visit_gaps = []
        opcodes, wait_ops = set(), set()
        delay_cycles = 0
        if "/" in address:
            gap(address.rsplit("/", 1)[0], "cross-call operand bindings are unresolved")
        start = clock
        end = start + issue
        bundle_extra = 0
        for index, instruction in enumerate(by_address[address]["instructions"]):
            if f"{visit}:{index}" in inactive:
                continue
            op, text = instruction["opcode"], instruction["text"]
            rhs = text.split("=", 1)[-1]
            predicated = re.search(r"@!?[pv]|\(!?%p\d|\(!?%vm\d", rhs)
            if predicated and not (
                op.startswith("shalt") and scenario.get("assume_no_faults")
            ):
                decision = scenario.get("predicates", {}).get(f"{visit}:{index}")
                if decision is None:
                    gap(address, "predicate outcome not supplied")
                elif not isinstance(decision, bool):
                    raise ValueError("predicate decisions must be booleans")
                elif not decision:
                    continue
            histogram[op] += 1
            opcodes.add(op)
            known_special = op.startswith(
                (
                    "sbr",
                    "sloop",
                    "scall",
                    "sret",
                    "shalt",
                    "dma.",
                    "vwait",
                    "sfence",
                    "cfence",
                    "barrier",
                    "send",
                    "recv",
                    "semaphore",
                )
            )
            if op == "inlined_call":
                cycles = scenario.get("call_cycles", {}).get(f"{visit}:{index}")
                if cycles is None:
                    gap(
                        address,
                        "unexpanded callee: supply call_cycles or a Final LLO manifest",
                    )
                else:
                    bundle_extra = max(
                        bundle_extra, _positive(cycles, "call_cycles", True)
                    )
            elif (
                op.split(".")[0] not in _SCHEDULED
                and not known_special
                and op != "vdelay"
            ):
                if op not in profile.get("instruction_extra_cycles", {}):
                    gap(address, f"unknown instruction {op}")
            if op.startswith(("sbr", "sloop", "scall", "sret")) or op in (
                "loop",
                "branch",
                "call",
                "return",
            ):
                if "path" not in scenario:
                    gap(address, "control flow requires an explicit executed path")
            if op.startswith("shalt") and not scenario.get("assume_no_faults"):
                gap(
                    address,
                    "conditional halt requires assume_no_faults or resolved execution",
                )
            if op == "vdelay":
                value = re.search(r"vdelay\s+\$?(0x[\da-fA-F]+|\d+)\b", text)
                mode = profile.get("vdelay_semantics")
                if not value or mode not in ("additional_cycles", "total_cycles"):
                    gap(
                        address,
                        "vdelay needs a constant operand and explicit semantics",
                    )
                else:
                    delay = _number(value.group(1))
                    delay_cycles = delay if mode == "additional_cycles" else max(0, delay - issue)
                    bundle_extra = max(
                        bundle_extra,
                        delay if mode == "additional_cycles" else max(0, delay - issue),
                    )
            if op.startswith("dma.") and op != "dma.done.wait":
                direction = op.removeprefix("dma.")
                # final_bundles carries granules and destination sync flag inline.
                match = re.search(r",\s*(\d+)\s*,.*?(\[#allocation\d+\])", text)
                config = profile.get("dma", {}).get(direction)
                if not match or not config:
                    gap(
                        address,
                        f"unmodeled DMA {direction}: need size, sync flag and profile",
                    )
                    continue
                units = int(match.group(1))
                size = units * _positive(
                    profile.get("dma_granule_bytes", 0), "dma_granule_bytes"
                )
                bandwidth = _positive(config["bytes_per_second"], "DMA bandwidth")
                latency = _positive(
                    config.get("latency_cycles", 0), "DMA latency", True
                )
                duration = latency + math.ceil(size * hz / bandwidth)
                resource = config.get("resource", direction)
                begin = max(start, resources.get(resource, 0))
                finish = begin + duration
                resources[resource] = finish
                flag = match.group(2)
                previous = flags.get(flag, (0, 0))
                flags[flag] = (previous[0] + units, max(previous[1], finish))
                transferred += size
                events.append(
                    {
                        "kind": "dma",
                        "address": address,
                        "direction": direction,
                        "resource": resource,
                        "bytes": size,
                        "start_cycle": begin,
                        "end_cycle": finish,
                    }
                )
            elif op == "dma.done.wait":
                wait_ops.add(op)
                match = re.search(r"(\[#allocation\d+\]),\s*(\d+)", text)
                pending = flags.get(match.group(1)) if match else None
                if not pending or pending[0] != int(match.group(2)):
                    gap(address, "DMA wait has unknown or partial completion credits")
                else:
                    end = max(end, pending[1])
            elif op.startswith("vsyncadd"):
                match = re.search(r"(\[#allocation\d+\]),\s*(-?\d+)", text)
                if not match:
                    gap(
                        address,
                        "sync credit update is not a constant final-bundle operand",
                    )
                if match and match.group(1) in flags:
                    units, finish = flags[match.group(1)]
                    value = int(match.group(2))
                    value = value - 2**32 if value >= 2**31 else value
                    if units + value >= 0:
                        flags[match.group(1)] = (units + value, finish)
                    else:
                        gap(address, "sync credit underflow")
            elif op.startswith(
                ("vwait", "sfence", "cfence", "barrier", "send", "recv", "semaphore")
            ):
                wait_ops.add(op)
                ready = scenario.get("wait_until_cycles", {}).get(f"{visit}:{index}")
                if ready is None:
                    gap(
                        address,
                        f"external/assembly synchronization {op} requires a completion model",
                    )
                else:
                    end = max(end, _positive(ready, "wait_until_cycles", True))
            if op in profile.get("instruction_extra_cycles", {}):
                bundle_extra = max(
                    bundle_extra,
                    _positive(profile["instruction_extra_cycles"][op], op, True),
                )
        stalls += max(0, end - (start + issue + bundle_extra))
        extra += bundle_extra
        clock = max(end, start + issue + bundle_extra)
        events.append(
            {
                "kind": "bundle",
                "address": address,
                "visit": visit,
                "start_cycle": start,
                "end_cycle": clock,
                "issue_end_cycle": start + issue + bundle_extra,
                "issue_cycles": issue,
                "delay_cycles": delay_cycles,
                "opcodes": sorted(opcodes),
                "wait_ops": sorted(wait_ops),
                "cost_gaps": visit_gaps,
            }
        )
    # Outstanding DMA must retire, but do not add already-overlapped transfers again.
    finish = max([clock, *resources.values()]) + tail
    return {
        "profile": deepcopy(profile),
        "scenario": deepcopy(scenario),
        "status": "partial" if gaps else "modeled",
        "scheduled_bundle_count": len(program),
        "modeled_bundle_visits": len(path),
        "path_source": "explicit" if "path" in scenario else "linear_scan",
        "issue_cycles": len(path) * issue,
        "wait_stall_cycles": stalls,
        "extra_instruction_cycles": extra,
        "completion_cycles": finish - clock,
        "modeled_cycles": finish,
        "modeled_seconds": finish / hz,
        "estimated_seconds": None if gaps else finish / hz,
        "dma_bytes": transferred,
        "instruction_counts": dict(sorted(histogram.items())),
        "gaps": gaps,
        "events": events,
        "activity_timeline": activity_timeline(program, events, hz, clock, finish, tail),
        "assumptions": [
            "Profile supplies issue rate and instruction timing; dump addresses are not cycles.",
            "Scheduled bundles cover internal instruction dependencies; profile supplies completion tail.",
            "DMA resources serialize transfers; execution can overlap DMA.",
            "Final LLO manifests expand reachable kernel calls per invocation.",
            "Static scenario estimate, not calibrated hardware execution time.",
        ],
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("dump", type=Path)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--scenario", type=Path)
    parser.add_argument("--output", type=Path)
    parser.add_argument(
        "--summary", action="store_true", help="Omit the per-event timeline"
    )
    args = parser.parse_args()
    if args.dump.suffix == ".json":
        program, provenance = load_final_manifest(args.dump)
    else:
        program, provenance = parse_bundles(args.dump.read_text()), {
            "entry_file": str(args.dump.resolve())
        }
    result = estimate_bundles(
        program,
        json.loads(args.profile.read_text()),
        json.loads(args.scenario.read_text()) if args.scenario else None,
    )
    result["analysis_source"] = "libtpu_bundles"
    result.update(provenance)
    if args.summary:
        result.pop("events")
    text = json.dumps(result, indent=2) + "\n"
    if args.output:
        args.output.write_text(text)
    else:
        print(text, end="")


if __name__ == "__main__":
    main()
