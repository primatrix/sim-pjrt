import unittest

from report import build_report


class ReportTest(unittest.TestCase):
    def test_serial_stream_with_per_execution_overlap(self):
        hardware = {
            "bf16_flops_per_second": 100,
            "hbm_bytes_per_second": 10,
            "compute_utilization": 0.5,
            "bandwidth_utilization": 1,
            "launch_seconds": 0.1,
        }
        records = [
            {"dot_flops": 100, "logical_bytes": 10, "unmodeled_ops": 0},
            {"dot_flops": 0, "logical_bytes": 30, "unmodeled_ops": 1},
        ]
        report = build_report(records, hardware)
        self.assertAlmostEqual(report["modeled_component_seconds"], 5.2)
        self.assertAlmostEqual(report["events"][1]["modeled_start_seconds"], 2.1)
        self.assertEqual(report["unmodeled_ops"], 1)
        self.assertFalse(report["complete_latency_prediction"])
        multi = build_report(
            [records[0], {**records[1], "num_devices": 2}, records[0]], hardware
        )
        self.assertIsNone(multi["modeled_component_seconds"])
        self.assertIsNone(multi["events"][1]["modeled_duration_seconds"])
        self.assertIsNone(multi["events"][2]["modeled_start_seconds"])
        self.assertEqual(multi["untimed_multi_device_executions"], 1)
        for invalid in (0, -1, float("nan"), float("inf")):
            with self.subTest(invalid=invalid), self.assertRaises(ValueError):
                build_report(records, {**hardware, "hbm_bytes_per_second": invalid})


if __name__ == "__main__":
    unittest.main()
