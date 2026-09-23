---
title: 环境变量
description: 后端选择、设备数、Virtual HBM与在线性能参数。
---

这些变量应在 **JAX 初始化后端之前**设置。修改后请启动新的 Python 进程。程序时间由 bundle profile 决定，显式 PJRT 传输使用 runtime 参数。

## 后端与存储

| 变量 | 默认值 / 示例 | 含义 |
| --- | --- | --- |
| `JAX_PLATFORMS` | 设置为 `tpu` | 选择插件占用的后端名称 |
| `PJRT_NAMES_AND_LIBRARY_PATHS` | `tpu:/绝对路径/pjrt_sim_plugin.so` | 指定插件 |
| `JAX_ENABLE_COMPILATION_CACHE` | 设置为 `false` | 禁用不受支持的持久化可执行文件缓存 |
| `PJRT_SIM_DEVICE_COUNT` | `1` | 接受 1 或不超过 256 的偶数；不得超过 libtpu 拓扑容量 |
| `PJRT_SIM_LIBTPU_PATH` | 必填 | 用此 libtpu 离线编译原始输入，以 Final LLO bundles 估时；不使用 TPU HLO，失败直接报错 |
| `PJRT_SIM_TPU_TOPOLOGY` | 未设置 | 必填，如 `v5e:2x2`；设备型号、坐标和 core 索引来自此拓扑，模拟设备数不能超过其容量 |
| `PJRT_SIM_BUNDLE_PROFILE` | 未设置 | 必填的 JSON 参数；缺口默认拒绝，`allow_partial=true` 显式允许未校准的部分估计 |
| `PJRT_SIM_BUNDLE_PYTHON` | `python3` | 运行纯函数估时模块的解释器；`PYTHONPATH` 需包含仓库 `python/` |
| `PJRT_SIM_BUNDLE_SCENARIO` | 未设置 | 可选执行路径、谓词和外部等待信息；进程中每次编译均使用此文件 |
| `PJRT_SIM_TRACE` | 未设置 | 执行日志和程序快照的输出前缀 |

例如，`PJRT_SIM_TRACE=/tmp/run/execution` 将生成 `execution.<pid>.jsonl` 以及对应程序快照。先创建父目录，并为新捕获使用独立目录。

## 时间与速率

所有计时参数放在 `PJRT_SIM_BUNDLE_PROFILE` 指向的 JSON。程序内部估算使用顶层 bundle 参数，显式 PJRT 操作使用 `runtime` 对象：

```json
{
  "runtime": {
    "launch_ns": 1000,
    "transfer_ns": 2000,
    "link_ns": 1000,
    "host_bytes_per_second": 32000000000,
    "link_bytes_per_second": 100000000000,
    "communication_scale": 1
  }
}
```

未写的字段采用上述默认值。时延为 `[0, 1e9]` 整数纳秒；带宽为正有限数，最多 `1e30`；倍率范围 `(0, 1e6]`。未知字段和错误类型会报错。

旧计时环境变量不再支持，设置后会提示迁移到 profile，避免无声忽略。Virtual HBM 没有按数组大小切换存储模式的配置。示例数值未校准。

## 验证脚本

| 变量 | 默认值 | 用途 |
| --- | --- | --- |
| `SIM_PYTHON` | `python3` | 测试使用的 Python |
| `SIM_RESULTS_DIR` | `/tmp/pjrt-sim-libtpu-results` | 测试输出根目录 |
| `SIM_TEST_TIMEOUT` | `300` | 单个框架测试的超时秒数 |

`PJRT_SIM_PROFILE_PYTHON` 和 `PJRT_SIM_PROFILE_HELPER` 已不再被插件使用。XProf 采集通过原生 profiler 扩展完成。

`SIM_MODEL=llama|qwen3_moe` 选择集成用例；`SIM_TP_SIZES`、`SIM_NUM_LAYERS`、`SIM_HIDDEN_SIZE` 和 `SIM_PROFILE=1` 控制运行规模及采集。
