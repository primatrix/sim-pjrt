"""Native collection keeps observed host events and adds aligned device estimates."""

import unittest

from native_profile import model_profile
from replay_test import dot_program, scenario
from virtual_clock import Event, ScheduledEvent
from xprof_export import Plane, xspace_class


def captured_profile():
    space = xspace_class()()
    plane = Plane(
        space.planes.add(id=0, name="/device:CUSTOM:0 PJRT host (CPU wall time)")
    )
    for correlation, start in ((1, 100), (2, 1000)):
        metadata = {
            "program_id": 7,
            "num_devices": 2,
            "num_replicas": 1,
            "correlation_id": correlation,
            "detail": "jit_jitted_run_model",
            "input_buffers": "1,2,3,4",
            "output_buffers": f"{10 + correlation * 2},{11 + correlation * 2}",
            "incomplete": 0,
        }
        call = Event(f"call{correlation}", "PJRT Execute submit", metadata=metadata)
        plane.add_event(
            "host", ScheduledEvent(call, start, start + 9, start, None), 2000
        )
        for device in (0, 1):
            pending = Event(
                f"pending{correlation}:{device}",
                "Execute submit-to-ready",
                metadata={
                    "correlation_id": correlation,
                    "device_id": device,
                    "incomplete": 0,
                },
            )
            plane.add_event(
                f"device{device}",
                ScheduledEvent(pending, start, start + 30, start, None),
                2000,
            )
    # This is an observed input profile, not the virtual exporter used to build the fixture.
    for line in plane.proto.lines:
        line.timestamp_ns = 1_700_000_000_000_000_000
        for event in line.events:
            for stat in event.stats:
                if plane.proto.stat_metadata[stat.metadata_id].name == "clock_domain":
                    stat.str_value = "cpu_wall"
    framework = space.planes.add(id=20, name="/host:CPU")
    framework.event_metadata[1].id = 1
    framework.event_metadata[1].name = "forward_batch_generation"
    framework.lines.add(id=1, timestamp_ns=1_700_000_000_000_000_000).events.add(
        metadata_id=1, offset_ps=90000, duration_ps=1000000
    )
    return space


class NativeProfileTest(unittest.TestCase):
    def test_one_capture_preserves_host_and_aligns_device_scopes(self):
        original = captured_profile()
        original_bytes = [
            p.SerializeToString(deterministic=True) for p in original.planes
        ]
        result = model_profile(original, {7: dot_program(False)}, scenario())
        self.assertEqual(
            original_bytes,
            [p.SerializeToString(deterministic=True) for p in result.planes[:2]],
        )
        scopes = []
        for plane in result.planes[2:]:
            self.assertNotIn("Simulated host", plane.name)
            for line in plane.lines:
                self.assertEqual(line.timestamp_ns, 1_700_000_000_000_000_000)
                if line.name == "Executions":
                    scopes += list(line.events)
                    self.assertEqual(
                        [e.offset_ps for e in line.events], [104000, 1004000]
                    )
                    self.assertEqual(
                        [e.duration_ps for e in line.events], [52000, 52000]
                    )
        self.assertEqual(len(scopes), 4)
        self.assertTrue(any("CPU-driven" in warning for warning in result.warnings))

    def test_program_capture_is_required(self):
        with self.assertRaises(KeyError):
            model_profile(captured_profile(), {}, scenario())
        empty = xspace_class()()
        self.assertEqual(len(model_profile(empty, {}, scenario()).planes), 0)


if __name__ == "__main__":
    unittest.main()
