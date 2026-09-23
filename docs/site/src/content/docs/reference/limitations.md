---
title: 支持范围与限制
description: 执行流程、数值结果、存储和性能模型的边界。
---

运行流程通过不代表数值正确，也不代表性能预测准确。sim-pjrt 用真实 libtpu 编译目标程序，以部分时间模型和占位输出运行模拟流程。

## 执行与 Virtual HBM

- 单主机；CPU 输出执行要求单 replica。
- 所有设备 buffer 使用 Virtual HBM，没有按大小选择真实设备存储的阈值。
- 浮点 payload 使用占位表示；整数、布尔和单元素浮点控制值仍有 CPU shadow storage。
- D2H 返回控制值或浮点占位数据；不会恢复原始权重或计算结果。
- 原始设备指针、远程 buffer copy、buffer bitcast、动态 shape、HLO tuple 参数和嵌套 tuple 输出不受支持。
- 未识别的 custom call 和不受支持的外部副作用会报错。

主机加载器、CPU 控制状态和 D2H 目标仍可能分配大数组。`memory_stats()` 跟踪逻辑 buffer 字节数，不是实际 CPU RSS；别名、编译临时存储和完整物理 HBM 分配尚未准确重建。

## 性能覆盖

| 部分 | 当前边界 |
| --- | --- |
| 调用 | 使用编译器去重映射展开 Final LLO kernel；跨调用参数绑定不完整 |
| 控制流 | 未指定执行路径时线性扫描；动态循环次数与谓词结果可能未知 |
| 指令 | 计 bundle 发射成本，部分额外延迟和指令语义未覆盖 |
| DMA / 同步 | 仅支持部分传输参数与完成 credit；通用 DMA 和 collective 仍有缺口 |
| 硬件 | profile 提供频率、带宽和延迟；示例值未校准 |
| 在线时间 | 模型期限使用真实时钟；CPU/JAX 调度及通知开销会影响空隙和端到端耗时 |

严格 profile 拒绝未解决的缺口；`allow_partial=true` 允许部分估算。部分估算既不是可靠的下界，也不是上界。

## Serving 结果的含义

测试 harness 包含 dummy Llama 和 Qwen3 MoE，可覆盖 prefill、decode、overlap、缓存复用、flush 和 XProf。dummy 权重与占位浮点输出不验证文本生成质量，也不代表真实 MoE 专家选择、负载均衡或生产吞吐。

复现步骤见[测试与验证](/development/testing/)。Virtual HBM 去阈值版本已用小型 Llama TP4 overlap 流程验证；Qwen3 MoE 和完整回归套件尚未重新运行，不能直接沿用旧版本的通过记录。
