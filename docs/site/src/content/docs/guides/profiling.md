---
title: XProf 性能分析
---

先完成[快速开始](/getting-started/)，再安装 XProf：

```sh
python -m pip install 'xprof==2.23.1'
```

## 采集模拟时间线

在已有的单进程 JAX 程序中，先编译、预热，再包住需要观察的调用：

```python
with jax.profiler.trace("./profile"):
    result = compiled(*inputs)
    jax.block_until_ready(result)
```

等待结果就绪后再结束采集，避免缺少完成事件。然后运行程序并打开 XProf：

```sh
spjrt run workload.py
xprof server --logdir ./profile --port 8791
```

浏览器打开 `http://localhost:8791`，选择 Trace Viewer。
SGLang 使用 scheduler 进程里的 profiler；已配置的
[集成测试](/development/testing/)可通过 `SIM_PROFILE=1 bash tests/run_libtpu_tests.sh` 采集。

## 看哪些轨道

| 轨道 | 含义 |
| --- | --- |
| XLA Modules | 整个编译程序的预测执行时间 |
| XLA Ops | 编译器操作的预测区间，可查看 `cost_gap` 等详情 |
| XLA TraceMe | 管理段、启动、显式传输和等待 |
| Host / PJRT | 当前 CPU 上实测的提交和等待时间 |
| Framework / Source code | 有编译器调试信息时显示框架及源码位置 |

先看 Modules 的整段时间，再展开 Ops 定位成本。轨道可能嵌套、重叠，不能相加。
Host 等待包含 CPU 调度和通知延迟，不代表真实 TPU 的传输或执行时间。

有缺口时，可运行 `spjrt run --report ./run workload.py`，查看程序报告中的原因。
缺少源码轨道通常表示编译产物没有对应调试标签。

## 需要真实 TPU 耗时

在真实 TPU 上用 `spjrt collect --output ./capture workload.py`。
采集结束后，`capture/timings.json` 保存实测耗时，`capture/profile/` 保存原始 profile。
模拟 profile 展示的是预测结果；真机采集才可用于校准和准确性验证。
