"""Exercise actual SPMD execution and asynchronous dependencies on simulated TPUs."""

import resource
import unittest

from runtime_profile import configure_runtime

configure_runtime(launch_ns=100000000)

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
        cls.row = NamedSharding(cls.mesh, P("tensor", None))
        cls.column = NamedSharding(cls.mesh, P(None, "tensor"))
        cls.replicated = NamedSharding(cls.mesh, P())

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

    def test_large_tp_decode_and_donation(self):
        n = len(self.devices)
        shardings = (self.column, self.row, self.column, self.row)
        before = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss

        def initialize():
            weights = tuple(
                jnp.zeros(shape, jnp.bfloat16)
                for shape in (
                    (4096, 16384),
                    (16384, 4096),
                    (4096, 16384),
                    (16384, 4096),
                )
            )
            return weights, jnp.zeros((4096, 4096), jnp.bfloat16)

        weights, cache = jax.jit(initialize, out_shardings=(shardings, self.column))()
        jax.block_until_ready((weights, cache))
        for w, sharding in zip(weights, shardings):
            self.assertTrue(w.sharding.is_equivalent_to(sharding, w.ndim))
            self.assertEqual(len(w.addressable_shards), n)
            self.assertTrue(
                all(s.data.nbytes == w.nbytes // n for s in w.addressable_shards)
            )
        # Earlier tests can still release asynchronous allocations. Check this
        # test's live footprint, not a delta against their transient usage.
        for d in self.devices:
            self.assertGreaterEqual(
                d.memory_stats()["bytes_in_use"],
                (512 * 1024**2 + cache.nbytes) // n,
            )

        def decode(weights, cache, length):
            x = jnp.ones((1, 4096), jnp.bfloat16)
            for up, down in zip(weights[::2], weights[1::2]):
                x = (x @ up) @ down
            cache = jax.lax.dynamic_update_slice(cache, x[:, :4096], (length, 0))
            return cache, length + 1

        step = jax.jit(
            decode,
            in_shardings=(shardings, self.column, self.replicated),
            out_shardings=(self.column, self.replicated),
            donate_argnums=(1,),
        )
        length = jax.device_put(np.int32(7), self.replicated)
        for _ in range(3):
            previous = cache
            cache, length = step(weights, cache, length)
            self.assertTrue(previous.is_deleted())
            self.assertFalse(cache.is_ready())
        self.assertEqual(int(length), 10)
        cache.block_until_ready()
        self.assertTrue(
            all(s.data.shape == (4096, 4096 // n) for s in cache.addressable_shards)
        )
        growth = (resource.getrusage(resource.RUSAGE_SELF).ru_maxrss - before) * 1024
        self.assertLess(growth, 2 * 1024**3)  # Includes the offline TPU compiler.
        print(f"TP={n}: 512 MiB weights, peak RSS growth {growth / 1024**2:.1f} MiB")
        for w in weights:
            w.delete()
        cache.delete()
        length.delete()

    def test_reshard_virtual_tensor(self):
        n = len(self.devices)
        value = jax.jit(
            lambda: jnp.zeros((8192, 8192), jnp.bfloat16), out_shardings=self.column
        )()
        rows = jax.jit(lambda x: x, in_shardings=self.column, out_shardings=self.row)(
            value
        )
        rows.block_until_ready()
        self.assertTrue(
            all(s.data.shape == (8192 // n, 8192) for s in rows.addressable_shards)
        )
        replicated = jax.jit(
            lambda x: x, in_shardings=self.row, out_shardings=self.replicated
        )(rows)
        replicated.block_until_ready()
        self.assertTrue(
            all(s.data.shape == (8192, 8192) for s in replicated.addressable_shards)
        )
        # A full D2H would legitimately allocate the logical 128 MiB on host.
        with self.assertRaisesRegex(Exception, "no materialized data"):
            replicated.addressable_shards[0].data.unsafe_buffer_pointer()
        value.delete()
        rows.delete()
        replicated.delete()

    def test_virtual_hbm_independent_of_shard_size(self):
        n = len(self.devices)
        vector = NamedSharding(self.mesh, P("tensor"))
        size = n * 3 * 1024 * 1024
        value = jax.jit(lambda: jnp.ones((size,), jnp.float32), out_shardings=vector)()
        np.testing.assert_array_equal(
            np.asarray(value.addressable_shards[0].data)[:4], 0
        )
        replicated = jax.jit(
            lambda x: x, in_shardings=vector, out_shardings=self.replicated
        )(value)
        replicated.block_until_ready()
        np.testing.assert_array_equal(
            np.asarray(replicated.addressable_shards[0].data), 0
        )
        small = jax.jit(
            lambda x: x, in_shardings=self.replicated, out_shardings=vector
        )(replicated)
        small.block_until_ready()
        self.assertEqual(small.addressable_shards[0].data.shape, (size // n,))
        # Floating placeholders can be materialized again after slicing.
        self.assertEqual(np.asarray(small.addressable_shards[0].data).size, size // n)
        value.delete()
        replicated.delete()
        small.delete()

    def test_reordered_mesh_keeps_integer_collectives(self):
        n = len(self.devices)
        mesh = Mesh(np.array(self.devices[::-1]), ("tensor",))
        matrix = NamedSharding(mesh, P("tensor", None))
        vector = NamedSharding(mesh, P("tensor"))
        value = jax.jit(
            lambda: jnp.zeros((n * 65536, 128), jnp.float32), out_shardings=matrix
        )()
        host = np.arange(n * 8, dtype=np.int32)
        tokens = jax.device_put(host, vector)

        @jax.jit
        @jax.shard_map(
            mesh=mesh,
            in_specs=(P("tensor", None), P("tensor")),
            out_specs=(P("tensor", None), P()),
            check_vma=False,
        )
        def communicate(x, tokens):
            return (
                jax.lax.ppermute(x, "tensor", [(i, (i + 1) % n) for i in range(n)]),
                jax.lax.psum(jnp.sum(tokens), "tensor"),
            )

        rotated, total = communicate(value, tokens)
        self.assertEqual(int(total), int(host.sum()))
        rotated.block_until_ready()
        self.assertEqual(
            [s.device for s in rotated.addressable_shards], self.devices[::-1]
        )
        self.assertTrue(
            all(s.data.shape == (65536, 128) for s in rotated.addressable_shards)
        )
        for x in (value, tokens, rotated, total):
            x.delete()

    def test_pallas_attention_in_shard_map(self):
        from jax.experimental.pallas.ops.tpu import flash_attention

        n = len(self.devices)
        sharding = NamedSharding(self.mesh, P(None, "tensor", None, None))
        shape = (1, n * 64, 2048, 128)
        value = jax.jit(lambda: jnp.ones(shape, jnp.bfloat16), out_shardings=sharding)()
        attention = jax.jit(
            jax.shard_map(
                flash_attention.flash_attention,
                mesh=self.mesh,
                in_specs=(P(None, "tensor", None, None),) * 3,
                out_specs=P(None, "tensor", None, None),
                check_vma=False,
            )
        )
        result = attention(value, value, value)
        result.block_until_ready()
        self.assertEqual(result.shape, shape)
        self.assertTrue(
            all(s.data.shape == (1, 64, 2048, 128) for s in result.addressable_shards)
        )
        value.delete()
        result.delete()


if __name__ == "__main__":
    unittest.main()
