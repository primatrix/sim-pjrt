"""Explicit communication scenarios; no bandwidth is inferred from CPU timing."""

import math
from dataclasses import dataclass

from virtual_clock import Event


def nonnegative(value, name):
    if not math.isfinite(value) or value < 0:
        raise ValueError(f"{name} must be finite and nonnegative")
    return value


@dataclass(frozen=True)
class Link:
    latency_ns: int
    bytes_per_second: float

    def __post_init__(self):
        nonnegative(self.latency_ns, "latency_ns")
        if nonnegative(self.bytes_per_second, "bytes_per_second") == 0:
            raise ValueError("Bandwidth must be positive")

    def duration(self, size):
        nonnegative(size, "transfer bytes")
        return math.ceil(self.latency_ns + size * 1e9 / self.bytes_per_second)


class Communication:
    """Directed links with explicit routes and store-and-forward hop scheduling.

    Two chiplets share a chip's ICI injection resources in the example topology.
    Ring rounds have a barrier: a conservative scenario, not TPU code generation.
    """

    def __init__(self, config):
        self.links = {name: Link(**value) for name, value in config["links"].items()}
        self.routes = config["routes"]
        self.host = Link(**config["host_link"])
        self.use_hbm = config.get("communication_uses_hbm", True)
        for route in self.routes.values():
            if not route or any(link not in self.links for link in route):
                raise ValueError("Routes must contain known links")

    def transfer(self, prefix, source, target, size, dependencies=()):
        if source == target:
            return [
                Event(prefix, "local buffer alias", dependencies=tuple(dependencies))
            ]
        key = f"{source}>{target}"
        if key not in self.routes:
            raise ValueError(f"No communication route for {key}")
        events = []
        deps = tuple(dependencies)
        for i, link in enumerate(self.routes[key]):
            resources = (link,)
            if self.use_hbm:
                resources += tuple(f"hbm:{d}" for d in (source, target))
            event = Event(
                f"{prefix}/hop{i}",
                f"transfer {source} → {target}",
                self.links[link].duration(size),
                deps,
                resources,
                metadata={
                    "bytes": size,
                    "source": source,
                    "target": target,
                    "link": link,
                },
            )
            events.append(event)
            deps = (event.id,)
        events.append(
            Event(
                prefix,
                "transfer complete",
                dependencies=deps,
                metadata={
                    "transfer_kind": "device",
                    "bytes": size,
                    "source": source,
                    "target": target,
                },
            )
        )
        return events

    def host_transfer(self, prefix, device, size, direction, dependencies=()):
        if direction not in ("h2d", "d2h"):
            raise ValueError("Unknown host transfer direction")
        resources = (f"host:{direction}", f"dma:{device}:{direction}")
        if self.use_hbm:
            resources += (f"hbm:{device}",)
        return Event(
            prefix,
            direction,
            self.host.duration(size),
            tuple(dependencies),
            resources,
            metadata={"device": device, "bytes": size, "transfer_kind": direction},
        )

    def ring(self, prefix, kind, participants, size, arrivals):
        """Size: full local input for all-reduce/reduce-scatter; local shard for gather."""
        if kind not in ("all-reduce", "all-gather", "reduce-scatter"):
            raise ValueError(f"Unsupported ring collective: {kind}")
        group = tuple(participants)
        if not group or len(set(group)) != len(group) or set(group) != arrivals.keys():
            raise ValueError("Collective requires one arrival per distinct participant")
        nonnegative(size, "collective bytes")
        rounds = (len(group) - 1) * (2 if kind == "all-reduce" else 1)
        chunk = size if kind == "all-gather" else math.ceil(size / len(group))
        deps = tuple(arrivals[d] for d in group)
        events = []
        for step in range(rounds):
            ends = []
            for i, source in enumerate(group):
                target = group[(i + 1) % len(group)]
                id = f"{prefix}/round{step}/{source}"
                events += self.transfer(id, source, target, chunk, deps)
                ends.append(id)
            deps = tuple(ends)
        events.append(
            Event(
                prefix,
                kind + " complete",
                dependencies=deps,
                metadata={
                    "participants": list(group),
                    "bytes": size,
                    "algorithm": "ring with round barriers",
                },
            )
        )
        return events
