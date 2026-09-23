import jax
import jax.numpy as jnp
from jax.experimental import topologies
from jax.sharding import SingleDeviceSharding

topo = topologies.get_topology_desc("v4:2x2x1", platform="tpu")
s = SingleDeviceSharding(topo.devices[0])

f = jax.jit(
    lambda x, w: jax.nn.relu(x @ w),
    in_shardings=(s, s),
    out_shardings=s,
)
x = jax.ShapeDtypeStruct((128, 64), jnp.float32)
w = jax.ShapeDtypeStruct((64, 256), jnp.float32)

compiled = f.lower(x, w).compile()
print(compiled.as_text())
