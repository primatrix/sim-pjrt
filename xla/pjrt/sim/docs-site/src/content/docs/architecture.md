---
title: 架构与执行流程
description: 理解编译、成本捕获、CPU 执行和在线就绪门控。
---

模拟器将 CPU 的功能执行与基于逻辑工作量的成本模型结合。CPU 负责真实程序生命周期，模型决定公开完成事件至少需要等待多久。

## 编译路径

```text
JAX / SGLang-Jax
      │ MLIR / HLO
      ▼
PJRT 插件导入程序
      │
      ├─ 虚拟多设备模式：先做 SPMD 分区
      │
      ▼
捕获逻辑工作量、执行计划和程序快照
      │
      ▼
替换浮点 dot / Pallas 数值计算
      │
      ├─ 虚拟存储：按阈值将浮点数组转换为标量物理存储
      │
      ▼
CPU 编译与异步执行
```

成本捕获在占位替换之前进行。虚拟多设备模式的成本使用分区后的局部形状，默认模式则保留分区前的工作描述。

## 在线执行

1. 绑定实际设备 ID、输入缓冲区生产者和前序执行依赖。
2. 按执行计划预留 compute、HBM 和通信链路资源。
3. CPU 运行时执行经过替换的程序。
4. 模型期限与必要的 CPU 数据均已就绪后，对外报告完成。

计时器使用映射到真实经过时间的 steady clock。完成回调在锁外、独立 executor 上执行。关闭 profiling 后，在线时间模型仍工作。

当前资源预留采用保守的 FIFO 策略。每个程序等待全部输入和参与设备上的上一次执行。动态控制流等未覆盖工作保留依赖，但其成本不完整。

## 存储与内存统计

默认模式实际分配 CPU 存储。虚拟模式的包装缓冲区对外返回逻辑 shape 和大小，对内持有很小的物理缓冲区。

`memory_stats()` 按设备汇总跟踪到的 live-buffer 逻辑字节数，并报告 96 GiB 的诊断容量。别名句柄可能重复计数，编译临时存储等未完全覆盖，也不执行容量约束。

## 代码地图

以下路径均相对于 `xla/pjrt/sim/`：

| 文件 | 职责 |
| --- | --- |
| `plugin.cc` | PJRT 入口、设备身份、MLIR/HLO 导入和 CPU 编译 |
| `partitioning.cc` | 虚拟存储前的 SPMD 分区 |
| `virtual_storage.cc` | 逻辑缓冲区包装和虚拟存储替换 |
| `hlo_model.cc` | 捕获原始工作量并做数值替换 |
| `execution_plan.cc` | 在线和离线共用的 HLO 建模与执行计划 |
| `program_snapshot.cc` / `plan_export.cc` | 导出原始 HLO 与计划，按设备数重新生成计划 |
| `runtime.cc` | 资源预留与在线完成事件 |
| `instrumentation.cc` | PJRT 调用观测、生产者追踪和就绪门控 |
| `profiler.cc` / `profiler_api.cc` | 并发采集与 profiler 扩展 |
| `execution_plan.py` | 读取嵌入计划，必要时调用原生工具重新生成 |
| `workload.py` / `communication.py` | 按场景速率和路由展开计划为设备与通信事件 |
| `virtual_clock.py` / `replay.py` | 虚拟时钟与固定工作负载重放 |

进一步了解[在线配置](/reference/configuration/)和[离线重放](/guides/replay/)。
