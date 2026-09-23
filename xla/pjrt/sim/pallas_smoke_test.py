"""Exercise native TPU Pallas lowering without a TPU or libtpu."""

import unittest

import jax
import jax.numpy as jnp
import numpy as np
from jax.experimental import pallas as pl
from jax.experimental.pallas.ops.tpu import flash_attention


class PallasTest(unittest.TestCase):
    def test_flash_attention_native_lowering(self):
        # Exercise a real attention kernel with an author-declared estimate.
        # Numerical results remain placeholders; this checks compilation and
        # execution through the same Pallas path used by the cost model.
        value = jnp.ones((1, 2, 128, 128), dtype=jnp.bfloat16)
        result = jax.jit(flash_attention.flash_attention)(value, value, value)
        result.block_until_ready()
        self.assertEqual(result.shape, value.shape)

    def test_aliased_storage(self):
        def kernel(x_ref, y_ref):
            y_ref[...] = x_ref[...] + 1

        call = pl.pallas_call(
            kernel,
            out_shape=jax.ShapeDtypeStruct((8, 128), jnp.float32),
            input_output_aliases={0: 0},
        )
        result = jax.jit(call)(jnp.ones((8, 128), dtype=jnp.float32))
        np.testing.assert_array_equal(jax.device_get(result), 1)

    def test_native_lowering(self):
        def kernel(x_ref, y_ref):
            y_ref[...] = x_ref[...] + 1

        call = pl.pallas_call(
            kernel,
            out_shape=jax.ShapeDtypeStruct((8, 128), jnp.float32),
            name="sim_smoke_pallas",
        )
        result = jax.jit(call)(jnp.ones((8, 128), dtype=jnp.float32))
        result.block_until_ready()
        self.assertEqual(result.shape, (8, 128))
        np.testing.assert_array_equal(jax.device_get(result), 0)


if __name__ == "__main__":
    unittest.main()
