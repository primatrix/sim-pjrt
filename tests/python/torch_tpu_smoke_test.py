"""Run through spjrt --framework torch_tpu; requires the optional TorchTPU wheel."""

import unittest

import torch


class TorchTpuSmokeTest(unittest.TestCase):
    def test_device_discovery(self):
        self.assertTrue(torch.accelerator.is_available())
        self.assertGreaterEqual(torch.accelerator.device_count(), 1)
        self.assertEqual(torch.accelerator.current_accelerator().type, "tpu")

    def test_integer_transfer_and_eager_control(self):
        source = torch.tensor([1, 2, 3, 4], dtype=torch.int32)
        value = source.to("tpu")
        torch.testing.assert_close(value.cpu(), source)
        torch.testing.assert_close((value + value).cpu(), source + source)

    def test_float_eager_metadata(self):
        value = torch.ones((8, 8), dtype=torch.bfloat16, device="tpu")
        result = torch.relu(value + value)
        self.assertEqual(result.device.type, "tpu")
        self.assertEqual(result.shape, (8, 8))
        self.assertEqual(result.cpu().dtype, torch.bfloat16)

    def test_nonblocking_host_transfer(self):
        source = torch.arange(128, dtype=torch.int32)
        result = (source.to("tpu") + 1).to("cpu", non_blocking=True)
        torch.accelerator.synchronize()
        torch.testing.assert_close(result, source + 1)

    def test_jax_kernel_bridge(self):
        import jax

        # Serving frameworks load both clients and inject JAX/Pallas kernels
        # into TorchTPU graphs. This exercises symbol isolation and ChipCount.
        self.assertEqual(jax.devices()[0].platform, "tpu")

        def add(x: jax.Array) -> jax.Array:
            return x + x

        op = torch.tpu.pallas.jax_op("sim_pjrt::jax_add", add)
        source = torch.arange(8, dtype=torch.int32)
        torch.testing.assert_close(op(source.to("tpu")).cpu(), source + source)

    def test_compiled_matmul(self):
        @torch.compile(backend="tpu", fullgraph=True)
        def model(x, y):
            return torch.relu(x @ y)

        x = torch.ones((8, 16), dtype=torch.bfloat16, device="tpu")
        y = torch.ones((16, 8), dtype=torch.bfloat16, device="tpu")
        for _ in range(2):
            result = model(x, y)
            self.assertEqual(result.device.type, "tpu")
            self.assertEqual(result.shape, (8, 8))
            self.assertEqual(result.cpu().dtype, torch.bfloat16)
        # Float values are simulator placeholders, not numerical TPU results.
        torch.accelerator.synchronize()


if __name__ == "__main__":
    unittest.main()
