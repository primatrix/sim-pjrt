"""Declared Pallas costs through the canonical native planner and replay."""

import base64
import json
import unittest

from device_load import summarize_device_load
from execution_plan import load_plan
from plan_test_utils import entry, snapshot_from_hlo
from replay_test import scenario
from virtual_clock import Event, simulate, summarize
from virtual_clock_test import network
from workload import Workload


def kernel_snapshot(cost=None, **call_fields):
    snapshot = snapshot_from_hlo("""
HloModule kernel
ENTRY main {
  ROOT attention = (bf16[4]) custom-call(), custom_call_target="tpu_custom_call", sharding={replicated}
}
""")
    config = {
        "custom_call_config": {
            "cost_estimate": cost
            if cost is not None
            else {
                "flops": 800,
                "transcendentals": 40,
                "bytes_accessed": 160,
            },
            **call_fields,
        }
    }
    entry(snapshot)["instructions"][0]["backend_config"] = base64.b64encode(
        json.dumps(config).encode()
    ).decode()
    return snapshot


def kernel_cost(snapshot, devices=1):
    node = next(n for n in load_plan(snapshot, devices)["nodes"] if n["hlo_id"])
    if node["cost_gap"]:
        raise ValueError(node["cost_gap"])
    return {
        "flops": node["flops"],
        "transcendentals": node["transcendentals"],
        "bytes_accessed": node["bytes"],
    }


class PallasCostTest(unittest.TestCase):
    def test_numeric_and_protobuf_string_counts(self):
        expected = {"flops": 800, "transcendentals": 40, "bytes_accessed": 160}
        self.assertEqual(kernel_cost(kernel_snapshot()), expected)
        self.assertEqual(
            kernel_cost(kernel_snapshot({k: str(v) for k, v in expected.items()})),
            expected,
        )

    def test_unknown_scope_and_invalid_counts(self):
        snapshot = kernel_snapshot()
        del entry(snapshot)["instructions"][0]["sharding"]
        with self.assertRaisesRegex(ValueError, "scope"):
            kernel_cost(snapshot, 2)
        for bad in (-1, True, None, "NaN", "Infinity", 2**63, 1.5, [], {}):
            with self.subTest(bad=bad), self.assertRaises(ValueError):
                kernel_cost(
                    kernel_snapshot(
                        {"flops": 800, "transcendentals": 40, "bytes_accessed": bad}
                    )
                )
        for bad in ("not base64", base64.b64encode(b"{}").decode()):
            snapshot = kernel_snapshot()
            entry(snapshot)["instructions"][0]["backend_config"] = bad
            with self.assertRaises(ValueError):
                kernel_cost(snapshot)

    def test_internal_communication_is_not_silently_ignored(self):
        for snapshot in (
            kernel_snapshot(has_communication=True),
            kernel_snapshot(
                {
                    "flops": 1,
                    "transcendentals": 0,
                    "bytes_accessed": 1,
                    "remote_bytes_transferred": 1,
                }
            ),
        ):
            with self.assertRaisesRegex(ValueError, "communication"):
                kernel_cost(snapshot)

    def test_three_roofline_limits_and_device_accounting(self):
        snapshot = kernel_snapshot()
        for rate, expected in ((1e9, 800), (1e7, 4000)):
            config = scenario()
            config["transcendentals_per_second"] = rate
            model = Workload(snapshot, (0, 1), config, network())
            events = [Event(f"start:{d}", "start") for d in (0, 1)] + model.lower()
            self.assertEqual(model.gaps, [])
            self.assertEqual(summarize(simulate(events))["makespan_ns"], expected)
            for row in summarize_device_load(events)["devices"].values():
                self.assertEqual(row["estimated_kernel_flops"], 800)
                self.assertEqual(row["estimated_kernel_bytes_accessed"], 160)
                self.assertEqual(row["estimated_kernel_transcendentals"], 40)
                self.assertEqual(row["estimated_dot_flops_by_dtype"], {})
        config["hbm_bytes_per_second"] = 1e6
        model = Workload(snapshot, (0,), config, network())
        self.assertEqual(
            summarize(simulate([Event("start:0", "start")] + model.lower()))[
                "makespan_ns"
            ],
            160000,
        )

    def test_missing_estimate_retains_dependency_and_gap(self):
        snapshot = kernel_snapshot()
        del entry(snapshot)["instructions"][0]["backend_config"]
        model = Workload(snapshot, (0,), scenario(), network())
        events = model.lower()
        self.assertEqual(len(model.gaps), 1)
        self.assertEqual(events[0].metadata["cost_status"], "unknown")
        self.assertEqual(events[0].dependencies, ("start:0",))


if __name__ == "__main__":
    unittest.main()
