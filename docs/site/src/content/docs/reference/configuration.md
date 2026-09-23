---
title: 环境变量
description: 后端选择、设备数、虚拟存储与在线性能参数。
---

这些变量应在 **JAX 初始化后端之前**设置。修改后请启动新的 Python 进程。在线模型参数与离线 scenario JSON 独立。

## 后端与存储

| 变量 | 默认值 / 示例 | 含义 |
| --- | --- | --- |
| `JAX_PLATFORMS` | 设置为 `tpu` | 选择插件占用的后端名称 |
| `PJRT_NAMES_AND_LIBRARY_PATHS` | `tpu:/绝对路径/pjrt_sim_plugin.so` | 指定插件 |
| `JAX_ENABLE_COMPILATION_CACHE` | 设置为 `false` | 禁用不受支持的持久化可执行文件缓存 |
| `PJRT_SIM_DEVICE_COUNT` | `1` | 接受 1 或不超过 256 的偶数；已验证 1/2/4/8 |
| `PJRT_SIM_MAX_MATERIALIZED_BYTES` | `0` | 关闭虚拟存储；正数至少 16 字节，按单个局部分片应用 |
| `PJRT_SIM_TRACE` | 未设置 | 执行日志和程序快照的输出前缀 |

例如，`PJRT_SIM_TRACE=/tmp/run/execution` 将生成 `execution.<pid>.jsonl` 以及对应程序快照。先创建父目录，并为新捕获使用独立目录。

## 时间与速率

| 变量 | 默认值 | 含义 |
| --- | --- | --- |
| `PJRT_SIM_COMPUTE_SCALE` | `1` | 计算 / HBM 时长倍率 |
| `PJRT_SIM_COMMUNICATION_SCALE` | `1` | 主机传输与设备通信时长倍率 |
| `PJRT_SIM_LAUNCH_NS` | `1000` | 每次执行的设备启动时延 |
| `PJRT_SIM_TRANSFER_NS` | `2000` | 主机传输启动时延 |
| `PJRT_SIM_LINK_NS` | `1000` | 链路启动时延 |
| `PJRT_SIM_FLOPS_PER_SECOND` | `1.1535e15` | 每设备计算速率 |
| `PJRT_SIM_TRANSCENDENTALS_PER_SECOND` | `1e12` | 每设备超越函数操作速率 |
| `PJRT_SIM_HBM_BYTES_PER_SECOND` | `3.69e12` | 每设备逻辑内存带宽 |
| `PJRT_SIM_HOST_BYTES_PER_SECOND` | `32e9` | 主机传输带宽 |
| `PJRT_SIM_LINK_BYTES_PER_SECOND` | `1e11` | 设备链路带宽 |

倍率必须为有限值，范围 `(0, 1e6]`。时延是 `[0, 1e9]` 范围的整数纳秒。速率是正有限值，最大 `1e30`。

这些默认值描述假设场景，未经真实 TPU 校准。调整倍率可验证敏感性，不能使缺失的成本模型自动完整。

## 验证脚本

| 变量 | 默认值 | 用途 |
| --- | --- | --- |
| `SIM_PYTHON` | `python3` | 测试使用的 Python |
| `SIM_RESULTS_DIR` | `/tmp/pjrt-sim-results` | 测试输出根目录 |
| `SIM_TEST_TIMEOUT` | `180` | 单个框架测试的超时秒数 |

`PJRT_SIM_PROFILE_PYTHON` 和 `PJRT_SIM_PROFILE_HELPER` 已不再被插件使用。XProf 采集通过原生 profiler 扩展完成。

## 离线计划工具

`PJRT_SIM_PLAN_EXPORT` 指定原生 `plan_export` 可执行文件。默认使用仓库的
`bazel-bin/plan_export`，仅在旧快照没有计划或请求的设备数变化时调用。
它不影响在线 client 的配置。
