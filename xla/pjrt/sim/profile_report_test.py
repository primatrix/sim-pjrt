import unittest

from profile_report import build_profile_report, interval_union


def event(name, start, duration, correlation, **stats):
    return {
        "name": name,
        "ts": start,
        "dur": duration,
        "args": {
            "clock_domain": "cpu_wall",
            "correlation_id": str(correlation),
            **stats,
        },
    }


class ProfileReportTest(unittest.TestCase):
    def test_pending_union_does_not_double_count_nested_intervals(self):
        self.assertEqual(interval_union([(0, 10), (2, 4), (5, 15), (20, 25)]), 20)
        report = build_profile_report(
            {
                "traceEvents": [
                    event("Execute submit-to-ready", 0, 10, 1, device_id="0"),
                    event("Execute submit-to-ready", 2, 3, 2, device_id="0"),
                    event("Execute submit-to-ready", 1, 6, 3, device_id="1"),
                ]
            }
        )
        self.assertEqual(report["devices"]["0"]["execute_pending_union_us"], 10)
        self.assertEqual(report["devices"]["1"]["execute_pending_union_us"], 6)
        self.assertFalse(report["tpu_latency_prediction"])

    def test_dependencies_errors_and_partial_capture(self):
        report = build_profile_report(
            {
                "traceEvents": [
                    event("H2D", 0, 1, 1, output_buffers="10,11"),
                    event(
                        "Execute",
                        1,
                        1,
                        2,
                        input_buffers="10,11,99",
                        output_buffers="12",
                    ),
                    event("Execute", 2, 1, 3, input_buffers="12", output_buffers="13"),
                    event(
                        "ready",
                        2,
                        4,
                        3,
                        incomplete="1",
                        dropped_events="7",
                        error="failed",
                    ),
                ]
            }
        )
        self.assertEqual(len(report["buffer_dependency_edges"]), 3)
        self.assertEqual(
            report["buffer_dependency_edges"][-1],
            {"producer": "2", "consumer": "3", "buffer_id": "12"},
        )
        self.assertEqual(report["buffers_produced_outside_capture"], ["99"])
        self.assertEqual(report["incomplete_events"], 1)
        self.assertEqual(report["dropped_events"], 7)
        self.assertEqual(report["errors"], [{"operation": "ready", "error": "failed"}])


if __name__ == "__main__":
    unittest.main()
