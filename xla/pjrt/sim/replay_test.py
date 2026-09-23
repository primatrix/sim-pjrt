"""Analytic sharding and capture-to-virtual-time integration checks."""

import unittest

from replay import build_replay
from virtual_clock import Event, simulate, summarize
from virtual_clock_test import network
from workload import Workload
from plan_test_utils import entry, snapshot_from_hlo


def scenario():
    comm = network()
    return {
        "bf16_flops_per_second": 1e9,
        "hbm_bytes_per_second": 1e9,
        "compute_utilization": 1.0,
        "bandwidth_utilization": 1.0,
        "host_submit_ns": 4,
        "launch_ns": 0,
        "communication": {
            "links": {name: vars(link) for name, link in comm.links.items()},
            "routes": comm.routes,
            "host_link": vars(comm.host),
            "communication_uses_hbm": False,
        },
    }


def dot_program(contract=True):
    lhs = "devices=[1,2]0,1" if contract else "replicated"
    rhs = "devices=[2,1]0,1" if contract else "devices=[1,2]0,1"
    out = "replicated" if contract else "devices=[1,2]0,1"
    return snapshot_from_hlo(
        f"""
HloModule dot_program
ENTRY main {{
  x = bf16[2,4] parameter(0), sharding={{{lhs}}}
  y = bf16[4,6] parameter(1), sharding={{{rhs}}}
  ROOT dot = bf16[2,6] dot(x,y), lhs_contracting_dims={{1}}, rhs_contracting_dims={{0}}, sharding={{{out}}}
}}
""",
        2,
    )


class ReplayTest(unittest.TestCase):
    def test_partitioned_snapshot_has_local_work_and_explicit_collective(self):
        snapshot = snapshot_from_hlo("""
HloModule local
sum {
  x = bf16[] parameter(0)
  y = bf16[] parameter(1)
  ROOT z = bf16[] add(x,y)
}
ENTRY main {
  x = bf16[2,4] parameter(0)
  y = bf16[4,6] parameter(1)
  dot = bf16[2,6] dot(x,y), lhs_contracting_dims={1}, rhs_contracting_dims={0}
  ROOT reduced = bf16[2,6] all-reduce(dot), replica_groups={{0,1}}, channel_id=1, to_apply=sum
}
""")
        snapshot["shape_scope"] = "per_partition"
        model = Workload(snapshot, (0, 1), scenario(), network())
        events = [Event(f"start:{d}", "start") for d in (0, 1)] + model.lower()
        self.assertEqual(model.gaps, [])
        self.assertEqual(model.inferred_collectives, 0)
        self.assertEqual(summarize(simulate(events))["makespan_ns"], 122)

    def test_partitioned_permute_uses_logical_bytes(self):
        snapshot = snapshot_from_hlo("""
HloModule permute
ENTRY main {
  x = bf16[2,4] parameter(0)
  ROOT move = bf16[2,4] collective-permute(x), source_target_pairs={{0,1}}, channel_id=1
}
""")
        snapshot["shape_scope"] = "per_partition"
        model = Workload(snapshot, (0, 1), scenario(), network())
        events = [Event(f"start:{d}", "start") for d in (0, 1)] + model.lower()
        self.assertEqual(model.gaps, [])
        self.assertEqual(summarize(simulate(events))["makespan_ns"], 17)

    def test_contracting_partition_infers_collective_and_local_work(self):
        model = Workload(dot_program(), (0, 1), scenario(), network())
        events = [Event(f"start:{d}", "start") for d in (0, 1)] + model.lower()
        self.assertEqual(model.gaps, [])
        self.assertEqual(model.inferred_collectives, 1)
        # Each device: 48 FLOPs and 56 bytes -> 56 ns. All-reduce: 2*(1+12).
        self.assertEqual(summarize(simulate(events))["makespan_ns"], 82)

    def test_output_partition_requires_no_collective(self):
        model = Workload(dot_program(False), (0, 1), scenario(), network())
        events = [Event(f"start:{d}", "start") for d in (0, 1)] + model.lower()
        self.assertEqual(model.gaps, [])
        self.assertEqual(model.inferred_collectives, 0)
        self.assertEqual(summarize(simulate(events))["makespan_ns"], 52)

    def test_unknown_sharding_and_opaque_work_stay_explicit(self):
        snapshot = dot_program()
        del entry(snapshot)["instructions"][-1]["sharding"]
        model = Workload(snapshot, (0, 1), scenario(), network())
        model.lower()
        self.assertEqual(model.inferred_collectives, 0)
        self.assertIn("unknown sharding", model.gaps[0]["reason"])

    def test_shared_callee_is_instantiated_per_call(self):
        snapshot = snapshot_from_hlo(
            """
HloModule calls
callee {
  x = bf16[2,4] parameter(0), sharding={replicated}
  y = bf16[4,6] parameter(1), sharding={devices=[1,2]0,1}
  ROOT dot = bf16[2,6] dot(x,y), lhs_contracting_dims={1}, rhs_contracting_dims={0}, sharding={devices=[1,2]0,1}
}
ENTRY main {
  x = bf16[2,4] parameter(0), sharding={replicated}
  y = bf16[4,6] parameter(1), sharding={devices=[1,2]0,1}
  a = bf16[2,6] call(x,y), to_apply=callee
  b = bf16[2,6] call(x,y), to_apply=callee
  ROOT result = (bf16[2,6], bf16[2,6]) tuple(a,b)
}
""",
            2,
        )
        model = Workload(snapshot, (0, 1), scenario(), network())
        events = model.lower()
        self.assertEqual(len([e for e in events if e.name == "dot"]), 4)
        self.assertEqual(sum(e.duration_ns for e in events), 4 * 52)

    def test_real_capture_contract_and_buffer_dependencies(self):
        def observed(name, correlation, ts, **stats):
            return {
                "ph": "X",
                "pid": 1,
                "tid": 2,
                "name": name,
                "ts": ts,
                "dur": 99999,
                "args": {
                    "clock_domain": "cpu_wall",
                    "correlation_id": correlation,
                    "incomplete": 0,
                    **stats,
                },
            }

        trace = {
            "traceEvents": [
                observed(
                    "PJRT Execute submit",
                    1,
                    0,
                    input_buffers="1,2,3,4",
                    output_buffers="10,11",
                ),
                observed("Execute submit-to-ready", 1, 0, device_id=0),
                observed("Execute submit-to-ready", 1, 0, device_id=1),
                observed(
                    "PJRT Execute submit",
                    2,
                    100000,
                    input_buffers="10,2,11,4",
                    output_buffers="12,13",
                ),
                observed("Execute submit-to-ready", 2, 100000, device_id=0),
                observed("Execute submit-to-ready", 2, 100000, device_id=1),
            ]
        }
        rows = [
            {"correlation_id": c, "program_id": 1, "num_devices": 2} for c in (1, 2)
        ]
        snapshots = {1: dot_program(False)}
        events, report = build_replay(trace, rows, snapshots, scenario())
        schedule = simulate(events)
        self.assertEqual(summarize(schedule)["makespan_ns"], 4 + 52 * 2)
        self.assertEqual(report["executions"], 2)
        self.assertFalse(report["complete_latency_prediction"])
        self.assertEqual(
            report["buffers_assumed_ready_at_capture_start"], ["1", "2", "3", "4"]
        )
        events, _ = build_replay(
            trace, rows, snapshots, scenario(), serial_dispatch=True
        )
        self.assertEqual(summarize(simulate(events))["makespan_ns"], (4 + 52) * 2)
        # CPU durations/gaps never become virtual durations.
        trace["traceEvents"][3]["dur"] *= 1000
        events, _ = build_replay(trace, rows, snapshots, scenario())
        self.assertEqual(summarize(simulate(events))["makespan_ns"], 108)
        with self.assertRaises(ValueError):
            build_replay(trace, rows[:1], snapshots, scenario())
        trace["traceEvents"][0]["args"]["dropped_events"] = 1
        with self.assertRaises(ValueError):
            build_replay(trace, rows, snapshots, scenario())


if __name__ == "__main__":
    unittest.main()
