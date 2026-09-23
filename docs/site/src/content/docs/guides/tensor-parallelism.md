---
title: 张量并行与重新分片
description: 在单主机上建立设备 mesh，运行虚拟张量并行。
---

设备数必须在后端初始化前确定。已验证的配置为 1、2、4、8 个设备；配置项接受 1 或不超过 256 的偶数。

```sh
export PJRT_SIM_DEVICE_COUNT=8
export PJRT_SIM_MAX_MATERIALIZED_BYTES=16777216
```

同时保留[快速开始](/getting-started/)中的 JAX 后端设置。

## 建立 mesh 并重新分片

```python
import jax
import jax.numpy as jnp
import numpy as np
from jax.sharding import Mesh, NamedSharding, PartitionSpec as P

mesh = Mesh(np.array(jax.devices()), ("tp",))
columns = NamedSharding(mesh, P(None, "tp"))
rows = NamedSharding(mesh, P("tp", None))

weight = jax.jit(
    lambda: jnp.zeros((16384, 16384), jnp.bfloat16),
    out_shardings=columns,
)()
weight_rows = jax.jit(
    lambda x: x,
    in_shardings=columns,
    out_shardings=rows,
)(weight)
weight_rows.block_until_ready()
```

权重分布到八个设备，每个局部分片超过设定阈值，使用虚拟存储。编译后的 identity 函数在设备端完成从列分片到行分片的转换。

部分 `jax.device_put` 重新分片路径会读回主机，对虚拟数组会失败。下面用两个设备说明具体行为。

## 为什么 device_put 会尝试读回主机

以下示例已在本地 JAX/jaxlib 0.11.1 和模拟器上验证。先保留[快速开始](/getting-started/)中的后端设置，再设置以下变量并启动一个**新的 Python 进程**：

```sh
export PJRT_SIM_DEVICE_COUNT=2
export PJRT_SIM_MAX_MATERIALIZED_BYTES=1024
```

```python
import jax
import jax.numpy as jnp
import numpy as np
from jax.sharding import Mesh, NamedSharding, PartitionSpec as P

# 将两个设备组成一个名为 tp 的 mesh 轴。
mesh = Mesh(np.array(jax.devices()), ("tp",))

# 两个位置分别对应矩阵的行维度和列维度。
# None 表示该维度不切分，tp 表示沿设备组切分。
columns = NamedSharding(mesh, P(None, "tp"))
rows = NamedSharding(mesh, P("tp", None))

# 创建逻辑形状为 (64, 64) 的矩阵，输出按列分片。
x = jax.jit(
    lambda: jnp.zeros((64, 64), jnp.float32),
    out_shardings=columns,
)()
x.block_until_ready()

# 尝试改成按行分片：在此配置下触发主机读回并报错。
y = jax.device_put(x, rows)
```

`mesh` 定义设备组织方式，`columns` 和 `rows` 定义分片规则；这三行本身不创建或移动张量。真正的创建发生在 `jax.jit(...)()` 调用时。

每个输入分片为 `64 × 32 × 4 = 8192` 字节，超过设置的 1024 字节阈值，因此使用虚拟存储。

### 从列分片到行分片

| 设备 | 输入 x：按列分片 | 目标 y：按行分片 |
| --- | --- | --- |
| 0 | `x[:, :32]`，形状 `(64, 32)` | `x[:32, :]`，形状 `(32, 64)` |
| 1 | `x[:, 32:]`，形状 `(64, 32)` | `x[32:, :]`，形状 `(32, 64)` |

逻辑矩阵仍为 `(64, 64)`，内容不变，也没有转置。改变的只是各设备负责的区域。代码没有请求 donation，转换不会以捐赠方式消耗 `x`。

目标设备 0 需要矩阵的上半部分，但已有分片分别是左半部分和右半部分。必须从两边各取一块才能组成目标分片。

### JAX 的回退路径

本地 JAX 0.11.1 的 `shard_sharded_device_array_slow_path` 先查找与目标切片索引完全匹配的已有缓冲区。若能找到，就复用或复制；若找不到，就通过 `x._value` 获取主机上的完整数组，再按目标规则切分和分发。逻辑可简化为：

```text
目标切片是否与某个已有分片完全匹配？
  ├─ 是 → 复用或复制该分片
  └─ 否 → 读取 x._value → 在主机重新切分 → 分发到设备
```

列分片转行分片不满足直接复用条件，因此进入主机回退路径。虚拟张量没有实际载荷，在读回时返回：

```text
FAILED_PRECONDITION: Virtual simulator tensor has no materialized data;
host reads and pointer export are unavailable
```

这是该版本、该分片组合的实现行为，不代表所有 `device_put` 都需要读回。普通实际存储的数组不受这项虚拟存储限制。设备端重新分片本身也不要求经过主机。

### 替代方式一：编译重新分片

将报错的最后一行替换为下面的代码，即可沿用原来的 mesh 和 `x`：

```python
y = jax.jit(
    lambda x: x,
    in_shardings=columns,
    out_shardings=rows,
)(x)
y.block_until_ready()
```

函数在逻辑上返回原值，输入和输出的分片约束让编译器生成设备端重新分片操作。此方式已在同一本地环境中验证通过。

### 替代方式二：显式分片与 jax.reshard

也可以使用 JAX 的专用接口 `jax.reshard`。本例需要将 mesh 轴声明为 `AxisType.Explicit`。保留前面的环境设置，在新进程中运行以下完整示例：

```python
import jax
import jax.numpy as jnp
import numpy as np
from jax.sharding import AxisType, Mesh, NamedSharding, PartitionSpec as P

mesh = Mesh(
    np.array(jax.devices()),
    ("tp",),
    axis_types=(AxisType.Explicit,),
)
columns = NamedSharding(mesh, P(None, "tp"))
rows = NamedSharding(mesh, P("tp", None))
x = jax.jit(
    lambda: jnp.zeros((64, 64), jnp.float32),
    out_shardings=columns,
)()

y = jax.reshard(x, rows)
y.block_until_ready()
```

此方式也已在本地 JAX 0.11.1 和模拟器上验证通过。不要直接把 `jax.reshard` 套到上面默认的 `Auto` mesh 轴上；它会因轴类型不符合要求而报错。接口说明见 [JAX 分布式数组文档](https://docs.jax.dev/en/latest/201/sharding.html)。

## 编译顺序与成本

虚拟多设备模式先执行 Shardy / sharding propagation 和 SPMD partitioner，再捕获成本并替换存储。因此计算形状已经是每个设备的局部形状，不能再次除以 TP 数。

| 输出字段 | 含义 |
| --- | --- |
| 执行日志 `work_scope=per_partition` | 工作量已按局部分片记录 |
| 程序快照 `shape_scope=per_partition` | HLO shape 已经过分区 |

全组 all-reduce、all-gather、reduce-scatter 使用合成 ring；all-to-all 和 collective-permute 使用有向逻辑链路与组屏障。子组通信、物理路由和实际拓扑争用仍存在覆盖缺口。

## 框架 smoke test

小模型的默认存储模式可通过以下命令测试：

```sh
unset PJRT_SIM_MAX_MATERIALIZED_BYTES
export PJRT_SIM_DEVICE_COUNT=4
python tests/python/sglang_smoke_test.py --tp-size 4 --overlap
```

虚拟存储下的 decode 路径已有专门测试，但完整大模型 SGLang serving 尚未验证。多设备执行目前限于单主机、单 replica。
