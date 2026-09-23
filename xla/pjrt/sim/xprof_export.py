"""Export a virtual schedule as XProf XSpace using the canonical XLA schema."""

import json
import math
from functools import lru_cache
from pathlib import Path

from virtual_clock import Event, ScheduledEvent

# XSpace expects epoch-based line timestamps. This fixed synthetic epoch gives
# deterministic output; event offsets still refer exclusively to virtual time.
EPOCH_NS = 1_000_000_000
DEFAULT_DESCRIPTOR = (
    Path(__file__).resolve().parents[3] / "bazel-bin/xla/pjrt/sim/xplane.descriptor.pb"
)


def xspace_class(descriptor_path=DEFAULT_DESCRIPTOR):
    return _load_xspace_class(str(Path(descriptor_path).resolve()))


@lru_cache(maxsize=8)
def _load_xspace_class(descriptor_path):
    from google.protobuf import descriptor_pb2, descriptor_pool, message_factory

    descriptor_path = Path(descriptor_path)
    if not descriptor_path.is_file():
        raise FileNotFoundError(
            f"Missing {descriptor_path}; build //xla/pjrt/sim:xplane_descriptor "
            "or pass --xspace-descriptor"
        )
    descriptors = descriptor_pb2.FileDescriptorSet.FromString(
        descriptor_path.read_bytes()
    )
    pool = descriptor_pool.DescriptorPool()
    for descriptor in descriptors.file:
        pool.Add(descriptor)
    return message_factory.GetMessageClass(
        pool.FindMessageTypeByName("tensorflow.profiler.XSpace")
    )


def event_track(event):
    """A single primary track per event; resource lists retain other reservations."""
    stats = event.metadata
    device = stats.get("device")
    if stats.get("annotation_kind") == "executable_scope":
        return f"Simulated TPU device {device}", "Executions"
    if stats.get("transfer_kind") in ("h2d", "d2h", "local_copy"):
        return f"Simulated TPU device {device}", stats["transfer_kind"]
    if event.resources:
        resource = event.resources[0]
        kind, _, value = resource.partition(":")
        if kind in ("compute", "hbm", "dma"):
            return f"Simulated TPU device {value.split(':')[0]}", kind
        if kind in ("host", "host-thread"):
            return "Simulated host", resource
        return "Simulated communication", resource
    if device is not None:
        return f"Simulated TPU device {device}", (
            "Unknown HLO cost"
            if stats.get("cost_status") == "unknown"
            else "Dependencies"
        )
    return "Simulated dependencies", "Dependencies"


class Plane:
    def __init__(self, proto):
        self.proto = proto
        self.names = {}
        self.stat_names = {}
        self.lines = {}

    def add_stat(self, target, name, value):
        if name not in self.stat_names:
            id = len(self.stat_names) + 1
            self.stat_names[name] = id
            metadata = self.proto.stat_metadata[id]
            metadata.id, metadata.name = id, name
        stat = target.stats.add(metadata_id=self.stat_names[name])
        if isinstance(value, bool):
            stat.int64_value = int(value)
        elif isinstance(value, int):
            stat.int64_value = value
        elif isinstance(value, float) and math.isfinite(value):
            stat.double_value = value
        elif isinstance(value, str):
            stat.str_value = value
        else:
            # Lists/dicts/null remain inspectable without inventing numeric costs.
            stat.str_value = json.dumps(value, sort_keys=True, allow_nan=False)

    def add_event(self, track, item, makespan_ns):
        event = item.event
        if event.name not in self.names:
            id = len(self.names) + 1
            self.names[event.name] = id
            metadata = self.proto.event_metadata[id]
            metadata.id, metadata.name = id, event.name
        if track not in self.lines:
            id = len(self.lines) + 1
            self.lines[track] = self.proto.lines.add(
                id=id,
                display_id=id,
                name=track,
                timestamp_ns=EPOCH_NS,
                duration_ps=makespan_ns * 1000,
            )
        out = self.lines[track].events.add(
            metadata_id=self.names[event.name],
            offset_ps=item.start_ns * 1000,
            duration_ps=(item.end_ns - item.start_ns) * 1000,
        )
        stats = {
            **event.metadata,
            "clock_domain": "simulated",
            "event_id": event.id,
            "dependencies": list(event.dependencies),
            "resources": list(event.resources),
            "resource_wait_ns": item.start_ns - item.ready_ns,
            "blocked_by": item.blocked_by or "",
            "complete_latency_prediction": False,
        }
        for name, value in stats.items():
            self.add_stat(out, name, value)


def execution_scopes(schedule):
    """Derived display spans, from device launch to completion, with no added cost."""
    boundaries = {}
    for item in schedule:
        stats = item.event.metadata
        boundary = stats.get("execution_boundary")
        if boundary is None:
            continue
        key = (stats["correlation_id"], stats["device"])
        group = boundaries.setdefault(key, {})
        if boundary in group:
            raise ValueError(f"Duplicate execution boundary: {key}")
        group[boundary] = item
    scopes = []
    for key, group in sorted(boundaries.items()):
        if set(group) != {"start", "end"}:
            raise ValueError(f"Incomplete execution boundaries: {key}")
        start, end = group["start"], group["end"]
        stats = start.event.metadata
        if (
            stats["program_id"] != end.event.metadata["program_id"]
            or end.end_ns < start.start_ns
        ):
            raise ValueError(f"Inconsistent execution boundaries: {key}")
        metadata = {k: v for k, v in stats.items() if k != "execution_boundary"}
        metadata["annotation_kind"] = "executable_scope"
        event = Event(
            f"execution-scope:{key[0]}:{key[1]}",
            stats["executable_name"],
            end.end_ns - start.start_ns,
            metadata=metadata,
        )
        scopes.append(
            ScheduledEvent(event, start.start_ns, end.end_ns, start.start_ns, None)
        )
    return scopes


def build_xspace(schedule, descriptor_path=DEFAULT_DESCRIPTOR):
    space = xspace_class(descriptor_path)()
    space.hostnames.append("pjrt-simulator")
    space.warnings.append(
        "Uncalibrated virtual-time scenario with partial cost coverage. "
        "Not measured TPU utilization or complete latency prediction."
    )
    schedule = list(schedule)
    schedule += execution_scopes(schedule)
    makespan = max((item.end_ns for item in schedule), default=0)
    # XEvent offsets and durations are signed int64 picoseconds.
    if makespan < 0 or makespan * 1000 > 2**63 - 1:
        raise ValueError("Virtual schedule exceeds XSpace's picosecond range")
    planes = {}
    names = sorted({event_track(item.event)[0] for item in schedule})
    for id, name in enumerate(names):
        plane = Plane(space.planes.add(id=id, name=f"/device:CUSTOM:{id} {name}"))
        plane.add_stat(plane.proto, "clock_domain", "simulated")
        plane.add_stat(plane.proto, "complete_latency_prediction", False)
        planes[name] = plane
    for item in sorted(
        schedule, key=lambda item: (item.start_ns, -item.end_ns, item.event.id)
    ):
        if not 0 <= item.ready_ns <= item.start_ns <= item.end_ns:
            raise ValueError(f"Invalid virtual interval: {item.event.id}")
        name, track = event_track(item.event)
        planes[name].add_event(track, item, makespan)
    return space


def export_xprof(schedule, directory, descriptor_path=DEFAULT_DESCRIPTOR):
    space = build_xspace(schedule, descriptor_path)
    path = Path(directory) / "plugins/profile/simulated/pjrt-simulator.xplane.pb"
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(".tmp")
    temporary.write_bytes(space.SerializeToString(deterministic=True))
    temporary.replace(path)
    return path
