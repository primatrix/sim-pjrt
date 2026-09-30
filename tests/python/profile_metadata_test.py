"""Compiler labels and conservative HLO loop bounds."""
import unittest
from sim_pjrt.llo.metadata import hlo_profile_metadata, annotate_timeline, hlo_loop_bounds


class ProfileMetadataTest(unittest.TestCase):
    def test_relative_loop_bound_requires_preserved_input_and_unit_step(self):
        hlo = '''HloModule loop
%body (p: (s32[], s32[])) -> (s32[], s32[]) {
 %p = (s32[], s32[]) parameter(0)
 %i = s32[] get-tuple-element(%p), index=0
 %x = s32[] get-tuple-element(%p), index=1
 %one = s32[] constant(1)
 %next = s32[] add(%i, %one)
 ROOT %out = (s32[], s32[]) tuple(%next, %x)
}
%cond (q: (s32[], s32[])) -> pred[] {
 %q = (s32[], s32[]) parameter(0)
 %ci = s32[] get-tuple-element(%q), index=0
 %cx = s32[] get-tuple-element(%q), index=1
 %three = s32[] constant(3)
 %stop = s32[] add(%cx, %three)
 ROOT %test = pred[] compare(%ci, %stop), direction=LT
}
ENTRY %main (input: s32[]) -> (s32[], s32[]) {
 %input = s32[] parameter(0)
 %copy = s32[] copy(%input)
 %init = (s32[], s32[]) tuple(%copy, %input)
 ROOT %loop = (s32[], s32[]) while(%init), condition=%cond, body=%body
}
'''
        self.assertEqual(hlo_loop_bounds(hlo)['next'], 3)
        for old, new in [('constant(1)', 'constant(2)'),
                         ('tuple(%next, %x)', 'tuple(%next, %next)'),
                         ('tuple(%copy, %input)', 'tuple(%one, %input)'),
                         ('direction=LT', 'direction=LE'),
                         ('constant(3)', 'constant(-3)')]:
            with self.subTest(change=new):
                self.assertFalse(hlo_loop_bounds(hlo.replace(old, new)))

    def test_hlo_c_escapes_in_parameter_names_and_source_paths(self):
        text = r'''HloModule model

FileNames
1 "/src/模型\'s\040forward.py"

FileLocations
1 {file_name_id=1 line=12 column=1}

StackFrames
1 {file_location_id=1 parent_frame_id=0}

ENTRY %main {
 %weights = bf16[3584,3584] parameter(0), metadata={op_name="weights[\'model.layers.0.self_attn.o_proj.weight\']" stack_frame_id=1}
 %fusion = bf16[3584] fusion(%weights), metadata={op_name="layer\x2fattention\t\"out\"" source_file="C:\\model.py" source_line=8}
}
'''
        metadata = hlo_profile_metadata(text)
        self.assertEqual(metadata['weights']['tf_op'], "weights['model.layers.0.self_attn.o_proj.weight']:")
        self.assertEqual(metadata['weights']['source'], "/src/模型's forward.py:12")
        self.assertEqual(metadata['fusion']['tf_op'], 'layer/attention\t"out":')
        self.assertEqual(metadata['fusion']['source'], 'C:\\model.py:8')

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


if __name__ == '__main__':
    unittest.main()
