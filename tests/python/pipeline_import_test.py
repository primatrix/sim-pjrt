"""Keep raw LLO identity and distinguish reconstructed times from measurements."""
from pathlib import Path
import tempfile
import unittest

from sim_pjrt.profiling.timeline import read_xplane
from sim_pjrt.profiling.xplane_pb2 import XSpace


class PipelineImportTest(unittest.TestCase):
    def test_instructions_are_opt_in_with_picosecond_fields(self):
        s = XSpace()
        p = s.planes.add(id=3, name='/device:TPU:0')
        p.event_metadata[1].name = 'vmatmul.mubr'
        p.stat_metadata[1].name = 'bundle_number'
        p.stat_metadata[2].name = 'details'
        p.stat_metadata[3].name = 'vmatmul.mubr %a'
        line = p.lines.add(id=9, name='MXU0 Instructions', timestamp_ns=1000)
        e = line.events.add(metadata_id=1, offset_ps=1234, duration_ps=525)
        e.stats.add(metadata_id=1, int64_value=10708)
        e.stats.add(metadata_id=2, ref_value=3)
        with tempfile.TemporaryDirectory() as d:
            path = Path(d) / 'profile.xplane.pb'
            path.write_bytes(s.SerializeToString())
            self.assertFalse(any(e['ph'] == 'X' for e in read_xplane(path)['traceEvents']))
            trace = read_xplane(path, include_instructions=True)
        event = next(e for e in trace['traceEvents'] if e['ph'] == 'X')
        self.assertEqual(event['args']['bundle_number'], 10708)
        self.assertEqual(event['args']['details'], 'vmatmul.mubr %a')
        self.assertEqual(event['args']['xplane_duration_ps'], 525)
        self.assertEqual(event['args']['timestamp_provenance'], 'xprof_reconstructed')
        self.assertAlmostEqual(event['ts'], .001234)


if __name__ == '__main__':
    unittest.main()
