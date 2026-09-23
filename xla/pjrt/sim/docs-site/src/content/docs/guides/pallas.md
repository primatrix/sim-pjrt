---
title: Pallas 内核成本
description: 使用内核声明的 FLOPs、超越函数操作数和访问字节数。
---

模拟器从 `tpu_custom_call` 的 backend config 中读取 `custom_call_config.cost_estimate`。JAX 0.11.1 的 TPU FlashAttention lowering 提供 `flops`、`transcendentals` 和 `bytes_accessed`。

## 估算方法

```text
内核时间 = max(
    flops / compute_rate,
    transcendentals / transcendental_rate,
    bytes_accessed / hbm_rate
)
```

在线模式再乘以 `PJRT_SIM_COMPUTE_SCALE`。计算与 HBM 资源在整个估算区间被预留。这是尚未校准的 roofline 近似。

成本按每次局部调用计入，静态调用点分别计数，不再按 TP 数相除。支持的作用域包括单设备、手动局部计算和明确复制的输入输出。

## 在哪里查看

| 字段 | 含义 |
| --- | --- |
| `cost_source=pallas_cost_estimate` | 成本来自内核作者声明 |
| `kernel_flops` | Pallas 声明的计算量，与普通 dot 分开 |
| `kernel_transcendentals` | 超越函数操作量 |
| `kernel_bytes_accessed` | 内核声明的总访问字节数 |
| `plan_cost_gaps` | 在线执行计划中的成本缺口 |

使用在线 profile 或 `replay.py` 查看这些成本。旧版 `report.py` 仍主要提供 HLO 汇总估计。

## 缺失的成本如何处理

声明缺失、格式错误、分片作用域不确定或内核包含内部通信时，保留明确的成本缺口。模拟器不会根据内核名称猜测成本，也不解释 Mosaic 内部指令。

声明的字节数不一定反映实际活跃 KV 长度、分块重读、因果跳过或真实 HBM 流量。没有成本元数据的任意 paged/ragged attention 仍需后续支持。

速率可通过[环境变量](/reference/configuration/)调整；在线变量不会自动修改离线 scenario。
