---
title: 虚拟存储
description: 了解逻辑形状与物理存储的分离、阈值配置和使用语义。
---

虚拟存储保留张量的逻辑 shape、dtype 和字节数，底层用标量 CPU 缓冲区承载所有权与就绪状态。成本估算仍基于存储替换前的逻辑工作量。

## 开启方式

在 JAX 初始化前设置：

```sh
export PJRT_SIM_MAX_MATERIALIZED_BYTES=16777216  # 16 MiB
```

默认 `0` 表示关闭。正数至少为 16 字节。超过阈值的静态浮点数组使用虚拟存储，未超过阈值的数组保留实际存储。阈值应用于**每个设备上的单个数组分片**，不是整个进程的内存上限，也不是 HBM 容量限制。

## 初始化示例

先按[快速开始](/getting-started/)配置后端，再运行：

```python
import jax
import jax.numpy as jnp

weight = jax.jit(
    lambda: jnp.zeros((4096, 4096), dtype=jnp.bfloat16)
)()
weight.block_until_ready()
print(weight.shape, weight.dtype)  # (4096, 4096) bfloat16
```

此示例中的数组超过上述 16 MiB 阈值，因此使用虚拟存储。初始化在编译程序内部完成，对外仍保留原来的 shape 和 dtype。

从主机导入满足虚拟存储条件的浮点数组时，插件会跳过实际载荷；但框架加载器或 JAX 在调用插件之前仍可能已经分配、复制了源数据。

## 哪些行为保持可用

- 整数控制的调用、循环和分支。
- cache 更新、缓冲区 donation 和本地设备复制。
- 多设备 SPMD 编译与受支持的设备端重新分片。
- 逻辑缓冲区大小、就绪事件与逻辑 live-buffer 统计。

## 使用边界

:::caution[占位数据没有数值意义]
虚拟张量没有真实载荷，不能读回主机或导出指针。由它产生的小浮点输出也可能是占位值。
:::

浮点到整数/布尔值的路径被保守拒绝，包括小浮点比较、argmax 和采样。整数或布尔数组超过阈值会报错；动态 shape、HLO tuple 参数、嵌套 tuple 输出和虚拟缓冲区 bitcast 不受支持。

编译后的内存分析不可用：底层 CPU 统计反映的是标量程序，不能作为原始逻辑张量的内存分析。

完整清单见[支持范围与限制](/reference/limitations/)。
