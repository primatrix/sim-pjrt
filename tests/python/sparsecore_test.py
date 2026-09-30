import unittest

from sim_pjrt.llo.sparsecore import (calibrate_operations, control_flow_metadata,
                        mark_unmodeled, offload_inventory, operation_key, bound_offloads)


class SparseCoreTest(unittest.TestCase):
    def test_segment_bounds_do_not_enumerate_conditional_combinations(self):
        calls, nodes, metadata, samples = [], {}, {}, []
        for i in range(6):
            branches = [f'c{i}_false', f'c{i}_true']
            nodes.update(control_flow_metadata(f"""ENTRY %main (x: pred[]) -> f32[8] {{
 %cond{i} = f32[8] conditional(%x, %a, %b), branch_computations={{%{branches[0]}, %{branches[1]}}}
}}"""))
            for branch, size, duration in zip(branches, (8, 16), (10, 20)):
                calls.append(dict(call=branch + '_call', op=branch, computation=branch,
                                  entry=False, core_ids=[0, 1], offload_type='OFFLOAD_COLLECTIVE'))
                metadata[branch] = {'hlo_text': f'%reduce = f32[{size}] all-reduce(%p)'}
                samples.append(dict(op=branch, duration_ns=duration))
        calibration = calibrate_operations(calls, metadata, samples)
        report = dict(profile={'frequency_hz': 1e9}, modeled_seconds=10e-9,
                      activity_timeline=[], assumptions=[])
        bound_offloads(report, calls, nodes, metadata, calibration)
        self.assertAlmostEqual(report['modeled_seconds'], 130e-9)
        self.assertEqual(len(report['sparsecore']['runtime_segments']), 6)
        self.assertEqual(report['sparsecore']['aligned_calls'], 6)
        self.assertFalse(report['sparsecore']['missing'])
        self.assertNotIn('branch_cases', report)

    def test_call_metadata_is_not_execution_timing(self):
        calls = offload_inventory('''%collective (x: f32[8]) -> f32[8] {
 ROOT %all-reduce.1 = f32[8] all-reduce(%x)
}, execution_thread="sparsecore"
ENTRY %main (x: f32[8]) -> f32[8] {
 %launch = ((), ()) call-start(), async_execution_thread="sparsecore", to_apply=%collective, backend_config={"sparse_core_config":{"offload":"OFFLOAD_COLLECTIVE","core_ids":["0","1"]}}
 ROOT %result = f32[8] call-done(%launch)
}
''')
        self.assertEqual(len(calls), 1)
        self.assertEqual(calls[0]['op'], 'all-reduce.1')
        self.assertEqual(calls[0]['core_ids'], [0, 1])
        report = dict(status='modeled', estimated_seconds=1, modeled_seconds=1,
                      gaps=[], activity_timeline=[])
        mark_unmodeled(report, calls, [])
        self.assertEqual(report['status'], 'partial')
        self.assertIsNone(report['estimated_seconds'])
        self.assertEqual(report['modeled_seconds'], 1)
        self.assertEqual(report['activity_timeline'], [])
        self.assertIn('SparseCore', report['gaps'][0]['reason'])

    def test_calibrated_calls_are_serialized_after_tensorcore(self):
        call = dict(call='launch', op='reduce', core_ids=[0, 1],
                    offload_type='OFFLOAD_COLLECTIVE', computation='main', entry=True)
        metadata = {'reduce': {'hlo_text': '%reduce = f32[8] all-reduce(%p)'}}
        def event(name, start, end):
            return dict(name=name, track='XLA Ops', start_ns=start, end_ns=end)
        report = dict(profile={'frequency_hz': 1e9}, modeled_seconds=40e-9,
                      activity_timeline=[event('input', 0, 10),
                                         event('independent', 10, 30),
                                         event('consumer', 30, 40)],
                      gaps=[], assumptions=[])
        mark_unmodeled(report, [call], [])
        calibration = calibrate_operations([call], metadata,
            [{'op': 'reduce', 'duration_ns': 50}])
        bound_offloads(report, [call], {}, metadata, calibration)
        tc = [e for e in report['activity_timeline'] if e['track'] == 'XLA Ops']
        self.assertEqual([(e['start_ns'], e['end_ns']) for e in tc], [(0, 10), (10, 30), (30, 40)])
        sc = [e for e in report['activity_timeline'] if e['track'] == 'Sparse Core Ops']
        self.assertEqual(len(sc), 2)
        self.assertEqual({e['sparse_core'] for e in sc}, {0, 1})
        self.assertTrue(all((e['start_ns'], e['end_ns']) == (40, 90) for e in sc))
        self.assertEqual(report['sparsecore']['added_critical_path_ns'], 50)
        self.assertEqual(report['sparsecore']['aligned_calls'], 1)
        self.assertEqual(report['sparsecore']['missing'], [])
        self.assertEqual(report['status'], 'partial')

    def test_calibration_does_not_match_other_shape(self):
        call = dict(op='reduce', core_ids=[0], offload_type='OFFLOAD_COLLECTIVE')
        key = operation_key(call, {'reduce': {'hlo_text': '%reduce = f32[8] all-reduce(%p)'}})
        other = operation_key(call, {'reduce': {'hlo_text': '%reduce = f32[16] all-reduce(%p)'}})
        self.assertNotEqual(key, other)
        with self.assertRaises(ValueError):
            calibrate_operations([call], {}, [{'op': 'reduce', 'duration_ns': float('nan')}])

    def test_unknown_loop_multiplicity_remains_a_gap(self):
        call = dict(call='launch', op='reduce', core_ids=[0],
                    offload_type='OFFLOAD_COLLECTIVE', computation='loop_body', entry=False)
        metadata = {'reduce': {'hlo_text': '%reduce = f32[8] all-reduce(%p)'}}
        calibration = calibrate_operations([call], metadata, [{'op': 'reduce', 'duration_ns': 50}])
        report = dict(profile={'frequency_hz': 1e9}, modeled_seconds=10e-9,
                      activity_timeline=[], gaps=[], assumptions=[])
        mark_unmodeled(report, [call], [])
        bound_offloads(report, [call], {}, metadata, calibration)
        self.assertEqual(report['activity_timeline'], [])
        self.assertEqual(report['sparsecore']['aligned_calls'], 0)
        self.assertIn('unbound loop or call multiplicity', report['sparsecore']['missing'][0]['reason'])


if __name__ == '__main__':
    unittest.main()
