"""Optional real libtpu -> expanded TPU bundles -> CPU simulation integration."""

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


class TpuCompilationTest(unittest.TestCase):
    def test_missing_libtpu_rejects_backend_initialization(self):
        root = Path(__file__).resolve().parents[2]
        env = dict(os.environ)
        env.pop("PJRT_SIM_LIBTPU_PATH", None)
        env.update(
            JAX_PLATFORMS="tpu",
            PJRT_SIM_BUNDLE_PROFILE=str(root / "configs/bundle_timing_example.json"),
            PJRT_NAMES_AND_LIBRARY_PATHS=f"tpu:{root}/bazel-bin/pjrt_sim_plugin.so",
        )
        process = subprocess.run(
            [sys.executable, "-c", "import jax; jax.devices()"],
            env=env,
            capture_output=True,
            text=True,
            timeout=30,
        )
        self.assertNotEqual(process.returncode, 0)
        self.assertIn("libtpu library path is required", process.stderr)

    @unittest.skipUnless(os.getenv("PJRT_SIM_TEST_LIBTPU_PATH"), "requires libtpu")
    def test_offline_compilation_drives_simulated_execution(self):
        root = Path(__file__).resolve().parents[2]
        with tempfile.TemporaryDirectory() as directory:
            profile = json.loads(
                (root / "configs/bundle_timing_example.json").read_text()
            )
            profile["bundle_issue_cycles"] = 100000
            profile_path = Path(directory) / "profile.json"
            profile_path.write_text(json.dumps(profile))
            env = dict(os.environ)
            env.update(
                JAX_PLATFORMS="tpu",
                JAX_ENABLE_COMPILATION_CACHE="false",
                PJRT_NAMES_AND_LIBRARY_PATHS=f"tpu:{root}/bazel-bin/pjrt_sim_plugin.so",
                PJRT_SIM_DEVICE_COUNT="1",
                PJRT_SIM_LIBTPU_PATH=env["PJRT_SIM_TEST_LIBTPU_PATH"],
                PJRT_SIM_TPU_TOPOLOGY="v5e:2x2",
                PJRT_SIM_BUNDLE_PROFILE=str(profile_path),
                PJRT_SIM_BUNDLE_PYTHON=sys.executable,
                PYTHONPATH=str(root / "python"),
                PJRT_SIM_TRACE=f"{directory}/execution",
                TPU_SKIP_MDS_QUERY="1",
                TPU_WORKER_HOSTNAMES="localhost",
                TPU_ACCELERATOR_TYPE="v5litepod-4",
            )
            process = subprocess.run(
                [
                    sys.executable,
                    "-c",
                    """
import jax
import numpy as np
import time, json, os
from pathlib import Path
assert jax.devices()[0].device_kind == "TPU v5 lite", jax.devices()
x = jax.device_put(np.ones((4096, 64), np.float32))
y = jax.device_put(np.ones((64, 2048), np.float32))
compiled = jax.jit(lambda x, y: x @ y).lower(x, y).compile()
start = time.monotonic()
z = compiled(x, y)
z.block_until_ready()
elapsed = time.monotonic() - start
records = [json.loads(line) for p in Path(os.environ["PJRT_SIM_TRACE"]).parent.glob("*.jsonl")
           for line in p.read_text().splitlines()]
assert elapsed >= records[-1]["bundle_duration_ns"] / 1e9 * 0.8, (elapsed, records[-1])
np.testing.assert_array_equal(np.asarray(z), np.zeros((4096, 2048), np.float32))
""",
                ],
                env=env,
                capture_output=True,
                text=True,
                timeout=180,
            )
            self.assertEqual(process.returncode, 0, process.stderr)
            records = [
                json.loads(line)
                for path in Path(directory).glob("*.jsonl")
                for line in path.read_text().splitlines()
            ]
            self.assertTrue(records)
            self.assertTrue(
                all(r["analysis_source"] == "libtpu_bundles" for r in records)
            )
            snapshots = [
                json.loads(path.read_text())
                for path in Path(directory).glob("*.program*.json")
            ]
            self.assertTrue(snapshots)
            self.assertTrue(all("hlo" not in s and "plan" not in s for s in snapshots))
            self.assertTrue(all(s["scheduled_bundle_count"] > 0 for s in snapshots))
            self.assertTrue(all(r["bundle_duration_ns"] > 0 for r in records))
            self.assertTrue(all(Path(s["entry_file"]).is_file() for s in snapshots))
            self.assertTrue(
                all(s["bundle_stage"] == "final_bundles" for s in snapshots)
            )
            self.assertTrue(
                all(
                    Path(f).is_file() and f.endswith("-final_bundles.txt")
                    for s in snapshots
                    for f in s["final_bundle_files"]
                )
            )
            self.assertTrue(
                all(s["analysis_source"] == "libtpu_bundles" for s in snapshots)
            )

            # Incomplete bundles must not silently select an HLO timing path.
            profile["allow_partial"] = False
            profile_path.write_text(json.dumps(profile))
            rejected = subprocess.run(
                [
                    sys.executable,
                    "-c",
                    "import jax, numpy as np; "
                    "jax.jit(lambda x: x + 1)(np.ones((8, 128), np.float32))",
                ],
                env=env,
                capture_output=True,
                text=True,
                timeout=180,
            )
            self.assertNotEqual(rejected.returncode, 0)
            self.assertIn("Bundle timing has unresolved semantics", rejected.stderr)
            self.assertIn("No HLO fallback", rejected.stderr)


if __name__ == "__main__":
    unittest.main()
