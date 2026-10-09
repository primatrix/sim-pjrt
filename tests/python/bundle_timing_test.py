"""Behavior regressions for bundle timing; no TPU required."""

from pathlib import Path
import copy
import json
import unittest
import os
import subprocess
import sys
import tempfile
from unittest.mock import patch

from sim_pjrt.llo.control_flow import resolve_scalar_operands
from sim_pjrt.llo.runtime import estimate_bundles
from sim_pjrt.llo.parser import expand_path, parse_bundles
from sim_pjrt.llo.program import compose_final_bundles, estimate_final_program

PROFILE = {"frequency_hz": 1e9, "bundle_issue_cycles": 1}
FIXTURES = Path(__file__).resolve().parents[1] / "fixtures" / "bundles"


class BundleTimingTest(unittest.TestCase):
    def test_native_cli_manifest_uses_execution_model_and_summary_contract(self):
        # Exercise the exact module/arguments launched by FinalizeBundles.
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            llo = root / '1-TLP-00-final_bundles.txt'
            llo.write_text('0: { vdelay 100 }\n1: { %v0 = vadd.f32 %input, 1.0 }')
            dedup = root / '1-TLP-01-deduplication-map.txt'
            dedup.write_text('key:TLP\nordinal:0\nequivalent_hlos[size=0]:\n')
            manifest = root / 'manifest.json'
            manifest.write_text(json.dumps({'files': [str(llo), str(dedup)], 'topology': 'tpu7x'}))
            profile = root / 'profile.json'
            profile.write_text(json.dumps(dict(PROFILE, vdelay_semantics='total_cycles', instruction_timeline=True)))
            output = root / 'report.json'
            env = dict(os.environ)
            env.pop('PJRT_SIM_LIBTPU_PATH', None)
            subprocess.run([sys.executable, '-m', 'bundle_timing', str(manifest),
                            '--profile', str(profile), '--summary', '--output', str(output)],
                           check=True, env=env, capture_output=True, text=True)
            report = json.loads(output.read_text())
        self.assertEqual(report['execution_engine'], 'gf_instruction_pipeline')
        self.assertEqual(report['bundle_stage'], 'final_bundles')
        self.assertEqual(report['scheduled_bundle_count'], 2)
        self.assertNotIn('events', report)
        self.assertEqual(report['status'], 'partial')
        alu = next(e for e in report['activity_timeline'] if e['name'] == 'vadd.f32')
        self.assertEqual(alu['start_ns'], 100)
        end = round(report['modeled_seconds'] * 1e9)
        for event in report['activity_timeline']:
            self.assertTrue(all(isinstance(event[k], str) for k in ('name', 'track', 'detail', 'cost_gap')))
            self.assertTrue(all(isinstance(event[k], int) for k in ('start_ns', 'end_ns', 'bytes')))
            self.assertTrue(0 <= event['start_ns'] <= event['end_ns'] <= end)

    def test_runtime_rejects_compiler_identity_mismatch_without_fallback(self):
        with patch.dict(os.environ, {}, clear=True):
            with self.assertRaisesRegex(ValueError, 'identity does not match'):
                estimate_bundles(parse_bundles('0: {}'), dict(PROFILE, compiler_binary_sha256='0'*64))

    def test_mxu_throughput_overlaps_units_and_scheduled_work(self):
        profile = dict(PROFILE, mxu_model='gf', vdelay_semantics='total_cycles')
        program = parse_bundles('''
0: { vmatmul.mubr.bf16.gmra.mrb[0].mxu0 %v0 ;; vmatmul.mubr.bf16.gmra.mrb[0].mxu1 %v1 }
1: { vdelay 3 }
2: { vmatmul.mubr.f32.gmra.mrb[4].mxu0 %v0 }
3: { vmatmul.mubr.f32.gmra.mrb[4].mxu1 %v1 }
''')
        report = estimate_bundles(program, profile)
        # GF result latency is 211 cycles; issue throughput stays 4/8.
        self.assertEqual(report['modeled_cycles'], 220)
        self.assertEqual(report['wait_stall_cycles'], 4)
        self.assertEqual([e['start_cycle'] for e in report['events']], [0, 1, 8, 9])
        self.assertEqual(report['execution_engine'], 'gf_instruction_pipeline')
        spaced = parse_bundles('''
0: { vmatmul.mubr.bf16.gmra.mrb[0].mxu0 %v0 }
1: { vdelay 20 }
2: { vmatmul.mubr.bf16.gmra.mrb[4].mxu0 %v0 }
3: { vdelay 20 }
''')
        self.assertEqual(estimate_bundles(spaced, profile)['modeled_cycles'], 232)
        for dtype, cycles in [('f32', 211), ('bf16', 211), ('f8e5m2', 204), ('f8e4m3fn', 204)]:
            single = parse_bundles(f'0: {{ vmatmul.mubr.{dtype}.gmra.mrb[0].mxu0 %v0 }}')
            self.assertEqual(estimate_bundles(single, profile)['modeled_cycles'], cycles)

    def test_mxu_delays_coissued_dma_and_honors_predicates(self):
        profile = dict(PROFILE, mxu_model='gf', dma_granule_bytes=1,
                       dma={'hbm_to_vmem': {'bytes_per_second': 1e9}})
        program = parse_bundles('''
0: { vmatmul.mubr.bf16.gmra.mrb[0].mxu0 %v0 }
1: { vmatmul.mubr.f32.gmra.mrb[4].mxu0 %v0 ;; dma.hbm_to_vmem %hbm, 20, %vmem, [#allocation0] }
2: { dma.done.wait [#allocation0], 20 }
''')
        report = estimate_bundles(program, profile)
        dma = next(e for e in report['events'] if e['kind'] == 'dma')
        self.assertEqual((dma['start_cycle'], dma['end_cycle']), (8, 28))
        self.assertEqual(report['modeled_cycles'], 219)
        self.assertEqual(report['wait_stall_cycles'], 25)
        program[0]['instructions'][0]['resolved_predicate'] = False
        skipped = estimate_bundles(program, profile)
        self.assertEqual(skipped['modeled_cycles'], 212)
        self.assertEqual(next(e for e in skipped['events'] if e['kind'] == 'dma')['start_cycle'], 1)

    def test_mxu_branch_bound_includes_occupancy_and_compact_report(self):
        modules = {'TLP': parse_bundles('''
0: { sbr.rel (%p0) target = $region1 }
1: { vmatmul.mubr.bf16.gmra.mrb[0].mxu0 %v0 }
2: { sbr.rel target = $region2 }
3: { vmatmul.mubr.f32.gmra.mrb[0].mxu1 %v1 } /* Start region 1 */
4: {} /* Start region 2 */
''')}
        profile = dict(PROFILE, mxu_model='gf', branch_delay_slots=0)
        report = estimate_final_program(modules, profile)
        self.assertEqual(report['modeled_cycles'], 213)
        self.assertEqual(report['runtime_segments'][0]['alternative_cycles'], [212, 212])
        compact = estimate_final_program(modules, profile, retain_events=False)
        for key in ('modeled_cycles', 'wait_stall_cycles', 'activity_timeline'):
            self.assertEqual(report[key], compact[key], key)
        loop = parse_bundles('''
0: { %s_seed = smov 0 }
1 LB: { %s_i = sphi %s_seed, %s_next } /* Start region 1 */
2: { vmatmul.mubr.bf16.gmra.mrb[0].mxu0 %v0 }
3: { %s_next = sadd.u32 %s_i, 1 }
4: { %p_more = scmp.lt.u32.totalorder %s_next, 1000000 }
5: { sbr.rel (%p_more) target = $region1 }
6: {}
''')
        bounded = estimate_final_program({'TLP': loop}, profile)
        self.assertEqual(bounded['modeled_cycles'], 212_000_002)
        self.assertEqual(bounded['runtime_loops'][0]['iteration_cycles'], 212)

    def test_mxu_unknown_format_or_modifiers_remain_gaps(self):
        for mnemonic in ('vmatmul.mubr.s8.mrb[0].mxu0',
                         'vmatmul.mubr.bf16.mrb[0]',
                         'vmatmul.lmr.bf16.mrb[0].mxu0'):
            report = estimate_bundles(parse_bundles(f'0: {{ {mnemonic} }}'),
                                      dict(PROFILE, mxu_model='gf'))
            self.assertEqual(report['status'], 'partial')
            self.assertTrue(any('unmapped cost' in g['reason'] for g in report['gaps']))
        with self.assertRaisesRegex(ValueError, 'unsupported mxu_model'):
            estimate_bundles(parse_bundles('0: {}'), dict(PROFILE, mxu_model='unknown'))

    def test_runtime_condition_takes_slower_dma_path_not_more_instructions(self):
        program = parse_bundles('''
0: { sbr.rel (%p_runtime) target = $region1 }
1: {}
2: {}
3: {}
4: { sbr.rel target = $region2 }
5: { dma.hbm_to_vmem %hbm, 100, %vmem, [#allocation0] } /* Start region 1 */
6: { dma.done.wait [#allocation0], 100 }
7: {} /* Start region 2 */
''')
        report = estimate_final_program({'TLP': program}, dict(PROFILE,
            branch_delay_slots=0, dma_granule_bytes=1,
            dma={'hbm_to_vmem': {'bytes_per_second': 1e9}}))
        self.assertEqual(report['modeled_cycles'], 102)
        self.assertEqual(report['modeled_bundle_visits'], 4)
        self.assertEqual(report['runtime_segments'][0]['selected_alternative'], 1)
        self.assertEqual(report['path_source'], 'segment_bound')
        self.assertFalse(any('completion credits' in g['reason'] or 'underflow' in g['reason'] for g in report['gaps']))


    def test_segment_bound_drains_dma_for_each_call(self):
        modules = {
            'TLP': parse_bundles('''
0: { inlined_call /* kernel */ }
1: { vdelay 100 }
2: { inlined_call /* alias */ }
'''),
            'kernel': parse_bundles('''
0: { sbr.rel (%p_runtime) target = $region1 }
1: { vdelay 10 ;; mystery }
2: { sbr.rel target = $region2 }
3: { dma.hbm_to_vmem %hbm, 20, %vmem, [#allocation0] } /* Start region 1 */
4: {} /* Start region 2 */
''')}
        profile = dict(PROFILE, branch_delay_slots=0, vdelay_semantics='total_cycles',
                       dma_granule_bytes=1, dma={'hbm_to_vmem': {'bytes_per_second': 1e9}})
        report = estimate_final_program(modules, profile, {'alias': 'kernel'})
        self.assertEqual(report['modeled_cycles'], 144)
        # Each invocation chooses its maximum and drains DMA before continuing.
        self.assertEqual([c['selected_alternative'] for c in report['runtime_segments']], [1, 1])
        compact = estimate_final_program(modules, profile, {'alias': 'kernel'}, retain_events=False)
        for field in ('modeled_cycles', 'activity_timeline', 'runtime_segments'):
            self.assertEqual(compact[field], report[field], field)
        self.assertTrue(any(g['reason'] == 'unmapped cost: mystery' for g in compact['gaps']))

    def test_runtime_bound_includes_offloads_from_other_branch(self):
        from sim_pjrt.llo.sparsecore import bound_offloads, calibrate_operations
        modules = {'TLP': parse_bundles("""
0: { sbr.rel (%p0) target = $region1 }
1: { vdelay 100 }
2: { sbr.rel target = $region2 }
3: {} /* Start region 1 */
4: {} /* Start region 2 */
""")}
        calls = [dict(call='launch', op='reduce', core_ids=[0], offload_type='OFFLOAD_COLLECTIVE',
                      computation='true', entry=False)]
        nodes = {'cond': dict(computation='main', entry=True, opcode='conditional', branches=['false', 'true'])}
        metadata = {'reduce': {'hlo_text': '%reduce = f32[8] all-reduce(%x)'}}
        calibration = calibrate_operations(calls, metadata, [dict(op='reduce', duration_ns=200)])
        report = estimate_final_program(modules, dict(PROFILE,
            branch_delay_slots=0, vdelay_semantics='total_cycles'),
            finalize_report=lambda r: bound_offloads(r, calls, nodes, metadata, calibration))
        self.assertAlmostEqual(report['modeled_cycles'], 303)
        self.assertEqual(report['sparsecore']['added_critical_path_ns'], 200)
        self.assertEqual(report['status'], 'partial')

    def test_segment_bound_drains_incoming_dma_and_preserves_common_credits(self):
        report = estimate_final_program({'TLP': parse_bundles("""
0: { dma.hbm_to_vmem %hbm, 100, %vmem, [#allocation0] }
1: { sbr.rel (%p0) target = $region1 }
2: { vdelay 5 }
3: {} /* Start region 1 */
4: { dma.done.wait [#allocation0], 100 }
""")}, dict(PROFILE, branch_delay_slots=0, vdelay_semantics='total_cycles',
            dma_granule_bytes=1, dma={'hbm_to_vmem': {'bytes_per_second': 1e9}}))
        self.assertEqual(report['modeled_cycles'], 109)
        self.assertEqual(report['completion_cycles'], 100)
        self.assertFalse(any('completion credits' in g['reason'] or 'underflow' in g['reason'] for g in report['gaps']))

        drains = [e for e in report['activity_timeline'] if e['name'] == 'Outstanding execution resources']
        self.assertIn((1, 100), [(e['start_ns'], e['end_ns']) for e in drains])

    def test_segment_join_keeps_only_shared_scalars_and_credits(self):
        report = estimate_final_program({'TLP': parse_bundles("""
0: { %s_units = smov 2 }
1: { sbr.rel (%p0) target = $region1 }
2: { %s_units = smov 8 ;; dma.hbm_to_vmem %hbm, 10, %vmem, [#allocation0] }
3: { dma.done.wait [#allocation0], 10 } /* Start region 1 */
4: { dma.hbm_to_vmem %hbm, %s_units, %vmem, [#allocation1] }
""")}, dict(PROFILE, branch_delay_slots=0, dma_granule_bytes=1,
            dma={'hbm_to_vmem': {'bytes_per_second': 1e9}}))
        reasons = [g['reason'] for g in report['gaps']]
        self.assertTrue(any('partial completion credits' in r for r in reasons))
        self.assertTrue(any('DMA service unmodeled' in r for r in reasons))
        self.assertEqual(report['status'], 'partial')
        self.assertIsNone(report['estimated_seconds'])

    def test_general_dma_infers_direction_and_keeps_descriptor_gap(self):
        program = parse_bundles('''
0: { %s_src = inlined_call_operand.vmem [shape: f32[32], index: 0] ;; %s_dst = inlined_call_operand.hbm [shape: f32[32], index: 1] }
1: { %s_units = smov 4 ;; %s_flag = smov [#allocation7] ;; %p0 = scmp.eq.u32.totalorder 1, 1 }
2: { dma.general (%p0), /*src=*/%s_src, /*size_in_granules=*/%s_units, /*dst=*/%s_dst, /*dst_syncflagno=*/%s_flag, /*src_syncflagno=*/0, /*stridedescaddr=*/[#allocation8], /*overrides=*/0, /*dst_syncflagno_1=*/0 }
3: { dma.done.wait [#allocation7], 4 }
''')
        self.assertEqual(program[2]['instructions'][0]['dma_direction'], 'vmem_to_hbm')
        resolved = resolve_scalar_operands(program)
        report = estimate_bundles(resolved, dict(PROFILE, dma_granule_bytes=32,
            dma={'vmem_to_hbm': {'bytes_per_second': 1e9}}),
            {'predicates': {'2:0': True}})
        self.assertEqual(report['dma_bytes'], 128)
        self.assertEqual(report['modeled_cycles'], 131)
        self.assertFalse(any('completion credits' in g['reason'] for g in report['gaps']))
        self.assertTrue(any('descriptor stride/padding' in g['reason'] for g in report['gaps']))

    def test_dma_unknown_flags_still_charge_traffic_and_contention(self):
        profile = dict(PROFILE, dma_granule_bytes=32,
                       dma={'vmem_to_hbm': {'bytes_per_second': 1e9}})
        program = parse_bundles('''
0: { %s_src = inlined_call_operand.vmem [index: 0] ;; %s_dst = inlined_call_operand.hbm [index: 1] }
1: { dma.general %s_src, 16, %s_dst, 16430, [#allocation15], [#allocation16], 16793600, 0 }
2: { dma.vmem_to_hbm %s_src, 4, %s_dst, %s_unknown }
3: { dma.done.wait [#allocation15], 16 }
''')
        report = estimate_bundles(program, profile)
        self.assertEqual(report['dma_bytes'], 640)
        self.assertEqual(report['modeled_cycles'], 641)
        events = [e for e in report['events'] if e['kind'] == 'dma']
        self.assertEqual(events[1]['start_cycle'], events[0]['end_cycle'])
        self.assertEqual(events[0]['stride_descriptor'], '[#allocation16]')
        self.assertTrue(any('partial completion credits' in g['reason'] for g in report['gaps']))

    def test_dma_uses_slower_memory_interface(self):
        program = parse_bundles('''
0: { dma.hbm_to_vmem %hbm, 4, %vmem, [#allocation0] }
1: { dma.done.wait [#allocation0], 4 }
''')
        for vmem_rate, expected in ((0.5e9, 263), (2e9, 135)):
            profile = dict(PROFILE, dma_granule_bytes=32,
                dma={'hbm_to_vmem': {'bytes_per_second': 1e9,
                    'vmem_bytes_per_second': vmem_rate, 'latency_cycles': 7}})
            report = estimate_bundles(program, profile)
            self.assertEqual(report['modeled_cycles'], expected)
            self.assertEqual(report['dma_bytes'], 128)
            self.assertFalse(any('completion credits' in g['reason'] or 'underflow' in g['reason'] for g in report['gaps']))


    def test_dma_wait_accepts_primed_and_partial_completion_credits(self):
        profile = dict(PROFILE, dma_granule_bytes=1,
                       dma={'hbm_to_vmem': {'bytes_per_second': 1e9}})
        primed = estimate_bundles(parse_bundles('''
0: { vsyncadd [#allocation0], 4 }
1: { dma.hbm_to_vmem %hbm, 4, %vmem, [#allocation0] }
2: { dma.done.wait [#allocation0], 8 }
3: { vadd 1, 2 }
'''), profile)
        self.assertFalse(any('completion credits' in g['reason'] or 'underflow' in g['reason'] for g in primed['gaps']))

        self.assertEqual(primed['modeled_cycles'], 6)
        partial = estimate_bundles(parse_bundles('''
0: { dma.hbm_to_vmem %hbm, 4, %vmem, [#allocation0] }
1: { dma.hbm_to_vmem %hbm, 4, %vmem, [#allocation0] }
2: { dma.done.wait [#allocation0], 4 }
3: { vsyncadd [#allocation0], 4294967292 }
4: { vadd 1, 2 }
5: { dma.done.wait [#allocation0], 4 }
'''), profile)
        self.assertFalse(any('completion credits' in g['reason'] or 'underflow' in g['reason'] for g in partial['gaps']))

        waits = [e['end_cycle'] for e in partial['events']
                 if e['kind'] == 'bundle' and e['address'] in ('0:0x2', '0:0x5')]
        self.assertEqual(waits, [4, 8])

    def test_dma_transactions_round_bytes_not_completion_credits(self):
        profile = dict(PROFILE, dma_granule_bytes=32, dma_transaction_bytes=512,
                       dma={'hbm_to_vmem': {'bytes_per_second': 1e9, 'latency_cycles': 7}})
        for units, payload, bus in ((1, 32, 512), (16, 512, 512), (17, 544, 1024)):
            with self.subTest(units=units):
                program = parse_bundles(f'''
0: {{ %dma = dma.hbm_to_vmem %hbm, {units}, %vmem, [#allocation0] }}
1: {{ %done = dma.done.wait [#allocation0], {units} }}
''')
                result = estimate_bundles(program, profile)
                self.assertEqual(result['dma_bytes'], payload)
                self.assertEqual(result['dma_bus_bytes'], bus)
                self.assertEqual(result['modeled_cycles'], bus + 7)
                self.assertFalse(any('completion credits' in g['reason'] for g in result['gaps']))
        with self.assertRaises(ValueError):
            estimate_bundles(program, dict(profile, dma_transaction_bytes=0.5))

    def test_scalar_loop_repeats_dma_and_consumes_credits(self):
        program = parse_bundles('''
0: { %s_seed = smov 0 }
1 LB: { %s_i = sphi %s_seed, %s_next ;; %s_size = sadd.u32 %s_i, 1 } /* Start region 7 */
2: { %dma = dma.hbm_to_vmem %hbm, %s_size, %vmem, [#allocation0] }
3: { %done = dma.done.wait [#allocation0], %s_size }
4: { %s_neg = ssub.u32 0, %s_size ;; %s_next = sadd.u32 %s_i, 1 }
5: { %credit = vsyncadd [#allocation0], %s_neg ;; %p_more = scmp.lt.u32.totalorder %s_next, 3 }
6: { %jump = sbr.rel (%p_more) target = $region7 }
7: { vadd 1, 2 }
''')
        resolved = resolve_scalar_operands(program, branch_delay_slots=0)
        self.assertEqual(len(resolved), 20)
        self.assertEqual(len({b['address'] for b in resolved}), 20)
        result = estimate_bundles(resolved, dict(PROFILE, dma_granule_bytes=32,
            dma={'hbm_to_vmem': {'bytes_per_second': 1e9, 'latency_cycles': 0}}))
        self.assertEqual(result['scheduled_bundle_count'], 8)
        self.assertEqual(result['modeled_bundle_visits'], 20)
        self.assertEqual(result['dma_bytes'], 192)
        self.assertFalse(any('completion credits' in g['reason'] or 'underflow' in g['reason'] for g in result['gaps']))

        composed = compose_final_bundles({
            'TLP': parse_bundles('0: { inlined_call /* kernel */ }'),
            'kernel': resolved})
        timeline = estimate_bundles(composed, PROFILE)['activity_timeline']
        self.assertEqual(len([e for e in timeline if e['track'] == 'XLA Ops']), 1)
        with self.assertRaisesRegex(ValueError, 'exceeds 10 visits'):
            resolve_scalar_operands(program, max_visits=10, branch_delay_slots=0)

    def test_scalar_dma_operands_and_flag_offsets(self):
        source = parse_bundles('''
0: { %s0 = smov 8 ;; %s1 = smov [#allocation7] }
1: { %s2 = smul.u32 %s0, 4 ;; %s3 = scalar_lea.sflag %s1, 1 }
2: { %dma = dma.hbm_to_vmem %hbm, %s2, %vmem, %s3 }
3: { %done = dma.done.wait %s3, 32 }
''')
        before = copy.deepcopy(source)
        resolved = resolve_scalar_operands(source)
        result = estimate_bundles(resolved, dict(PROFILE, dma_granule_bytes=32,
            dma={'hbm_to_vmem': {'bytes_per_second': 1e9, 'latency_cycles': 0}}))
        self.assertEqual(result['dma_bytes'], 1024)
        self.assertEqual(result['modeled_cycles'], 1027)
        self.assertNotIn('DMA wait has unknown or partial completion credits',
                         [g['reason'] for g in result['gaps']])
        self.assertEqual(source, before)

    def test_activity_scopes_preserve_aliases_and_repeated_calls(self):
        program = compose_final_bundles(
            {
                "TLP": parse_bundles(
                    "0 : { inlined_call /* %fusion.1 = fusion(%x) */ }\n"
                    "1 : { inlined_call /* %copy.2 = copy(%y) */ }"
                ),
                "shared": parse_bundles("0 : { vmov 1, 2 }\n1 : { vmov 3, 4 }"),
            },
            {"fusion.1": "shared", "copy.2": "shared"},
        )
        report = estimate_bundles(program, PROFILE)
        scopes = [e for e in report["activity_timeline"] if e["track"] == "XLA Ops"]
        self.assertEqual([e["name"] for e in scopes], ["fusion.1", "copy.2"])
        self.assertEqual([(e["start_ns"], e["end_ns"]) for e in scopes], [(0, 2), (2, 4)])
        self.assertTrue(all("module=shared" in e["detail"] for e in scopes))
        self.assertNotEqual(scopes[0]["detail"], scopes[1]["detail"])
        # Replaying the same call site must create another scope, not merge it.
        repeated = estimate_bundles(
            program, PROFILE,
            {"path": [{"repeat": 2, "body": [b["address"] for b in program[:2]]}]},
        )
        scopes = [e for e in repeated["activity_timeline"] if e["track"] == "XLA Ops"]
        self.assertEqual(len(scopes), 2)

    def test_activity_dma_and_tail_preserve_wait_time_inside_kernel(self):
        program = parse_bundles(
            "0 : { dma.hbm_to_vmem %src, 1, %dst, [#allocation1] }\n"
            "1 : { dma.hbm_to_vmem %src, 1, %dst, [#allocation2] }\n"
            "2 : { dma.done.wait [#allocation2], 1 }"
        )
        report = estimate_bundles(program, dict(
            PROFILE, dma_granule_bytes=8, completion_tail_cycles=2,
            dma={"hbm_to_vmem": {"bytes_per_second": 1e9, "resource": "hbm"}},
        ))
        timeline = report["activity_timeline"]
        self.assertFalse(any(e["track"].startswith("DMA / ") for e in timeline))
        dma = [e for e in report["events"] if e["kind"] == "dma"]
        self.assertEqual([(e["start_cycle"], e["end_cycle"]) for e in dma], [(0, 8), (8, 16)])
        self.assertEqual([e["bytes"] for e in dma], [8, 8])
        self.assertFalse(any(e["track"] == "Wait" for e in timeline))
        kernel = next(e for e in timeline if e["track"] == "XLA Ops")
        self.assertEqual((kernel["start_ns"], kernel["end_ns"]), (0, 16))
        tail = next(e for e in timeline if e["name"] == "Completion tail")
        self.assertEqual((tail["start_ns"], tail["end_ns"]), (16, 18))
        self.assertEqual(report["modeled_cycles"], 18)
        self.assertTrue(all(0 <= e["start_ns"] <= e["end_ns"] <= 18 for e in timeline))

    def test_real_pallas_dump(self):
        p = parse_bundles((FIXTURES / "pallas_add.txt").read_text())
        profile = json.loads((FIXTURES / "example_profile.json").read_text())
        original = copy.deepcopy((p, profile))
        r = estimate_bundles(p, profile, {"assume_no_faults": True})
        self.assertEqual(
            len(p), 34
        )  # libtpu schedule-analysis independently reports 34
        self.assertEqual(r["dma_bytes"], 8192)
        self.assertEqual(r["wait_stall_cycles"], 126)
        self.assertEqual(r["modeled_cycles"], 160)
        self.assertEqual(r["status"], "partial")
        self.assertEqual((p, profile), original)

    def test_delay_is_explicit_and_not_double_counted(self):
        p = parse_bundles("0 : { %0 = vdelay 5 ;; %1 = sfence }")
        r = estimate_bundles(
            p,
            dict(PROFILE, vdelay_semantics="total_cycles"),
            {"wait_until_cycles": {"0:1": 10}},
        )
        self.assertEqual(r["modeled_cycles"], 10)
        self.assertEqual(r["wait_stall_cycles"], 5)
        self.assertIsNone(estimate_bundles(p, PROFILE)["estimated_seconds"])

    def test_control_flow_nested_loops_and_predicates(self):
        p = parse_bundles("0 : { %0 = sbr.rel (%p1) target = $region2 }\n1 : {}")
        with self.assertRaisesRegex(ValueError, "branch target and delay slots"):
            estimate_bundles(p, PROFILE)
        scenario = {
            "path": [
                {"repeat": 2, "body": ["0:0x0", {"repeat": 3, "body": ["0:0x1"]}]}
            ],
            "predicates": {"0:0": False, "4:0": False},
        }
        r = estimate_bundles(p, PROFILE, scenario)
        self.assertEqual(r["modeled_cycles"], 8)
        self.assertEqual(r["status"], "partial")
        self.assertEqual(expand_path([{"repeat": 0, "body": ["0:0x0"]}]), ())
        with self.assertRaises(ValueError):
            expand_path([{"repeat": 10**10, "body": ["0:0x0"]}])


if __name__ == "__main__":
    unittest.main()
