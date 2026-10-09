"""Small PJRT requests for the unified LLO execution model.

Run through `lab capped ... python -m sim_pjrt run --plugin ... --report ...`
with libtpu 0.0.48. Outputs are simulator placeholders, not numerical validation.
"""
import json
import jax
import jax.numpy as jnp


def main():
    x = jnp.ones((8, 128), jnp.bfloat16)
    y = jax.jit(lambda a: a + 1)(x)
    y.block_until_ready()
    z = jax.jit(lambda a: a @ a.T)(x)
    z.block_until_ready()
    print(json.dumps({'platform': jax.devices()[0].platform,
                      'add_shape': list(y.shape), 'matmul_shape': list(z.shape)}))


if __name__ == '__main__':
    main()
