---
title: 张量并行与重新分片
description: 在单主机模拟设备上运行分片程序。
---

`PJRT_SIM_DEVICE_COUNT` 决定模拟设备数，必须在 JAX 初始化前设置，且不能超过 libtpu 编译拓扑的容量。运行 TP4 时可使用 `v5e:2x2`，其余环境设置见[快速开始](/getting-started/)。

```sh
export PJRT_SIM_DEVICE_COUNT=4
```

## 编译设备端重新分片

```python
import jax
import jax.numpy as jnp
import numpy as np
from jax.sharding import Mesh, NamedSharding, PartitionSpec as P

mesh = Mesh(np.array(jax.devices()), ("tp",))
columns = NamedSharding(mesh, P(None, "tp"))
rows = NamedSharding(mesh, P("tp", None))
weight = jax.jit(
    lambda: jnp.zeros((4096, 4096), jnp.bfloat16),
    out_shardings=columns,
)()
weight_rows = jax.jit(
    lambda x: x, in_shardings=columns, out_shardings=rows,
)(weight)
weight_rows.block_until_ready()
```

逻辑形状保持不变，改变的是各设备负责的切片。libtpu 编译原始分片程序；CPU 输出路径独立执行分区和 Virtual HBM 改写。

部分 `jax.device_put` 重新分片路径会先读回完整主机数组，再切分并分发。Virtual HBM 的 D2H 支持生成占位数据，但主机目标仍需实际分配。大数组优先使用上面的编译重新分片路径。

## 通信与计时

整个程序的估时来自 Final LLO，不能再次简单除以 TP 数。显式 PJRT 设备 copy 单独计时，内部 collective 则需要 LLO 的 DMA、等待与跨设备依赖模型。当前没有完整的物理路由或网络争用模拟，不能把整段 `Bundles` 事件当作通信细节。

目前仅支持单主机、单 replica 的 Virtual HBM 执行。完整 serving 用例与复现环境见[测试与验证](/development/testing/)。
