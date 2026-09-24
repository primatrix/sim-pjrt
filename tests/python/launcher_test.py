"""Exercise the launcher through a real child process without loading JAX."""

import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import tempfile
import unittest

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

    def test_exit_status_and_signal(self):
        self.assertEqual(self.launch(["python", "-c", "raise SystemExit(17)"]).returncode, 17)
        self.assertEqual(self.launch(["python", "-c",
            "import os, signal; os.kill(os.getpid(), signal.SIGTERM)"]).returncode, -signal.SIGTERM)

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

    def test_missing_command_is_actionable(self):
        result = self.launch([])
        self.assertEqual(result.returncode, 2)
        self.assertIn("Provide a command", result.stderr)
        result = self.launch(["sim-pjrt-command-that-does-not-exist"])
        self.assertEqual(result.returncode, 2)
        self.assertNotIn("Traceback", result.stderr)


if __name__ == "__main__":
    unittest.main()
