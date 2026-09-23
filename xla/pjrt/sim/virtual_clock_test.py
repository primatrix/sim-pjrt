"""Hand-computed causal and resource-contention checks for virtual timing."""

import unittest

from communication import Communication, Link
from virtual_clock import Event, simulate, summarize, trace_viewer


def network(devices=2):
    return Communication(
        {
            "links": {
                f"link:{a}>{b}": {"latency_ns": 1, "bytes_per_second": 1e9}
                for a in range(devices)
                for b in range(devices)
                if a != b
            },
            "routes": {
                f"{a}>{b}": [f"link:{a}>{b}"]
                for a in range(devices)
                for b in range(devices)
                if a != b
            },
            "host_link": {"latency_ns": 1, "bytes_per_second": 1e9},
            "communication_uses_hbm": False,
        }
    )


class VirtualClockTest(unittest.TestCase):
    def test_host_device_overlap_and_serial_dispatch(self):
        def run(serial):
            return simulate(
                [
                    Event("h1", "host", 4, resources=("host",)),
                    Event("c1", "compute", 6, ("h1",), ("compute",)),
                    Event("h2", "host", 4, ("c1" if serial else "h1",), ("host",)),
                    Event("c2", "compute", 6, ("h2",), ("compute",)),
                ]
            )

        self.assertEqual(summarize(run(False))["makespan_ns"], 16)
        self.assertEqual(summarize(run(True))["makespan_ns"], 20)
        self.assertEqual(run(False)[-1].blocked_by, "c1")
        self.assertEqual(run(False)[-1].start_ns - run(False)[-1].ready_ns, 2)

    def test_late_participant_and_two_device_all_reduce(self):
        events = [Event("a", "arrival"), Event("b", "arrival", release_ns=50)]
        events += network().ring("r", "all-reduce", (0, 1), 100, {0: "a", 1: "b"})
        schedule = simulate(events)
        # Two rounds, each sends 50 bytes on independent full-duplex links.
        self.assertEqual(summarize(schedule)["makespan_ns"], 50 + 2 * (1 + 50))
        self.assertTrue(
            all(e.start_ns >= 50 for e in schedule if "/round" in e.event.id)
        )

    def test_all_gather_reduce_scatter_and_singleton(self):
        for kind, expected in (("all-gather", 33), ("reduce-scatter", 12)):
            events = [Event(str(d), "arrival") for d in range(4)]
            events += network(4).ring(
                "r", kind, range(4), 10, {d: str(d) for d in range(4)}
            )
            self.assertEqual(summarize(simulate(events))["makespan_ns"], expected)
        events = [Event("a", "arrival", release_ns=7)]
        events += network().ring("r", "all-reduce", [0], 10, {0: "a"})
        self.assertEqual(summarize(simulate(events))["makespan_ns"], 7)

    def test_shared_route_contends_and_independent_links_overlap(self):
        comm = network(3)
        comm.routes["0>2"] = ["link:0>1", "link:1>2"]
        events = comm.transfer("a", 0, 2, 9) + comm.transfer("b", 0, 1, 9)
        schedule = simulate(events)
        result = {e.event.id: e for e in schedule}
        self.assertEqual(result["a"].end_ns, 20)
        self.assertEqual(result["b"].end_ns, 20)
        self.assertEqual(result["b/hop0"].start_ns, 10)

    def test_resource_arbitration_is_deterministic_and_zero_nodes_do_not_reserve(self):
        events = [
            Event("slow", "work", 10, resources=("r",)),
            Event("zero", "alias", resources=("r",)),
            Event("fast", "work", 1, resources=("s",)),
            Event("after", "work", 1, ("fast",), ("r",)),
        ]
        expected = simulate(events)
        self.assertEqual(next(e for e in expected if e.event.id == "zero").start_ns, 0)
        for _ in range(4):
            self.assertEqual(simulate(events), expected)
        trace = trace_viewer(expected)
        self.assertTrue(
            all(
                e["args"]["clock_domain"] == "simulated"
                for e in trace["traceEvents"]
                if e["ph"] == "X"
            )
        )

    def test_invalid_graph_and_cost_fail_closed(self):
        for events in (
            [Event("a", "a"), Event("a", "a")],
            [Event("a", "a", dependencies=("missing",))],
            [
                Event("a", "a", dependencies=("b",)),
                Event("b", "b", dependencies=("a",)),
            ],
            [Event("a", "a", -1)],
            [Event("a", "a", float("nan"))],
        ):
            with self.assertRaises(ValueError):
                simulate(events)
        for bandwidth in (0, -1, float("inf"), float("nan")):
            with self.assertRaises(ValueError):
                Link(1, bandwidth)
        with self.assertRaises(ValueError):
            network().transfer("x", 0, 9, 10)
        with self.assertRaises(ValueError):
            network().ring("x", "all-reduce", [0, 1], 10, {0: "a"})


if __name__ == "__main__":
    unittest.main()
