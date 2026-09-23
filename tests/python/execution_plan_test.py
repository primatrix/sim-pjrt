"""Snapshot portability, native replanning, and offline dependency regressions."""

import copy
import unittest
from unittest.mock import patch

from execution_plan import export_snapshot, load_plan
from plan_test_utils import snapshot_from_hlo
from replay_test import dot_program, scenario
from virtual_clock import Event, simulate, summarize
from virtual_clock_test import network
from workload import Workload


class ExecutionPlanTest(unittest.TestCase):
    def test_embedded_plan_needs_no_native_binary_and_matches_replanning(self):
        snapshot = export_snapshot(dot_program(False), 2)
        original = copy.deepcopy(snapshot)
        with patch(
            "execution_plan.export_snapshot",
            side_effect=AssertionError("must not replan"),
        ):
            embedded = Workload(snapshot, (7, 9), scenario(), network()).lower()
        snapshot.pop("plan")
        rebuilt = Workload(snapshot, (7, 9), scenario(), network()).lower()
        self.assertEqual(embedded, rebuilt)
        ids = {
            i.get("id", "0")
            for c in original["hlo"]["computations"]
            for i in c["instructions"]
        }
        self.assertTrue(
            all(n["hlo_id"] in ids for n in original["plan"]["nodes"] if n["hlo_id"])
        )

    def test_device_count_change_replans_from_original_hlo(self):
        snapshot = export_snapshot(dot_program(), 2)
        two = load_plan(snapshot, 2)
        one = load_plan(snapshot, 1)
        self.assertEqual(sum(n["flops"] for n in two["nodes"]), 48)
        self.assertEqual(sum(n["flops"] for n in one["nodes"]), 96)
        self.assertEqual(sum(n["inferred"] for n in one["nodes"]), 0)
        four = load_plan(snapshot, 4)
        self.assertGreater(four["cost_gaps"], 0)
        self.assertEqual(sum(n["flops"] for n in four["nodes"]), 0)
        self.assertEqual(snapshot["plan"]["devices"], 2)

    def test_partitioned_shapes_are_not_divided_again(self):
        snapshot = dot_program()
        snapshot["shape_scope"] = "per_partition"
        snapshot = export_snapshot(snapshot, 2)
        self.assertEqual(snapshot["shape_scope"], "per_partition")
        for devices in (1, 2, 4):
            plan = load_plan(snapshot, devices)
            self.assertEqual(sum(n["flops"] for n in plan["nodes"]), 96)
            self.assertEqual(sum(n["inferred"] for n in plan["nodes"]), 0)

    def test_call_control_predecessor_gates_callee_work(self):
        snapshot = snapshot_from_hlo(
            """
HloModule controlled
callee {
  x = f32[4] parameter(0)
  ROOT y = f32[4] add(x,x)
}
ENTRY main {
  x = f32[4] parameter(0), sharding={manual}
  gate = f32[4] collective-permute(x), source_target_pairs={{0,1}}, channel_id=1
  ROOT call = f32[4] call(x), to_apply=callee, control-predecessors={gate}
}
""",
            2,
            embedded=True,
        )
        model = Workload(snapshot, (0, 1), scenario(), network())
        schedule = simulate(
            [Event(f"start:{d}", "start") for d in (0, 1)] + model.lower()
        )
        self.assertEqual(model.gaps, [])
        # Communication uses a link, so a missing edge would let compute overlap.
        self.assertEqual(summarize(schedule)["makespan_ns"], 17 + 48)

    def test_call_gate_covers_zero_argument_callee(self):
        snapshot = snapshot_from_hlo(
            """
HloModule controlled
callee {
  ROOT y = f32[4] iota(), iota_dimension=0, sharding={replicated}
}
ENTRY main {
  x = f32[4] parameter(0), sharding={replicated}
  gate = f32[4] collective-permute(x), source_target_pairs={{0,1}}, channel_id=1
  ROOT call = f32[4] call(), to_apply=callee, control-predecessors={gate}
}
""",
            2,
            embedded=True,
        )
        model = Workload(snapshot, (0, 1), scenario(), network())
        schedule = simulate(
            [Event(f"start:{d}", "start") for d in (0, 1)] + model.lower()
        )
        self.assertEqual(model.gaps, [])
        self.assertEqual(summarize(schedule)["makespan_ns"], 17 + 16)

    def test_non_identity_sharding_stays_an_explicit_gap(self):
        snapshot = snapshot_from_hlo(
            """
HloModule permutation
ENTRY main {
  x = f32[4] parameter(0), sharding={devices=[2]1,0}
  ROOT y = f32[4] add(x,x), sharding={devices=[2]1,0}
}
""",
            2,
            embedded=True,
        )
        model = Workload(snapshot, (0, 1), scenario(), network())
        self.assertEqual(len(model.gaps), 1)
        self.assertIn("non-identity", model.gaps[0]["reason"])

    def test_work_outside_root_data_ancestry_is_in_completion(self):
        snapshot = snapshot_from_hlo(
            """
HloModule disconnected
ENTRY main {
  x = f32[4] parameter(0)
  extra = f32[4] add(x,x)
  ROOT result = f32[4] parameter(1)
}
""",
            embedded=True,
        )
        model = Workload(snapshot, (0,), scenario(), network())
        events = model.lower()
        self.assertEqual(
            summarize(simulate([Event("start:0", "start")] + events))["makespan_ns"], 48
        )
        # A host consumer of done must also wait for the disconnected work.
        events.append(Event("consumer", "consumer", 1, ("done:0",)))
        self.assertEqual(
            summarize(simulate([Event("start:0", "start")] + events))["makespan_ns"], 49
        )

    def test_elementwise_coverage_comes_from_native_opcode_rules(self):
        snapshot = snapshot_from_hlo(
            """
HloModule elementwise
ENTRY main {
  x = f32[4] parameter(0)
  ROOT result = f32[4] log(x)
}
""",
            embedded=True,
        )
        model = Workload(snapshot, (0,), scenario(), network())
        self.assertEqual(model.gaps, [])
        self.assertEqual(sum(e.duration_ns for e in model.lower()), 32)

    def test_invalid_dependencies_and_unknown_schema_are_rejected(self):
        snapshot = export_snapshot(dot_program(), 2)
        snapshot["plan"]["nodes"][0]["dependencies"] = [0]
        with self.assertRaisesRegex(ValueError, "dependencies"):
            load_plan(snapshot, 2)
        snapshot["plan"]["schema_version"] = 999
        with self.assertRaisesRegex(ValueError, "schema"):
            load_plan(snapshot, 2)

    def test_legacy_snapshot_uses_native_replanning(self):
        snapshot = dot_program(False)
        snapshot["schema_version"] = 1
        snapshot.pop("shape_scope")
        snapshot["costs"] = {}  # Legacy costs are superseded by the native plan.
        self.assertEqual(load_plan(snapshot, 2)["cost_gaps"], 0)

    def test_missing_planner_has_actionable_error(self):
        snapshot = dot_program()
        with patch(
            "execution_plan.planner_path", return_value="/nonexistent/plan_export"
        ):
            with self.assertRaisesRegex(ValueError, "bazel build"):
                load_plan(snapshot, 2)


if __name__ == "__main__":
    unittest.main()
