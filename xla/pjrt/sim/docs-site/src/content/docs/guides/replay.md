---
title: 离线重放与设备负载
description: 从 profile 和 HLO 快照重建固定工作负载的虚拟时间线。
---

`replay.py` 将同一个进程的执行日志、原始程序快照与 XProf 捕获按 correlation ID 关联，重建缓冲区依赖和主机线程提交顺序，然后用整数虚拟纳秒调度事件图。

## 1. 生成匹配的捕获

保留[快速开始](/getting-started/)的环境设置。每次运行用新目录，避免混入旧日志：

```sh
sim_capture=$(mktemp -d /tmp/pjrt-sim-capture.XXXXXX)
export PJRT_SIM_DEVICE_COUNT=4
export PJRT_SIM_TRACE="$sim_capture/execution"
python xla/pjrt/sim/sglang_smoke_test.py \
  --tp-size 4 --overlap --profile-dir "$sim_capture/profile"
unset PJRT_SIM_TRACE
ls "$sim_capture"
```

产物包括 `<prefix>.<pid>.jsonl` 和 `<prefix>.<pid>.program<ID>.json`。保留快照与对应 JSONL 在同一目录，选择实际执行模型的进程日志。

新快照使用 schema version 2，同时保存原始 HLO 和 C++ 生成的执行计划。设备数不变时，Python 直接读取嵌入计划；速率和路由仍可通过 scenario 调整。

旧快照或更改设备数时，需要原生计划工具：

```sh
bazel build -c opt //xla/pjrt/sim:plan_export
```

Python 默认从仓库的 `bazel-bin` 查找该工具；在其他位置运行时，设置 `PJRT_SIM_PLAN_EXPORT=/path/to/plan_export`。也可以先导出新计划，再把快照复制到没有原生工具的机器：

```sh
bazel-bin/xla/pjrt/sim/plan_export 4 < original.program.json > replanned.program.json
```

## 2. 运行重放

构建原生 XSpace 导出所用的 protobuf descriptor：

```sh
bazel build -c opt //xla/pjrt/sim:xplane_descriptor
```

将下面的路径换成同一次运行中的 profile 和 JSONL：

```sh
python xla/pjrt/sim/replay.py /tmp/my-capture/profile \
  /tmp/my-capture/execution.123.jsonl \
  --scenario xla/pjrt/sim/replay_scenario.json \
  --output /tmp/replay
```

增加 `--serial-dispatch` 可对同一个事件图比较串行提交策略。这不会重新运行 SGLang 调度器，也不会重新决定 batch。

## 3. 查看结果

| 文件 | 内容 |
| --- | --- |
| `report.json` | 资源 busy time、关键链、成本缺口和设备负载 |
| `timeline.json` | 可用 Perfetto 查看，带依赖与资源预留信息 |
| `xprof/plugins/profile/simulated/pjrt-simulator.xplane.pb` | 模拟 XProf 会话 |

```sh
xprof server --logdir /tmp/replay/xprof --port 8791
```

选择 `simulated` 会话的 Trace Viewer。未知操作保留为零时长节点，并标记未知成本；零时长不意味着实际免费。

## 单独分析一个程序

```sh
python xla/pjrt/sim/device_load.py /tmp/my-capture/execution.123.program10.json \
  --devices 4 --output /tmp/program10.load.json
```

输入必须是插件生成的 JSON 程序快照，不是原始 HLO 文本。更改设备数会从原始 HLO 重新生成计划；不兼容的 sharding 会保留为成本缺口。`per_partition` 快照中的 shape 已是局部大小，重新生成计划不会恢复全局 shape 或重新执行 SPMD 分区。结果描述一次调用，可查看 dot FLOPs、逻辑读写流量、通信和成本缺口。

## 解释边界

CPU 执行耗时、排队空隙和编译时间不作为 TPU 计算时长。离线主机提交成本来自 scenario 参数，捕获中的 batch 保持固定。

报告使用 `partial_makespan_ns`，并始终设置 `complete_latency_prediction=false`。逻辑读写字节数不等于峰值存储或实测 HBM 流量，已覆盖指令的数量比例也不等于运行时间覆盖率。

原生导出支持 Trace Viewer；硬件计数器面板、编译器 Graph Viewer 和原生 HLO Op Profile 尚未实现。
