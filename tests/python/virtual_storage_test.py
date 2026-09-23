"""Large logical tensors with bounded host storage, through unmodified JAX.

Run with the simulator plugin selected; this test enables virtual storage.
"""

import os
import resource
import unittest

os.environ["PJRT_SIM_MAX_MATERIALIZED_BYTES"] = str(16 * 1024 * 1024)
os.environ["PJRT_SIM_DEVICE_COUNT"] = "2"
os.environ["PJRT_SIM_LAUNCH_NS"] = "100000000"
os.environ["PJRT_SIM_TRANSFER_NS"] = "100000000"

import jax
import jax.numpy as jnp
import numpy as np


class VirtualStorageTest(unittest.TestCase):
    def test_large_model_state_and_decode_control(self):
        # Four 32 GiB weights plus a 512 MiB KV-like cache. No host weight array.
        @jax.jit
        def initialize():
            weights = tuple(
                jnp.zeros(shape, jnp.bfloat16)
                for shape in (
                    (65536, 262144),
                    (262144, 65536),
                    (65536, 262144),
                    (262144, 65536),
                )
            )
            return weights, jnp.zeros((65536, 4096), jnp.bfloat16)

        before = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
        weights, cache = initialize()
        jax.block_until_ready((weights, cache))
        self.assertEqual(sum(w.nbytes for w in weights), 128 * 1024**3)
        self.assertEqual(cache.shape, (65536, 4096))
        self.assertGreaterEqual(
            jax.devices()[0].memory_stats()["bytes_in_use"], 128 * 1024**3
        )

        def decode(weights, cache, length):
            x = jnp.zeros((1, 65536), jnp.bfloat16)
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
        self.assertEqual(final.shape, (65536, 4096))
        with self.assertRaisesRegex(Exception, "no materialized data"):
            np.asarray(weights[0])
        growth = (resource.getrusage(resource.RUSAGE_SELF).ru_maxrss - before) * 1024
        self.assertLess(growth, 1024**3)
        print(f"logical weights: 128 GiB; peak RSS growth: {growth / 1024**2:.1f} MiB")
        for w in weights:
            w.delete()
        final.delete()

    def test_host_import_copy_and_export_rejection(self):
        source = np.zeros((8 * 1024 * 1024,), np.float32)
        x = jax.device_put(source, jax.devices()[0])
        del source
        x.block_until_ready()
        y = jax.device_put(x, jax.devices()[1])
        self.assertFalse(y.is_ready())
        y.block_until_ready()
        self.assertEqual(y.shape, x.shape)
        with self.assertRaisesRegex(Exception, "no materialized data"):
            np.asarray(y)
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
        with self.assertRaisesRegex(Exception, "no materialized data"):
            np.asarray(result)
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

    def test_small_control_and_rejected_boundaries(self):
        np.testing.assert_array_equal(
            jax.jit(lambda x: x * 3 + 1)(jnp.arange(7, dtype=jnp.int32)),
            np.arange(7) * 3 + 1,
        )
        with self.assertRaisesRegex(Exception, "integer/control data"):
            jax.jit(lambda x: x > 0)(jnp.float32(1))
        with self.assertRaisesRegex(Exception, "Nonfloating tensor"):
            jax.jit(lambda: jnp.arange(8 * 1024 * 1024, dtype=jnp.int32))()


if __name__ == "__main__":
    unittest.main()
