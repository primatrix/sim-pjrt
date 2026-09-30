"""Offline TPU operation attribution, metadata, and conservative grouping."""

import gzip
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

from sim_pjrt.profiling.hlo import expression_metadata, module_metadata, parse_hlo
from sim_pjrt.profiling.importer import build_database, import_profile, operation_kind
from sim_pjrt.prediction import ReplayPredictor


def capture(events, devices=1):
    metadata = []
    for device in range(devices):
        metadata += [
            {"ph": "M", "name": "process_name", "pid": device,
             "args": {"name": f"/device:TPU:{device}"}},
            {"ph": "M", "name": "thread_name", "pid": device, "tid": 2,
             "args": {"name": "XLA Modules"}},
            {"ph": "M", "name": "thread_name", "pid": device, "tid": 3,
             "args": {"name": "XLA Ops"}}]
    return {"traceEvents": metadata + events}


def module(program=100, ts=0, dur=10, pid=0, name="jit_work"):
    return {"ph": "X", "pid": pid, "tid": 2, "ts": ts, "dur": dur,
            "name": f"{name}({program})", "args": {}}


def operation(expression, ts=1, dur=2, pid=0):
    return {"ph": "X", "pid": pid, "tid": 3, "ts": ts, "dur": dur,
            "name": expression.split(" = ")[0].lstrip("%"),
            "args": {"long_name": expression}}


class ProfileImportTest(unittest.TestCase):
    def test_plain_profile_shapes_and_warmup_without_identities(self):
        text = "%add.1 = bf16[4,8]{1,0} add(bf16[4,8]{1,0} %a, bf16[4,8]{1,0} %b)"
        db = build_database(capture([module(ts=0), operation(text, ts=1),
                                     module(ts=20), operation(text, ts=21, dur=3)]))
        self.assertEqual(len(db["programs"]), 1)
        self.assertFalse(db["executables"])
        program = next(iter(db["programs"].values()))
        self.assertEqual(program["program_id"], "100")
        op = next(iter(program["operations"].values()))
        self.assertEqual(op["input_shapes"][0]["dimensions"], [4, 8])
        self.assertEqual(op["input_shapes"][0]["dtype"], "bf16")
        self.assertEqual(op["devices"]["/device:TPU:0"]["samples_ns"], [3000])
        self.assertEqual(op["observations"][1]["offset_ns"], 1000)
        self.assertFalse(op["structure_complete"])

    def test_module_fingerprint_separates_same_names(self):
        db = build_database(capture([module(100), module(200, ts=20)]), skip_first=0)
        self.assertEqual({p["program_id"] for p in db["programs"].values()}, {"100", "200"})

    def test_collective_parameters_and_async_dependencies(self):
        start = "%ar-start = (f32[8], f32[8]) all-reduce-start(f32[8] %x), replica_groups={{0,1},{2,3}}, channel_id=7, to_apply=%sum"
        done = "%ar-done = f32[8] all-reduce-done((f32[8], f32[8]) %ar-start)"
        db = build_database(capture([module(), operation(start), operation(done, ts=6)]), skip_first=0)
        program = next(iter(db["programs"].values()))
        by_name = {o["name"]: o for o in program["operations"].values()}
        self.assertEqual(by_name["ar-start"]["kind"], "collective")
        self.assertEqual(by_name["ar-start"]["communication"]["replica_groups"], "{{0,1},{2,3}}")
        self.assertEqual(by_name["ar-start"]["communication"]["channel_id"], "7")
        self.assertEqual(by_name["ar-start"]["communication"]["participants_per_group"], [2])
        self.assertEqual(by_name["ar-done"]["communication"]["channel_id"], "7")
        self.assertEqual(by_name["ar-done"]["features"]["output"]["bytes"], 32)
        self.assertIsNone(by_name["ar-start"]["communication"]["wire_bytes"])
        self.assertEqual(len(program["async_dependencies"]), 1)
        self.assertEqual(program["async_dependencies"][0]["invocation_pairing"], "not_inferred")
        for opcode in ("all-gather", "reduce-scatter", "all-to-all", "collective-permute"):
            self.assertEqual(operation_kind(opcode), "collective")
        self.assertEqual(operation_kind("send-done"), "communication")

    def test_devices_are_kept_separate(self):
        text = "%copy = f32[8] copy(f32[8] %x)"
        db = build_database(capture([
            module(pid=0), operation(text, pid=0), module(pid=1, dur=20),
            operation(text, pid=1, dur=8)], devices=2), skip_first=0)
        program = next(iter(db["programs"].values()))
        op = next(iter(program["operations"].values()))
        self.assertEqual(op["devices"]["/device:TPU:0"]["median_ns"], 2000)
        self.assertEqual(op["devices"]["/device:TPU:1"]["median_ns"], 8000)

    def test_overlapping_invocations_require_unambiguous_attribution(self):
        text = "%negate = f32[8] negate(f32[8] %x)"
        events = [module(100), module(200), operation(text)]
        db = build_database(capture(events), skip_first=0)
        self.assertEqual(len(db["unmatched_events"]), 1)
        events[-1]["args"]["program_id"] = "200"
        db = build_database(capture(events), skip_first=0)
        self.assertFalse(db["unmatched_events"])
        self.assertEqual(sum(len(p["operations"]) for p in db["programs"].values()), 1)

    def test_simulated_ops_and_unknown_shapes_are_not_invented(self):
        simulated = operation("%fake = f32[8] negate(f32[8] %x)")
        simulated["args"]["clock_domain"] = "simulated"
        unknown = operation("%unknown = f32[8] negate(f32[8] %x)", ts=4)
        unknown["args"] = {}
        db = build_database(capture([module(), simulated, unknown]), skip_first=0)
        op = next(iter(next(iter(db["programs"].values()))["operations"].values()))
        self.assertIsNone(op["input_shapes"])
        self.assertIsNone(op["output_shape"])

    def test_tuple_shapes_and_output_are_not_confused_with_inputs(self):
        record = expression_metadata(
            "%gather = f32[16,8] all-gather(f32[4,8] %x), dimensions={0}, replica_groups={{0,1,2,3}}")
        self.assertEqual(record["input_shapes"][0]["dimensions"], [4, 8])
        self.assertEqual(record["output_shape"]["dimensions"], [16, 8])
        record = expression_metadata("%gte = f32[4] get-tuple-element((f32[4], token[]) %x), index=0")
        self.assertEqual(record["input_shapes"][0]["kind"], "tuple")

    def test_json_gzip_import_needs_no_simulator_environment(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "trace.json.gz"
            path.write_bytes(gzip.compress(json.dumps(capture([module()])).encode()))
            out = Path(tmp) / "timings.json"
            db = import_profile(path, out, skip_first=0)
            self.assertEqual(len(db["programs"]), 1)
            with self.assertRaisesRegex(ValueError, "No exact replay identities"):
                ReplayPredictor(out)
            with self.assertRaisesRegex(ValueError, "already exists"):
                import_profile(path, out)


@unittest.skipUnless(importlib.util.find_spec("jaxlib"), "HLO parsing requires installed jaxlib")
class HloGroupingTest(unittest.TestCase):
    def test_isolated_parser_does_not_rebuild_dump_schedule(self):
        text = """HloModule scheduled, is_scheduled=true
ENTRY main {
 x = f32[4] parameter(0)
 ROOT y = f32[4] negate(x)
}"""
        metadata = parse_hlo(text, source="test")
        self.assertEqual(metadata["operations"]["y"]["input_shapes"][0]["dimensions"], [4])
        self.assertIn("is_scheduled=true", metadata["hlo_text"])
        with self.assertRaisesRegex(ValueError, "parser exited"):
            parse_hlo("HloModule invalid\nENTRY broken { invalid }", source="test")

    def test_async_call_sugar_and_hidden_computations(self):
        text = """HloModule async, is_scheduled=true
called_computation {
 param = f32[4] parameter(0)
 ROOT out = f32[4] negate(param)
}, execution_thread="sparsecore"
ENTRY main {
 input = f32[4] parameter(0)
 start = ((), (), s32[]) call-start(), async_execution_thread="sparsecore", to_apply=called_computation
 update = ((f32[4]), f32[4]) call-update(start, input)
 ROOT done = f32[4] call-done(update)
}"""
        metadata = parse_hlo(text, source="test")
        done = metadata["operations"]["done"]
        self.assertTrue(done["structure_complete"])
        self.assertIn("negate", done["contained_opcodes"])

    @staticmethod
    def hlo(size=8, dtype="f32", body="negate", name="jit_work"):
        return f"""HloModule {name}
fused {{
 p = {dtype}[{size}] parameter(0)
 ROOT out = {dtype}[{size}] {body}(p)
}}
ENTRY main {{
 x = {dtype}[{size}] parameter(0)
 ROOT fusion = {dtype}[{size}] fusion(x), kind=kLoop, calls=fused
}}"""

    def test_shape_is_a_feature_dtype_and_body_are_separate(self):
        a, b, c, d = [module_metadata(text)["operations"]["fusion"] for text in (
            self.hlo(8), self.hlo(16), self.hlo(16, "bf16"), self.hlo(16, body="exponential"))]
        self.assertEqual(a["structure_key"], b["structure_key"])
        self.assertEqual(a["dtype_key"], b["dtype_key"])
        self.assertEqual(b["structure_key"], c["structure_key"])
        self.assertNotEqual(b["dtype_key"], c["dtype_key"])
        self.assertNotEqual(b["structure_key"], d["structure_key"])

    def test_same_name_hlo_dumps_match_observed_signatures_and_group_shapes(self):
        catalog = [module_metadata(self.hlo(size)) for size in (8, 16)]
        events = []
        for index, size in enumerate((8, 16)):
            text = catalog[index]["operations"]["fusion"]["hlo_text"]
            events += [module(100 + index, ts=index * 20), operation(text, ts=index * 20 + 1)]
        db = build_database(capture(events), hlo_catalog=catalog, skip_first=0)
        self.assertEqual(len(db["operation_groups"]), 1)
        group = next(iter(db["operation_groups"].values()))
        self.assertEqual(len(group["points"]), 2)
        self.assertEqual({p["input_shapes"][0]["dimensions"][0] for p in group["points"]}, {8, 16})
        self.assertTrue(all("hlo_match_error" not in p for p in db["programs"].values()))

    def test_same_name_and_shapes_but_different_bodies_stay_ambiguous(self):
        catalog = [module_metadata(self.hlo(body=body)) for body in ("negate", "exponential")]
        expression = catalog[0]["operations"]["fusion"]["hlo_text"]
        db = build_database(capture([module(), operation(expression)]),
                            hlo_catalog=catalog, skip_first=0)
        self.assertFalse(db["operation_groups"])
        self.assertIn("hlo_match_error", next(iter(db["programs"].values())))

    def test_embedded_metadata_and_external_dump_do_not_create_false_ambiguity(self):
        embedded = module_metadata(self.hlo(), source="xprof_embedded_hlo:jit_work(1)")
        external = module_metadata(self.hlo().replace("kind=kLoop", 'kind=kLoop, backend_config="impl"'))
        expression = embedded["operations"]["fusion"]["hlo_text"]
        db = build_database(capture([module(), operation(expression)]),
                            hlo_catalog=[embedded, external], skip_first=0)
        self.assertEqual(len(db["operation_groups"]), 1)
        op = next(iter(next(iter(db["programs"].values()))["operations"].values()))
        self.assertEqual(op["shape_source"], embedded["source"])

    def test_single_wrong_shape_dump_cannot_overwrite_profile_shapes(self):
        small = module_metadata(self.hlo(8))
        large = module_metadata(self.hlo(16))
        expression = large["operations"]["fusion"]["hlo_text"]
        db = build_database(capture([module(), operation(expression)]),
                            hlo_catalog=[small], skip_first=0)
        program = next(iter(db["programs"].values()))
        self.assertIn("hlo_match_error", program)
        op = next(iter(program["operations"].values()))
        self.assertEqual(op["input_shapes"][0]["dimensions"], [16])
        self.assertFalse(op["structure_complete"])

    def test_collective_groups_include_reduction_and_replica_groups(self):
        def hlo(reduction="add", groups="{{0,1}}"):
            return f"""HloModule collective
reduce {{
 x = f32[] parameter(0)
 y = f32[] parameter(1)
 ROOT out = f32[] {reduction}(x,y)
}}
ENTRY main {{
 p = f32[8] parameter(0)
 ROOT ar = f32[8] all-reduce(p), replica_groups={groups}, to_apply=reduce
}}"""
        a, b, c = [module_metadata(text)["operations"]["ar"]["structure_key"]
                   for text in (hlo(), hlo("maximum"), hlo(groups="{{0,1,2,3}}"))]
        self.assertNotEqual(a, b)
        self.assertNotEqual(a, c)


if __name__ == "__main__":
    unittest.main()
