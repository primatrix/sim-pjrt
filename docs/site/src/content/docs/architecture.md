---
title: 架构与执行流程
---

![sim-pjrt 架构](../../../../images/architecture.svg)

项目只保留一条计时路径：

```text
StableHLO → libtpu TPU 编译 → Final LLO bundles → 估时 → 模拟设备完成
         → CPU 输出编译 / Virtual HBM → 占位输出与控制值
```

原始程序直接交给 libtpu，CPU 输出替换不会影响 TPU 编译输入。设备型号、坐标和 core 索引来自指定的 TPU 拓扑。没有 libtpu 或 bundle 产物时直接报错。

编译既可以在 JAX/SGLang-Jax 运行时按需触发（JIT），也可以通过 `.lower(...).compile()` 在执行前显式完成（AOT），两者使用同一条编译路径。

底层调用基于 topology 的 `PJRT_Compile` 接口，无需真实 TPU。这里的“离线编译”指编译器不需要连接真实 TPU，并不限制编译发生的时机；服务运行期间也可以编译新程序。

CPU 输出编译内部仍使用 HLO 表示、SPMD 分区和存储改写；它不参与性能估算。程序计时只使用 Final LLO bundles。

bundle 解析和估时采用纯函数。C++ 负责调用编译器、收集 Final LLO 文件、调用估时模块和驱动完成事件。Python 估时模块结合 deduplication-map，按 TLP 调用点展开 kernel。缺口默认拒绝，示例 profile 显式允许部分估算。

执行等待输入依赖与设备先前任务，按程序时长预留 compute/HBM 资源；公开 ready 还要等待 CPU 输出就绪。显式 H2D/D2H 和设备 copy 单独计时，程序内部通信需要 bundle 模型覆盖。

| 文件 | 职责 |
| --- | --- |
| `src/tpu_compilation.cc` | libtpu 拓扑、编译与 Final LLO 收集 |
| `python/bundle_timing.py` | bundle 解析、路径与时间估算 |
| `src/bundle_timing.cc` | 调用估时模块、校验报告 |
| `src/compilation.cc` | 组织 TPU 编译与 CPU 输出编译 |
| `src/output_simulation.cc` / `src/virtual_hbm.cc` | 占位输出、逻辑形状与存储 |
| `src/runtime.cc` | 资源预留、计时器与就绪依赖 |
| `src/profiler.cc` | 原生 XPlane 导出 |

参见[配置](/reference/configuration/)和[XProf](/guides/profiling/)。
