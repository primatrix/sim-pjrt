"""Large logical floating tensors with bounded host storage, through unmodified JAX.

Run with the simulator plugin selected; exercises Virtual HBM.
"""

import os
import resource
import unittest

os.environ["PJRT_SIM_DEVICE_COUNT"] = "2"
from runtime_profile import configure_runtime

configure_runtime(launch_ns=100000000, transfer_ns=100000000)

import jax
import jax.numpy as jnp
import numpy as np


class VirtualHbmTest(unittest.TestCase):
    def test_large_model_state_and_decode_control(self):
        # Four 128 MiB weights plus a 32 MiB KV-like cache. No host weight array.
        @jax.jit
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

        before = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
        weights, cache = initialize()
        jax.block_until_ready((weights, cache))
        self.assertEqual(sum(w.nbytes for w in weights), 512 * 1024**2)
        self.assertEqual(cache.shape, (4096, 4096))
        self.assertGreaterEqual(
            jax.devices()[0].memory_stats()["bytes_in_use"], 512 * 1024**2
        )

        def decode(weights, cache, length):
            x = jnp.zeros((1, 4096), jnp.bfloat16)
            for up, down in zip(weights[::2], weights[1::2]):
                x = (x @ up) @ down

            # Integer loop state and the cache update index remain executable.
            def body(state):
                i, cache = state
                cache = jax.lax.dynamic_update_slice(cache, x[:, :4096], (i, 0))
                return i + 1, cache

            return jax.lax.while_loop(
                lambda state: state[0] < length + 3, body, (length, cache)
            )

        step = jax.jit(decode, donate_argnums=(1,))
        length, updated = step(weights, cache, jnp.int32(7))
        self.assertTrue(cache.is_deleted())
        self.assertEqual(int(length), 10)
        length, final = step(weights, updated, length)
        self.assertTrue(updated.is_deleted())
        self.assertFalse(final.is_ready())
        self.assertEqual(int(length), 13)
        final.block_until_ready()
        self.assertEqual(final.shape, (4096, 4096))
        # Read a small derived result, never allocate a 128 MiB D2H destination.
        sample = jax.jit(lambda w: w[:1, :8])(weights[0])
        np.testing.assert_array_equal(np.asarray(sample), 0)
        growth = (resource.getrusage(resource.RUSAGE_SELF).ru_maxrss - before) * 1024
        self.assertLess(growth, 2 * 1024**3)  # Includes the offline TPU compiler.
        print(f"logical weights: 512 MiB; peak RSS growth: {growth / 1024**2:.1f} MiB")
        for w in weights:
            w.delete()
        final.delete()

    def test_host_import_copy_and_lazy_d2h(self):
        source = np.zeros((8 * 1024 * 1024,), np.float32)
        x = jax.device_put(source, jax.devices()[0])
        del source
        x.block_until_ready()
        y = jax.device_put(x, jax.devices()[1])
        self.assertFalse(y.is_ready())
        y.block_until_ready()
        self.assertEqual(y.shape, x.shape)
        host = np.asarray(y)
        self.assertEqual(host.shape, y.shape)
        np.testing.assert_array_equal(host, 0)
        with self.assertRaisesRegex(Exception, "no materialized data"):
            y.unsafe_buffer_pointer()
        x.delete()
        y.delete()

    def test_virtual_pallas_attention_and_alias(self):
        from jax.experimental import pallas as pl
        from jax.experimental.pallas.ops.tpu import flash_attention

        value = jax.jit(lambda: jnp.ones((1, 64, 2048, 128), jnp.bfloat16))()
        result = jax.jit(flash_attention.flash_attention)(value, value, value)
        result.block_until_ready()
        self.assertEqual(result.shape, value.shape)
        np.testing.assert_array_equal(np.asarray(result), 0)
        value.delete()
        result.delete()

        def kernel(x_ref, y_ref):
            y_ref[...] = x_ref[...] + 1

        block = pl.BlockSpec((8, 128), lambda i: (i, 0))
        call = pl.pallas_call(
            kernel,
            out_shape=jax.ShapeDtypeStruct((65536, 128), jnp.float32),
            grid=(8192,),
            in_specs=(block,),
            out_specs=block,
            input_output_aliases={0: 0},
        )
        value = jax.jit(lambda: jnp.ones((65536, 128), jnp.float32))()
        result = jax.jit(call, donate_argnums=(0,))(value)
        self.assertTrue(value.is_deleted())
        result.block_until_ready()
        self.assertEqual(result.shape, (65536, 128))
        result.delete()

    def test_integer_control_and_small_float_placeholders(self):
        np.testing.assert_array_equal(
            jax.jit(lambda x: x * 3 + 1)(jnp.arange(7, dtype=jnp.int32)),
            np.arange(7) * 3 + 1,
        )
        self.assertTrue(bool(jax.jit(lambda x: x > 0)(jnp.float32(1))))
        self.assertEqual(int(jax.jit(jnp.argmax)(jnp.array([1.0, 3.0, 2.0]))), 0)

    def test_large_weight_with_explicit_output_sharding(self):
        mesh = jax.sharding.Mesh(np.array(jax.devices()[:1]), ("tensor",))
        sharding = jax.sharding.NamedSharding(
            mesh, jax.sharding.PartitionSpec(None, "tensor")
        )
        weight = jax.jit(
            lambda: jnp.zeros((4096, 4096), jnp.bfloat16), out_shardings=sharding
        )()
        weight.block_until_ready()
        self.assertEqual(weight.shape, (4096, 4096))
        with self.assertRaisesRegex(Exception, "pointer export"):
            weight.addressable_shards[0].data.unsafe_buffer_pointer()
        np.testing.assert_array_equal(np.asarray(weight[:1, :4]), np.zeros((1, 4)))


if __name__ == "__main__":
    unittest.main()
