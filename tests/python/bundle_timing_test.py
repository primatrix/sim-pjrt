"""Behavior checks for pure bundle parsing and timing; no JAX/libtpu required."""

import copy
import json
from pathlib import Path
import unittest

from bundle_timing import (
    compose_final_bundles,
    estimate_bundles,
    expand_path,
    parse_bundles,
    parse_deduplication_map,
)

PROFILE = {"frequency_hz": 1e9, "bundle_issue_cycles": 1}
FIXTURES = Path(__file__).resolve().parents[1] / "fixtures" / "bundles"


class BundleTimingTest(unittest.TestCase):
    def test_final_calls_expand_per_invocation(self):
        modules = {
            "TLP": parse_bundles(
                "0 : { inlined_call /* %kernel = fusion(%x) */ }\n1 : { inlined_call /* %kernel = fusion(%y) */ }"
            ),
            "kernel": parse_bundles("0 : { vadd 1, 2 }\n1 : {}"),
            "unused": parse_bundles("0 : { unknown }"),
        }
        before = copy.deepcopy(modules)
        result = compose_final_bundles(modules)
        self.assertEqual(len(result), 4)
        self.assertEqual(len({b["address"] for b in result}), 4)
        self.assertEqual(estimate_bundles(result, PROFILE)["issue_cycles"], 4)
        self.assertEqual(modules, before)
        self.assertEqual({b["module"] for b in result}, {"kernel"})

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
        scopes = [e for e in report["activity_timeline"] if e["track"] == "Kernels"]
        self.assertEqual([e["name"] for e in scopes], ["fusion.1", "copy.2"])
        self.assertEqual([(e["start_ns"], e["end_ns"]) for e in scopes], [(0, 2), (2, 4)])
        self.assertTrue(all("module=shared" in e["detail"] for e in scopes))
        self.assertNotEqual(scopes[0]["detail"], scopes[1]["detail"])
        # Replaying the same call site must create another scope, not merge it.
        repeated = estimate_bundles(
            program, PROFILE,
            {"path": [{"repeat": 2, "body": [b["address"] for b in program[:2]]}]},
        )
        scopes = [e for e in repeated["activity_timeline"] if e["track"] == "Kernels"]
        self.assertEqual(len(scopes), 2)

    def test_no_operation_track(self):
        report = estimate_bundles(parse_bundles(
            "0 : { vadd 1, 2 }\n1 : { vmul 1, 2 }\n2 : { vmov 1, 2 }"
        ), PROFILE)
        self.assertEqual({e["track"] for e in report["activity_timeline"]}, {"Kernels"})
        self.assertEqual(report["modeled_cycles"], 3)

    def test_activity_dma_wait_and_tail_share_the_model_clock(self):
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
        dma = [e for e in timeline if e["track"] == "DMA / hbm"]
        self.assertEqual([(e["start_ns"], e["end_ns"]) for e in dma], [(0, 8), (8, 16)])
        self.assertEqual([e["bytes"] for e in dma], [8, 8])
        wait = next(e for e in timeline if e["track"] == "Wait")
        self.assertEqual((wait["start_ns"], wait["end_ns"]), (3, 16))
        tail = next(e for e in timeline if e["track"] == "Completion")
        self.assertEqual((tail["start_ns"], tail["end_ns"]), (16, 18))
        self.assertEqual(report["modeled_cycles"], 18)
        self.assertTrue(all(0 <= e["start_ns"] <= e["end_ns"] <= 18 for e in timeline))

    def test_unresolved_cost_is_a_marker_not_invented_latency(self):
        report = estimate_bundles(parse_bundles("0 : { vwait.ge [sflag:$52], $8 }"), PROFILE)
        timeline = report["activity_timeline"]
        self.assertFalse(any(e["track"] == "Wait" for e in timeline))
        unknown = next(e for e in timeline if e["track"] == "Unresolved")
        self.assertEqual(unknown["start_ns"], unknown["end_ns"])
        self.assertTrue(unknown["cost_gap"])
        self.assertEqual(report["modeled_cycles"], 1)

    def test_final_control_markers_and_deduplication(self):
        kernel = parse_bundles(
            "0 LB: > { sbr.rel target = $region1 }\n1 : > { vadd 1, 2 }\n2 LE: { }"
        )
        self.assertEqual(len(kernel), 3)
        program = compose_final_bundles(
            {
                "TLP": parse_bundles(
                    "0 : { inlined_call /* %kernel.clone = fusion(%x) */ }"
                ),
                "kernel": kernel,
            },
            parse_deduplication_map(
                "key:kernel\nordinal:1\nequivalent_hlos[size=2]:\n  kernel\n  kernel.clone\n"
            ),
        )
        report = estimate_bundles(program, PROFILE)
        self.assertEqual(report["scheduled_bundle_count"], 3)
        self.assertTrue(any("control flow" in g["reason"] for g in report["gaps"]))

    def test_malformed_deduplication_map_rejected(self):
        for text in [
            "",
            "key:k\nordinal:0\nequivalent_hlos[size=2]:\n  x\n",
            "key:k\nordinal:0\nequivalent_hlos[size=1]:\n  x\nkey:m\nordinal:1\nequivalent_hlos[size=1]:\n  x\n",
        ]:
            with self.subTest(text=text), self.assertRaises(ValueError):
                parse_deduplication_map(text)

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

    def test_parallel_instructions_and_empty_bundle(self):
        p = parse_bundles(
            "0:0x10 : {v0 = vadd.f32 v1, v2; v3 = vmul.f32 v4, v5}\n0:0x30 : {}"
        )
        r = estimate_bundles(p, PROFILE)
        self.assertEqual(r["modeled_cycles"], 2)  # not address delta or opcode count
        self.assertEqual(r["status"], "modeled")

    def test_multiline_comments_and_nested_braces(self):
        p = parse_bundles(
            "0 : { %0 = inlined_call_operand.hbm [shape index: {}] /* }; ;;\nignored */ ;; %1 = vadd.f32 1, %0 }"
        )
        self.assertEqual(len(p[0]["instructions"]), 2)

    def test_invalid_input(self):
        for text in (
            "not a dump",
            "0 : { vadd 1",
            "0 : {}\n0 : {}",
            "0 : { /* unclosed }",
        ):
            with self.assertRaises(ValueError):
                parse_bundles(text)
        with self.assertRaises(ValueError):
            estimate_bundles(parse_bundles("0 : {}"), {"frequency_hz": float("nan")})

    def test_real_pallas_dump(self):
        p = parse_bundles((FIXTURES / "pallas_add.txt").read_text())
        profile = json.loads((FIXTURES / "example_profile.json").read_text())
        original = copy.deepcopy((p, profile))
        r = estimate_bundles(p, profile, {"assume_no_faults": True})
        self.assertEqual(
            len(p), 34
        )  # libtpu schedule-analysis independently reports 34
        self.assertEqual(r["dma_bytes"], 8192)
        self.assertEqual(r["wait_stall_cycles"], 118)
        self.assertEqual(r["modeled_cycles"], 152)
        self.assertEqual(r["status"], "modeled")
        self.assertEqual((p, profile), original)

    def test_dma_overlap_and_resource_contention(self):
        p = parse_bundles(
            """0 : { %0 = dma.hbm_to_vmem %src, 1, %dst, [#allocation1] }
1 : { %1 = dma.hbm_to_vmem %src, 1, %dst, [#allocation2] }
2 : { %2 = dma.done.wait [#allocation2], 1 }"""
        )
        profile = dict(
            PROFILE,
            dma_granule_bytes=10,
            dma={"hbm_to_vmem": {"bytes_per_second": 1e9, "resource": "hbm"}},
        )
        r = estimate_bundles(p, profile)
        self.assertEqual(r["modeled_cycles"], 20)
        self.assertEqual(r["wait_stall_cycles"], 17)
        self.assertEqual(r["dma_bytes"], 20)

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
        self.assertEqual(estimate_bundles(p, PROFILE)["status"], "partial")
        scenario = {
            "path": [
                {"repeat": 2, "body": ["0:0x0", {"repeat": 3, "body": ["0:0x1"]}]}
            ],
            "predicates": {"0:0": False, "4:0": False},
        }
        r = estimate_bundles(p, PROFILE, scenario)
        self.assertEqual(r["modeled_cycles"], 8)
        self.assertEqual(r["status"], "modeled")
        self.assertEqual(expand_path([{"repeat": 0, "body": ["0:0x0"]}]), ())
        with self.assertRaises(ValueError):
            expand_path([{"repeat": 10**10, "body": ["0:0x0"]}])

    def test_unknown_and_unexpanded_calls_are_gaps(self):
        p = parse_bundles("0 : { %0 = mystery }\n1 : { %1 = inlined_call }")
        self.assertEqual(len(estimate_bundles(p, PROFILE)["gaps"]), 2)
        r = estimate_bundles(
            p,
            dict(PROFILE, instruction_extra_cycles={"mystery": 2}),
            {"call_cycles": {"1:0": 10}},
        )
        self.assertEqual(r["modeled_cycles"], 14)

    def test_unknown_wait_and_partial_credit(self):
        for text in (
            "0 : {%0 = dma.done.wait [#allocation7], 8}",
            "0:0x0 : {_ = vwait.ge [sflag:$52], $8}",
        ):
            self.assertIsNone(
                estimate_bundles(parse_bundles(text), PROFILE)["estimated_seconds"]
            )

    def test_repeated_dma_reuses_credits_and_unknown_update_is_reported(self):
        p = parse_bundles(
            """0 : { %0 = dma.hbm_to_vmem %src, 1, %dst, [#allocation1] }
1 : { %1 = dma.done.wait [#allocation1], 1 }
2 : { %2 = vsyncadd [#allocation1], 4294967295 }"""
        )
        profile = dict(
            PROFILE,
            dma_granule_bytes=10,
            dma={"hbm_to_vmem": {"bytes_per_second": 1e9}},
        )
        r = estimate_bundles(
            p, profile, {"path": [{"repeat": 2, "body": ["0:0x0", "0:0x1", "0:0x2"]}]}
        )
        self.assertEqual(r["modeled_cycles"], 22)
        self.assertEqual(r["status"], "modeled")
        p = parse_bundles("0 : { %0 = vsyncadd [#allocation1], %s1 }")
        self.assertEqual(estimate_bundles(p, PROFILE)["status"], "partial")


if __name__ == "__main__":
    unittest.main()
