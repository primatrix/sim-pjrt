"""Apply scenario rates and routes to the canonical C++ execution plan.

HLO interpretation and cost coverage live in execution_plan.cc. Python only
expands the plan into per-device events for offline scheduling and accounting.
"""

import math

from communication import nonnegative
from execution_plan import load_plan
from virtual_clock import Event


class Workload:
    def __init__(self, snapshot, devices, scenario, communication):
        self.devices = tuple(devices)
        if not self.devices or len(set(self.devices)) != len(self.devices):
            raise ValueError("Devices must be nonempty and distinct")
        self.plan = load_plan(snapshot, len(self.devices))
        self.scenario = scenario
        self.communication = communication
        self.gaps = [
            {"instruction": n["hlo_id"], "name": n["name"], "reason": n["cost_gap"]}
            for n in self.plan["nodes"]
            if n["cost_gap"]
        ]
        self.inferred_collectives = sum(n["inferred"] for n in self.plan["nodes"])
        self.compute_rate = self._rate("bf16_flops_per_second", "compute_utilization")
        self.memory_rate = self._rate("hbm_bytes_per_second", "bandwidth_utilization")
        self.transcendental_rate = nonnegative(
            scenario.get("transcendentals_per_second", 1e12),
            "transcendentals_per_second",
        )
        if self.transcendental_rate == 0:
            raise ValueError("transcendentals_per_second must be positive")

    def _rate(self, rate, utilization):
        value = nonnegative(self.scenario[rate], rate)
        fraction = nonnegative(self.scenario[utilization], utilization)
        if not value or not 0 < fraction <= 1:
            raise ValueError(f"Invalid {rate} or {utilization}")
        return value * fraction

    def _metadata(self, node, device):
        if not node["hlo_id"]:
            return {}
        kernel = node["cost_source"] == "pallas_cost_estimate"
        unknown = bool(node["cost_gap"])
        return {
            "hlo_id": node["hlo_id"],
            "framework_op": node["framework_op"],
            "opcode": node["opcode"],
            "device": device,
            "dtype": node["dtype"],
            "cost_status": "unknown"
            if unknown
            else ("structural" if node["kind"] == "barrier" else "estimated"),
            "cost_gap": node["cost_gap"],
            "dot_flops": None
            if unknown
            else (node["flops"] if node["opcode"] == "dot" else 0),
            "logical_read_bytes": None if unknown else node["logical_read_bytes"],
            "logical_write_bytes": None if unknown else node["logical_write_bytes"],
            **(
                {
                    "cost_source": node["cost_source"],
                    "kernel_flops": node["flops"],
                    "transcendentals": node["transcendentals"],
                    "kernel_bytes_accessed": node["bytes"],
                }
                if kernel
                else {}
            ),
        }

    def lower(self):
        events = []
        for index, node in enumerate(self.plan["nodes"]):
            prefix = f"plan/{index}"
            results = {d: f"{prefix}:{d}" for d in self.devices}
            communication = node["kind"] not in ("barrier", "compute")
            local = {
                d: results[d] + "/local" if communication else results[d]
                for d in self.devices
            }
            duration = 0
            if node["kind"] == "compute":
                duration = math.ceil(
                    max(
                        node["flops"] / self.compute_rate,
                        node["transcendentals"] / self.transcendental_rate,
                        node["bytes"] / self.memory_rate,
                    )
                    * 1e9
                )
            for d in self.devices:
                dependencies = tuple(f"plan/{i}:{d}" for i in node["dependencies"])
                events.append(
                    Event(
                        local[d],
                        node["name"],
                        duration,
                        dependencies or (f"start:{d}",),
                        (f"compute:{d}", f"hbm:{d}") if duration else (),
                        metadata=self._metadata(node, d),
                    )
                )
            if communication:
                end = prefix + "/collective"
                if node["kind"] == "transfers":
                    arrivals = tuple(local.values())
                    completed = []
                    for source, target in node["transfers"]:
                        transfer = f"{end}/{source}>{target}"
                        events += self.communication.transfer(
                            transfer,
                            self.devices[source],
                            self.devices[target],
                            node["bytes"],
                            arrivals,
                        )
                        completed.append(transfer)
                    events.append(
                        Event(
                            end,
                            node["name"] + " complete",
                            dependencies=tuple(completed) or arrivals,
                        )
                    )
                else:
                    events += self.communication.ring(
                        end,
                        node["kind"],
                        self.devices,
                        node["bytes"],
                        local,
                    )
                for d in self.devices:
                    events.append(
                        Event(
                            results[d], "collective result ready", dependencies=(end,)
                        )
                    )
        for d in self.devices:
            events.append(
                Event(
                    f"done:{d}",
                    "program complete",
                    dependencies=(f"plan/{self.plan['root']}:{d}",),
                    metadata={"device": d, "execution_boundary": "end"},
                )
            )
        return events
