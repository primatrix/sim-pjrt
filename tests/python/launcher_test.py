"""Exercise the launcher through a real child process without loading JAX."""

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

from sim_pjrt.cli import environment
from argparse import Namespace


class LauncherTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.file = Path(self.directory.name) / "asset with spaces"
        self.file.touch()
        self.options = ["--plugin", str(self.file), "--libtpu", str(self.file),
                        "--topology", "v5e:2x2", "--devices", "4",
                        "--timing-profile", str(self.file)]

    def launch(self, command, action="run", separator=True):
        return subprocess.run(
            [sys.executable, "-m", "sim_pjrt", action, *self.options,
             *(["--"] if separator else []), *command],
            text=True, capture_output=True,
        )

    def test_child_environment_and_literal_arguments(self):
        argument = "spaces ; $(echo must-not-execute)"
        code = ("import os, sys, json; print(json.dumps([sys.executable, sys.argv[1:], "
                "{k:os.environ[k] for k in ('JAX_PLATFORMS', 'PJRT_SIM_DEVICE_COUNT', "
                "'PJRT_SIM_BUNDLE_PYTHON', 'PJRT_NAMES_AND_LIBRARY_PATHS')}]))")
        script = self.file.parent / "workload.py"
        script.write_text(code)
        for command, separator in (([str(script)], False), (["python", "-c", code], True)):
            result = self.launch(command + [argument, "--devices", "2"], separator=separator)
            self.assertEqual(result.returncode, 0, result.stderr)
            executable, received, env = json.loads(result.stdout)
            self.assertEqual(executable, sys.executable)
            self.assertEqual(received, [argument, "--devices", "2"])
            self.assertEqual(env["JAX_PLATFORMS"], "tpu")
            self.assertEqual(env["PJRT_SIM_DEVICE_COUNT"], "4")
            self.assertEqual(env["PJRT_SIM_BUNDLE_PYTHON"], sys.executable)
            self.assertEqual(env["PJRT_NAMES_AND_LIBRARY_PATHS"], f"tpu:{self.file}")

    def test_precedence_and_no_parent_mutation(self):
        inherited = {"PJRT_SIM_DEVICE_COUNT": "2", "JAX_PLATFORMS": "cpu"}
        args = Namespace(action="run", plugin=str(self.file), libtpu=str(self.file), topology="v5e:2x2",
                         devices=4, timing_profile=str(self.file))
        env = environment(args, inherited)
        self.assertEqual(env["PJRT_SIM_DEVICE_COUNT"], "4")
        self.assertEqual(inherited, {"PJRT_SIM_DEVICE_COUNT": "2", "JAX_PLATFORMS": "cpu"})
        args.devices = None
        self.assertEqual(environment(args, inherited)["PJRT_SIM_DEVICE_COUNT"], "2")
        args.topology = None
        defaults = environment(args, {})
        self.assertEqual(defaults["PJRT_SIM_TPU_TOPOLOGY"], "tpu7x:2x2x1")
        self.assertEqual(defaults["PJRT_SIM_DEVICE_COUNT"], "8")
        args.devices = 0
        with self.assertRaisesRegex(ValueError, "positive integer"):
            environment(args, inherited)
        args.devices = 1
        args.timing_profile = None
        self.assertEqual(Path(environment(args, inherited)["PJRT_SIM_BUNDLE_PROFILE"]).name,
                         "tpu7x.json")

    def test_report_does_not_initialize_an_unused_parent_backend(self):
        try:
            import jax
        except ImportError:
            self.skipTest('jax is required for the report runner')
        report = self.file.parent / 'report'
        self.options += ['--report', str(report)]
        script = self.file.parent / 'workload.py'
        script.write_text('pass\n')
        result = self.launch([str(script)])
        # The empty plugin is deliberately unloadable: any backend
        # initialization would fail even though the workload needs none.
        self.assertEqual(result.returncode, 0, result.stderr)
        summary = json.loads((report / 'summary.json').read_text())
        self.assertEqual(summary['status'], 'complete')
        self.assertIsNone(summary['device_memory'])

    def test_torch_tpu_library_is_separate_from_offline_compiler(self):
        compiler = self.file.parent / "libtpu.so"
        compiler.touch()
        args = Namespace(action="run", framework="torch_tpu", plugin=str(self.file),
                         libtpu=str(compiler), topology=None, devices=1, timing_profile=str(self.file))
        inherited = {"TPU_LIBRARY_PATH": "/old/libtpu.so"}
        env = environment(args, inherited)
        self.assertEqual(env["TPU_LIBRARY_PATH"], str(self.file))
        self.assertEqual(env["PJRT_SIM_LIBTPU_PATH"], str(compiler))
        self.assertEqual(inherited["TPU_LIBRARY_PATH"], "/old/libtpu.so")
        collected = environment(Namespace(action="collect"), env)
        self.assertNotIn("TPU_LIBRARY_PATH", collected)
        self.assertEqual(environment(Namespace(action="collect"), inherited)["TPU_LIBRARY_PATH"],
                         "/old/libtpu.so")

    def test_torch_tpu_replay_rejected_before_creating_report(self):
        report = self.file.parent / "report"
        self.options += ["--framework", "torch_tpu", "--predictor", "replay",
                         "--report", str(report)]
        result = self.launch(["workload.py"])
        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertIn("collection/replay is JAX-only", result.stderr)
        self.assertFalse(report.exists())

    def test_torch_tpu_report_waits_without_jax_observer(self):
        from sim_pjrt.run import run

        report = self.file.parent / "report"
        report.mkdir()
        events = []
        with mock.patch("sim_pjrt.torch_tpu.initialize", side_effect=lambda: events.append("init")), \
             mock.patch("sim_pjrt.run.run_python", side_effect=lambda command: events.append(command)), \
             mock.patch("sim_pjrt.torch_tpu.synchronize", side_effect=lambda: events.append("sync")), \
             mock.patch("sim_pjrt.run.compilation_observer", side_effect=AssertionError("JAX used")):
            run(["workload.py"], framework="torch_tpu", report=report)
        self.assertEqual(events, ["init", ["workload.py"], "sync"])
        summary = json.loads((report / "summary.json").read_text())
        self.assertEqual(summary["status"], "complete")
        self.assertIsNone(summary["device_memory"])

    def test_torch_tpu_async_failure_marks_report_failed(self):
        from sim_pjrt.run import run

        report = self.file.parent / "report"
        report.mkdir()
        with mock.patch("sim_pjrt.torch_tpu.initialize"), \
             mock.patch("sim_pjrt.run.run_python"), \
             mock.patch("sim_pjrt.torch_tpu.synchronize", side_effect=RuntimeError("execution failed")):
            with self.assertRaisesRegex(RuntimeError, "execution failed"):
                run(["workload.py"], framework="torch_tpu", report=report)
        self.assertEqual(json.loads((report / "summary.json").read_text())["status"], "failed")

    def test_compile_script_forwards_arguments_without_timing(self):
        output = str(self.file.parent / "dumps")
        self.options = self.options[:-2] + ["--output", output]
        script = self.file.parent / "workload.py"
        script.write_text("import os,sys,json; print(json.dumps([sys.argv[1:], "
                          "os.environ['PJRT_SIM_DUMP_DIR'], "
                          "os.environ.get('PJRT_SIM_BUNDLE_PROFILE')]))")
        # Options after the script belong to the workload, even on name clashes.
        for separator in (False, True):
            result = self.launch([str(script), "--output", "script-output", "--devices", "2"],
                                 action="compile", separator=separator)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(json.loads(result.stdout),
                             [["--output", "script-output", "--devices", "2"], output, None])

    def test_offline_import_does_not_require_plugin_libtpu_or_workload(self):
        trace = self.file.parent / "trace.json"
        trace.write_text(json.dumps({"traceEvents": [
            {"ph": "M", "name": "process_name", "pid": 1, "args": {"name": "/device:TPU:0"}},
            {"ph": "M", "name": "thread_name", "pid": 1, "tid": 2, "args": {"name": "XLA Modules"}},
            {"ph": "X", "pid": 1, "tid": 2, "name": "ordinary_program(123)", "ts": 0, "dur": 10}
        ]}))
        output = self.file.parent / "timings.json"
        result = subprocess.run([sys.executable, "-m", "sim_pjrt", "import-profile", str(trace),
                                 "--skip-first", "0", "--output", str(output)],
                                env=dict(os.environ, SIM_PJRT_PLUGIN_PATH="/missing/plugin.so",
                                         PJRT_SIM_LIBTPU_PATH="/missing/libtpu.so"),
                                text=True, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(json.loads(output.read_text())["programs"]), 1)


if __name__ == "__main__":
    unittest.main()
