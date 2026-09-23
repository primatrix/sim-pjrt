"""Changing model costs must change live JAX completion, without a profiler."""

import json
import os
import statistics
import subprocess
import sys
import time
import unittest


def measure():
    import jax
    import jax.numpy as jnp
    import numpy as np
    from jax.sharding import Mesh, NamedSharding
    from jax.sharding import PartitionSpec as P
    from jax.experimental import pallas as pl

    x = jax.device_put(np.ones((256, 256), dtype=np.float32))
    dot = jax.jit(lambda a: a @ a)
    dot(x).block_until_ready()
    mesh = Mesh(np.array(jax.devices()), ("d",))

    @jax.jit
    @jax.shard_map(mesh=mesh, in_specs=P("d"), out_specs=P(), check_vma=False)
    def communicate(value):
        return jax.lax.psum(value, "d")

    value = jax.device_put(np.ones(512, dtype=np.float32), NamedSharding(mesh, P("d")))
    communicate(value).block_until_ready()

    def kernel(x_ref, y_ref):
        y_ref[...] = x_ref[...]

    pallas = jax.jit(
        pl.pallas_call(
            kernel,
            out_shape=jax.ShapeDtypeStruct((256, 256), jnp.float32),
            cost_estimate=pl.CostEstimate(
                flops=0, transcendentals=200000, bytes_accessed=0
            ),
        )
    )
    pallas(x).block_until_ready()
    result = {}
    for name, operation in (
        ("compute", lambda: dot(x)),
        ("communication", lambda: communicate(value)),
        ("pallas", lambda: pallas(x)),
    ):
        times = []
        for _ in range(3):
            start = time.monotonic()
            output = operation()
            output.block_until_ready()
            times.append(time.monotonic() - start)
        result[name] = statistics.median(times)
    # Consume control results too, after timed readiness has completed.
    assert bool(jnp.all(communicate(value) == 2))
    print(json.dumps(result))


class RuntimeSensitivityTest(unittest.TestCase):
    def test_model_costs_change_observed_completion(self):
        observations = {}
        for name, compute, communication, transcendentals in (
            ("baseline", 100000, 1, 1e12),
            ("slow_compute", 1000000, 1, 1e12),
            ("slow_communication", 100000, 10, 1e12),
            ("slow_transcendentals", 100000, 1, 1e11),
        ):
            environment = {
                **os.environ,
                "PJRT_SIM_DEVICE_COUNT": "2",
                "PJRT_SIM_COMPUTE_SCALE": str(compute),
                "PJRT_SIM_COMMUNICATION_SCALE": str(communication),
                "PJRT_SIM_TRANSCENDENTALS_PER_SECOND": str(transcendentals),
                "PJRT_SIM_LINK_NS": "10000000",
                "PJRT_SIM_LAUNCH_NS": "1000",
                "PJRT_SIM_TRANSFER_NS": "2000",
            }
            child = subprocess.run(
                [sys.executable, __file__, "--measure"],
                env=environment,
                text=True,
                capture_output=True,
                timeout=60,
            )
            self.assertEqual(child.returncode, 0, child.stderr)
            observations[name] = json.loads(child.stdout.splitlines()[-1])
        print(json.dumps({"online_cost_sensitivity_seconds": observations}))
        self.assertGreater(
            observations["slow_compute"]["compute"],
            3 * observations["baseline"]["compute"],
        )
        self.assertGreater(
            observations["slow_communication"]["communication"],
            3 * observations["baseline"]["communication"],
        )
        self.assertGreater(
            observations["slow_compute"]["pallas"],
            3 * observations["baseline"]["pallas"],
        )
        self.assertGreater(
            observations["slow_transcendentals"]["pallas"],
            3 * observations["baseline"]["pallas"],
        )
        for operation in ("compute", "communication"):
            self.assertLess(
                observations["slow_transcendentals"][operation],
                3 * observations["baseline"][operation],
            )


if __name__ == "__main__":
    if "--measure" in sys.argv:
        measure()
    else:
        unittest.main()
