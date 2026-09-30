"""Device measurement attribution and exact replay matching."""

from argparse import Namespace
import json
from pathlib import Path
import tempfile
import unittest

from sim_pjrt.cli import environment
from sim_pjrt.profiling.importer import build_database
from sim_pjrt.profiling.identity import hlo_module_id
from sim_pjrt.prediction import CompilationPredictor, ReplayMiss, ReplayPredictor, execution_key
from sim_pjrt.report import summarize


def trace(events):
    return {"traceEvents": [
        {"ph": "M", "name": "process_name", "pid": 1, "args": {"name": "/device:TPU:0"}},
        {"ph": "M", "name": "thread_name", "pid": 1, "tid": 2,
         "args": {"name": "XLA Modules"}},
        {"ph": "M", "name": "process_name", "pid": 9, "args": {"name": "Host Threads"}},
        {"ph": "M", "name": "thread_name", "pid": 9, "tid": 2,
         "args": {"name": "XLA Modules"}},
        *events]}


def event(program=7, duration=10, ts=0, pid=1):
    return {"ph": "X", "name": "jit_matmul", "pid": pid, "tid": 2,
            "ts": ts, "dur": duration, "args": {"program_id": program}}


class CollectionTest(unittest.TestCase):
    def setUp(self):
        self.records = {
            "a" * 64: {"name": "jit_matmul", "modules": [{"name": "jit_matmul", "program_id": 7}]},
            "b" * 64: {"name": "jit_matmul", "modules": [{"name": "jit_matmul", "program_id": 8}]},
        }

    def test_device_intervals_ids_warmup_and_units(self):
        db = build_database(trace([event(duration=100, ts=0), event(duration=10, ts=200),
                                   event(duration=12, ts=300), event(8, 30), event(8, 40, 100),
                                   event(duration=99999, pid=9)]), self.records)
        a, b = db["executables"]["a" * 64], db["executables"]["b" * 64]
        self.assertEqual(a["samples_ns"], [10000, 12000])
        self.assertEqual(a["median_ns"], 11000)
        self.assertEqual(b["samples_ns"], [40000])
        self.assertEqual(a["skipped_samples"], 1)

    def test_ambiguous_names_and_unknown_ids_are_not_guessed(self):
        unnamed = event()
        unnamed["args"] = {}
        db = build_database(trace([unnamed, event(999)]), self.records, skip_first=0)
        self.assertFalse(db["executables"])
        self.assertEqual(len(db["unmatched_events"]), 2)

    def test_tpu_runtime_fingerprint_label_matches_compile_tag(self):
        name = "jit_matmul__spjrt_" + "a" * 64
        self.records["a" * 64]["modules"][0]["name"] = name
        sample = event()
        sample["name"] = name + "(2496501389981351648)"
        sample["args"] = {"program_id": "2496501389981351648"}
        db = build_database(trace([sample]), self.records, skip_first=0)
        self.assertEqual(db["executables"]["a" * 64]["samples_ns"], [10000])

    def test_multidevice_samples_are_not_pooled(self):
        t = trace([event(), event(pid=2)])
        t["traceEvents"] += [
            {"ph": "M", "name": "process_name", "pid": 2, "args": {"name": "/device:TPU:1"}},
            {"ph": "M", "name": "thread_name", "pid": 2, "tid": 2,
             "args": {"name": "XLA Modules"}}]
        db = build_database(t, self.records, skip_first=0)
        self.assertIn("Multi-device", db["excluded"]["a" * 64])

    def test_conflicting_compile_tag_does_not_fall_back_to_local_program_id(self):
        sample = event(program=7)
        sample["name"] = "jit_matmul__spjrt_" + "c" * 64
        db = build_database(trace([sample]), self.records, skip_first=0)
        self.assertFalse(db["executables"])
        self.assertEqual(len(db["unmatched_events"]), 1)

    def test_replay_median_and_strict_miss(self):
        db = build_database(trace([event(duration=10), event(duration=20)]), self.records,
                            skip_first=0)
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "timings.json"
            path.write_text(json.dumps(db))
            replay = ReplayPredictor(path)
            prediction = replay.predict("a" * 64)
            self.assertEqual(prediction["duration_ns"], 15000)
            self.assertEqual(prediction["activity_timeline"], [])
            self.assertEqual(prediction["analysis_source"], "tpu_replay")
            with self.assertRaisesRegex(ValueError, "Replay miss"):
                replay.predict("c" * 64)
            for invalid in (0, -1, float("nan"), True, "10"):
                replay.database["executables"]["a" * 64]["samples_ns"] = [invalid]
                with self.assertRaisesRegex(ValueError, "valid device-duration"):
                    replay.predict("a" * 64)

    def test_identity_includes_program_options_and_target(self):
        base = execution_key("tensor<2xf32>", b"options", {"topology": "a"})
        self.assertNotEqual(base, execution_key("tensor<4xf32>", b"options", {"topology": "a"}))
        self.assertNotEqual(base, execution_key("tensor<2xf32>", b"new", {"topology": "a"}))
        self.assertNotEqual(base, execution_key("tensor<2xf32>", b"options", {"topology": "b"}))

    def test_replay_requires_one_valid_compiler_environment(self):
        db = build_database(trace([event(duration=10), event(8, 20)]), self.records,
                            skip_first=0)
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "timings.json"
            path.write_text(json.dumps(db))
            replay = ReplayPredictor(path)
            self.assertEqual(replay.compiler_environment(), {})
            for record in replay.database["executables"].values():
                record["context"] = {"compiler_flags": {"LIBTPU_INIT_ARGS": "--target-flag=true"}}
            self.assertEqual(replay.compiler_environment(), {"LIBTPU_INIT_ARGS": "--target-flag=true"})
            replay.database["executables"]["b" * 64]["context"] = {}
            with self.assertRaisesRegex(ValueError, "mixes compiler flag"):
                replay.compiler_environment()

    def test_hlo_id_skips_nested_fields(self):
        # name (field 1), opaque computation (field 3), module id (field 5).
        self.assertEqual(hlo_module_id(b"\x0a\x01x\x1a\x02\x28\x09\x28\x96\x01"), 150)
        self.assertEqual(hlo_module_id(b"\x0a\x01x"), 0)
        with self.assertRaisesRegex(ValueError, "Truncated"):
            hlo_module_id(b"\x1a\x08short")

    def test_collect_uses_real_backend_without_plugin_or_profile(self):
        inherited = {"PJRT_NAMES_AND_LIBRARY_PATHS": "tpu:fake.so", "PJRT_SIM_PREDICTOR": "replay",
                     "PJRT_SIM_DUMP_DIR": "/tmp/dump", "TPU_WORKER_HOSTNAMES": "worker"}
        env = environment(Namespace(action="collect"), inherited)
        self.assertNotIn("PJRT_NAMES_AND_LIBRARY_PATHS", env)
        self.assertFalse(any(k.startswith("PJRT_SIM_") for k in env))
        self.assertEqual(env["TPU_WORKER_HOSTNAMES"], "worker")
        self.assertEqual(env["JAX_PLATFORMS"], "tpu")
        self.assertIn("PJRT_SIM_PREDICTOR", inherited)

    def test_lookup_counts_and_execution_counts_are_distinct(self):
        key = "a" * 64
        with tempfile.TemporaryDirectory() as tmp:
            directory = Path(tmp)
            database = directory / "db.json"
            database.write_text(json.dumps({"schema_version": 1,
                "measurement": "tpu_xprof_module_duration",
                "executables": {key: {"samples_ns": [10, 20]}}}))
            policy = CompilationPredictor("replay", database, "llo")
            self.assertEqual(policy.predict(key)["duration_ns"], 15)
            self.assertTrue(policy.predict("b" * 64)["replay_miss"])
            rows = [{"program_id": 1, "execution_key": key, "name": "same_name",
                     "num_devices": 1, "analysis_source": "tpu_replay", "bundle_cost_gaps": 0,
                     "duration_ns": 15} for _ in range(5)]
            rows.append({"program_id": 2, "execution_key": "b" * 64, "name": "same_name",
                         "num_devices": 1, "analysis_source": "libtpu_bundles", "bundle_cost_gaps": 2,
                         "bundle_duration_ns": 30, "replay_miss": True})
            (directory / "execution.1.jsonl").write_text("\n".join(map(json.dumps, rows)))
            summary = summarize(directory, policy.queries)
            self.assertEqual(summary["compile_queries"], 2)
            self.assertEqual(summary["replay_hit_rate"], .5)
            self.assertEqual(summary["execution_sources"], {"tpu_replay": 5, "libtpu_bundles": 1})
            self.assertEqual(summary["fallback_executions"], 1)
            self.assertEqual(summary["executions_with_cost_gaps"], 1)
            strict = CompilationPredictor("replay", database)
            with self.assertRaises(ReplayMiss):
                strict.predict("c" * 64)
            self.assertIsNone(strict.queries[0]["source"])
            policy.replay.database["executables"][key]["samples_ns"] = [0]
            with self.assertRaises(ValueError):
                policy.predict(key)  # Malformed data must never trigger a fallback.
            self.assertEqual(policy.queries[-1]["replay_lookup"], "invalid")


if __name__ == "__main__":
    unittest.main()
