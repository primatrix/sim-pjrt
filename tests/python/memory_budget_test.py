"""Native allocation admission with a deliberately tiny per-device budget."""

import gc
import os
import time
import unittest

from runtime_profile import configure_runtime

os.environ["PJRT_SIM_DEVICE_COUNT"] = "2"
configure_runtime(hbm_capacity_bytes=1040, hbm_reserved_bytes=16, transfer_ns=100000000)

import jax
import numpy as np


class MemoryBudgetTest(unittest.TestCase):
    def used(self, device):
        return device.memory_stats()["bytes_in_use"]

    def wait_used(self, device, expected):
        deadline = time.monotonic() + 3
        while self.used(device) != expected and time.monotonic() < deadline:
            gc.collect()
            time.sleep(.01)
        self.assertEqual(self.used(device), expected)

    def test_capacity_donation_copy_and_release(self):
        first, second = jax.devices()[:2]
        self.assertEqual(first.memory_stats()["bytes_limit"], 1040)
        self.assertEqual(self.used(first), 16)
        x = jax.device_put(np.ones(256, dtype=np.float32), first)
        x.block_until_ready()
        self.assertEqual(self.used(first), 1040)
        with self.assertRaisesRegex(Exception, "Virtual HBM OOM"):
            jax.device_put(np.ones(1, dtype=np.float32), first)
        self.assertEqual(self.used(first), 1040)

        donated = jax.jit(lambda value: value + 1, donate_argnums=(0,))(x)
        donated.block_until_ready()
        self.assertTrue(x.is_deleted())
        self.assertEqual(self.used(first), 1040)
        self.assertEqual(first.memory_stats()["peak_bytes_in_use"], 1040)

        # Output reservation fails before executing or consuming the input.
        with self.assertRaisesRegex(Exception, "Virtual HBM OOM"):
            jax.jit(lambda value: value + 2)(donated)
        self.assertFalse(donated.is_deleted())
        self.assertEqual(self.used(first), 1040)

        copied = jax.device_put(donated, second)
        copied.block_until_ready()
        self.assertEqual(self.used(second), 1040)
        donated.delete()
        self.wait_used(first, 16)
        self.assertEqual(self.used(second), 1040)
        copied.delete()
        self.wait_used(second, 16)
        self.assertEqual(first.memory_stats()["peak_bytes_in_use"], 1040)

    def test_pending_d2h_keeps_source_allocation_after_delete(self):
        device = jax.devices()[0]
        self.wait_used(device, 16)
        value = jax.device_put(np.ones(256, dtype=np.float32), device)
        value.block_until_ready()
        value.copy_to_host_async()
        value.delete()
        self.assertEqual(self.used(device), 1040)
        with self.assertRaisesRegex(Exception, "Virtual HBM OOM"):
            jax.device_put(np.ones(1, dtype=np.float32), device)
        self.wait_used(device, 16)


if __name__ == "__main__":
    unittest.main()
