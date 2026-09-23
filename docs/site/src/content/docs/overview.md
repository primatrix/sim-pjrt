---
title: 项目概览
---

sim-pjrt 在 CPU 上运行受支持的 JAX 和 SGLang-Jax 模拟流程。它需要 libtpu 软件库，但不需要 TPU 硬件。

支持运行时按需编译（JIT），也支持通过 `.lower(...).compile()` 提前编译（AOT）。两种方式都由 libtpu 完成 TPU 编译。

libtpu 将原始 StableHLO 编译为 Final LLO bundles；模型据此估时，CPU 后端产生控制值和占位输出，runtime 用估算时长约束完成事件。所有设备 buffer 使用 Virtual HBM；浮点 payload 不保留完整 CPU backing，控制值保留主机状态。

当前可验证 PJRT 接入、异步缓冲区、donation、整数控制、张量并行、SGLang overlap 和 XProf 采集。浮点 matmul 与受支持 TPU kernel 使用占位结果，不能用输出判断模型数值正确性。

模型仍缺少完整的控制流、DMA/通信同步语义和硬件校准。示例 profile 只允许部分估算；真实 host 调度与回调延迟也会影响端到端耗时。

从[快速开始](/getting-started/)设置 libtpu、拓扑和 bundle profile。
