"""Deterministic, non-preemptive DAG scheduling in integer virtual nanoseconds."""

import heapq
from collections import defaultdict
from dataclasses import dataclass, field


@dataclass(frozen=True)
class Event:
    id: str
    name: str
    duration_ns: int = 0
    dependencies: tuple[str, ...] = ()
    resources: tuple[str, ...] = ()
    release_ns: int = 0
    metadata: dict = field(default_factory=dict)


@dataclass(frozen=True)
class ScheduledEvent:
    event: Event
    start_ns: int
    end_ns: int
    ready_ns: int
    blocked_by: str | None


def simulate(events):
    """Schedule the earliest feasible ready event; input order breaks ties.

    Resources are exclusive for an event's entire duration. This is a declared
    scheduling policy, not an optimization of the makespan. Zero-duration nodes
    express dependencies without reserving a resource.
    """
    events = list(events)
    indices = {event.id: i for i, event in enumerate(events)}
    if len(indices) != len(events):
        raise ValueError("Duplicate event ID")
    successors = defaultdict(list)
    remaining = {}
    for event in events:
        for value in (event.duration_ns, event.release_ns):
            if type(value) is not int or value < 0:
                raise ValueError(f"{event.id}: times must be nonnegative integers")
        if len(set(event.resources)) != len(event.resources):
            raise ValueError(f"{event.id}: duplicate resource")
        dependencies = set(event.dependencies)
        if any(dep not in indices for dep in dependencies):
            raise ValueError(f"{event.id}: missing dependencies")
        remaining[event.id] = len(dependencies)
        for dependency in dependencies:
            successors[dependency].append(event.id)
    finished = {}
    available = {}  # Resource -> (available time, previous owner).
    schedule = []

    def candidate(id):
        event = events[indices[id]]
        constraints = [(event.release_ns, None)] + [
            (finished[dep], dep) for dep in event.dependencies
        ]
        ready_ns = max(time for time, _ in constraints)
        if event.duration_ns:
            constraints += [available.get(r, (0, None)) for r in event.resources]
        start, blocker = max(constraints, key=lambda pair: pair[0])
        return start, indices[id], ready_ns, blocker

    ready = [candidate(id)[:2] for id, count in remaining.items() if not count]
    heapq.heapify(ready)
    while ready:
        earliest, index = heapq.heappop(ready)
        event = events[index]
        start, _, ready_ns, blocker = candidate(event.id)
        # Resource availability only increases. Heap entries are lower bounds;
        # refresh lazily until the smallest entry is also feasible.
        if start != earliest:
            heapq.heappush(ready, (start, index))
            continue
        end = start + event.duration_ns
        finished[event.id] = end
        if event.duration_ns:
            for resource in event.resources:
                available[resource] = (end, event.id)
        schedule.append(ScheduledEvent(event, start, end, ready_ns, blocker))
        for successor in successors[event.id]:
            remaining[successor] -= 1
            if not remaining[successor]:
                heapq.heappush(ready, candidate(successor)[:2])
    if len(schedule) != len(events):
        raise ValueError("Dependency cycle")
    return schedule


def summarize(schedule):
    makespan = max((item.end_ns for item in schedule), default=0)
    busy = defaultdict(int)
    by_id = {item.event.id: item for item in schedule}
    for item in schedule:
        for resource in item.event.resources:
            busy[resource] += item.event.duration_ns
    chain = []
    if schedule:
        current = max(schedule, key=lambda item: item.end_ns)
        while current:
            chain.append(current.event.id)
            current = by_id.get(current.blocked_by)
    return {
        "clock_domain": "simulated",
        "makespan_ns": makespan,
        "event_count": len(schedule),
        "resource_busy_ns": dict(sorted(busy.items())),
        "critical_chain": list(reversed(chain)),
    }


def trace_viewer(schedule):
    """Standalone Trace Event JSON. Never mixes CPU and virtual clock epochs."""
    lanes = sorted(
        {r for item in schedule for r in item.event.resources} | {"dependencies"}
    )
    tids = {lane: i for i, lane in enumerate(lanes)}
    trace = [
        {"ph": "M", "pid": 1, "tid": tid, "name": "thread_name", "args": {"name": lane}}
        for lane, tid in tids.items()
    ]
    for item in schedule:
        event = item.event
        trace.append(
            {
                "ph": "X",
                "pid": 1,
                "tid": tids[event.resources[0] if event.resources else "dependencies"],
                "name": event.name,
                "ts": item.start_ns / 1000,
                "dur": event.duration_ns / 1000,
                "args": {
                    **event.metadata,
                    "clock_domain": "simulated",
                    "id": event.id,
                    "dependencies": list(event.dependencies),
                    "resources": list(event.resources),
                    "resource_wait_ns": item.start_ns - item.ready_ns,
                    "blocked_by": item.blocked_by or "",
                },
            }
        )
    return {"traceEvents": trace, "displayTimeUnit": "ns"}
