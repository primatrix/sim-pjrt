"""Verify live PJRT gates with profiling disabled, through unmodified JAX."""

import os
import time
import unittest

# Set before the backend initializes; these deliberately slow deadlines make
# bypasses observable without relying on microsecond host timing.
os.environ["PJRT_SIM_DEVICE_COUNT"] = "2"
from runtime_profile import configure_runtime

configure_runtime(launch_ns=100000000, transfer_ns=100000000)
os.environ.pop("PJRT_SIM_PROFILE_PYTHON", None)
os.environ.pop("PJRT_SIM_PROFILE_HELPER", None)

import jax
import numpy as np


class OnlineRuntimeTest(unittest.TestCase):
    def test_ready_control_buffer_still_requires_d2h(self):
        x = jax.device_put(np.arange(8, dtype=np.int32))
        x.block_until_ready()
        start = time.monotonic()
        np.testing.assert_array_equal(np.asarray(x), np.arange(8))
        self.assertGreaterEqual(time.monotonic() - start, 0.09)

    def test_device_put_and_copy_wait_for_modeled_transfer(self):
        start = time.monotonic()
        x = jax.device_put(np.arange(16, dtype=np.int32), jax.devices()[0])
        self.assertFalse(x.is_ready())
        x.block_until_ready()
        self.assertGreaterEqual(time.monotonic() - start, 0.1)
        y = jax.device_put(x, jax.devices()[1])
        np.testing.assert_array_equal(np.asarray(y), np.arange(16))
        self.assertTrue(y.is_ready())

    def test_execute_donation_and_host_read_cannot_bypass_model(self):
        step = jax.jit(lambda x: x + 1, donate_argnums=(0,))
        x = jax.device_put(np.arange(16, dtype=np.int32))
        x = step(x)
        x.block_until_ready()  # Warm compilation before timing.
        start = time.monotonic()
        y = step(x)
        self.assertTrue(x.is_deleted())
        self.assertFalse(y.is_ready())
        z = step(y)
        self.assertTrue(y.is_deleted())
        np.testing.assert_array_equal(jax.device_get(z), np.arange(16) + 3)
        self.assertGreaterEqual(time.monotonic() - start, 0.2)


if __name__ == "__main__":
    unittest.main()
