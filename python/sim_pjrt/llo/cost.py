"""Charge bundle issue, DMA resources and synchronization; record missing costs."""

from collections import Counter
from copy import deepcopy
import heapq
import math
import re

from .parser import dma_operands, expand_path, _number
from .mxu import matmul_throughput

_SYNC_FLAG = r"(\[#allocation\d+(?:\s*\+\s*\$0x[\da-fA-F]+)?\])"


_SCHEDULED = set(
    """sadd ssub smul sand sor sxor snot smov simm sld sst scmp seq
slt sge sle sgt sne sshll sshrl sshra sphi scalar_lea scalar_select scalar_parameter_address
int_to_ptr ptr_to_int reloc set compiler-scheduling-barrier inlined_call_operand
vadd vsub vmul vdiv vmax vmin vand vor vxor vnot vmov vld vst vstv vsel vcmp veq
vlt vge vle vgt vne vlaneseq vshll vshrl vshra vsetiar vsettm vtrace vrng
vmatpush vmatmul vdwg vxpose cld pmov por pand pxor pneg pnot pnand vsyncpa vsyncadd""".split()
)


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


class ActivityTimeline:
    """Accumulate kernel intervals while visiting bundles; no event history needed."""

    def __init__(self, hz):
        self.hz = hz
        self.items, self.previous = [], {}
        self.run, self.last_position, self.last_callsite = 0, -1, None
        self.communication = set()

    def add(self, track, name, start, end, bundle=None, gap=""):
        bundle = bundle or {}
        module, callsite = bundle.get("module", ""), bundle.get("callsite", "")
        source = bundle.get("source_address", bundle.get("address", ""))
        key = (name, module, callsite, gap, self.run)
        prior = self.previous.get(track)
        if prior and prior[0] == key and prior[1] == start:
            item = prior[2]
            item["end_ns"] = math.ceil(end / self.hz * 1e9)
            item["last_address"] = source
        else:
            item = dict(track=track, name=name,
                        start_ns=math.ceil(start / self.hz * 1e9),
                        end_ns=math.ceil(end / self.hz * 1e9),
                        module=module, callsite=callsite,
                        first_address=source, last_address=source,
                        cost_gap=gap, bytes=-1)
            self.items.append(item)
        self.previous[track] = (key, end, item)
        return item

    def visit(self, bundle, position, start, end, opcodes, gaps):
        callsite = bundle.get("callsite", "")
        if callsite != self.last_callsite or position <= self.last_position:
            self.run += 1
        self.last_callsite, self.last_position = callsite, position
        scope = self.add(
            "XLA TraceMe" if bundle.get("module") in {"TLP", "<late-initialization>", "<late-finalization>"} else "XLA Ops",
            bundle.get("kernel", bundle.get("module", "Final LLO")), start, end, bundle)
        if gaps:
            scope["cost_gap"] = "partial bundle cost coverage"
        for op in opcodes:
            key = (self.run, op)
            if op.startswith(("send", "recv")) and key not in self.communication:
                self.communication.add(key)
                self.add("XLA TraceMe", op, start, start, bundle, "; ".join(gaps))

    def finish(self, clock, finish, tail, pending_name="Outstanding DMA"):
        retired = finish - tail
        if retired > clock:
            self.add("XLA TraceMe", pending_name, clock, retired)
        if tail:
            self.add("XLA TraceMe", "Completion tail", retired, finish)
        for item in self.items:
            item["detail"] = (
                f"module={item.pop('module')}; callsite={item.pop('callsite')}; "
                f"bundles={item.pop('first_address')}..{item.pop('last_address')}"
            )
        return self.items


def estimate_bundles(program, profile, scenario=None, *, retain_events=True):
    """Estimate one execution scenario without mutating any input.

    scenario.path is an ordered list of addresses, including repeated loop
    iterations. scenario.inactive is a list of 'visit_index:instruction_index'
    to skip. scenario.predicates maps the same keys to boolean decisions.
    Unknown branch paths, waits, DMA operands and delay semantics remain gaps.
    """
    scenario = scenario or {}
    mxu_model = profile.get("mxu_model")
    if mxu_model not in (None, "gf"):
        raise ValueError(f"unsupported mxu_model: {mxu_model}")
    hz = _positive(profile["frequency_hz"], "frequency_hz")
    transaction = _positive(profile.get("dma_transaction_bytes", 1), "dma_transaction_bytes")
    if not float(transaction).is_integer():
        raise ValueError("dma_transaction_bytes must be an integer")
    issue = _positive(profile.get("bundle_issue_cycles", 1), "bundle_issue_cycles")
    tail = _positive(
        profile.get("completion_tail_cycles", 0), "completion_tail_cycles", True
    )
    if 'path' in scenario:
        by_address = {b['address']: (i, b) for i, b in enumerate(program)}
        path = expand_path(scenario['path'])
        if not path or any(a not in by_address for a in path):
            raise ValueError('path must contain existing bundle addresses')
        scheduled = sum(b.get('static_bundle_count', 1) for _, b in by_address.values())
        execution = (by_address[a] for a in path)
    else:
        scheduled = 0
        execution = enumerate(program)
    inactive = set(scenario.get("inactive", []))
    unused_inactive = set(inactive)
    clock = stalls = extra = transferred = bus_transferred = 0
    resources, flags, histogram, gaps, events = {}, {}, Counter(), [], []
    mxu_ready, mxu_stalls = {}, 0
    seen_gaps = {}
    visit_gaps = []
    visits = 0
    scalar_resolved = False
    timeline = ActivityTimeline(hz)
    frames, segments, loops = [], [], []

    def flag_state(flag, now):
        state = flags.setdefault(flag, [0, []])
        while state[1] and state[1][0][0] <= now:
            _, units = heapq.heappop(state[1])
            state[0] += units
        return state

    def gap(address, reason):
        if reason in visit_gaps:
            return
        visit_gaps.append(reason)
        if not retain_events:
            address = bundle.get('module', 'Final LLO') + '/' + bundle.get('source_address', address)
        key = (address, reason)
        if key not in seen_gaps:
            item = {"address": address, "reason": reason}
            if not retain_events:
                item['count'] = 0
            seen_gaps[key] = item
            gaps.append(item)
        if not retain_events:
            seen_gaps[key]['count'] += 1

    def drain():
        nonlocal clock, stalls, mxu_stalls
        dma_finish = max([clock, *resources.values()])
        finish = max([dma_finish, *mxu_ready.values()])
        mxu_stalls += finish - dma_finish
        if finish > clock:
            name = 'Segment resource drain' if finish > dma_finish else 'Segment DMA drain'
            timeline.add('XLA TraceMe', name, clock, finish)
            stalls += finish - clock
            clock = finish
        for flag in flags:
            flag_state(flag, clock)
        resources.clear()
        mxu_ready.clear()
        # Do not mutate a preceding segment's last activity after snapshotting.
        timeline.previous.clear()
        timeline.run += 1

    def costs():
        return clock, stalls, extra, transferred, bus_transferred, visits, scheduled, histogram.copy(), mxu_stalls

    def finish_arm(frame):
        drain()
        frame['arms'].append(dict(costs=costs(), flags=deepcopy(flags),
                                 events=events[frame['event_start']:],
                                 timeline=timeline.items[frame['timeline_start']:]))
        del events[frame['event_start']:]
        del timeline.items[frame['timeline_start']:]

    for visit, (position, bundle) in enumerate(execution):
        address = bundle['address']
        if 'boundary' in bundle:
            boundary = bundle['boundary']
            if boundary == 'loop_start':
                scheduled += bundle.get('static_bundle_count', 0)
                drain()
                frames.append(dict(address=address, repeat=bundle['repeat'],
                                   bound_source=bundle['bound_source'], base=costs()))
                # An arbitrary iteration cannot assume entry-only DMA credits.
                flags.clear()
            elif boundary == 'loop_end':
                drain()
                frame = frames.pop()
                count, base = frame['repeat'], frame['base']
                duration = clock - base[0]
                finish = base[0] + duration * count
                timeline.add('XLA TraceMe', 'Remaining loop iterations', clock, finish, bundle)
                loops.append(dict(address=address, iterations=count,
                                  bound_source=frame['bound_source'],
                                  iteration_cycles=duration, modeled_cycles=duration * count))
                clock = finish
                stalls = base[1] + (stalls - base[1]) * count
                extra = base[2] + (extra - base[2]) * count
                transferred = base[3] + (transferred - base[3]) * count
                bus_transferred = base[4] + (bus_transferred - base[4]) * count
                visits = base[5] + (visits - base[5]) * count
                histogram = base[7] + Counter({k: (v - base[7][k]) * count for k, v in histogram.items()})
                mxu_stalls = base[8] + (mxu_stalls - base[8]) * count
                flags.clear()
                timeline.previous.clear()
                timeline.run += 1
            elif boundary == 'start':
                scheduled += bundle.get('static_bundle_count', 0)
                drain()
                frames.append(dict(address=address, join_address=bundle['join_address'],
                                   base=costs(), flags=deepcopy(flags), arms=[],
                                   event_start=len(events), timeline_start=len(timeline.items)))
            else:
                frame = frames[-1]
                finish_arm(frame)
                if boundary == 'next':
                    clock, stalls, extra, transferred, bus_transferred, visits, scheduled, histogram, mxu_stalls = frame['base']
                    histogram = histogram.copy()
                    flags = deepcopy(frame['flags'])
                else:
                    frames.pop()
                    arms = frame['arms']
                    selected = max(range(len(arms)), key=lambda i: arms[i]['costs'][0])
                    chosen = arms[selected]
                    clock, stalls, extra, transferred, bus_transferred, visits, scheduled, histogram, mxu_stalls = chosen['costs']
                    events.extend(chosen['events'])
                    timeline.items.extend(chosen['timeline'])
                    # Drained flags have no pending completions. A guaranteed
                    # credit must exist in every arm; never inherit only the
                    # winning arm's credits into a shared continuation.
                    all_flags = set().union(*(a['flags'] for a in arms))
                    flags = {f: [min(a['flags'].get(f, [0])[0] for a in arms), []] for f in all_flags}
                    segments.append(dict(address=address, join_address=frame['join_address'],
                        alternative_cycles=[a['costs'][0] - frame['base'][0] for a in arms],
                        selected_alternative=selected, modeled_cycles=clock - frame['base'][0]))
            continue
        visits += 1
        scalar_resolved |= bundle.get('scalar_path_resolved', False)
        if 'path' not in scenario:
            scheduled += bundle.get('static_bundle_count', 1)
        visit_gaps = []
        opcodes, wait_ops = set(), set()
        delay_cycles = 0
        if "/" in address:
            gap(address.rsplit("/", 1)[0], "cross-call operand bindings are unresolved")
        active, reservations = [], {}
        for index, instruction in enumerate(bundle["instructions"]):
            if f"{visit}:{index}" in inactive:
                unused_inactive.discard(f'{visit}:{index}')
                continue
            op, text = instruction["opcode"], instruction["text"]
            rhs = text.split("=", 1)[-1]
            predicated = re.search(r"@!?[pv]|\(!?%p\d|\(!?%vm\d", rhs)
            if (predicated or 'resolved_predicate' in instruction) and not (
                op.startswith("shalt") and scenario.get("assume_no_faults")
            ):
                decision = scenario.get("predicates", {}).get(
                    f"{visit}:{index}", instruction.get("resolved_predicate"))
                if decision is None:
                    gap(address, "predicate outcome not supplied")
                elif not isinstance(decision, bool):
                    raise ValueError("predicate decisions must be booleans")
                elif not decision:
                    continue
            active.append((index, instruction))
            if mxu_model and op.startswith('vmatmul'):
                reservation = matmul_throughput(rhs.strip().split()[0])
                if reservation is None:
                    gap(address, f"unmodeled GF MXU throughput: {op}")
                else:
                    resource, hold = reservation
                    if resource in reservations:
                        gap(address, f"co-issued operations share {resource}")
                    reservations[resource] = reservations.get(resource, 0) + hold
        # Already-issued independent work, explicit delays and DMA waits can
        # hide these holds. Charge only the remaining interval before issue.
        start = max([clock, *(mxu_ready.get(r, 0) for r in reservations)])
        mxu_wait = start - clock
        stalls += mxu_wait
        mxu_stalls += mxu_wait
        for resource, hold in reservations.items():
            mxu_ready[resource] = start + hold
        end = start + issue
        bundle_extra = 0
        for index, instruction in active:
            op, text = instruction['opcode'], instruction['text']
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
                if "path" not in scenario and not bundle.get('scalar_path_resolved'):
                    gap(address, "control flow requires an explicit executed path")
                elif "path" not in scenario and not bundle.get('branch_delay_slots_resolved'):
                    gap(address, "branch delay slots are not reconstructed from Final LLO")
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
                direction = instruction.get('dma_direction', op.removeprefix("dma."))
                # final_bundles carries granules and destination sync flag inline.
                operands = dma_operands(text)
                known = len(operands) >= 4 and re.fullmatch(r'\d+', operands[1])
                config = profile.get("dma", {}).get(direction)
                if not known or not config:
                    gap(
                        address,
                        f"unmodeled DMA {direction}: need size, direction and profile",
                    )
                    continue
                units = int(operands[1])
                size = units * _positive(
                    profile.get("dma_granule_bytes", 0), "dma_granule_bytes"
                )
                bandwidth = _positive(config["bytes_per_second"], "DMA bandwidth")
                latency = _positive(
                    config.get("latency_cycles", 0), "DMA latency", True
                )
                bus_size = math.ceil(size / transaction) * transaction
                if transaction > 1:
                    gap(address, "DMA transaction rounding assumes aligned contiguous transfer; address/stride unverified")
                if op == 'dma.general':
                    gap(address, 'general DMA uses payload bandwidth; descriptor stride/padding and source completion are not modeled')
                bandwidth_cycles = bus_size * hz / bandwidth
                # A transfer must cross both memory interfaces. Rates are per
                # modeled core, not full-chip aggregate bandwidth.
                if 'vmem_bytes_per_second' in config and 'vmem' in direction:
                    vmem_bandwidth = _positive(config['vmem_bytes_per_second'], 'VMEM DMA bandwidth')
                    bandwidth_cycles = max(bandwidth_cycles, size * hz / vmem_bandwidth)
                duration = latency + math.ceil(bandwidth_cycles)
                resource = config.get("resource", direction)
                begin = max(start, resources.get(resource, 0))
                finish = begin + duration
                resources[resource] = finish
                flag = operands[3]
                if re.fullmatch(_SYNC_FLAG, flag):
                    heapq.heappush(flag_state(flag, start)[1], (finish, units))
                else:
                    # Encoded/unknown flags do not make the transfer disappear.
                    # Do not alias numeric flags to allocation-relative names.
                    gap(address, 'DMA destination completion flag is unresolved')
                transferred += size
                bus_transferred += bus_size
                if retain_events:
                    events.append({
                        "kind": "dma",
                        "address": address,
                        "direction": direction,
                        "resource": resource,
                        "bytes": size,
                        "bus_bytes": bus_size,
                        "latency_cycles": latency,
                        "bandwidth_cycles": math.ceil(bandwidth_cycles),
                        "destination_flag": flag,
                        "start_cycle": begin,
                        "end_cycle": finish,
                    })
                    if op == 'dma.general' and len(operands) == 8:
                        events[-1].update(source_flag=operands[4],
                                          stride_descriptor=operands[5],
                                          overrides=operands[6],
                                          second_destination_flag=operands[7])
            elif op == "dma.done.wait":
                wait_ops.add(op)
                match = re.search(_SYNC_FLAG + r",\s*(\d+)", text)
                ready = None
                if match and match[1] in flags:
                    credits, pending = flag_state(match[1], start)
                    required = int(match[2])
                    if credits >= required:
                        ready = start
                    else:
                        for completion, units in sorted(pending):
                            credits += units
                            if credits >= required:
                                ready = completion
                                break
                if ready is None:
                    gap(address, "DMA wait has unknown or partial completion credits")
                else:
                    end = max(end, ready)
            elif op.startswith("vsyncadd"):
                match = re.search(_SYNC_FLAG + r",\s*(-?\d+)", text)
                if not match:
                    gap(
                        address,
                        "sync credit update is not a constant final-bundle operand",
                    )
                if match:
                    state = flag_state(match[1], start)
                    value = int(match.group(2))
                    value = value - 2**32 if value >= 2**31 else value
                    if state[0] + value >= 0:
                        state[0] += value
                    else:
                        gap(address, "sync credit underflow")
            elif op.startswith(
                ("vwait", "sfence", "cfence", "barrier", "send", "recv", "semaphore")
            ):
                wait_ops.add(op)
                ready = scenario.get("wait_until_cycles", {}).get(f"{visit}:{index}")
                if ready is None and instruction.get('peer_wait') and profile.get('assume_peers_ready'):
                    ready = start
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
        timeline.visit(bundle, position, start - mxu_wait, clock, opcodes, visit_gaps)
        if retain_events:
            events.append({
                "kind": "bundle",
                "address": address,
                "visit": visit,
                "start_cycle": start,
                "end_cycle": clock,
                "issue_end_cycle": start + issue + bundle_extra,
                "issue_cycles": issue,
                "delay_cycles": delay_cycles,
                "mxu_stall_cycles": mxu_wait,
                "opcodes": sorted(opcodes),
                "wait_ops": sorted(wait_ops),
                "cost_gaps": visit_gaps,
            })
    if not visits:
        raise ValueError('path must contain existing bundle addresses')
    if unused_inactive:
        raise ValueError('inactive refers to nonexistent instruction visits')
    # Drain outstanding resources without charging already-overlapped work again.
    dma_finish = max([clock, *resources.values()])
    resource_finish = max([dma_finish, *mxu_ready.values()])
    finish = resource_finish + tail
    return {
        "profile": deepcopy(profile),
        "scenario": deepcopy(scenario),
        "status": "partial" if gaps else "modeled",
        "scheduled_bundle_count": scheduled,
        "modeled_bundle_visits": visits,
        "path_source": ("explicit" if "path" in scenario else
                        "scalar_resolved" if scalar_resolved
                        else "linear_scan"),
        "issue_cycles": visits * issue,
        "wait_stall_cycles": stalls,
        "mxu_stall_cycles": mxu_stalls,
        "mxu_completion_cycles": resource_finish - dma_finish,
        "extra_instruction_cycles": extra,
        "completion_cycles": finish - clock,
        "modeled_cycles": finish,
        "runtime_loops": loops,
        "modeled_seconds": finish / hz,
        "estimated_seconds": None if gaps else finish / hz,
        "dma_bytes": transferred,
        "dma_bus_bytes": bus_transferred,
        "instruction_counts": dict(sorted(histogram.items())),
        "runtime_segments": segments,
        "gaps": gaps,
        "events": events,
        "activity_timeline": timeline.finish(clock, finish, tail,
            "Outstanding resources" if resource_finish > dma_finish else "Outstanding DMA"),
        "assumptions": [
            "Profile supplies issue rate and instruction timing; dump addresses are not cycles.",
            "Scheduled bundles cover internal instruction dependencies; profile supplies completion tail.",
            "DMA resources serialize transfers; execution can overlap DMA.",
            "Final LLO manifests expand reachable kernel calls per invocation.",
            "Static scenario estimate, not calibrated hardware execution time.",
        ] + (["Peers are assumed ready: marked readiness polls run once with zero external wait; DMA costs remain modeled."]
             if profile.get('assume_peers_ready') else [])
          + (["GF matmul throughput is tracked per MXU; result latency and other MXU hazards rely on the compiler schedule, not a full MXU simulation."]
             if mxu_model else []),
    }
