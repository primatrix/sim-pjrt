---
title: XProf 性能分析
---

插件通过原生 `PJRT_Profiler_Extension` 输出 `*.xplane.pb`，无 Python 导出助手。

设置[后端环境](/getting-started/)，安装 `requirements/profiling-requirements.txt`，运行：

```sh
SIM_PYTHON=.venv/bin/python SIM_TP_SIZES=4 SIM_PROFILE=1 bash tests/run_libtpu_tests.sh
xprof server --logdir /path/to/run/tp4/xprof --port 8791
```

在 Trace Viewer 展开 `/device:CUSTOM:1000 Simulated TPU 0` 等设备行：

| 轨道 | 含义 |
| --- | --- |
| Bundles | 整个程序的 bundle 模型时长，非逐指令测量 |
| Launch | 模拟启动延迟 |
| DMA | 显式 H2D/D2H/设备 copy 的模拟传输 |
| Host completion / device N | 执行和传输的提交到完成区间 |
| PJRT host API | 主机调用线程 |

模型区间与 host 共用时间基准，但 `simulated` 和 `cpu_wall` 不是同一种测量。长 H2D submit-to-ready 可能来自主机通知延迟，不能当作 DMA 时长。异步区间分配到不交叉的行。逐 buffer 的 ready 查询、销毁、回调注册和额外通知延迟事件不再采集。

SGLang profiler 在 scheduler 进程中启停。脚本先预热完整请求流程、flush 缓存，再采集第二轮；不会在导出后压缩或删除时间空隙。

`correlation_id` 关联提交与完成，`sim_program_id` 关联执行程序。设置 `PJRT_SIM_TRACE` 可保留执行 JSONL 和每个程序的 bundle 报告，其中有 Final LLO 文件与去重映射路径。

```sh
python python/profile_report.py /path/to/xprof --output report.json --trace-output trace.json
```

累计 pending 区间可能重叠，不等于计算利用率。设备时间是部分、未校准的估算；停止时未完成的事件会标记 `incomplete`。每个 session 最多收集一百万个事件，并报告丢弃数。

连续 decode 可以提前排队，掩盖主机开销；请求结束或 batch 切换时队列可能耗尽。此时的 bubble 包含主机调度、输入准备和通知延迟，不能直接解释为真实 TPU 内部停顿。
