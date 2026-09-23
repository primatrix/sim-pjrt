"""Check shard-local work and endpoint-versus-route traffic accounting."""

import unittest

from device_load import summarize_device_load
from replay_test import dot_program, scenario
from virtual_clock_test import network
from workload import Workload


class DeviceLoadTest(unittest.TestCase):
    def test_partitioned_dot_and_collective_counts(self):
        model = Workload(dot_program(), (0, 1), scenario(), network())
        report = summarize_device_load(model.lower())
        for row in report["devices"].values():
            self.assertEqual(row["estimated_dot_flops_by_dtype"], {"BF16": 48})
            self.assertEqual(row["estimated_hlo_read_bytes"], 32)
            self.assertEqual(row["estimated_hlo_write_bytes"], 24)
            self.assertEqual(row["estimated_hlo_duration_ns"], 56)
            self.assertEqual(row["device_send_bytes"], 24)
            self.assertEqual(row["device_receive_bytes"], 24)
            self.assertEqual(row["collective_count"], 1)
            self.assertEqual(row["top_hlo_by_dot_flops"][0]["logical_bytes"], 56)
        self.assertFalse(report["complete_work_estimate"])

    def test_unknown_work_is_not_a_zero_flop_estimate(self):
        snapshot = dot_program()
        del snapshot["hlo"]["computations"][0]["instructions"][-1]["sharding"]
        model = Workload(snapshot, (0, 1), scenario(), network())
        events = model.lower()
        unknown = [e for e in events if e.metadata.get("cost_status") == "unknown"]
        self.assertEqual(len(unknown), 2)
        self.assertTrue(all(e.metadata["dot_flops"] is None for e in unknown))
        for row in summarize_device_load(events)["devices"].values():
            self.assertEqual(row["hlo_cost_gap_counts"], {"unknown sharding": 1})
            self.assertEqual(row["estimated_dot_flops_by_dtype"], {})
            self.assertEqual(row["top_hlo_by_dot_flops"], [])

    def test_multiple_hops_do_not_multiply_endpoint_bytes(self):
        comm = network(3)
        comm.routes["0>2"] = ["link:0>1", "link:1>2"]
        events = comm.transfer("copy", 0, 2, 100)
        events += [comm.host_transfer("upload", 0, 200, "h2d")]
        events += [comm.host_transfer("download", 2, 50, "d2h")]
        report = summarize_device_load(events)
        self.assertEqual(report["devices"]["0"]["device_send_bytes"], 100)
        self.assertEqual(report["devices"]["2"]["device_receive_bytes"], 100)
        self.assertEqual(report["devices"]["0"]["h2d_bytes"], 200)
        self.assertEqual(report["devices"]["2"]["d2h_bytes"], 50)
        self.assertEqual(
            report["routed_link_bytes"], {"link:0>1": 100, "link:1>2": 100}
        )

    def test_repeated_executions_accumulate_work(self):
        events = Workload(dot_program(False), (0, 1), scenario(), network()).lower()
        report = summarize_device_load(events * 3)
        row = report["devices"]["0"]
        self.assertEqual(row["estimated_dot_flops_by_dtype"], {"BF16": 144})
        self.assertEqual(row["estimated_hlo_read_bytes"], 120)
        self.assertEqual(row["top_hlo_by_dot_flops"][0]["occurrences"], 3)
        self.assertEqual(row["collective_count"], 0)


if __name__ == "__main__":
    unittest.main()
