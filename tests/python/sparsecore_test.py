import unittest

from sparsecore import (align_offloads, branch_variants, calibrate_operations,
                        mark_unmodeled, offload_inventory, operation_key)


class SparseCoreTest(unittest.TestCase):
    def test_branch_cases_bind_inputs_and_exclude_inactive_calls(self):
        nodes = {
            'pred': dict(opcode='parameter', inputs=[], computation='main',
                         entry=True, parameter=3, scalar_predicate=True),
            'selector': dict(opcode='convert', inputs=['pred'], computation='main', entry=True),
            'input': dict(opcode='fusion', inputs=[], computation='main', entry=True),
            'tuple': dict(opcode='tuple', inputs=['input'], computation='main', entry=True),
            'cond': dict(opcode='conditional', inputs=['selector', 'tuple', 'tuple'],
                         computation='main', entry=True, branches=['false', 'true']),
            'consumer': dict(opcode='fusion', inputs=['cond'], computation='main', entry=True),
        }
        calls, metadata = [], {}
        for branch, shape in [('false', 8), ('true', 16)]:
            for name, opcode, inputs, extra in [
                ('param', 'parameter', [], dict(parameter=0)),
                ('get', 'get-tuple-element', [branch + '_param'], dict(index=0)),
                ('update', 'call-update', [branch + '_launch', branch + '_get'], {}),
                ('done', 'call-done', [branch + '_update'], dict(root=True)),
            ]:
                nodes[branch + '_' + name] = dict(opcode=opcode, inputs=inputs,
                                                 computation=branch, entry=False, **extra)
            calls.append(dict(call=branch + '_launch', op=branch + '_reduce',
                              computation=branch, entry=False, core_ids=[0],
                              offload_type='OFFLOAD_COLLECTIVE'))
            metadata[branch + '_reduce'] = {'hlo_text': f'%reduce = f32[{shape}] all-reduce(%p)'}
        calibration = calibrate_operations(calls, metadata, [
            dict(op='false_reduce', duration_ns=20), dict(op='true_reduce', duration_ns=50)])
        report = dict(profile={'frequency_hz': 1e9}, modeled_seconds=20e-9,
                      activity_timeline=[dict(name='input', track='XLA Ops', start_ns=0, end_ns=10),
                                         dict(name='consumer', track='XLA Ops', start_ns=10, end_ns=20)],
                      gaps=[], assumptions=[])
        branch_variants(report, calls, nodes, metadata, calibration)
        self.assertEqual(report['branch_parameters'], [3])
        for case, branch, duration in zip(report['branch_cases'], ['false', 'true'], [20, 50]):
            sc = [e for e in case['activity_timeline'] if e['track'] == 'Sparse Core Ops']
            self.assertEqual([(e['name'], e['start_ns'], e['end_ns']) for e in sc],
                             [(branch + '_reduce', 10, 10 + duration)])
            self.assertEqual(case['duration_ns'], 20 + duration)
            self.assertEqual(case['sparsecore']['missing'], [])
        # A separate unresolved computation is still a gap in every case.
        unknown = dict(calls[0], call='unknown_launch', computation='loop_body')
        branch_variants(report, calls + [unknown], nodes, metadata, calibration)
        for case in report['branch_cases']:
            self.assertEqual(case['sparsecore']['missing'][0]['call'], 'unknown_launch')
        # A selector computed from data must not be guessed from the profile.
        nodes['pred']['scalar_predicate'] = False
        report.pop('branch_cases')
        report.pop('branch_parameters')
        branch_variants(report, calls, nodes, metadata, calibration)
        self.assertNotIn('branch_cases', report)
        # Shared computations need call-site-specific binding, not overwriting.
        nodes['pred']['scalar_predicate'] = True
        nodes['other_cond'] = dict(nodes['cond'])
        branch_variants(report, calls, nodes, metadata, calibration)
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

    def test_no_sparsecore_leaves_report_unchanged(self):
        report = {}
        mark_unmodeled(report, [], [])
        self.assertEqual(report, {})

    def test_input_ready_overlap_and_consumer_wait(self):
        call = dict(call='launch', op='reduce', core_ids=[0, 1],
                    offload_type='OFFLOAD_COLLECTIVE', entry=True)
        nodes = {
            'input': dict(opcode='fusion', inputs=[]),
            'update': dict(opcode='call-update', inputs=['launch', 'input']),
            'done': dict(opcode='call-done', inputs=['update']),
            'independent': dict(opcode='fusion', inputs=[]),
            'consumer': dict(opcode='fusion', inputs=['done']),
        }
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
        align_offloads(report, [call], nodes, metadata, calibration)
        tc = [e for e in report['activity_timeline'] if e['track'] == 'XLA Ops']
        self.assertEqual([(e['start_ns'], e['end_ns']) for e in tc], [(0, 10), (10, 30), (60, 70)])
        sc = [e for e in report['activity_timeline'] if e['track'] == 'Sparse Core Ops']
        self.assertEqual(len(sc), 2)
        self.assertEqual({e['sparse_core'] for e in sc}, {0, 1})
        self.assertTrue(all((e['start_ns'], e['end_ns']) == (10, 60) for e in sc))
        self.assertEqual(report['sparsecore']['added_critical_path_ns'], 30)
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

    def test_unexecuted_branch_is_not_scheduled(self):
        call = dict(call='launch', op='reduce', core_ids=[0],
                    offload_type='OFFLOAD_COLLECTIVE', entry=False)
        metadata = {'reduce': {'hlo_text': '%reduce = f32[8] all-reduce(%p)'}}
        calibration = calibrate_operations([call], metadata, [{'op': 'reduce', 'duration_ns': 50}])
        report = dict(profile={'frequency_hz': 1e9}, modeled_seconds=10e-9,
                      activity_timeline=[], gaps=[], assumptions=[])
        mark_unmodeled(report, [call], [])
        align_offloads(report, [call], {}, metadata, calibration)
        self.assertEqual(report['activity_timeline'], [])
        self.assertEqual(report['sparsecore']['aligned_calls'], 0)
        self.assertIn('execution path', report['sparsecore']['missing'][0]['reason'])


if __name__ == '__main__':
    unittest.main()
