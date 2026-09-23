"""Exercise actual SPMD execution and asynchronous dependencies on simulated TPUs."""

import unittest

import jax
import jax.numpy as jnp
import numpy as np
from jax.sharding import Mesh, NamedSharding
from jax.sharding import PartitionSpec as P


class MultiDeviceTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.devices = jax.devices()
        if len(cls.devices) < 2:
            raise RuntimeError("Set PJRT_SIM_DEVICE_COUNT to at least 2")
        cls.mesh = Mesh(np.array(cls.devices), ("tensor",))
        cls.sharding = NamedSharding(cls.mesh, P("tensor"))

    def test_topology(self):
        from jax.experimental import mesh_utils

        devices = mesh_utils.create_device_mesh(
            (1, len(self.devices)), allow_split_physical_axes=True
        )
        self.assertEqual(set(devices.flat), set(self.devices))
        identities = {(tuple(d.coords), d.core_on_chip) for d in self.devices}
        self.assertEqual(len(identities), len(self.devices))

    def test_memory_is_per_device(self):
        initial = [d.memory_stats()["bytes_in_use"] for d in self.devices]
        values = [
            jax.device_put(np.arange(16 * (i + 1), dtype=np.int32), d)
            for i, d in enumerate(self.devices)
        ]
        for i, value in enumerate(values):
            value.block_until_ready()
            self.assertEqual(
                self.devices[i].memory_stats()["bytes_in_use"],
                initial[i] + 64 * (i + 1),
            )
        for value in values:
            value.delete()
        self.assertEqual(
            [d.memory_stats()["bytes_in_use"] for d in self.devices], initial
        )

    def test_collectives_and_multiple_outputs(self):
        n = len(self.devices)
        host = np.arange(n * 4, dtype=np.int32)
        value = jax.device_put(host, self.sharding)

        @jax.jit
        @jax.shard_map(
            mesh=self.mesh,
            in_specs=P("tensor"),
            out_specs=(P(), P(), P("tensor")),
            check_vma=False,
        )
        def communicate(x):
            return (
                jax.lax.psum(jnp.sum(x), "tensor"),
                jax.lax.all_gather(x, "tensor", tiled=True),
                jax.lax.ppermute(x, "tensor", [(i, (i + 1) % n) for i in range(n)]),
            )

        total, gathered, rotated = jax.device_get(communicate(value))
        self.assertEqual(total, host.sum())
        np.testing.assert_array_equal(gathered, host)
        np.testing.assert_array_equal(rotated, np.roll(host, 4))

    def test_async_donation_and_resharding(self):
        host = np.arange(len(self.devices) * 8, dtype=np.int32)
        value = jax.device_put(host, self.sharding)
        step = jax.jit(lambda x: x + 1, donate_argnums=(0,))
        # Enqueue dependent steps without a host wait between launches.
        for _ in range(12):
            previous = value
            value = step(value)
            self.assertTrue(previous.is_deleted())
        replicated = jax.device_put(value, NamedSharding(self.mesh, P()))
        replicated.copy_to_host_async()
        np.testing.assert_array_equal(jax.device_get(replicated), host + 12)
        self.assertEqual(len(replicated.addressable_shards), len(self.devices))


if __name__ == "__main__":
    unittest.main()
