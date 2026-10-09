"""Behavior regressions for llo control flow; no TPU required."""

import unittest

from sim_pjrt.llo.control_flow import resolve_scalar_operands
from sim_pjrt.llo.runtime import estimate_bundles
from sim_pjrt.llo.parser import parse_bundles
from sim_pjrt.llo.program import estimate_final_program, iter_final_bundles

PROFILE = {"frequency_hz": 1e9, "bundle_issue_cycles": 1}


class LloControlFlowTest(unittest.TestCase):
    def test_predicate_short_circuit_does_not_explore_disabled_dma(self):
        from sim_pjrt.llo.scalar import _evaluate
        for first, second in [(0, None), (None, 0)]:
            values = {'%p0': first, '%p1': second}
            self.assertEqual(_evaluate('pnand', '%p0, %p1', lambda x: values.get(x.strip()), {}), 1)
            self.assertEqual(_evaluate('pand', '%p0, %p1', lambda x: values.get(x.strip()), {}), 0)
        self.assertEqual(_evaluate('por', '%p0, %p1', lambda x: {'%p0': None, '%p1': 1}.get(x.strip()), {}), 1)
        self.assertIsNone(_evaluate('pnand', '%p0, %p1', lambda x: {'%p0': 1, '%p1': None}.get(x.strip()), {}))
        path = resolve_scalar_operands(parse_bundles("""
0: { %p_off = pmov 0 }
1: { %p_skip = pnand %p_off, %p_unknown }
2: { dma.hbm_to_vmem (!%p_skip), %src, %unknown_size, %dst, [#allocation0] }
"""))
        self.assertFalse(any('alternatives' in b for b in path))
        self.assertFalse(path[-1]['instructions'][0]['resolved_predicate'])

    def test_runtime_smem_indirect_loads_and_stores(self):
        path = resolve_scalar_operands(parse_bundles("""
0: { %s_base = smov [#allocation1] ;; %s_idx = smov 1 }
1: { %s_size = sld [smem:[%s_base + %s_idx]] }
2: { %s_next = sadd.u32 %s_size, 1 }
3: { sst [smem:[%s_base + %s_idx]] %s_next }
4: { %s_actual = sld [smem:[#allocation1 + $0x1]] }
5: { dma.hbm_to_vmem %src, %s_actual, %dst, [#allocation0] }
"""), runtime_inputs={'smem': {'#allocation1': [0, 32]}})
        self.assertIn(', 33,', path[-1]['instructions'][0]['text'])

    def test_runtime_argument_and_pointer_cast_preserve_known_value(self):
        path = resolve_scalar_operands(parse_bundles("""
0: { %s_value = inlined_call_operand.<no memory space> [shape: s32[], index: 1, kind: input] }
1: { %s_pointer = int_to_ptr.hbm [resolvable:$true] %s_value }
2: { %s_size = ptr_to_int %s_pointer }
3: { dma.hbm_to_vmem %src, %s_size, %dst, [#allocation0] }
"""), runtime_inputs={'scalar_inputs': {'1': 32}})
        self.assertIn(', 32,', path[-1]['instructions'][0]['text'])
        for invalid in ({'scalar_inputs': {'1': True}}, {'valid_addresses': 'yes'}, {'unknown': 1}):
            with self.assertRaises(ValueError):
                resolve_scalar_operands(parse_bundles('0: {}'), runtime_inputs=invalid)

    def test_clamped_runtime_index_keeps_copy_loop_bounded(self):
        program = parse_bundles('''
0: { %s_index = smin.u32 132944, %runtime }
1: { %s_page = sshrl.u32 %s_index, 10 }
2: { %s_offset = sadd.s32 %s_page, 16 }
3: { %s_remaining = ssub.s32 149, %s_offset }
4: { %p_short = scmp.lt.s32.totalorder %s_remaining, 16 }
5: { %s_size = smov (!%p_short, %s_remaining), 16 }
6: { %s_bytes = sshll.u32 %s_size, 2 }
7: { %s_vectors = sshrl.u32 %s_bytes, 3 }
8: { %s_groups = sshrl.u32 %s_vectors, 6 ;; %s_seed = smov 0 }
9 LB: { %s_i = sphi %s_seed, %s_next } /* Start region 1 */
10: { %s_next = sadd.u32 %s_i, 1 }
11: { %p_more = scmp.lt.u32.totalorder %s_next, %s_groups }
12: { sbr.rel (%p_more) target = $region1 }
13: {}
''')
        report = estimate_final_program({'TLP': program}, dict(PROFILE, branch_delay_slots=0))
        self.assertEqual(report['modeled_cycles'], 15)
        from sim_pjrt.llo.scalar import _evaluate
        registers = {'%r': range(0, 8)}
        read = lambda token: registers[token.strip()] if token.strip().startswith('%') else int(token)
        self.assertIsNone(_evaluate('sadd.u32', '%r, 4294967295', read, {}))
        self.assertIsNone(_evaluate('ssub.s32', '%r, 3', read, {}))

    def test_local_smem_constants_survive_other_dma_but_not_aliasing_writes(self):
        resolved = resolve_scalar_operands(parse_bundles('''
0: { %s0 = smov 16 ;; %s_negative = smov 4294967288 }
1: { sst [smem:[#allocation1 + $0x0]] %s0 ;; sst [smem:[#allocation2 + $0x3]] %s0 }
2: { %s_shifted = sshra.s32 %s_negative, 1 }
3: { %p_signed = scmp.eq.s32.totalorder %s_shifted, 4294967292 }
4: { dma.hbm_to_smem %hbm, 16, [#allocation2], [#allocation5] }
5: { %s_kept = sld [smem:[#allocation1]] ;; %s_lost = sld [smem:[#allocation2 + $0x3]] }
6: { %s_count = sshra.s32 %s_kept, 3 }
7: { dma.hbm_to_vmem (%p_signed), %hbm, %s_count, %vmem, [#allocation0] }
8: { dma.hbm_to_vmem %hbm, %s_lost, %vmem, [#allocation0] }
9: { dma.hbm_to_smem %hbm, 16, %unknown, [#allocation5] }
10: { %s_unknown = sld [smem:[#allocation1]] }
11: { dma.hbm_to_vmem %hbm, %s_unknown, %vmem, [#allocation0] }
'''))
        self.assertIn(', 2,', resolved[7]['instructions'][0]['text'])
        self.assertTrue(resolved[7]['instructions'][0]['resolved_predicate'])
        self.assertIn('%s_lost', resolved[8]['instructions'][0]['text'])
        self.assertIn('%s_unknown', resolved[11]['instructions'][0]['text'])

    def test_predicated_setup_keeps_a_relative_pointer_loop_bounded(self):
        program = parse_bundles('''
0: { %s_input = inlined_call_operand.vmem [shape: f32[32], index: 0] }
1: { %s_limit = scalar_lea.vmem %s_input, 24 }
2: { %s_seed = smov (!%p_skip), %s_input }
3: { sbr.rel (%p_skip) target = $region2 }
4: {}
5 LB: { %s_ptr = sphi %s_seed, %s_next } /* Start region 1 */
6: { %s_next = scalar_lea.vmem %s_ptr, 8 }
7: { %p_done = scmp.gt.s32.totalorder %s_next, %s_limit }
8: { sbr.rel (!%p_done) target = $region1 }
9: {}
10 PF: {} /* Start region 2 */
''')
        report = estimate_final_program({'TLP': program}, dict(PROFILE, branch_delay_slots=1))
        self.assertEqual(report['modeled_bundle_visits'], 26)
        self.assertEqual(report['instruction_counts']['scalar_lea.vmem'], 5)

    def test_branch_phi_selects_each_incoming_edge_before_merging(self):
        for predicate in ('', ';; %p_skip = pmov 0', ';; %p_skip = pmov 1'):
            program = parse_bundles('''
0: { %s_a = smov 4 ;; %s_b = smov 99 PREDICATE }
1: { sbr.rel (%p_skip) target = $region1 }
2: {}
3: { %s_b = smov 4 }
4 PF: { %s_size = sphi %s_a, %s_b ;; %s_double = sadd.u32 %s_size, %s_size } /* Start region 1 */
5: { dma.hbm_to_vmem %hbm, %s_double, %vmem, [#allocation0] }
'''.replace('PREDICATE', predicate))
            profile = dict(PROFILE, branch_delay_slots=1, dma_granule_bytes=1,
                           dma={'hbm_to_vmem': {'bytes_per_second': 1e9}})
            report = estimate_final_program({'TLP': program}, profile)
            self.assertEqual(report['dma_bytes'], 8)
            self.assertFalse(any('completion credits' in g['reason'] or 'underflow' in g['reason'] for g in report['gaps']))


    def test_clamped_runtime_index_can_prove_a_constant_after_shift(self):
        program = parse_bundles('''
0: { %s_index = smin.u32 4, %s_runtime }
1: { %s_masked = sand.u32 1023, %s_index }
2: { %s_shifted = sshrl.u32 %s_masked, 10 }
3: { %p_zero = scmp.eq.u32.totalorder %s_shifted, 0 }
4: { sbr.rel (%p_zero) target = $region2 }
5: {}
6 LB: { sbr.rel (%p_unknown) target = $region1 } /* Start region 1 */
7: {}
8 PF: {} /* Start region 2 */
''')
        resolved = resolve_scalar_operands(program, branch_delay_slots=1)
        self.assertEqual([b['source_address'] for b in resolved],
                         [f'0:{i:#x}' for i in (0, 1, 2, 3, 4, 5, 8)])

    def test_ready_peers_skip_poll_retries_but_keep_compute_and_dma(self):
        program = parse_bundles('''
0: {}
1 LB: { vwait.ge [#allocation1], 1 /* global-barrier-wait */ } /* Start region 1 */
2: { %s_seed = smov 0 }
3 LB: { %s_i = sphi %s_seed, %s_next } /* Start region 2 */
4: { %s_next = sadd.u32 %s_i, 1 }
5: { %p_more = scmp.lt.u32.totalorder %s_next, 2 }
6: { sbr.rel (%p_more) target = $region2 }
7: {}
8: { sbr.rel (!%p_ready) target = $region1 ;; %s_size = smov (%p_ready) 4 }
9: { dma.hbm_to_vmem %hbm, %s_size, %vmem, [#allocation0] }
10: { dma.done.wait [#allocation0], 4 /* enhanced-barrier-wait */ }
''')
        profile = dict(PROFILE, branch_delay_slots=1, dma_granule_bytes=1,
                       dma={'hbm_to_vmem': {'bytes_per_second': 1e9, 'latency_cycles': 20}})
        with self.assertRaisesRegex(ValueError, 'no finite worst-case bound'):
            estimate_final_program({'TLP': program}, profile)
        profile['assume_peers_ready'] = True
        report = estimate_final_program({'TLP': program}, profile)
        self.assertEqual(report['modeled_bundle_visits'], 16)
        self.assertEqual(report['instruction_counts']['vwait.ge'], 1)
        self.assertEqual(report['instruction_counts']['sadd.u32'], 2)
        self.assertEqual(report['dma_bytes'], 4)
        self.assertEqual(report['wait_stall_cycles'], 23)
        self.assertFalse(any('completion credits' in g['reason'] or 'underflow' in g['reason'] for g in report['gaps']))

        self.assertTrue(any('Peers are assumed ready' in a for a in report['assumptions']))
        # Unmarked synchronization is still an unresolved cost.
        unmarked = estimate_bundles(parse_bundles('0: { vwait.ge [#allocation1], 1 }'), profile)
        self.assertEqual(unmarked['status'], 'partial')

    def test_large_counted_loop_bounds_all_iterations_without_expanding(self):
        program = parse_bundles('''
0: { %s_seed = smov 0 }
1 LB: { %s_i = sphi %s_seed, %s_next ;; %s_data = sphi %s_input, %s_data ;; %s_next = sadd.u32 %s_i, 1 } /* Start region 1 */
2: { %p_first = scmp.eq.u32.totalorder %s_i, 0 }
3: { sbr.rel (%p_first) target = $region2 }
4: { vdelay 20 }
5: {} /* Start region 2 */
6: { %p_more = scmp.lt.u32.totalorder %s_next, 1000000000 }
7: { sbr.rel (%p_more) target = $region1 }
8: {}
''')
        profile = dict(PROFILE, branch_delay_slots=0, vdelay_semantics='total_cycles')
        report = estimate_final_program({'TLP': program}, profile)
        self.assertEqual(report['modeled_cycles'], 28_000_000_002)
        self.assertEqual(report['modeled_bundle_visits'], 7_000_000_002)
        self.assertEqual(report['scheduled_bundle_count'], 9)
        self.assertEqual(report['runtime_loops'][0]['iterations'], 1_000_000_000)
        self.assertLess(len(report['events']), 20)
        self.assertFalse(any('completion credits' in g['reason'] or 'underflow' in g['reason'] for g in report['gaps']))

        extra = estimate_final_program({'TLP': program}, dict(profile, instruction_extra_cycles={'sbr.rel': 5}))
        self.assertEqual(extra['modeled_cycles'], 33_000_000_002)
        with self.assertRaisesRegex(ValueError, 'analysis exceeds'):
            estimate_final_program({'TLP': program}, dict(profile, max_scalar_visits=2))

    def test_large_loop_does_not_reuse_first_iteration_dma_size(self):
        program = parse_bundles('''
0: { %s_seed = smov 0 }
1 LB: { %s_i = sphi %s_seed, %s_next } /* Start region 1 */
2: { dma.hbm_to_vmem %hbm, %s_i, %vmem, [#allocation0] }
3: { %s_next = sadd.u32 %s_i, 1 }
4: { %p_more = scmp.lt.u32.totalorder %s_next, 1000000 }
5: { sbr.rel (%p_more) target = $region1 }
6: {}
''')
        report = estimate_final_program({'TLP': program}, dict(PROFILE, branch_delay_slots=0))
        self.assertEqual(report['runtime_loops'][0]['iterations'], 1000000)
        self.assertTrue(any('DMA service unmodeled' in g['reason'] for g in report['gaps']))
        self.assertIsNone(report['estimated_seconds'])

    def test_large_body_keeps_small_outer_loop_counter_for_inner_bound(self):
        program = parse_bundles('''
0: { %s_seed = smov 0 }
1 LB: { %s_i = sphi %s_seed, %s_next } /* Start region 1 */
2: { %s_bound = sadd.u32 %s_i, 1 }
3: { %s_inner_seed = smov 0 }
4 LB: { %s_j = sphi %s_inner_seed, %s_inner_next } /* Start region 2 */
5: { %s_inner_next = sadd.u32 %s_j, 1 }
6: { %p_inner = scmp.lt.u32.totalorder %s_inner_next, %s_bound }
7: { sbr.rel (%p_inner) target = $region2 }
8: { %s_next = sadd.u32 %s_i, 1 }
9: { %p_outer = scmp.lt.u32.totalorder %s_next, 3 }
10: { sbr.rel (%p_outer) target = $region1 }
11: {}
''')
        padding = tuple(dict(address=f'padding:{i}', instructions=[]) for i in range(4000))
        program = program[:8] + padding + program[8:]
        report = estimate_final_program({'TLP': program}, dict(PROFILE, branch_delay_slots=0))
        self.assertEqual(report['modeled_cycles'], 12049)
        self.assertFalse(report['runtime_loops'])
        self.assertFalse(any('completion credits' in g['reason'] or 'underflow' in g['reason'] for g in report['gaps']))


    def test_counter_overflow_cannot_prove_a_loop_bound(self):
        program = parse_bundles('''
0: { %s_seed = smov 0 }
1 LB: { %s_i = sphi %s_seed, %s_next } /* Start region 1 */
2: { %s_next = sadd.u32 %s_i, 2 }
3: { %p_more = scmp.lt.u32.totalorder %s_next, 4294967295 }
4: { sbr.rel (%p_more) target = $region1 }
''')
        with self.assertRaisesRegex(ValueError, 'analysis exceeds'):
            resolve_scalar_operands(program, branch_delay_slots=0, max_visits=30)

    def test_runtime_bound_preserves_predicate_correlation_and_delay_slot_writes(self):
        program = parse_bundles('''
0: { sbr.rel (%p_runtime) target = $region1 ;; %s_units = smov 1 }
1: { %s_units = smov 5 }
2: { sbr.rel (!%p_runtime) target = $region2 }
3: {}
4: { dma.hbm_to_vmem %hbm, 1000, %vmem, [#allocation0] }
5: { dma.hbm_to_vmem %hbm, %s_units, %vmem, [#allocation0] } /* Start region 1 :: Start region 2 */
''')
        report = estimate_final_program({'TLP': program}, dict(PROFILE,
            branch_delay_slots=1, dma_granule_bytes=1,
            dma={'hbm_to_vmem': {'bytes_per_second': 1e9}}))
        self.assertEqual(len(report['runtime_segments']), 1)
        self.assertEqual(report['dma_bytes'], 5)
        self.assertEqual(report['modeled_cycles'], 9)

    def test_runtime_bound_rejects_unbounded_loop_but_scales_to_many_branches(self):
        loop = {'TLP': parse_bundles('''
0 LB: { sbr.rel (%p_runtime) target = $region1 } /* Start region 1 */
1: {}
''')}
        for ready in (False, True):
            with self.assertRaisesRegex(ValueError, 'no finite worst-case bound'):
                estimate_final_program(loop, dict(PROFILE, branch_delay_slots=0,
                                                   assume_peers_ready=ready))
        # Eighty independent conditions would require 2**80 full paths.
        text = '\n'.join(
            f'{2*i}: {{ sbr.rel (%p{i}) target = $region{i+1} }} /* Start region {i} */\n'
            f'{2*i+1}: {{}}' for i in range(80))
        text += '\n160: {} /* Start region 80 */'
        report = estimate_final_program({'TLP': parse_bundles(text)}, dict(PROFILE, branch_delay_slots=0))
        self.assertEqual(len(report['runtime_segments']), 80)
        self.assertEqual(report['modeled_cycles'], 161)

    def test_runtime_bound_explores_early_exit_inside_statically_bounded_loop(self):
        report = estimate_final_program({'TLP': parse_bundles('''
0: { %s_seed = smov 0 }
1 LB: { %s_i = sphi %s_seed, %s_next } /* Start region 1 */
2: { %p_quit = scmp.eq.u32.totalorder %s_data, 0 }
3: { sbr.rel (%p_quit) target = $region2 }
4: { %s_next = sadd.u32 %s_i, 1 }
5: { %p_more = scmp.lt.u32.totalorder %s_next, 3 }
6: { sbr.rel (%p_more) target = $region1 }
7: {}
8: {} /* Start region 2 */
''')}, dict(PROFILE, branch_delay_slots=0))
        self.assertEqual(len(report['runtime_segments']), 3)
        self.assertEqual(report['modeled_cycles'], 26)
        self.assertTrue(all(c['selected_alternative'] == 0 for c in report['runtime_segments']))

    def test_runtime_bound_excludes_proven_error_halt_path(self):
        report = estimate_final_program({'TLP': parse_bundles('''
0: { sbr.rel (%p0) target = $region1 }
1: { vdelay 10 }
2: { sbr.rel target = $region2 }
3: { shalt.err (%p0) } /* Start region 1 */
4: {} /* Start region 2 */
''')}, dict(PROFILE, branch_delay_slots=0, vdelay_semantics='total_cycles'))
        self.assertEqual(len(report['runtime_segments'][0]['alternative_cycles']), 1)
        self.assertEqual(report['modeled_cycles'], 13)

    def test_segment_join_preserves_loop_entry_phi(self):
        report = estimate_final_program({'TLP': parse_bundles("""
0: { %s_seed = smov 0 }
1: { sbr.rel (%p0) target = $region1 }
2: {}
3 LB: { %s_i = sphi %s_seed, %s_next } /* Start region 1 */
4: { %s_next = sadd.u32 %s_i, 1 }
5: { %p_more = scmp.lt.u32.totalorder %s_next, 2 }
6: { sbr.rel (%p_more) target = $region1 }
7: {}
""")}, dict(PROFILE, branch_delay_slots=0))
        self.assertEqual(report['modeled_cycles'], 13)
        self.assertEqual(len(report['runtime_segments']), 1)

    def test_delayed_loop_branch_keeps_phi_updates_and_dma(self):
        program = parse_bundles('''
0: { %s_seed = smov 0 }
1 LB: { %s_i = sphi %s_seed, %s_next } /* Start region 1 */
2: { %p_more = scmp.lt.u32.totalorder %s_i, 2 }
3: { sbr.rel (%p_more) target = $region1 }
4: { %s_next = sadd.u32 %s_i, 1 }
5: { dma.hbm_to_vmem %hbm, %s_next, %vmem, [#allocation0] }
6: { vadd 1, 2 }
''')
        resolved = resolve_scalar_operands(program, branch_delay_slots=2)
        self.assertEqual([b['source_address'] for b in resolved],
                         ['0:0x0'] + [f'0:{i:#x}' for i in range(1, 6)] * 3 + ['0:0x6'])
        dmas = [b['instructions'][0]['text'] for b in resolved
                if b['source_address'] == '0:0x5']
        self.assertEqual(dmas, [f'dma.hbm_to_vmem %hbm, {n}, %vmem, [#allocation0]'
                               for n in (1, 2, 3)])
        with self.assertRaisesRegex(ValueError, 'delay slots are not supplied'):
            resolve_scalar_operands(program)

    def test_branch_decision_uses_issue_time_predicate(self):
        program = parse_bundles('''
0: { %p0 = scmp.eq.u32.totalorder 1, 1 }
1: { sbr.rel (%p0) target = $region3 }
2: { %p0 = scmp.eq.u32.totalorder 1, 0 }
3: { dma.hbm_to_vmem %hbm, 100, %vmem, [#allocation0] }
4 PF: { vadd 1, 2 } /* Start/End empty region 3 */
''')
        resolved = resolve_scalar_operands(program, branch_delay_slots=1)
        self.assertEqual([b['source_address'] for b in resolved],
                         ['0:0x0', '0:0x1', '0:0x2', '0:0x4'])

    def test_scalar_select_and_u32_wrap(self):
        resolved = resolve_scalar_operands(parse_bundles('''
0: { %s0 = sadd.u32 4294967295, 5 }
1: { %p0 = scmp.eq.u32.totalorder %s0, 4 }
2: { %s1 = scalar_select %p0, %s0, 8 }
3: { %dma = dma.hbm_to_vmem %hbm, %s1, %vmem, [#allocation0] }
'''))
        self.assertIn(', 4,', resolved[3]['instructions'][0]['text'])

    def test_scalar_spills_preserve_loop_control_values(self):
        program = parse_bundles('''
0: { %s0 = smov 32 }
1: { %store = sst [smem:[#allocation7_spill]] %s0 ;; sst [smem:[#allocation8 + $0x3]] %s0 }
2: { %s1 = sld [smem:[#allocation7_spill]] }
3: { %dma = dma.hbm_to_vmem %hbm, %s1, %vmem, [#allocation0] }
4: { inlined_call /* kernel */ }
5: { %unknown = sst [smem:%s_pointer] %s0 }
6: { %s2 = sld [smem:[#allocation7_spill]] }
7: { %dma2 = dma.hbm_to_vmem %hbm, %s2, %vmem, [#allocation1] }
''')
        resolved = resolve_scalar_operands(program)
        self.assertIn(', 32,', resolved[3]['instructions'][0]['text'])
        self.assertIn(', 32,', resolved[7]['instructions'][0]['text'])
        program[0]['instructions'].append({
            'opcode': 'smov', 'text': '%s_escape = smov [#allocation7_spill]'})
        resolved = resolve_scalar_operands(program)
        self.assertIn('%s2,', resolved[7]['instructions'][0]['text'])

    def test_scalar_coissue_unknown_writes_and_predicates(self):
        resolved = resolve_scalar_operands(parse_bundles('''
0: { %s0 = smov 8 }
1: { %s0 = smov 16 ;; %s1 = smul.u32 %s0, 4 }
2: { %s2 = smov 4294967295 ;; %s3 = sld %unknown }
3: { %p0 = scmp.lt.s32.totalorder %s2, 0 }
4: { %s4 = smov (%p0, %s0), 64 }
5: { %dma = dma.hbm_to_vmem %hbm, %s1, %vmem, [#allocation0] }
6: { %dma2 = dma.hbm_to_vmem (!%p0), %hbm, %s4, %vmem, [#allocation1] }
7: { %s1 = smov (%p_unknown), 100 }
8: { %s1 = sld %unknown }
9: { %dma3 = dma.hbm_to_vmem %hbm, %s1, %vmem, [#allocation2] }
'''))
        self.assertIn(', 32,', resolved[5]['instructions'][0]['text'])
        self.assertIn(', 64,', resolved[6]['instructions'][0]['text'])
        self.assertFalse(resolved[6]['instructions'][0]['resolved_predicate'])
        self.assertIn('%s1,', resolved[9]['instructions'][0]['text'])
        result = estimate_bundles(iter_final_bundles({'TLP': resolved}), dict(PROFILE, dma_granule_bytes=32,
            dma={'hbm_to_vmem': {'bytes_per_second': 1e9, 'latency_cycles': 0}}))
        self.assertEqual(result['dma_bytes'], 1024)


if __name__ == "__main__":
    unittest.main()
