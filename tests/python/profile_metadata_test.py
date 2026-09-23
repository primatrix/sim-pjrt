"""Compiler debug annotations remain separate from bundle timing."""
import unittest
from profile_metadata import hlo_profile_metadata, annotate_timeline
from bundle_timing import compose_final_bundles, parse_bundles, estimate_bundles


class ProfileMetadataTest(unittest.TestCase):
    def test_source_tables_and_exact_aliases(self):
        text = '''HloModule model

FileNames
1 "/src/model.py"

FileLocations
1 {file_name_id=1 line=42 column=7}

StackFrames
9 {file_location_id=1 parent_frame_id=0}

ENTRY %main {
 %fusion.1 = f32[8] fusion(%x), metadata={op_name="jit(model)/layer/add" stack_frame_id=9}
 %fusion.2 = f32[8] fusion(%x), metadata={op_name="jit(model)/other/mul" source_file="/src/other.py" source_line=8}
}
'''
        metadata = hlo_profile_metadata(text)
        self.assertEqual(metadata['fusion.1']['source'], '/src/model.py:42')
        self.assertEqual(metadata['fusion.1']['tf_op'], 'jit(model)/layer/add:')
        self.assertEqual(metadata['fusion.2']['source'], '/src/other.py:8')
        timeline = [dict(name=n, track='XLA Ops', start_ns=1, end_ns=9)
                    for n in ('fusion.1', 'fusion.2', 'unknown')]
        annotate_timeline(timeline, metadata)
        self.assertEqual(timeline[1]['tf_op'], 'jit(model)/other/mul:')
        self.assertNotIn('source', timeline[2])
        self.assertTrue(all(e['start_ns'] == 1 and e['end_ns'] == 9 for e in timeline))

    def test_tlp_is_traceme_without_losing_cost(self):
        program = compose_final_bundles({
            'TLP': parse_bundles('0: { sadd 1, 2 }\n1: { inlined_call /* fusion.1 */ }'),
            'fusion.1': parse_bundles('0: { vadd 1, 2 }'),
        })
        r = estimate_bundles(program, {'frequency_hz': 1e9, 'bundle_issue_cycles': 1})
        self.assertEqual(r['modeled_cycles'], 2)
        self.assertEqual([(e['track'], e['name']) for e in r['activity_timeline']],
                         [('XLA TraceMe', 'TLP'), ('XLA Ops', 'fusion.1')])


if __name__ == '__main__':
    unittest.main()
