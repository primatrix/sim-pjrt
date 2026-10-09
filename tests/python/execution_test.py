"""Execution-model regressions: dynamic dependencies, loops and GF namespaces."""
import json
from pathlib import Path
import unittest

from sim_pjrt.llo.compiler_costs import CompilerCosts
from sim_pjrt.llo.execution import GfMapping, build_execution
from sim_pjrt.llo.parser import parse_bundles
from sim_pjrt.llo.pipeline import simulate

ROOT = Path(__file__).resolve().parents[2]


class ExecutionTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.table = json.loads((ROOT / 'configs/gf_costs_libtpu_0_0_48.json').read_text())
        cls.data = json.loads((ROOT / 'configs/gf_mapping_libtpu_0_0_48.json').read_text())
        cls.costs = CompilerCosts(cls.table, binary_sha256=cls.table['binary_sha256'])
        cls.mapping = GfMapping(cls.data, cls.costs)

    def run_llo(self, text, **kw):
        bundles, audit = build_execution(parse_bundles(text), self.mapping, **kw)
        report = simulate(bundles, frequency_hz=1e9, gaps=audit['gaps'],
                          initial_ready=audit['initial_ready'], model_provenance=self.mapping.provenance)
        return bundles, audit, report

    def test_mrb_abbreviations_and_missing_producer_remain_gaps(self):
        _, audit, _ = self.run_llo('0: { vmatmul.mubr %v0 }\n1: { vpop.f32.mrb[0].mxu0 }')
        self.assertIn('unmapped cost: vmatmul.mubr', audit['gaps'])
        self.assertTrue(any('MRB read without known producer' in gap for gap in audit['gaps']))

    def test_delay_operand_changes_issue_cursor_in_both_semantics(self):
        for mode, expected in [('total_cycles', 100), ('additional_cycles', 101)]:
            _, _, report = self.run_llo('0: { vdelay 100 }\n1: { vadd.f32 %input, 1 }',
                                        memory_profile={'vdelay_semantics': mode})
            self.assertEqual(report['events'][1]['start_cycle'], expected)
        _, audit, _ = self.run_llo('0: { vdelay 100 }')
        self.assertIn('vdelay needs a constant operand and explicit semantics', audit['gaps'])

    def calibrated_profile(self, **changes):
        table=dict(schema_version=1,kind='empirical_bundle_issue_floor',frequency_hz=1e9,
                   compiler_binary_sha256=self.costs.binary_sha256,
                   default_floor_cycles=2,cycles_by_signature={'vadd.f32':3})
        table.update(changes)
        return dict(frequency_hz=1e9,bundle_issue_calibration=table)

    def test_empirical_issue_floor_preserves_dependency_readiness(self):
        _,audit,r=self.run_llo('0: { %v0 = vpow2.f32 %input }\n1: { %v1 = vadd.f32 %v0, 1.0 }\n2: { vmul.f32 %other, 2.0 }',
                              memory_profile=self.calibrated_profile())
        self.assertEqual([e['start_cycle'] for e in r['events']],[0,10,13])
        self.assertTrue(any('empirical bundle issue' in g for g in audit['gaps']))

    def test_empirical_issue_floor_does_not_add_to_explicit_delay(self):
        profile=self.calibrated_profile();profile['vdelay_semantics']='total_cycles'
        _,_,r=self.run_llo('0: { vdelay 20 }\n1: { vadd.f32 %input, 1.0 }',memory_profile=profile)
        self.assertEqual(r['events'][1]['start_cycle'],20)

    def test_empirical_issue_calibration_rejects_mismatched_identity_and_bad_costs(self):
        for changes in ({'frequency_hz':2e9},{'compiler_binary_sha256':'0'*64},
                        {'default_floor_cycles':float('nan')},{'cycles_by_signature':{'vld':True}}):
            with self.subTest(changes=changes), self.assertRaises(ValueError):
                self.run_llo('0: { vld %input }',memory_profile=self.calibrated_profile(**changes))

    def test_gf_not_gl_namespace(self):
        for mnemonic, expected in [('vpop.eup', 416), ('vpop', 418), ('vpow2.f32', 264), ('vrcp.f32', 268)]:
            self.assertEqual(self.mapping.classify(dict(text=mnemonic, opcode=mnemonic))['performance_id'], expected)
        self.assertEqual(len(self.mapping.by_opcode), 274)

    def test_reject_binary_mismatch(self):
        with self.assertRaisesRegex(ValueError, 'identity mismatch'):
            GfMapping(dict(self.data, binary_sha256='0'*64), self.costs)

    def test_duplicate_mnemonic_requires_raw_opcode(self):
        self.assertIsNone(self.mapping.classify(dict(opcode='vpack', text='vpack %v0')))
        self.assertIsNotNone(self.mapping.classify(dict(opcode='vpack', text='vpack %v0', llo_opcode=294)))
        self.assertIsNone(self.mapping.classify(dict(opcode='vadd.unknown', text='vadd.unknown %v0')))

    def test_raw_stalls_but_independent_work_overlaps(self):
        _, audit, report = self.run_llo('''
0: { %v0 = vpow2.f32 %input }
1: { %v1 = vadd.f32 %other, 1.0 }
2: { %v2 = vadd.f32 %v0, %v1 }
''', live_ins=['%input', '%other'])
        self.assertEqual([e['start_cycle'] for e in report['events']], [0, 1, 10])
        self.assertEqual(audit['counts']['mapped'], 3)
        self.assertEqual(set(audit['dependencies'][2]['depends_on']), {'0:0', '1:0'})

    def test_coissued_reads_old_producer_and_waw_is_versioned(self):
        bundles, _, report = self.run_llo('''
0: { %v0 = vpow2.f32 %input }
1: { %v0 = vadd.f32 %other, 1.0 ;; %v1 = vadd.f32 %v0, 2.0 }
2: { %v2 = vadd.f32 %v0, %v1 }
''')
        self.assertEqual(bundles[1].operations[1].depends_on, ('0:0',))
        self.assertEqual(set(bundles[2].operations[0].depends_on), {'1:0', '1:1'})
        self.assertEqual(report['events'][1]['start_cycle'], 10)

    def test_counted_loop_phi_tracks_backedge(self):
        bundles, audit, _ = self.run_llo('''
0: { %s_seed = smov 0 }
1 LB: { %s_i = sphi %s_seed, %s_next } /* Start region 1 */
2: { %s_next = sadd.s32 %s_i, 1 }
3: { %p_more = scmp.lt.s32.totalorder %s_next, 3 }
4: { sbr.rel (%p_more) target = $region1 }
5: { %s_out = sadd.s32 %s_next, 1 }
''', branch_delay_slots=0)
        self.assertEqual(len(bundles), 14)
        adds = [r for r in audit['dependencies'] if r['opcode'] == 'sadd.s32']
        self.assertEqual(adds[0]['depends_on'], ['0:0'])
        self.assertIn(adds[0]['id'], adds[1]['depends_on'])
        self.assertIn(adds[1]['id'], adds[2]['depends_on'])
        self.assertFalse(any('live-ins' in g for g in audit['gaps']))

    def test_branch_delay_slots_execute(self):
        bundles, _, _ = self.run_llo('''
0: { sbr.rel target = $region1 }
1: { %v0 = vadd.f32 %input, 1.0 }
2: { %vbad = vadd.f32 %input, 9.0 }
3: { %v1 = vadd.f32 %v0, 2.0 } /* Start region 1 */
''', branch_delay_slots=1)
        self.assertEqual([b.address for b in bundles], ['0:0x0', '0:0x1', '0:0x3'])
        self.assertEqual(bundles[2].operations[0].depends_on, ('1:0',))

    def test_false_predicate_preserves_old_producer(self):
        bundles, _, _ = self.run_llo('''
0: { %s0 = smov 0 ;; %v0 = vadd.f32 %input, 1.0 }
1: { %p0 = scmp.ne.s32.totalorder %s0, 0 }
2: { %v0 = vpow2.f32 (%p0) %input }
3: { %v1 = vadd.f32 %v0, 2.0 }
''')
        self.assertEqual(bundles[2].operations, ())
        self.assertEqual(bundles[3].operations[0].depends_on, ('0:1',))

    def test_unresolved_predicate_refused(self):
        with self.assertRaisesRegex(ValueError, 'concrete path|unresolved instruction predicate'):
            self.run_llo('0: { %v0 = vadd.f32 (%p_unknown) %input, 1.0 }')

    def test_memory_operations_preserve_raw_without_global_frontier(self):
        bundles, _, _ = self.run_llo('''
0: { %v0 = vld [vmem:[#allocation0]] ;; %v1 = vld [vmem:[#allocation1]] }
1: { %v2 = vadd.f32 %v0, %v1 }
2: { vst [vmem:[#allocation2]] %v2 }
''')
        self.assertEqual(set(bundles[2].operations[0].depends_on), {'1:0'})

    def test_unknown_cost_is_retained_and_reported(self):
        bundles, audit, report = self.run_llo('0: { %v0 = mystery %input }\n1: { %v1 = vadd.f32 %v0, 1.0 }')
        self.assertEqual(bundles[1].operations[0].depends_on, ('0:0',))
        self.assertEqual(audit['counts']['unmapped'], 1)
        self.assertIsNone(report['estimated_seconds'])
        self.assertIn('unmapped cost: mystery', report['gaps'])

    def test_global_resource_intersection(self):
        _, _, report = self.run_llo('0: { %v0 = vrng }\n1: { %v1 = vrng }')
        self.assertEqual([e['start_cycle'] for e in report['events']], [0, 2])

    def test_same_bundle_duplicate_writes_rejected(self):
        with self.assertRaisesRegex(ValueError, 'multiple co-issued writes'):
            self.run_llo('0: { %v0 = vadd.f32 %input, 1.0 ;; %v0 = vadd.f32 %input, 2.0 }')

    def test_physical_register_reuse_waits_for_prior_writer(self):
        bundles, _, report = self.run_llo('0: { %v1_v0 = vpow2.f32 %input }\n1: { %v2_v0 = vadd.f32 %other, 1.0 }')
        self.assertIn('0:0', bundles[1].operations[0].depends_on)
        self.assertEqual(report['events'][1]['start_cycle'], 10)

    def test_mxu_units_overlap_pop_waits_and_slots_release(self):
        bundles, audit, report = self.run_llo('''
0: { %m0 = vmatmul.mubr.bf16.mrb[0].mxu0 %input ;; %m1 = vmatmul.mubr.bf16.mrb[0].mxu1 %input }
1: { %v0 = vpop.f32.mrb[0].mxu0 ;; %v1 = vpop.f32.mrb[0].mxu1 }
2: { %m2 = vmatmul.mubr.bf16.mrb[0].mxu0 %input }
''', bf16_result_slots=1)
        self.assertEqual(audit['counts']['mapped'], 5)
        self.assertEqual(bundles[1].operations[0].depends_on, ('0:0',))
        self.assertEqual(bundles[1].operations[1].depends_on, ('0:1',))
        self.assertIn('1:0', bundles[2].operations[0].depends_on)
        self.assertEqual(report['events'][1]['start_cycle'], 211)
        self.assertIsNone(report['estimated_seconds'])

    def test_live_mrb_overwrite_is_rejected(self):
        with self.assertRaisesRegex(ValueError, 'MRB overwritten'):
            self.run_llo('0: { %m0 = vmatmul.mubr.bf16.mrb[0].mxu0 %input }\n1: { %m1 = vmatmul.mubr.bf16.mrb[0].mxu0 %input }')

    def test_eup_pop_tracks_implicit_fifo_producer(self):
        bundles, _, report = self.run_llo('0: { %123 = vpow2.f32 %input }\n1: { %v0 = vpop.eup }')
        self.assertEqual(bundles[1].operations[0].depends_on, ('0:0',))
        self.assertEqual(report['events'][1]['start_cycle'], 10)

    def test_bf16_pack_disambiguates_raw_opcode(self):
        row = self.mapping.classify(dict(opcode='vpack.c.bf16', text='%v0 = vpack.c.bf16 %v1, %v2'))
        self.assertEqual(row['llo_opcode'], 294)
        self.assertEqual(row['performance_id'], 136)
        self.assertIsNone(self.mapping.classify(dict(opcode='vpack', text='vpack %v1, %v2')))

    def test_bf16_matpush_latency_and_unit_throughput(self):
        bundles, _, report = self.run_llo('''
0: { %1 = vmatpush1.bf16.msra.mxu0 %input ;; %2 = vmatpush1.bf16.msra.mxu1 %input }
1: { %3 = vmatpush1.bf16.msra.mxu0 %input }
''')
        self.assertEqual(bundles[0].operations[0].latency, 4)  # table 8, ceil(/2).
        self.assertEqual([e['start_cycle'] for e in report['events']], [0, 4])

    def test_unknown_matpush_modifiers_not_silently_stripped(self):
        self.assertIsNone(self.mapping.classify(dict(opcode='vmatpush1', text='vmatpush1.bf16.unknown.msra.mxu0 %input')))

    def test_transpose_matpush_uses_full_latency_and_eight_cycle_issue(self):
        bundles, _, report = self.run_llo('''
0: { %1 = vmatpush1.bf16.xpose.msra.mxu0 %input ;; %2 = vmatpush1.bf16.xpose.msrb.mxu1 %input }
1: { %3 = vmatpush1.bf16.xpose.msrb.mxu0 %input }
''')
        self.assertEqual(bundles[0].operations[0].latency, 8)
        self.assertEqual([e['start_cycle'] for e in report['events']], [0, 8])

    def test_xlu_unit_mapping_preserves_latency_dependency_and_independence(self):
        bundles, audit, report = self.run_llo('''
0: { %1 = vmax.xlane.f32.xlu0 %input ;; %2 = vadd.xlane.f32.xlu1 %input }
1: { %v0 = vpop.xlane.xlu0 %1 ;; %v1 = vpop.xlane.xlu1 %2 }
''')
        self.assertEqual(audit['counts']['mapped'], 4)
        self.assertEqual([e['start_cycle'] for e in report['events']], [0, 141])
        self.assertIn('xlu0.gf.resource.17', bundles[0].operations[0].issue_checks)
        self.assertIn('xlu1.gf.resource.17', bundles[0].operations[1].issue_checks)
        self.assertFalse(any('specialized resource' in g for g in audit['gaps']))

    def test_xlu_conflicts_depend_on_direction_and_unit(self):
        for unit, forward, backward in [(0, 22, 31), (1, 17, 36)]:
            reduce = f'vmax.xlane.f32.xlu{unit}'
            permute = f'vperm.xlu{unit}'
            for first, second, expected in [(reduce, permute, forward),
                                             (permute, reduce, backward)]:
                with self.subTest(first=first, second=second):
                    _, _, report = self.run_llo(
                        f'0: {{ %1 = {first} %input }}\n1: {{ %2 = {second} %other }}')
                    self.assertEqual(report['events'][1]['start_cycle'], expected)

    def test_xlu_conflicts_preserve_unit_overlap_and_raw_waits(self):
        _, _, report = self.run_llo('''
0: { %1 = vmax.xlane.f32.xlu0 %input }
1: { %2 = vperm.xlu1 %other }
2: { %3 = vperm.xlu0 %1 }
''')
        self.assertEqual([e['start_cycle'] for e in report['events']], [0, 1, 141])

    def test_xlu_stage_columns_do_not_become_generic_exclusion_holds(self):
        _, audit, report = self.run_llo('''
0: { %1 = vmax.xlane.f32.xlu0 %input }
1: { %2 = vmin.xlane.f32.xlu0 %other }
''')
        self.assertEqual(report['events'][1]['start_cycle'], 4)
        self.assertFalse(any('specialized resource' in g for g in audit['gaps']))

    def test_rpu_fifo_adds_implicit_producer_waits_and_pop_spacing(self):
        bundles, _, report = self.run_llo('''
0: { %1 = vmax.xlane.f32.xlu0 %input }
1: { %2 = vmin.xlane.f32.xlu0 %other }
2: { %v0 = vpop.xlane.xlu0 }
3: { %v1 = vpop.permute.xlu0 }
''')
        self.assertEqual(bundles[2].operations[0].depends_on, ('0:0',))
        self.assertEqual(bundles[3].operations[0].depends_on, ('1:0',))
        self.assertEqual([e['start_cycle'] for e in report['events']], [0, 4, 141, 145])

    def test_rpu_fifo_units_are_independent_and_unknown_producer_is_a_gap(self):
        bundles, _, report = self.run_llo('''
0: { %1 = vmax.xlane.f32.xlu0 %input ;; %2 = vmax.xlane.f32.xlu1 %other }
1: { %v0 = vpop.xlane.xlu0 ;; %v1 = vpop.xlane.xlu1 }
''')
        self.assertEqual(bundles[1].operations[0].depends_on, ('0:0',))
        self.assertEqual(bundles[1].operations[1].depends_on, ('0:1',))
        self.assertEqual(report['events'][1]['start_cycle'], 141)
        _, audit, _ = self.run_llo('0: { %v0 = vpop.xlane.xlu0 }')
        self.assertIn('RPU result read without known producer', audit['gaps'])

    def test_result_fifo_families_do_not_share_a_drain_deadline(self):
        _, _, report = self.run_llo('''
0: { %v0 = vpop.xlane.xlu0 }
1: { %v1 = vpop.trf.xlu0 }
''')
        self.assertEqual(report['events'][1]['start_cycle'], 1)
        self.assertIsNone(self.mapping.classify(dict(opcode='vadd.f32',
                                                    text='vadd.f32.xlu0 %input, 1')))

    def test_explicit_result_operand_cannot_bypass_fifo_head(self):
        with self.assertRaisesRegex(ValueError, 'contradicts FIFO order'):
            self.run_llo('''
0: { %1 = vmax.xlane.f32.xlu0 %input }
1: { %2 = vmin.xlane.f32.xlu0 %other }
2: { %v0 = vpop.xlane.xlu0 %2 }
''')

    def test_eup_tail_opcodes_use_fifo_and_bf16_push_interval(self):
        for name in ('vsinq.bf16', 'vcosq.bf16', 'verf.bf16'):
            with self.subTest(name=name):
                bundles, _, report = self.run_llo(
                    f'0: {{ %1 = {name} %input }}\n1: {{ %2 = {name} %other }}\n'
                    '2: { %v0 = vpop.eup }\n3: { %v1 = vpop.eup }')
                self.assertEqual(bundles[2].operations[0].depends_on, ('0:0',))
                self.assertEqual(bundles[3].operations[0].depends_on, ('1:0',))
                self.assertEqual([e['start_cycle'] for e in report['events']], [0, 2, 11, 13])

    def test_coissued_fifo_push_is_visible_only_to_later_bundles(self):
        for instructions in ('%1 = vpow2.f32 %input ;; %v0 = vpop.eup',
                             '%v0 = vpop.eup ;; %1 = vpow2.f32 %input'):
            with self.subTest(instructions=instructions):
                bundles, audit, report = self.run_llo(
                    f'0: {{ {instructions} }}\n1: {{ %v1 = vpop.eup }}')
                pop = next(op for op in bundles[0].operations if op.name == 'vpop.eup')
                push = next(op for op in bundles[0].operations if op.name == 'vpow2.f32')
                self.assertEqual(pop.depends_on, ())
                self.assertEqual(bundles[1].operations[0].depends_on, (push.id,))
                self.assertIn('EUP result read without known producer', audit['gaps'])
                self.assertEqual([e['start_cycle'] for e in report['events']], [0, 10])

    def test_implicit_accumulator_wait_does_not_serialize_other_work(self):
        _, _, report = self.run_llo('''
0: { %v0 = vmaxabs.f32 %input }
1: { %v1 = vadd.f32 %other, 1.0 }
2: { %v2 = vmovacc.add.high }
''')
        self.assertEqual([e['start_cycle'] for e in report['events']], [0, 1, 2])
        _, _, report = self.run_llo(
            '0: { %v0 = vmaxabs.f32 %input }\n1: { %v1 = vmovacc.add.high }')
        self.assertEqual(report['events'][1]['start_cycle'], 2)

    def test_current_table_drives_mxu_throughput_and_xlu_penalties(self):
        table = json.loads(json.dumps(self.table))
        table['rows'][295]['resource_values']['5'] = 13
        table['xlu_conflict_cycles']['0:5:0'] = 70
        mapping = GfMapping(self.data, CompilerCosts(table, binary_sha256=table['binary_sha256']))
        bundles, audit = build_execution(parse_bundles('''
0: { %1 = vmatmul.mubr.bf16.mrb[0].mxu0 %input }
1: { %2 = vmatmul.mubr.bf16.mrb[4].mxu0 %other }
2: { %3 = vmax.xlane.f32.xlu0 %input }
3: { %4 = vperm.xlu0 %other }
'''), mapping)
        report = simulate(bundles, frequency_hz=1e9, gaps=audit['gaps'],
                          initial_ready=audit['initial_ready'], model_provenance=mapping.provenance)
        self.assertEqual([e['start_cycle'] for e in report['events']], [0, 13, 14, 84])

    def test_missing_scheduling_costs_remain_explicit_gaps(self):
        table = {k: v for k, v in self.table.items()
                 if k not in ('xlu_conflict_cycles', 'bf16_eup_issue_cycles')}
        mapping = GfMapping(self.data, CompilerCosts(table, binary_sha256=table['binary_sha256']))
        for name, expected in [('vmax.xlane.f32.xlu0', 'XLU conflict cost table is missing'),
                               ('vcosq.bf16', 'BF16 EUP issue cost missing')]:
            _, gaps, _ = mapping.operation(dict(opcode=name, text=name + ' %input'), 'op', ())
            self.assertIn(expected, gaps)

    def test_known_formats_and_comparisons_replace_placeholder_costs(self):
        expected = {'vpack.c.b16': 2, 'vpack.i.b16': 2,
                    'vunpack.c.l.bf16': 2, 'vunpack.c.h.bf16': 2,
                    'vunpack.c.l.s4': 2, 'vunpack.c.0.s8': 2,
                    'vweird.f32': 1, 'vcmp.eq.f32.partialorder': 1,
                    'vcmp.le.s32.totalorder': 1, 'vcmp.lt.u32.totalorder': 1,
                    'scmp.ne.f32.partialorder': 2, 'vsetiar.raw.iar0': 7,
                    'vsetiar.raw.iar1': 7}
        for name, latency in expected.items():
            with self.subTest(name=name):
                op, gaps, identity = self.mapping.operation(dict(opcode=name, text=name+' %input'), '0', ())
                self.assertIsNotNone(identity)
                self.assertEqual(op.latency, latency)
                self.assertFalse(any('unmapped cost' in g for g in gaps))
        for name in ['vpack.c.unknown', 'vunpack.c.l.unknown', 'vcmp.eq.f64.partialorder',
                     'vcmp.eq.s32.partialorder', 'vsetiar.raw.iar2', 'vmax.xlane.f32.xlu2']:
            self.assertIsNone(self.mapping.classify(dict(opcode=name, text=name+' %input')))

    def test_compare_equivalence_fails_closed_if_candidate_costs_differ(self):
        table = json.loads(json.dumps(self.table))
        identities = self.data['vector_compare_cost_equivalence']['f32.partialorder']['performance_ids']
        table['rows'][identities[-1]]['latency_cycles'] += 1
        mapping = GfMapping(self.data, CompilerCosts(table, binary_sha256=table['binary_sha256']))
        name = 'vcmp.eq.f32.partialorder'
        self.assertIsNone(mapping.classify(dict(opcode=name, text=name+' %v0, %v1')))

    def test_pseudo_latency_uses_compiler_rule_without_claiming_issue_expansion(self):
        bundles, audit, _ = self.run_llo('''
0: { %s0 = scalar_parameter_address 4 }
1: { %s1 = scalar_select %p0, %s0, 0 }
''', resolved=True)
        move_latency = self.costs.rows[27][0]
        self.assertEqual(bundles[0].operations[0].latency, move_latency)
        self.assertEqual(bundles[1].operations[0].latency, 2 * move_latency)
        self.assertIn('scalar_select assembly issue expansion is not modeled', audit['gaps'])

    def test_syncmov_disambiguation_by_fifo_consumer(self):
        for pop, identity, latency in [('spop', 437, 49), ('vpop.sfrf', 406, 3)]:
            bundles, audit, report = self.run_llo(
                f'0: {{ %1 = vsyncmov [#allocation0] }}\n1: {{ %s0 = {pop} %1 }}')
            self.assertEqual(audit['dependencies'][0]['performance_id'], identity)
            self.assertEqual(bundles[0].operations[0].latency, latency)
            self.assertEqual(report['events'][1]['start_cycle'], latency)
        for text in ['0: { %1 = vsyncmov [#allocation0] }',
                     '0: { %1 = vsyncmov [#allocation0] }\n1: { %s0 = spop %1 }\n2: { %v0 = vpop.sfrf %1 }',
                     '0: { %1 = vsyncmov [#allocation0] }\n1: { %s0 = mystery %1 }']:
            _, audit, _ = self.run_llo(text)
            self.assertIn('unmapped cost: vsyncmov', audit['gaps'])

    def test_dma_profile_prices_service_and_compute_overlap(self):
        profile = {'frequency_hz': 1e9, 'dma_granule_bytes': 32, 'dma_transaction_bytes': 512,
                   'dma': {'hbm_to_vmem': {'bytes_per_second': 128e9, 'latency_cycles': 20}}}
        bundles, audit, report = self.run_llo('''
0: { dma.hbm_to_vmem %hbm, 32, %vmem, [#allocation0] }
1: { %v0 = vadd.f32 %input, 1.0 }
2: { dma.done.wait [#allocation0], 32 }
''', memory_profile=profile)
        self.assertEqual(bundles[0].operations[0].latency, 28)
        self.assertEqual([e['start_cycle'] for e in report['events']], [0, 1, 2])
        self.assertEqual(report['events'][2]['issue_end_cycle'], 28)
        self.assertEqual(audit['counts']['dma_profile_costs'], 1)
        self.assertIsNone(report['estimated_seconds'])

    def test_dma_missing_and_invalid_rates(self):
        text = '0: { dma.hbm_to_vmem %hbm, 1, %vmem, [#allocation0] }'
        _, audit, _ = self.run_llo(text, memory_profile={})
        self.assertIn('DMA service unmodeled: hbm_to_vmem', audit['gaps'])
        profile = {'frequency_hz': 1e9, 'dma_granule_bytes': 32,
                   'dma': {'hbm_to_vmem': {'bytes_per_second': 0}}}
        with self.assertRaisesRegex(ValueError, 'invalid DMA'):
            self.run_llo(text, memory_profile=profile)

    def test_general_dma_compiler_direction_survives_unknown_pointer_types(self):
        profile = {'frequency_hz': 1e9, 'dma_granule_bytes': 32,
                   'dma': {'hbm_to_vmem': {'bytes_per_second': 32e9, 'latency_cycles': 20}}}
        bundles, audit, report = self.run_llo('''
0: { dma.general /*src=*/%s_phi, /*size_in_granules=*/32, /*dst=*/%s_arithmetic, /*dst_syncflagno=*/[#allocation0], /*src_syncflagno=*/0, /*stridedescaddr=*/[#allocation8], /*overrides=*/0, /*dst_syncflagno_1=*/0 /* hbm-to-vmem */ }
1: { dma.done.wait [#allocation0], 32 }
''', memory_profile=profile)
        self.assertEqual(audit['dma_events'][0]['bytes'], 1024)
        self.assertEqual(audit['dma_events'][0]['direction'], 'hbm_to_vmem')
        self.assertEqual(bundles[0].operations[0].latency, 52)
        self.assertEqual(report['events'][1]['issue_end_cycle'], 52)
        self.assertFalse(any('service unmodeled: general' in g for g in audit['gaps']))
        self.assertTrue(any('stride/padding' in g for g in audit['gaps']))

    def test_conflicting_dma_direction_rejected(self):
        with self.assertRaisesRegex(ValueError, 'direction annotation conflicts'):
            parse_bundles('''
0: { %s_src = scalar_lea.hbm [#allocation1] }
1: { %s_dst = scalar_lea.vmem [#allocation2] }
2: { dma.general %s_src, 32, %s_dst, 0, 0, 0, 0, 0 /* vmem-to-hbm */ }
''')

    def test_composed_spilled_output_flag_matches_dma_wait(self):
        profile = {'frequency_hz': 1e9, 'dma_granule_bytes': 32,
                   'dma': {'vmem_to_hbm': {'bytes_per_second': 32e9, 'latency_cycles': 20}}}
        _, audit, report = self.run_llo('''
0: { %s_base = scalar_lea.sflag [#allocation6], 1 }
1: { %s_flag = scalar_lea.sflag %s_base, 6 [#allocation6] }
2: { sst [smem:[#allocation1502_spill]] %s_flag }
3: { %s_reload = sld [smem:[#allocation1502_spill]] }
4: { dma.general %s_src, 32, %s_dst, %s_reload, 0, 0, 0, 0 /* vmem-to-hbm */ }
5: { dma.done.wait [#allocation6 + $0x7], 32 }
6: { vsyncadd [#allocation6 + $0x7], 4294967264 }
''', memory_profile=profile)
        self.assertEqual(audit['dma_events'][0]['destination_flag'], '[#allocation6 + $0x7]')
        self.assertFalse(any('completion credits' in g or 'underflow' in g or
                             'destination completion flag' in g for g in report['gaps']))
        self.assertEqual(report['final_credits']['[#allocation6+$0x7]'], 0)
        self.assertEqual(report['events'][5]['issue_end_cycle'], report['events'][4]['start_cycle'] + 52)


if __name__ == '__main__':
    unittest.main()
