"""Check the cost contract against real JAX TPU lowering, without TPU hardware."""

import base64
import unittest

import jax
import jax.numpy as jnp
from jax.experimental.pallas.ops.tpu import flash_attention

from pallas_cost_test import kernel_snapshot, kernel_cost
from plan_test_utils import entry


def custom_calls(operation):
    if operation.name == "stablehlo.custom_call":
        yield operation
    for region in operation.regions:
        for block in region.blocks:
            for child in block.operations:
                yield from custom_calls(child.operation)


class PallasLoweringTest(unittest.TestCase):
    def test_flash_attention_emits_consumable_costs(self):
        value = jax.ShapeDtypeStruct((1, 2, 128, 128), jnp.bfloat16)
        lowered = (
            jax.jit(flash_attention.flash_attention)
            .trace(value, value, value)
            .lower(lowering_platforms=("tpu",))
        )
        calls = [
            call
            for call in custom_calls(lowered.compiler_ir("stablehlo").operation)
            if call.attributes["call_target_name"].value == "tpu_custom_call"
        ]
        self.assertEqual(len(calls), 1)
        config = calls[0].attributes["backend_config"].value
        # Match HloInstructionProto's bytes-in-JSON representation.
        snapshot = kernel_snapshot()
        entry(snapshot)["instructions"][0]["backend_config"] = base64.b64encode(
            config.encode()
        ).decode()
        cost = kernel_cost(snapshot)
        self.assertEqual(cost["flops"], 16842752)
        self.assertEqual(cost["transcendentals"], 32768)
        self.assertEqual(cost["bytes_accessed"], 262144)


if __name__ == "__main__":
    unittest.main()
