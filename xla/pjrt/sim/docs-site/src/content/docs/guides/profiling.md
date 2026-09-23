---
title: XProf 性能分析
description: 采集主机调用和模拟设备时间线，正确解释事件时钟。
---

插件通过 `PJRT_Profiler_Extension` 接入 JAX 的 profiler 生命周期，输出标准 `*.xplane.pb`。采集本身不需要 Python 转换助手。

## 采集一个框架运行

使用[快速开始](/getting-started/)的后端环境，并安装 `profiling-requirements.txt` 中的依赖：

```sh
export PJRT_SIM_DEVICE_COUNT=4
python xla/pjrt/sim/sglang_smoke_test.py \
  --tp-size 4 --overlap --profile-dir /tmp/sim-profile
xprof server --logdir /tmp/sim-profile
```

在 XProf 中选择捕获会话和 Trace Viewer。时间线包含框架 host annotations、PJRT 提交与等待、模拟执行、HLO、DMA 和通信。

如果要继续做离线重放，需要在采集之前同时设置 `PJRT_SIM_TRACE`，见[离线重放](/guides/replay/)。

## 两类时间

| 时间域 | 含义 |
| --- | --- |
| `cpu_wall` | 实际观测到的主机调用、CPU 就绪通知等时间 |
| `simulated`，`clock_alignment=runtime_realtime` | 在线模型的设备资源预留，与实时运行对齐 |

在线完成事件同时等待模型期限和必要的 CPU 数据就绪。设备区间是模型结果，不是硬件测量。

## 关键事件

| 事件 | 解释 |
| --- | --- |
| Compile / Execute submit | 主机 API 调用，包括观测开销 |
| Execute submit-to-ready | 从提交到观测完成，包含排队与提交时间 |
| Host source releasable | 主机源数据可以复用，与设备输出就绪不同 |
| Buffer ready / Event await | 就绪查询与实际阻塞 |
| Executions | 设备上的可执行程序范围 |

`correlation_id` 关联提交与完成；`sim_program_id` 标识程序；`buffer_id`、`input_buffers`、`output_buffers` 关联缓冲区依赖。缓冲区 ID 表示句柄，不表示底层唯一物理分配。

## 导出报告

```sh
python xla/pjrt/sim/profile_report.py /tmp/sim-profile \
  --output /tmp/profile.report.json \
  --trace-output /tmp/profile.trace.json
```

累计区间可能重叠，pending 时长也不等于计算时间或利用率。

## 采集注意事项

SGLang 的执行发生在 scheduler 进程。仅在父进程用 `jax.profiler.trace` 包住 `engine.generate()` 可能漏掉子进程，应使用框架自身的 profiler 请求。集成测试采用 `host_tracer_level=1`、`python_tracer_level=0`，避免大量 Python 编译事件挤占时间线。

每个插件 session 最多接受 100,000 个观测事件，并报告丢弃数量；设备模型事件在收集时生成，数量可能更多。停止采集不会等待所有设备任务结束，尚未完成的区间会被裁剪并标记 `incomplete=1`。
