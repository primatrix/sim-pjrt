---
title: Virtual HBM
description: 设备逻辑内存、CPU 控制状态与按需 D2H。
---

Virtual HBM 是模拟器统一的设备内存表示。它保留数组的 shape、dtype、设备位置、逻辑字节数和就绪状态，不按数组大小切换存储模式，也没有 16 MiB 阈值。

## 设备数据与主机状态

浮点张量使用标量占位 backing；从主机导入时不保留完整浮点载荷。整数、布尔值及单元素浮点控制值保留 CPU shadow storage，用于 token ID、索引、循环计数和调度。单元素浮点状态也用于 SGLang-Jax 的跨设备可用显存汇总。这些控制值属于模拟器的主机状态，仍会占用主机内存。

Virtual HBM 不等于完整物理 HBM 模拟：当前不重建内存颗粒、bank、碎片或 cache 行为，也不保证任意整数程序的主机内存占用恒定。

## 创建与读回

先按[快速开始](/getting-started/)配置后端：

```python
import jax
import jax.numpy as jnp

weight = jax.jit(lambda: jnp.zeros((4096, 4096), jnp.bfloat16))()
weight.block_until_ready()
print(weight.shape, weight.dtype, weight.nbytes)
sample = jax.jit(lambda x: x[:1, :8])(weight)
print(jax.device_get(sample))  # 浮点占位数据
```

D2H 时才创建所需尺寸的主机目标，复制控制值或填充浮点零占位数据，并模拟传输耗时。读回整个大数组仍需要相应的主机内存。这个过程不会恢复丢弃的权重，也不会补算真实数值结果。

框架在调用插件之前可能已经加载或复制权重。要避免 checkpoint 分配，使用集成示例的 `load_format="dummy"`，而不是依赖 Virtual HBM 拦截上游加载。

## API 边界

设备缓冲区支持逻辑尺寸查询、就绪事件、普通执行 donation 和本地设备复制。原始设备指针不可导出。当前不支持动态 shape、HLO tuple 参数、嵌套 tuple 输出、远程 buffer copy 和 buffer bitcast。

整数控制结果可以保留；从浮点占位数据派生的比较、采样或专家路由没有真实数值意义。编译内存分析不能用底层 CPU backing 的大小代替原始 TPU 工作负载。

完整限制见[支持范围](/reference/limitations/)。
