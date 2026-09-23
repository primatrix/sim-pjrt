---
title: Pallas 内核
---

Pallas 调用随原始 StableHLO 一起交给 libtpu 编译，计时直接使用 Final LLO bundles。`cost_estimate` 不参与程序耗时估算。

CPU 输出模拟支持已识别的 TPU kernel：无别名输出使用占位值，有别名输出保留其约定的输入关系。未知 custom call、外部副作用和无法保持控制语义的程序会被拒绝。

bundle 中未解释的循环、谓词、DMA/wait 或指令保持为显式缺口。严格 profile 会拒绝；显式允许部分估算的 profile 不代表完整 TPU 执行时间。

SGLang 集成测试包含 FlashAttention；数值结果是模拟值。参见[测试](/development/testing/)。
