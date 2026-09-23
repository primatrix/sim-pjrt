# XProf 接入：十轮迭代

日期：2026-09-14。目标：不修改 SGLang-Jax，采集真实多设备 overlap 的运行信息，
为后续模拟时钟与性能模型提供可检查的事件和依赖。当前时间口径全部为 CPU wall time。

| 轮次 | 交付 | 验证 |
| --- | --- | --- |
| 1 | 线程安全的采集会话；停止时截断未完成事件；容量限制 | C++ 检查异步完成、迟到回调、会话重启和事件丢弃 |
| 2 | PJRT Profiler Extension，支持传统 collect 与 consume/serialize 接口 | JAX start_trace/stop_trace 生成 XSpace，并经 XProf 转换器读取 |
| 3 | H2D、跨设备复制、bitcast、buffer 释放与稳定 ID | 实际 device_put 与复制；检查 256 字节输入、设备和 handle ID |
| 4 | Execute host 提交与每设备完成区间分离 | 两设备连续八次异步 donation，检查每设备完成和关联 ID |
| 5 | D2H、外部引用、就绪查询、等待、回调注册与执行 | 实际异步 host 读取、block_until_ready 和 callback 记录 |
| 6 | SGLang 原生 profiler 请求集成 | 双设备 overlap 的模型完成事件和框架 forward 标注出现在同一 profile |
| 7 | 错误路径与跨会话并发加固 | 两线程异步失败、旧回调在新会话中完成、PJRT error 所有权测试 |
| 8 | 记录 Execute 与复制的输入输出 buffer 关系 | 验证每一步 donation 输出 ID 等于下一步输入 ID |
| 9 | XProf profile 分析报告与 JSON 导出 | 区间并集不重复计时、依赖关系、错误/截断统计；实际 profile 导出 |
| 10 | 自动化完整矩阵、连续采集、依赖固定和文档 | run_tests.sh 覆盖 TP=1/2/4/8、两次独立采集、XProf 转换和报告 |

最终回归全部通过：36 个框架请求、10 份经 XProf 转换验证的 profile，
执行错误和采集丢弃均为零。停止时尚未完成的区间保留 `incomplete` 标记。
原始结果：容器 `/tmp/pjrt-sim-results/run.ifx1Pc`；共享副本：
`/tmp/pjrt-sim-profiling-validation`。TP=8 的框架 profile 包含 30,878 个插件事件、
6,704 条 buffer 依赖边，模型有 248 个设备完成事件。

第 6 轮发现默认 Python tracing 产生超过 800 万条 host 事件，XProf Viewer 截断后
只显示开头的插件事件。原始 XSpace 保留完整插件记录；使用框架已有参数
`host_tracer_level=1, python_tracer_level=0` 后通过验证，没有修改或 monkeypatch 框架。

第 7 轮修正了 PJRT 错误转换函数的所有权使用：记录错误必须采用不释放对象的重载，
保留调用方和用户回调对 error 的所有权。针对这一点新增了实际 C API 回归测试。

这些迭代完成了运行观测闭环。大张量虚拟存储、虚拟完成时间、传输与通信成本、
host/device 联合模拟仍是后续工作，不能用当前 profile 推断真实 TPU 延迟。

## 2026-09-15：虚拟时钟与通信重放

新增确定性整数纳秒事件调度器、显式资源占用与阻塞关键链；通信按场景给定的
alpha、带宽和有向路由建模，支持逐跳传输、ring 各轮屏障和参与者晚到。
原始 HLO 在占位替换前保存为 JSON，执行记录增加唯一程序 ID、profiler 关联 ID
及 replica/partition 数。重放器利用 buffer 依赖关联真实框架提交。

范围明确的分片推导覆盖普通二维 TP dot：列切分使用局部工作，收缩维切分接
all-reduce。Pallas attention、未知重分片和控制流保留依赖并明确报告成本缺口。
静态调用按调用点展开。CPU wall time 与 simulated 时间线分别导出。

新增 11 个 Python 手算/集成检查，覆盖 host/device overlap、晚到参与者、
all-reduce/all-gather/reduce-scatter、共享路由争用、单参与者、图错误、未知分片、
局部 dot 成本、共享 callee、buffer 依赖和失效采集。C++ 检查快照保留原始 dot
及 FLOPs，未启用快照时不构造 JSON。Raw D2H 提交记录使用实际传输字节数。

完整 run_tests.sh 通过：C++ 三个测试目标、Python/runtime 检查、TP=1/2/4/8
的 36 个真实框架请求、10 份 XProf capture、TP=8 两种虚拟提交策略。
最终 TP=8 采集有 33,206 个插件事件，无执行错误和事件丢弃；停止时有 8 个
未完成 CPU 观察区间，重放报告保留该数量。

TP=8 重放结果：165 次 PJRT 执行，150,140 个虚拟事件，66 次推导 all-reduce；
132 次执行存在成本缺口。异步和串行提交的 partial_makespan_ns 分别为
9,625,535 和 9,979,625。两者是同一固定采集图在假设场景下的部分成本结果，
不代表真实 TPU 延迟或 SGLang overlap 加速比。

容器原始记录：`/tmp/pjrt-sim-virtual-regression/run.ddpUPQ`。
共享副本：`/tmp/pjrt-sim-virtual-validation`。
完整日志：`/tmp/pjrt-sim-virtual-regression.log`。

## 模拟时间直接导出 XProf

新增 `xprof_export.py`，从仓库官方 `xplane.proto` 的 Bazel 构建描述文件加载
Python protobuf 类，直接导出原生 `.xplane.pb`，无需 TensorFlow。重放默认增加
`xprof/plugins/profile/simulated/pjrt-simulator.xplane.pb`，报告记录相对路径。
每个事件只放在一个主轨道上，其他资源占用保留在 stats；轨道包括模拟 host、
8 个 TPU device、DMA、通信链路和依赖。时间来自虚拟调度，固定合成 epoch 与
CPU wall time 分离。未知成本保留零时长标记和文本 null，不伪造硬件计数器。

3 个新增测试通过，验证官方 XProf 转换路径、纳秒/皮秒单位、合成 epoch、
确定性序列化、元数据、异常时间和缺失 schema；另有 15 个重放/负载相关测试通过。
复用 TP=8 原始框架采集生成模拟 XSpace，经实际 XProf Trace Viewer 转换后逐事件
核对：150,140 个事件全部保留，ID、相对起止时间和 FLOPs 一致，16,944 个未知
成本事件标记保留。虚拟模型与框架运行时未因此改变。

共享样例：`/tmp/pjrt-sim-xprof-example/plugins/profile/simulated/pjrt-simulator.xplane.pb`。
验证记录：`/tmp/pjrt-sim-xprof-example.validation.json`。
使用 `xprof server --logdir /tmp/pjrt-sim-xprof-example`，选择 simulated 的 Trace Viewer。

## SGLang-Jax 原生 XProf 同时包含框架与模拟设备

按原生采集目标接入 PJRT Profiler CollectData/Consume：开启 native profile 后，
编译保留原始程序快照，执行将程序 ID 和快照关联到当前采集会话。收集阶段通过
无 shell 的参数化子进程和管道调用 `native_profile.py`，复用现有模型；返回的
XSpace 保留原始 PJRT host/pending planes，并加入模拟 device planes。JAX 最终
与 SGLang-Jax 的 host tracer 合并成框架原生 start/stop 产出的同一份文件。
不修改 SGLang-Jax、不依赖外部 PJRT_SIM_TRACE 文件，也不要求用户手动重放。

设备模拟以实际 host 提交时刻为 release time，显式标记
clock_alignment=observed_host_submissions。host 标注保持实测时间。框架依旧由
CPU 执行和实际完成事件驱动；这里提供针对观察到的提交序列的条件成本估计。
模型/采样/future-token 程序名出现在设备 Executions 行，HLO 保留 framework_op
来源路径。展示区间不额外增加模拟工作量。

新增 C++ 会话快照所有权/去重/停止后不可变/重启隔离测试；Python 检查原始 host
planes 字节不变、设备时间对齐以及缺失程序失败。完整回归通过：3 个 C++ 测试
目标、Python 模型与 XProf 测试、TP=1/2/4/8 的 36 个框架请求和连续采集。
4 个框架 case 均要求同一份文件中有模型模拟区间；overlap case 同时要求原生
forward_batch_generation，且要求 HLO FlashAttention 来源标注存在。

最终 TP=8 文件包含 142,083 个模拟事件和 256 个模型设备区间（32 次 × 8 设备）。
原始采集：容器 `/tmp/pjrt-sim-native-regression/run.bIHL77/tp8/profile`。
共享的原生文件：`/tmp/pjrt-sim-sglang-native-profile/plugins/profile/2026_09_15_04_11_47/282a0f599647.xplane.pb`。
完整日志：`/tmp/pjrt-sim-native-regression.log`。


## Online runtime completion and native profiling (2026-09-15)

The C++ runtime now gates public PJRT completion, independently of profiling.
Compilation builds an original-HLO plan; submissions reserve compute/HBM and
synthetic communication resources, bind buffer producers and schedule steady
clock deadlines. CPU functional work remains responsible for control data;
readiness joins modeled and CPU completion. Copies, D2H, direct references,
donation chains, per-client teardown and reentrant completion callbacks are
covered. Unsupported import/allocation paths fail explicitly.

Native profiler collection now only serializes runtime records. Removed the
collection subprocess and its in-memory program snapshot store. The original
Python model remains available for offline replay. Simulated intervals carry
`runtime_realtime` alignment; CPU readiness observation and callback notification
lag are separate measured tracks. Unknown HLO costs are marked explicitly, with
null numeric estimates. Stop clips pending reservations and omits future work.

Validation:

- Five C++ test targets pass, including deadline scheduling, dependencies,
  communication, callback reentry, cancellation and profile clipping.
- JAX without profiling: delayed H2D, asynchronous output readiness, donated
  execution chains and host reads respect modeled completion.
- Without profiling, a 10x compute multiplier changed warmed JAX completion
  from 21.8 ms to 213.7 ms. A 10x communication multiplier changed a two-device
  collective from 20.3 ms to 200.3 ms; the other operation stayed near baseline.
- Full runner `/tmp/pjrt-sim-online-regression/run.nBZaOz`: 36 SGLang-Jax
  requests across TP 1/2/4/8, overlap on TP 2/4/8, all passed; ten native captures
  and both existing offline replay policies also passed.
- Two additional TP-2 overlap runs without profiling: 11 requests each passed.
  With compute scale 10000 and communication scale 1000, the second cached
  request changed from 13.7 ms to 257.6 ms. This verifies runtime influence on
  framework waiting; these are not calibrated TPU latency measurements.

Remaining limits: real-time advancement and CPU functional overhead, conservative
program-wide input barriers/FIFO reservations, one replica, synthetic ring without
collective reduction arithmetic/HBM contention, and explicit Pallas/control-flow/
resharding cost gaps. No SGLang-Jax source changes.

Final TP-8 capture after profiler metadata cleanup: 11 requests passed,
159192 simulated events and 248 model execution scopes. Raw XSpace retains
`program_id`; `sim_program_id` exposes it in Trace Viewer. The verified native
file is `/tmp/pjrt-sim-sglang-online-profile/plugins/profile/2026_09_15_06_06_43/282a0f599647.xplane.pb` (35.40 MiB) in the shared workspace.

## Declared Pallas costs (2026-09-15)

The online plan and offline replay now consume the existing
`custom_call_config.cost_estimate` contract. JAX FlashAttention supplies FLOPs,
transcendentals and bytes accessed. A three-component roofline feeds existing
compute/HBM reservations and completion gates. Profiles and load reports keep
kernel counts separate from ordinary dots; execution traces expose per-device
kernel totals. No numerical semantics changed. Missing estimates, unsupported
scope and internal communication remain explicit gaps.

Validation used a fresh local Bazel build and an isolated Python 3.13 environment
at `/tmp/pjrt-sim-validation`, with JAX/jaxlib 0.11.1 and XProf 2.23.1. The old
`xla` container and pinned SGLang source directory were absent on this machine.

- Five C++ targets (28 cases) pass, covering costs, scope, call multiplicity,
  invalid metadata, completion, profiler fields and existing runtime contracts.
- 29 Python lowering/replay/report/export tests pass; dependency checks pass.
- JAX online readiness, sensitivity, smoke and native Pallas/FlashAttention
  tests pass. Multi-device runtime tests pass for 2, 4 and 8 devices.
- With compute scale 100000, lowering transcendental throughput from 1e12 to
  1e11 changed Pallas completion from 20.19 ms to 200.20 ms; ordinary dot and
  communication remained near 21.6 ms and 20.3 ms. These are gate-sensitivity
  checks, not TPU measurements.
- A real FlashAttention invocation produced matching online/replay intervals
  (72 ns under the default hypothetical rates), 16,842,752 kernel FLOPs,
  32,768 transcendentals and 262,144 bytes. Exact counts were checked in raw
  XSpace as well as execution JSONL; Trace Viewer rounds displayed doubles.
  Artifacts are in `/tmp/pjrt-sim-attention-native`.

The full SGLang request matrix was not rerun. Virtual-time-driven serving,
paged/ragged attention without declared costs, communication/memory extensions
and TPU calibration remain unfinished; see `PERFORMANCE_PLAN.md`. No Falcon
experiment was submitted; hardware/cluster or an existing experiment ID is
still needed for calibration.

## Virtual storage for large tensors (2026-09-16)

`PJRT_SIM_MAX_MATERIALIZED_BYTES` enables a per-array storage threshold. Large
static floating arrays retain logical metadata over scalar CPU buffers. A small
HLO transformation changes the physical signatures and replaces affected floating
operations, while the original execution plan still supplies costs. CPU PJRT
continues to own asynchronous execution, donation and buffer lifetimes. Logical
layouts and buffer sizes are exposed through wrappers; virtual host reads and
pointer exports fail explicitly. Configuration is captured per client.

The first version supports single-partition executables, integer-controlled
calls/loops/branches, cache updates and local device copies. Large nonfloating
arrays, dynamic shapes, nested result tuples and tuple parameters are rejected.
Float-to-control conversion is conservatively rejected, including small float
comparisons and sampling. This avoids requiring a new interpreter or propagating
value validity across executable boundaries. Default storage is unchanged.

Validation on the local Python 3.13 / JAX 0.11.1 environment:

- Six C++ test targets pass, including new HLO verification for a large loop-carried
  tensor, small slices and rejected integer/control boundaries.
- Four virtual-storage JAX tests pass. Four logical 32 GiB weights plus a 512 MiB
  cache increase peak RSS by 65 MiB. Two donated decode calls execute dense
  projections and cache updates; integer loop state advances from 7 to 10 to 13.
- Virtual H2D, local device copies, modeled asynchronous readiness, logical live
  memory accounting, and rejected host reads/pointer access pass. Reading a
  logical 32 GiB weight fails without increasing RSS by that size.
- Native FlashAttention lowering on virtual inputs and an aliased, donated Pallas
  output pass. FlashAttention still reports 137,975,824,384 declared FLOPs and
  134,217,728 accessed bytes in the execution trace, not scalar-buffer costs.
- Default-mode readiness, cost sensitivity, smoke and Pallas tests pass, along
  with multi-device regression for 2, 4 and 8 devices.

This validates large logical model state and a decode computation, not a full
large-model serving framework. Weight loading may allocate host data before PJRT.
Virtual tensor-parallel serving, sampling policy, virtual-time request scheduling,
physical HBM capacity/alias accounting and real TPU calibration remain unfinished.

## Virtual tensor parallelism (2026-09-16)

Virtual storage now supports one-host, one-replica SPMD execution. The plugin
runs XLA's Shardy/sharding propagation and SPMD partitioner before estimating
costs and replacing storage. Public executable metadata retains global shardings;
individual buffers expose local logical shapes and sizes. CPU compilation skips
the already-completed partitioning passes, while retaining normal optimization,
code generation and integer collective execution. The storage threshold applies
to each device shard, including transitions between materialized and virtual
storage during compiled resharding.

Online plans use local shapes and explicit inserted collectives. All-to-all and
collective-permute now reserve directed logical links with group barriers;
existing all-reduce/all-gather/reduce-scatter retain the synthetic ring. Compact
XLA collective groups are normalized in snapshots for offline replay. The new
`per_partition` scope prevents dividing already-local dot or traffic counts by TP
again. Subgroups and physical topology/HBM contention remain coverage limits.

Validation:

- Six C++ targets pass, including local-dot/explicit-all-reduce accounting,
  all-to-all/permute payload sizes and directed-transfer completion on reordered
  physical devices. The 31 Python replay/cost/report tests pass.
- Five new virtual TP tests pass for each of 2, 4 and 8 devices: 128 GiB dense
  weights plus a 512 MiB cache, three donated decode steps, column/row/replicated
  resharding, storage threshold crossings, reordered meshes with mixed integer
  collectives, and native Pallas FlashAttention in shard_map.
- Peak RSS growth for the large TP state/decode test: 75.0 MiB (TP 2), 73.0 MiB
  (TP 4), 74.1 MiB (TP 8). These are host storage observations, not TPU timings.
- Local decode FLOPs are 68,719,476,736 / 34,359,738,368 / 17,179,869,184 for
  TP 2/4/8. Online and replay report zero cost gaps for that test. FlashAttention
  retains 137,975,824,384 declared FLOPs per device for its fixed local shape.
  Captures are `/tmp/pjrt-sim-virtual-tp{2,4,8}.*`.
- Existing integer/multi-device tests pass in virtual and default modes at
  TP 2/4/8. Single-partition virtual storage, online readiness, sensitivity,
  ordinary smoke and native Pallas regressions also pass.

Some JAX `device_put` repartitioning paths require a host read and therefore
cannot move virtual arrays. Compiled identity functions with explicit input and
output shardings perform device-side resharding; the README includes an example.
No JAX/framework source patch was introduced. Full large-model serving and token
sampling remain unvalidated/unsupported respectively; the clock is still real
time, and no TPU calibration was performed.
