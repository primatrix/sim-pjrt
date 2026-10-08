"""Device measurement attribution and exact replay matching."""

from argparse import Namespace
import base64
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
from subprocess import CompletedProcess

from sim_pjrt.cli import environment
from sim_pjrt.profiling.importer import build_database, load_profile
from sim_pjrt.profiling.identity import hlo_module_id, identity_options, identity_text
from sim_pjrt.prediction import CompilationPredictor, ReplayMiss, ReplayPredictor, execution_key
from sim_pjrt.profiling.source import capture_sources, replay_sources
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

    def test_multidevice_replay_aligns_invocations_instead_of_pooling_devices(self):
        samples = [event(ts=10, duration=10), event(pid=2, ts=12, duration=20),
                   event(ts=100, duration=5)]
        for index, sample in enumerate(samples):
            sample['args'].update(run_id=str(index + 100), queue_id='0')
        captured = trace(samples)
        captured['traceEvents'] += [
            {'ph': 'M', 'name': 'process_name', 'pid': 2, 'args': {'name': '/device:TPU:1'}},
            {'ph': 'M', 'name': 'thread_name', 'pid': 2, 'tid': 2, 'args': {'name': 'XLA Modules'}}]
        self.records['a' * 64]['num_partitions'] = 2
        db = build_database(captured, self.records, skip_first=0)
        measured = db['executables']['a' * 64]
        self.assertEqual(measured['samples_ns'], [22000])
        self.assertEqual(measured['incomplete_invocations'], 1)
        self.assertEqual(len(measured['observations']), 3)
        samples[0]['args'].pop('run_id')
        db = build_database(captured, self.records, skip_first=0)
        self.assertEqual(db['executables']['a' * 64]['samples_ns'], [22000])
        samples[2].update(ts=15, dur=5)
        db = build_database(captured, self.records, skip_first=0)
        self.assertNotIn('a' * 64, db['executables'])  # Overlapping invocations are ambiguous.
        samples[0]['args'].pop('queue_id')
        db = build_database(captured, self.records, skip_first=0)
        self.assertIn('requires queue_id', db['excluded']['a' * 64])

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

    def test_replay_retains_one_whole_invocation_and_device_offsets(self):
        captured = trace([])
        for pid in (1, 2):
            captured['traceEvents'].append({'ph': 'M', 'name': 'process_name', 'pid': pid,
                                            'args': {'name': f'/device:TPU:{pid - 1}'}})
            for tid, name in ((2, 'XLA Modules'), (3, 'XLA Ops'),
                              (4, 'Async XLA Ops'), (7, 'XLA TraceMe')):
                captured['traceEvents'].append({'ph': 'M', 'name': 'thread_name',
                                                'pid': pid, 'tid': tid, 'args': {'name': name}})
            for start, duration in ((0, 10), (100, 20), (200, 40)):
                module = event(pid=pid, ts=start + pid, duration=duration)
                module['args']['queue_id'] = 0
                captured['traceEvents'].append(module)
                for tid in (3, 4, 7):
                    captured['traceEvents'].append(dict(module, tid=tid, name=f'op-{start}-{pid}',
                        ts=start + pid + 1, dur=duration - 2,
                        args={'program_id': 7, 'tf_op': 'layer/dot:MatMul',
                              'source': 'model.py:42', 'source_stack': 'model.py:42:7'}))
        self.records['a' * 64]['num_partitions'] = 2
        db = build_database(captured, self.records, skip_first=0)
        record = db['executables']['a' * 64]
        self.assertEqual(record['samples_ns'], [11000, 21000, 41000])
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / 'timings.json'
            path.write_text(json.dumps(db))
            prediction = ReplayPredictor(path).predict('a' * 64)
        self.assertEqual(prediction['duration_ns'], 21000)
        timeline = prediction['activity_timeline']
        self.assertEqual(len(timeline), 8)
        modules = [e for e in timeline if e['track'] == 'XLA Modules']
        self.assertEqual([(e['device_index'], e['start_ns'], e['end_ns']) for e in modules],
                         [(0, 0, 20000), (1, 1000, 21000)])
        for activity in timeline[2:]:
            self.assertEqual(activity['name'], f"op-100-{activity['device_index'] + 1}")
            self.assertEqual(activity['tf_op'], 'layer/dot:MatMul')
            self.assertEqual(activity['source'], 'model.py:42')
            self.assertEqual(activity['source_stack'], 'model.py:42:7')
            self.assertEqual(activity['end_ns'] - activity['start_ns'], 18000)

    def test_raw_xplane_import_keeps_metadata_and_common_clock(self):
        try:
            from sim_pjrt.profiling.xplane_pb2 import XSpace
        except ImportError:
            self.skipTest('protobuf is required for raw XPlane import')
        space = XSpace()
        plane = space.planes.add(id=0, name='/device:TPU:0')
        plane.event_metadata[1].name = 'jit_matmul(7)'
        op = plane.event_metadata[2]
        op.name = '%dot = f32[2] add(f32[2] %x, f32[2] %y)'
        op.display_name = 'dot'
        for index, (name, value) in enumerate((('tf_op', 'layer/add:Add'),
                                              ('source', 'model.py:42')), 1):
            plane.stat_metadata[index].name = name
            plane.stat_metadata[index + 10].name = value
            op.stats.add(metadata_id=index, ref_value=index + 10)
        modules = plane.lines.add(id=2, name='XLA Modules', timestamp_ns=1000000)
        modules.events.add(metadata_id=1, offset_ps=0, duration_ps=10000000)
        ops = plane.lines.add(id=3, name='XLA Ops', timestamp_ns=1001000)
        ops.events.add(metadata_id=2, offset_ps=0, duration_ps=2000000)
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / 'test.xplane.pb'
            path.write_bytes(space.SerializeToString())
            captured, _ = load_profile(path)
        db = build_database(captured, self.records, skip_first=0)
        timeline = db['executables']['a' * 64]['replay_timeline']['activity_timeline']
        self.assertEqual(timeline[1]['start_ns'], 1000)
        self.assertEqual(timeline[1]['end_ns'], 3000)
        self.assertEqual(timeline[1]['hlo_text'], op.name)
        self.assertEqual(timeline[1]['tf_op'], 'layer/add:Add')
        self.assertEqual(timeline[1]['source'], 'model.py:42')

    def test_source_changes_do_not_invalidate_timings_or_reuse_stale_links(self):
        with tempfile.TemporaryDirectory() as tmp:
            source = Path(tmp) / '模型 "forward".py'
            source.write_text('def forward(x): return x + 1\n')
            location = str(source).replace('"', r'\22')
            with patch('sim_pjrt.profiling.source.subprocess.run', side_effect=[
                    CompletedProcess([], 0), CompletedProcess([], 0, stdout='abc123\n')]):
                files = capture_sources(f'#loc = loc("{location}":1:5)')
            self.assertEqual(files[str(source)]['git_commit'], 'abc123')
            timeline = [{'name': 'add', 'source': f'{source}:1', 'start_ns': 10, 'end_ns': 20}]
            db = {'schema_version': 1, 'measurement': 'tpu_xprof_module_duration',
                  'executables': {'a' * 64: {'samples_ns': [20], 'source_files': files,
                      'replay_timeline': {'duration_ns': 20, 'activity_timeline': timeline}}}}
            path = Path(tmp) / 'timings.json'
            path.write_text(json.dumps(db))
            replay = ReplayPredictor(path)
            for status in ('verified', 'changed', 'missing'):
                if status == 'changed':
                    source.write_text('# moved down a line\ndef forward(x): return x + 1\n')
                elif status == 'missing':
                    source.unlink()
                prediction = replay.predict('a' * 64)
                self.assertEqual(prediction['duration_ns'], 20)
                event = prediction['activity_timeline'][0]
                self.assertEqual(event['source_status'], status)
                self.assertEqual(event['source'], f'{source}:1')
                self.assertIn('git_commit=abc123', event['source_revision'])
                self.assertEqual((event['start_ns'], event['end_ns']), (10, 20))
            self.assertNotIn('source_status', timeline[0])
            self.assertNotIn('source_status', replay.database['executables']['a' * 64]
                             ['replay_timeline']['activity_timeline'][0])
            self.assertEqual(replay_sources(timeline, {})[0]['source_status'], 'unverified')

    def test_source_stack_requires_all_frames_to_match(self):
        with tempfile.TemporaryDirectory() as tmp:
            top, parent = Path(tmp) / 'model.py', Path(tmp) / 'caller.py'
            top.write_text('model'); parent.write_text('caller')
            files = capture_sources(f'loc("{top}":1:2) loc("{parent}":3:4)')
            timeline = [{'source': f'{top}:1', 'source_stack': f'{top}:1:2\n{parent}:3:4\n'}]
            self.assertEqual(replay_sources(timeline, files)[0]['source_status'], 'verified')
            parent.write_text('new caller')
            annotated = replay_sources(timeline, files)[0]
            self.assertEqual(annotated['source_status'], 'verified')
            self.assertEqual(annotated['source_stack_status'], 'changed')

    def test_identity_includes_program_options_and_target(self):
        base = execution_key("tensor<2xf32>", b"options", {"topology": "a"})
        self.assertNotEqual(base, execution_key("tensor<4xf32>", b"options", {"topology": "a"}))
        self.assertNotEqual(base, execution_key("tensor<2xf32>", b"new", {"topology": "a"}))
        self.assertNotEqual(base, execution_key("tensor<2xf32>", b"options", {"topology": "b"}))

    def test_tpu_identity_ignores_gpu_cache_paths_but_keeps_compile_settings(self):
        try:
            from jaxlib import xla_client
        except ImportError:
            self.skipTest('jaxlib is required for compile-option serialization')
        options = xla_client.CompileOptions()
        original = identity_options(options)
        debug = options.executable_build_options.debug_options
        debug.xla_gpu_cuda_data_dir = '/cuda'
        debug.xla_gpu_kernel_cache_file = '/cache/kernels'
        debug.xla_gpu_per_fusion_autotune_cache_dir = '/cache/autotune'
        self.assertEqual(identity_options(options), original)
        self.assertEqual(debug.xla_gpu_kernel_cache_file, '/cache/kernels')
        options.num_partitions = 8
        self.assertNotEqual(identity_options(options), original)

    def test_embedded_kernel_identity_ignores_locations_but_keeps_code_and_options(self):
        try:
            from jax._src.interpreters import mlir
            from jaxlib.mlir import ir
        except ImportError:
            self.skipTest('JAX is required for embedded MLIR serialization')
        def module(location, value=1, option=1):
            with mlir.make_ir_context() as context:
                context.allow_unregistered_dialects = True
                body = ir.Module.parse('module { "test.op"() {value = '
                    + str(value) + ': i32} : () -> () loc("' + location + '") }')
                stream = io.BytesIO()
                body.operation.write_bytecode(stream)
                config = json.dumps({'custom_call_config': {
                    'body': base64.b64encode(stream.getvalue()).decode()}, 'option': option})
                return 'backend_config = ' + str(ir.StringAttr.get(config))
        original = identity_text(module('first'))
        self.assertEqual(original, identity_text(module('second')))
        self.assertNotEqual(original, identity_text(module('first', value=2)))
        self.assertNotEqual(original, identity_text(module('first', option=2)))

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
