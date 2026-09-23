"""Run with PJRT_NAMES_AND_LIBRARY_PATHS=tpu:/absolute/path/to/plugin.so."""

import unittest

import jax
import jax.numpy as jnp
import numpy as np


class RuntimeTest(unittest.TestCase):
    def test_device(self):
        (device,) = jax.devices()
        self.assertEqual(device.platform, "tpu")
        self.assertTrue(device.device_kind.startswith("TPU"), device.device_kind)
        self.assertEqual(tuple(device.coords), (0, 0, 0))
        self.assertEqual(device.core_on_chip, 0)

    def test_memory_accounting(self):
        (device,) = jax.devices()
        initial = device.memory_stats()["bytes_in_use"]
        x = jax.device_put(np.ones(1024, dtype=np.float32))
        x.block_until_ready()
        self.assertEqual(device.memory_stats()["bytes_limit"], 96 * 1024**3)
        self.assertEqual(device.memory_stats()["bytes_in_use"], initial + 4096)
        x.delete()
        self.assertEqual(device.memory_stats()["bytes_in_use"], initial)

    def test_simulated_matmul(self):
        x = jax.device_put(np.ones((4, 8), dtype=np.float32))
        y = jax.device_put(np.ones((8, 3), dtype=np.float32))
        result = jax.jit(lambda a, b: a @ b)(x, y)
        result.block_until_ready()
        host = jax.device_get(result)
        self.assertEqual(host.shape, (4, 3))
        self.assertEqual(host.dtype, np.float32)
        np.testing.assert_array_equal(host, 0)  # Explicit placeholder contract.

    def test_control_values_and_transfers(self):
        x = jax.device_put(np.arange(8, dtype=np.int32)[::2])
        result = jax.jit(lambda a: (a + 1, jnp.sum(a)))(x)
        actual, total = jax.device_get(result)
        np.testing.assert_array_equal(actual, [1, 3, 5, 7])
        self.assertEqual(total, 12)
        x.delete()
        self.assertTrue(x.is_deleted())
        with self.assertRaises((RuntimeError, ValueError)):
            x.block_until_ready()

    def test_donation(self):
        x = jax.device_put(np.arange(4, dtype=np.int32))
        result = jax.jit(lambda a: a + 2, donate_argnums=(0,))(x)
        np.testing.assert_array_equal(jax.device_get(result), [2, 3, 4, 5])


if __name__ == "__main__":
    unittest.main()
