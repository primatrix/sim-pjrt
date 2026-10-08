"""Behavior regressions for llo program; no TPU required."""

import copy
import json
from pathlib import Path
import tempfile
import unittest

from sim_pjrt.llo.control_flow import resolve_scalar_operands
from sim_pjrt.llo.cost import estimate_bundles
from sim_pjrt.llo.parser import parse_bundles, parse_deduplication_map
from sim_pjrt.llo.program import (
    annotate_branch_delays, annotate_loop_bounds, compose_final_bundles,
    estimate_final_program, load_final_modules,
)

PROFILE = {"frequency_hz": 1e9, "bundle_issue_cycles": 1}


class LloProgramTest(unittest.TestCase):
    def test_scalar_arguments_are_bound_per_call_including_deduplicated_kernels(self):
        modules = {'TLP': parse_bundles('''
0: { %s_arg = smov 0 }
1: { inlined_call %s_arg /* kernel */ }
2: { %s_arg = smov 1 }
3: { inlined_call %s_arg /* alias */ }
'''), 'kernel': parse_bundles('''
0: { %s0 = inlined_call_operand.<no memory space> [shape: s32[], index: 0, kind: input, shape index: {}] }
1: { %p0 = scmp.eq.s32.totalorder %s0, 0 }
2: { sbr.rel (%p0) target = $region1 }
3: { vdelay 100 }
4: {} /* Start region 1 */
''')}
        report = estimate_final_program(modules, dict(PROFILE, branch_delay_slots=0,
            vdelay_semantics='total_cycles'), {'alias': 'kernel'})
        self.assertEqual(report['modeled_cycles'], 110)

    def test_assembly_recovers_missing_exit_region_for_every_invocation(self):
        modules = {
            'TLP': parse_bundles('0: { inlined_call /* kernel */ }\n1: { inlined_call /* kernel */ }'),
            'kernel': parse_bundles('0: { sbr.rel (%p0) target = $region7 }\n1: {}'),
        }
        assembly = '''0: {(pc) = sbr.rel @p0 $+1, $0 (=0x1)}
1: {}
2: {(pc) = sbr.rel @p0 $+1, $0 (=0x3)}
3: {}'''
        with self.assertRaisesRegex(ValueError, 'does not target the kernel exit'):
            annotate_branch_delays(copy.deepcopy(modules), {}, assembly.replace('(=0x3)', '(=0x2)'))
        annotate_branch_delays(modules, {}, assembly)
        self.assertEqual(modules['kernel'][-1]['regions'], ['7'])
        report = estimate_final_program(modules, PROFILE)
        self.assertEqual(report['modeled_cycles'], 4)

    def test_hlo_bound_matches_a_unique_unconditional_loop_call(self):
        modules = {'TLP': parse_bundles('''
0: {}
1 LB: {} /* Start region 1 */
2: { inlined_call /* body */ }
3: { sbr.rel (%p_runtime) target = $region1 }
4: {}
'''), 'body': parse_bundles('0: { vdelay 10 }')}
        annotate_loop_bounds(modules['TLP'], {'body': 3})
        report = estimate_final_program(modules, dict(PROFILE, branch_delay_slots=1,
                                                     vdelay_semantics='total_cycles'))
        self.assertEqual(report['modeled_cycles'], 40)
        self.assertEqual(report['runtime_loops'][0]['bound_source'], 'hlo')
        # Another invocation or a skippable call cannot establish this binding.
        for text in ('''0: { inlined_call /* body */ }
1 LB: { inlined_call /* body */ } /* Start region 1 */
2: { sbr.rel (%p_runtime) target = $region1 }
3: {}''', '''0 LB: { sbr.rel (%p_skip) target = $region2 } /* Start region 1 */
1: { inlined_call /* body */ }
2: { sbr.rel (%p_runtime) target = $region1 } /* Start region 2 */
3: {}''', '''0 LB: { inlined_call (%p_skip) /* body */ } /* Start region 1 */
1: { sbr.rel (%p_runtime) target = $region1 }
2: {}'''):
            program = parse_bundles(text)
            annotate_loop_bounds(program, {'body': 3})
            self.assertFalse(any('hlo_loop_bound' in b for b in program))

    def test_implicit_assembly_branch_delay_requires_profile_value(self):
        modules = {'TLP': parse_bundles('''
0: { sbr.rel target = $region1 }
1: {}
2: {}
3: {} /* Start region 1 */
''')}
        annotate_branch_delays(modules, {}, '''
0: {(pc) = sbr.rel $+3 (=0x3)}
1: {}
2: {}
3: {}
''')
        self.assertNotIn('branch_delay_slots', modules['TLP'][0]['instructions'][0])
        with self.assertRaisesRegex(ValueError, 'delay slots are not supplied'):
            estimate_final_program(modules, PROFILE)
        report = estimate_final_program(modules, dict(PROFILE, branch_delay_slots=1))
        self.assertEqual(report['modeled_cycles'], 3)

    def test_assembly_supplies_compacted_branch_delays_per_instruction(self):
        for delay in (0, 1, 3, 6):
            with self.subTest(delay=delay):
                modules = {'TLP': parse_bundles('''
0: { %p41_p0 = scmp.eq.u32.totalorder 1, 1 }
1: { sbr.rel (%p41_p0) target = $region1 }
2: { %s_units = smov 32 }
3: {}
4: {}
5: {}
6: {}
7: {}
8: { dma.hbm_to_vmem %hbm, 100, %vmem, [#allocation0] }
9: {} /* Start region 1 */
''')}
                assembly = '\n'.join(
                    f'{i}: {{' + (f'(pc) = sbr.rel @p0 $+8, ${delay} (=0x9)' if i == 1 else '') + '}'
                    for i in range(10))
                annotate_branch_delays(modules, {}, assembly, topology='v5e:2x2')
                # Assembly takes precedence over a nominal target setting.
                resolved = resolve_scalar_operands(modules['TLP'], branch_delay_slots=6)
                self.assertEqual([b['source_address'] for b in resolved],
                                 [f'0:{i:#x}' for i in range(2 + delay)] + ['0:0x9'])
                self.assertEqual(estimate_bundles(resolved, PROFILE)['dma_bytes'], 0)

    def test_v5e_manifest_supplies_fixed_branch_delay(self):
        # The fourth delay slot sets the DMA size. The taken branch skips the
        # following overwrite, so a wrong delay changes the modeled transfer.
        llo = '''0: { sbr.rel target = $region1 }
1: {}
2: {}
3: {}
4: { %s_units = smov 32 }
5: { %s_units = smov 64 }
6: { dma.hbm_to_vmem %hbm, %s_units, %vmem, [#allocation0] } /* Start region 1 */
'''
        assembly = '\n'.join(f'{i}: {{' + (
            '(pc) = sbr.rel $+6 (=0x6)' if i == 0 else '') + '}' for i in range(7))
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            files = []
            for name, text in (
                ('1-TLP-00-final_bundles.txt', llo),
                ('1-TLP-01-assembly-pre-overlay.txt', assembly),
                ('1-TLP-02-deduplication-map.txt', 'key:TLP\nordinal:0\nequivalent_hlos[size=0]:\n'),
            ):
                path = root / name
                path.write_text(text)
                files.append(str(path))
            manifest = root / 'manifest.json'
            manifest.write_text(json.dumps({'files': files, 'topology': 'v5e:2x2'}))
            modules, aliases, provenance = load_final_modules(manifest)
        self.assertEqual(provenance['topology'], 'v5e:2x2')
        resolved = resolve_scalar_operands(modules['TLP'])
        self.assertEqual([b['source_address'] for b in resolved],
                         [f'0:{i:#x}' for i in (0, 1, 2, 3, 4, 6)])
        report = estimate_final_program(modules, dict(PROFILE, dma_granule_bytes=1,
            dma={'hbm_to_vmem': {'bytes_per_second': 1e9}}), aliases)
        self.assertEqual(report['dma_bytes'], 32)

    def test_assembly_alignment_validates_calls_predicates_targets_and_length(self):
        modules = {
            'TLP': parse_bundles('0: { inlined_call /* kernel */ }\n1: { inlined_call /* alias */ }'),
            'kernel': parse_bundles('''
0: { sbr.rel (!%p10_p1) target = $region1 }
1: {} /* Start region 1 */
''')}
        assembly = '''
0: {(pc) = sbr.rel @!p1 $+1, $0 (=0x1)}
1: {}
2: {(pc) = sbr.rel @!p1 $+1, $0 (=0x3)}
3: {}
'''
        aliases = parse_deduplication_map(
            'key:kernel\nordinal:0\nequivalent_hlos[size=1]:\n  alias\n')
        annotate_branch_delays(modules, aliases, assembly)
        self.assertEqual(modules['kernel'][0]['instructions'][0]['branch_delay_slots'], 0)
        for invalid, reason in (
            (assembly.replace('@!p1', '@p1', 1), 'predicate mismatch'),
            (assembly.replace('(=0x1)', '(=0x3)', 1), 'target mismatch'),
            (assembly.replace('3: {}', ''), 'bundle counts differ'),
            (assembly.replace('$0 (=0x3)', '$1 (=0x3)'), 'inconsistent branch delay'),
        ):
            with self.subTest(reason=reason), self.assertRaisesRegex(ValueError, reason):
                annotate_branch_delays(copy.deepcopy(modules), aliases, invalid)

    def test_top_level_far_target_is_not_compared_before_overlays(self):
        modules = {'TLP': parse_bundles('''
0: { sbr.rel (%p0) target = $region1 }
1: {} /* Start region 1 */
''')}
        # Pre-overlay assembly may print a sign-extended wrapped destination.
        annotate_branch_delays(modules, {}, '''
0: {(pc) = sbr.rel @p0 $-37810, $0 (=0xffffffffffff6cd5)}
1: {}
''')
        self.assertEqual(modules['TLP'][0]['instructions'][0]['branch_delay_slots'], 0)

    def test_final_calls_fail_closed(self):
        for text in [
            "inlined_call",
            "inlined_call /* missing */",
            "inlined_call /* TLP */",
            "inlined_call /* kernel */ ;; vadd 1, 2",
        ]:
            with self.subTest(text=text), self.assertRaises(ValueError):
                compose_final_bundles(
                    {
                        "TLP": parse_bundles("0 : { " + text + " }"),
                        "kernel": parse_bundles("0 : {}"),
                    }
                )


if __name__ == "__main__":
    unittest.main()
