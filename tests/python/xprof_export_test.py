"""Verify simulated XSpace serialization and the actual XProf Trace Viewer path."""

import json
import tempfile
import unittest
from pathlib import Path

from profile_report import load_trace
from virtual_clock import Event, ScheduledEvent, simulate
from xprof_export import EPOCH_NS, build_xspace, export_xprof, xspace_class


def example():
    return simulate(
        [
            Event("host", "submit", 3, resources=("host-thread:1:2",)),
            Event(
                "dot",
                "matmul",
                17,
                ("host",),
                ("compute:0", "hbm:0"),
                metadata={"device": 0, "dot_flops": 96, "hlo_id": "original-dot"},
            ),
            Event(
                "copy",
                "H2D",
                10,
                ("host",),
                ("host:h2d", "dma:1:h2d"),
                metadata={"device": 1, "transfer_kind": "h2d", "bytes": 64},
            ),
            Event("hop", "ICI transfer", 11, ("dot",), ("ici:0>1",)),
            Event(
                "unknown",
                "Pallas cost unknown",
                dependencies=("hop",),
                metadata={"device": 1, "cost_status": "unknown", "dot_flops": None},
            ),
        ]
    )


class XprofExportTest(unittest.TestCase):
    def test_integer_timing_metadata_and_determinism(self):
        schedule = example()
        space = build_xspace(schedule)
        events = {}
        for plane in space.planes:
            for line in plane.lines:
                self.assertEqual(line.timestamp_ns, EPOCH_NS)
                for event in line.events:
                    name = plane.event_metadata[event.metadata_id].name
                    events[name] = event
                    stats = {
                        plane.stat_metadata[s.metadata_id].name: s for s in event.stats
                    }
                    self.assertEqual(stats["clock_domain"].str_value, "simulated")
                    self.assertEqual(
                        stats["complete_latency_prediction"].int64_value, 0
                    )
        self.assertEqual(len(events), len(schedule))
        self.assertEqual(events["matmul"].offset_ps, 3000)
        self.assertEqual(events["matmul"].duration_ps, 17000)
        self.assertEqual(events["Pallas cost unknown"].duration_ps, 0)
        self.assertEqual(
            space.SerializeToString(deterministic=True),
            build_xspace(reversed(schedule)).SerializeToString(deterministic=True),
        )

    def test_xprof_converter_preserves_virtual_events(self):
        with tempfile.TemporaryDirectory() as directory:
            path = export_xprof(example(), directory)
            self.assertEqual(
                path.relative_to(directory).as_posix(),
                "plugins/profile/simulated/pjrt-simulator.xplane.pb",
            )
            decoded = xspace_class().FromString(path.read_bytes())
            self.assertIn("virtual-time", decoded.warnings[0])
            trace = load_trace(directory)
        events = {
            e["name"]: e
            for e in trace["traceEvents"]
            if e.get("args", {}).get("clock_domain") == "simulated"
        }
        self.assertEqual(len(events), 5)
        self.assertAlmostEqual(events["submit"]["ts"], EPOCH_NS / 1000)
        self.assertAlmostEqual(events["matmul"]["dur"], 0.017)
        self.assertAlmostEqual(events["matmul"]["ts"] - events["submit"]["ts"], 0.003)
        self.assertEqual(int(events["matmul"]["args"]["dot_flops"]), 96)
        self.assertEqual(
            json.loads(events["matmul"]["args"]["resources"]), ["compute:0", "hbm:0"]
        )
        self.assertEqual(events["Pallas cost unknown"]["args"]["dot_flops"], "null")
        names = [
            e.get("args", {}).get("name", "")
            for e in trace["traceEvents"]
            if e.get("ph") == "M"
        ]
        self.assertTrue(any("Simulated TPU device 0" in name for name in names))
        self.assertTrue(any("Simulated TPU device 1" in name for name in names))
        self.assertTrue(any("Simulated communication" in name for name in names))

    def test_invalid_intervals_and_missing_schema(self):
        with self.assertRaisesRegex(ValueError, "Invalid virtual interval"):
            build_xspace([ScheduledEvent(Event("bad", "bad"), -1, 1, 0, None)])
        with self.assertRaisesRegex(ValueError, "picosecond range"):
            build_xspace([ScheduledEvent(Event("large", "large"), 0, 2**63, 0, None)])
        with (
            tempfile.TemporaryDirectory() as directory,
            self.assertRaisesRegex(FileNotFoundError, "xplane_descriptor"),
        ):
            build_xspace([], Path(directory) / "missing.pb")
        self.assertEqual(len(build_xspace([]).planes), 0)


if __name__ == "__main__":
    unittest.main()
