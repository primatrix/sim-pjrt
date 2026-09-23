"""Capture pre-substitution plans through the real PJRT compile boundary."""

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

from execution_plan import export_snapshot
from replay_test import scenario
from virtual_clock_test import network
from workload import Workload


class ProgramSnapshotTest(unittest.TestCase):
    maxDiff = None

    def test_capture_and_replan_before_and_after_partitioning(self):
        plugin = (
            Path(__file__).resolve().parents[3]
            / "bazel-bin/xla/pjrt/sim/pjrt_sim_plugin.so"
        )
        for devices, storage_limit in ((1, 0), (2, 16)):
            with (
                self.subTest(devices=devices),
                tempfile.TemporaryDirectory() as directory,
            ):
                env = dict(os.environ)
                env.update(
                    {
                        "JAX_PLATFORMS": "tpu",
                        "JAX_ENABLE_COMPILATION_CACHE": "false",
                        "PJRT_NAMES_AND_LIBRARY_PATHS": f"tpu:{plugin}",
                        "PJRT_SIM_DEVICE_COUNT": str(devices),
                        "PJRT_SIM_MAX_MATERIALIZED_BYTES": str(storage_limit),
                        "PJRT_SIM_TRACE": str(Path(directory) / "execution"),
                    }
                )
                result = subprocess.run(
                    [
                        sys.executable,
                        "-c",
                        """
import os
import jax
import numpy as np
from jax.sharding import Mesh, NamedSharding, PartitionSpec as P
mesh = Mesh(np.array(jax.devices()), ("tp",))
a = NamedSharding(mesh, P(None, "tp"))
b = NamedSharding(mesh, P("tp", None))
out = NamedSharding(mesh, P())
x = jax.device_put(np.ones((2, 4), np.float32), a)
y = jax.device_put(np.ones((4, 6), np.float32), b)
z = jax.jit(lambda x, y: x @ y, out_shardings=out)(x, y)
z.block_until_ready()
if os.environ["PJRT_SIM_MAX_MATERIALIZED_BYTES"] == "0":
    np.testing.assert_array_equal(np.asarray(z), np.zeros((2, 6), np.float32))
""",
                    ],
                    env=env,
                    capture_output=True,
                    text=True,
                    timeout=90,
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                snapshots = [
                    json.loads(p.read_text())
                    for p in Path(directory).glob("*.program*.json")
                ]
                dots = [
                    s
                    for s in snapshots
                    if any(n["opcode"] == "dot" for n in s["plan"]["nodes"])
                ]
                self.assertTrue(dots)
                for snapshot in dots:
                    self.assertEqual(snapshot["schema_version"], 2)
                    self.assertEqual(
                        snapshot["shape_scope"],
                        "per_partition" if storage_limit else "pre_partition",
                    )
                    self.assertTrue(
                        any(
                            i["opcode"] == "dot"
                            for c in snapshot["hlo"]["computations"]
                            for i in c["instructions"]
                        )
                    )
                    rebuilt = export_snapshot(snapshot, devices)
                    self.assertEqual(snapshot["plan"], rebuilt["plan"])
                    model = Workload(snapshot, range(devices), scenario(), network())
                    self.assertTrue(model.lower())
                    self.assertEqual(model.gaps, [])


if __name__ == "__main__":
    unittest.main()
