"""Virtual tensor parallelism through JAX; run with 2, 4 or 8 devices."""

import os
import resource
import unittest

from runtime_profile import configure_runtime

configure_runtime(launch_ns=100000000)

import jax
import jax.numpy as jnp
import numpy as np
from jax.sharding import Mesh, NamedSharding, PartitionSpec as P


class VirtualMultiDeviceTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.devices = jax.devices()
        if len(cls.devices) < 2:
            raise RuntimeError("Set PJRT_SIM_DEVICE_COUNT to 2, 4 or 8")
        cls.mesh = Mesh(np.array(cls.devices), ("tp",))
        cls.row = NamedSharding(cls.mesh, P("tp", None))
        cls.column = NamedSharding(cls.mesh, P(None, "tp"))
        cls.replicated = NamedSharding(cls.mesh, P())

    def test_large_tp_decode_and_donation(self):
        n = len(self.devices)
        shardings = (self.column, self.row, self.column, self.row)
        before = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
        initial = [d.memory_stats()["bytes_in_use"] for d in self.devices]

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
        for d, baseline in zip(self.devices, initial):
            self.assertGreaterEqual(
                d.memory_stats()["bytes_in_use"] - baseline,
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
        vector = NamedSharding(self.mesh, P("tp"))
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
        mesh = Mesh(np.array(self.devices[::-1]), ("tp",))
        matrix = NamedSharding(mesh, P("tp", None))
        vector = NamedSharding(mesh, P("tp"))
        value = jax.jit(
            lambda: jnp.zeros((n * 65536, 128), jnp.float32), out_shardings=matrix
        )()
        host = np.arange(n * 8, dtype=np.int32)
        tokens = jax.device_put(host, vector)

        @jax.jit
        @jax.shard_map(
            mesh=mesh,
            in_specs=(P("tp", None), P("tp")),
            out_specs=(P("tp", None), P()),
            check_vma=False,
        )
        def communicate(x, tokens):
            return (
                jax.lax.ppermute(x, "tp", [(i, (i + 1) % n) for i in range(n)]),
                jax.lax.psum(jnp.sum(tokens), "tp"),
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
        sharding = NamedSharding(self.mesh, P(None, "tp", None, None))
        shape = (1, n * 64, 2048, 128)
        value = jax.jit(lambda: jnp.ones(shape, jnp.bfloat16), out_shardings=sharding)()
        attention = jax.jit(
            jax.shard_map(
                flash_attention.flash_attention,
                mesh=self.mesh,
                in_specs=(P(None, "tp", None, None),) * 3,
                out_specs=P(None, "tp", None, None),
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
