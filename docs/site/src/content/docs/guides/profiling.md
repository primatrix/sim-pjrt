---
title: XProf 性能分析
---

插件通过原生 `PJRT_Profiler_Extension` 输出 `*.xplane.pb`，无 Python 导出助手。

设置[后端环境](/getting-started/)，安装 `requirements/profiling-requirements.txt`，运行：

```sh
SIM_PYTHON=.venv/bin/python SIM_TP_SIZES=4 SIM_PROFILE=1 bash tests/run_libtpu_tests.sh
xprof server --logdir /path/to/run/tp4/xprof --port 8791
```

在 Trace Viewer 展开 `/device:TPU:0` 等设备行，使用与真实 TPU 相同的 XProf 轨道：

| 轨道 | 含义 |
| --- | --- |
| XLA Modules | 整个编译程序的模拟执行区间 |
| XLA Ops | Final LLO 对应的编译器操作调用，保留去重前名称 |
| XLA TraceMe | TLP 管理段、模拟启动、传输、通信标记和收尾等待 |
| Framework Name Scope | XProf 根据编译器 `tf_op` 元数据派生的框架作用域 |
| Framework Ops | XProf 根据同一元数据派生的框架操作 |
| Source code | XProf 根据编译器源码位置派生的源码轨道 |

框架和源码标签来自 libtpu 的 TLP HLO 调试信息，只用于标注，计时仍完全来自 Final LLO。缺失的标签不推测补齐，因此没有调试信息时对应派生轨道可能缺省。提交与完成事件写入标准 `/host:CPU` 下的 PJRT 线程，保留主机观察值。

同步 PJRT 调用使用实际线程 ID，与 JAX 的 `PjRtCApiLoadedExecutable::Execute` 嵌套在同一主机线程。`PJRT_LoadedExecutable_Execute` 内分别记录执行准备、CPU 输出提交、模拟执行入队和输出关联；子阶段继承父提交的 correlation ID 与 program ID。H2D 记录 buffer 准备及入队，D2H 记录入队，`PJRT_Event_Await` 记录实际等待 API 调用。异步 submit-to-ready 区间是诊断视图，不代表独占某个 CPU 线程。

真实 libtpu 的 `pjrt_tpu_execute` 是线程池名称；模拟器不创建同名假线程，也不伪造 allocator、semaphore 或驱动内部事件。主机阶段可以语义对应，但本机 CPU 观测时长不等于真实 TPU 主机开销预测。

模型区间与 host 共用时间基准，但 `simulated` 和 `cpu_wall` 不是同一种测量。长 H2D submit-to-ready 可能来自主机通知延迟，不能当作 DMA 时长。异步区间分配到不交叉的行。逐 buffer 的 ready 查询、销毁、回调注册和额外通知延迟事件不再采集。

SGLang profiler 在 scheduler 进程中启停。脚本先预热完整请求流程、flush 缓存，再采集第二轮；不会在导出后压缩或删除时间空隙。

`correlation_id` 关联提交与完成，`sim_program_id` 关联执行程序。设置 `PJRT_SIM_TRACE` 可保留执行 JSONL 和每个程序的 bundle 报告，其中有 Final LLO 文件与去重映射路径。

```sh
python python/profile_report.py /path/to/xprof --output report.json --trace-output trace.json
```

累计 pending 区间可能重叠，不等于计算利用率。设备时间是部分、未校准的估算；停止时未完成的事件会标记 `incomplete`。每个 session 最多收集一百万个事件，并报告丢弃数。

连续 decode 可以提前排队，掩盖主机开销；请求结束或 batch 切换时队列可能耗尽。此时的 bubble 包含主机调度、输入准备和通知延迟，不能直接解释为真实 TPU 内部停顿。

内部活动直接来自同一次 Final LLO 估时，使用相对于 executable 开始的时间偏移；不按总耗时平均切分。同一调用片段内的连续发射区间会合并，内部 DMA 仅保留在计时报告中，不单独显示轨道；显式 H2D/D2H/设备 copy 仍保留。等待、延迟和控制操作的耗时包含在 kernel 区间内，不再逐条导出；未解析成本通过 kernel 的 `cost_gap` 标注，完整原因仍保留在 bundle 报告。点击事件可查看 `detail` 中的模块、调用位置与 bundle 地址范围，以及 `bytes`、`cost_gap`。

`XLA Modules`、`XLA Ops` 与底层活动是同一执行的不同视图，区间可能包含或重叠，不能相加。嵌套调用会形成多个连续片段，尚未导出完整的父子调用树。

Fusion/copy 的名称来自编译器调用注释；collective、spill/reload 等若没有足够元数据，只在计时报告中保留底层 opcode 或 DMA，不推测高层操作类型。优化掉的操作不产生事件。多设备目前使用相同的程序活动模板，不能据此推断各设备独立的通信时序。

原生轨道导出通过 XProf 官方转换器验证，覆盖框架/源码派生轨道及主机提交到完成的关联。已有 `.xplane.pb` 不会改变；需要更新插件和 Python 计时模块并采集新的 profile 才能看到调整后的轨道。
