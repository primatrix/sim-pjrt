# SGLang-Jax / TPU v7x 性能模拟器设计草案

状态：已实现单主机多设备、小模型与 overlap 运行基线；完整性能模拟仍按下述目标扩展。更新日期：2026-09-15。

实现与运行说明见 [sim/README.md](../docs/plugin-guide.md)。当前复用 CPU 运行时，
已验证真实 SGLang-Jax 请求与多设备 overlap；现已增加离线事件重放、显式链路通信成本和有限的逐分片工作量推导。
大张量虚拟存储、完整成本覆盖和驱动框架调度的在线虚拟时钟尚未实现。

## 已确定的需求

- 接入框架：SGLang-Jax。
- 目标硬件：TPU v7x（TPU7x / Ironwood）。
- 目标用途：推理框架性能建模。
- 核心验收标准：没有真实 TPU 时也能启动 SGLang-Jax 并走通推理请求。
  至少支持多设备张量并行下的原生 overlap 调度。
  离线分析是辅助工具，不能替代框架运行闭环。
- 用户已确认：不需要数值正确；允许模拟 token，但框架控制流程必须有效。
- 当前没有真实 TPU profiling 数据；暂不承诺绝对延迟预测误差。
- 已更新的本地框架目录：`/home/yanko/lab/sglang-jax`，main 提交为
  `7ebbbef498b9e484fdc5902986578a3504734e46`。
- 测试使用该提交的干净源文件快照、Python 3.12、JAX/jaxlib 0.11.1、Flax 0.12.9。
  当前插件在 XLA `4426f247713c9f46bad35775cc032265d5795f04` 基础上开发。

## 目标架构

`SGLang-Jax → JAX → PJRT 适配层 → 工作负载表示 → 成本模型 → 事件调度器`

工作负载表示记录算子或 kernel、shape、dtype、分片、依赖、buffer 生命周期，
以及 attention 的实际序列长度、分页和分块信息。支持离线输入，以便独立验证模拟核心。
普通 HLO 可复用 `xla/service/hlo_cost_analysis.h` 提取基础工作量，
但其中的逻辑字节量不能直接视为真实 HBM 流量。

本地 SGLang-Jax 的 flashattention backend 调用 ragged paged attention v3。
该 kernel 使用 TPU Pallas，需要单独验证 lowering 和元数据提取路径。
为已识别 kernel 提供专用成本模型；未知 custom call 必须报告不支持，
不能默认为零耗时。CPU 编译结果不能被视为 TPU 的融合和调度结果。

PJRT 接口实现与 TPU lowering 兼容性是两个独立问题。
仓库的 `example_plugin` 仅提供接口骨架，目前报告零设备，不是可运行的后端。
必须先验证 JAX 能否对模拟平台完成 tracing/lowering，尤其是 Pallas 路径。

## v7x 参数与口径

公开规格：[Google Cloud TPU7x](https://docs.cloud.google.com/tpu/docs/tpu7x)。

| 参数 | 公开值 / 建模规则 |
| --- | --- |
| JAX device | 每颗物理芯片暴露两个 chiplet device，分别拥有独立内存 |
| HBM 容量 | 规格表为每芯片 192 GiB；每 device 96 GiB |
| BF16 峰值 | 每芯片 2307 TFLOP/s |
| FP8 峰值 | 每芯片 4614 TFLOP/s |
| HBM 带宽 | 每芯片 7380 GB/s，GB 使用十进制 |
| ICI | 每芯片双向总带宽 1200 GB/s，不能直接当作单链路单向带宽 |
| 单主机配置 | 4 颗芯片、8 个 JAX devices |

容量使用规格表 GiB 口径；官方正文亦有 GB 表述，配置中保留来源和单位。
若初版将每芯片计算/HBM 带宽均分给两个 device，标记为建模假设。
拓扑显式记录 host、chip、chiplet，区分 D2D、ICI 和跨主机 DCN；
不从 `v7x-N` 名称推断设备数量。

## 时间与数值语义

目标中的大模型性能模式采用虚拟时钟、虚拟大张量和可控的 token 输出，
保留调度所需的长度、索引、请求完成状态等实际值。此模式用于预设工作负载，
不保证生成文本正确，也不自动覆盖内容相关的提前终止、MoE 路由或推测解码。
这些机制需要显式的路由/接受率轨迹或数值执行。

小规模数值执行作为独立验证路径，支持范围需逐项确认。
模拟器不通过 sleep 表示 TPU 耗时。设备完成事件、host 调度和请求到达
必须在统一时间模型中推进；CPU 上实际执行框架的墙钟时间不是模拟 TPU 延迟。

初始成本模型用峰值给出计算与访存的理想时间，再显式加入利用率、启动开销、
分块及数据复用假设。仅在相应重叠假设成立时采用两者的最大值。
事件调度器根据依赖与共享资源决定重叠，避免逐算子时间直接相加。
未知利用率做参数敏感性扫描，输出情景范围，不称作统计置信区间。

## 实施顺序与验收

1. **接入验证**：固定本地依赖版本，验证最小 JAX matmul 的设备发现、
   lowering、编译输入获取；检查一个真实 attention Pallas 调用。
   记录需要适配的 TPU 平台判断和 custom call，明确原生支持与替换路径。
2. **无 TPU 框架闭环（首要里程碑）**：先用小型 dense Transformer，
   在没有 TPU 的机器上完成 SGLang-Jax 启动、设备发现、模型初始化、
   prefill、decode、KV cache 生命周期和请求返回。
   必须打通 buffer、编译、执行、结果回传和同步语义，处理实际遇到的
   Pallas kernel 与 TPU 平台判断。采用虚拟输出模式；
   不能用离线输入跑通或仅枚举虚拟设备代替此验收。
3. **接入性能模拟核心**：设备配置、工作负载表示、matmul/HBM 成本、
   事件调度、JSON 报告。以离线用例辅助验证单位换算、依赖顺序、
   资源争用及不支持操作的处理，再接入实际框架执行路径。
   从单 chiplet 单元场景扩展到完整芯片两个 devices。
   数值正确性验证与性能预测分别报告。
4. **单主机并行**：4 芯片 / 8 devices，添加 collective 和链路争用模型，
   扫描 batch、上下文长度、TP 配置，输出 TTFT、逐 token 延迟和吞吐量。
   多主机、MoE、FP8 的详细建模在此后扩展。

每份报告记录支持覆盖率、公开参数、推导参数、假设参数及模型版本。
在获得实机数据前，验收关注接入、内部一致性和可解释性；预测准确率待校准。

## 尚待确定

- 第一个目标模型及精度。
- 首个部署拓扑；建议从单主机 4 芯片 / 8 devices 开始。

## 当前实现与验证

- `src/` 提供 PJRT 动态库、HLO 转换和执行记录；`python/` 提供参数化报告。
- 通过 TPU 平台注册进入 JAX 原生 Pallas lowering；C API 适配层复用 CPU 运行时，
  保存真实控制数据和小模型张量，替换浮点 dot 与已识别 Pallas kernel 的数值计算。
- 占位规则：dot 和非别名 Pallas 输出为零，别名 Pallas 输出保留输入内容。
  未知 custom call 和外部副作用明确返回错误。
- 已验证设备发现、H2D/D2H、JIT matmul、整数控制运算、donation、Pallas lowering，
  以及未修改 SGLang-Jax 的小型 Llama dummy 请求，完成 prefill 和多轮 decode。
- `PJRT_SIM_DEVICE_COUNT` 配置单主机设备数；TP=2/4/8 开启原生 overlap，
  验证不同输出长度的并发请求、future-token 映射、缓存复用及清空后继续生成。
  每设备独立统计逻辑 buffer 字节；集合通信和异步执行复用 CPU PJRT 的实现。
  拓扑为满足 JAX mesh 的合成条带，尚未建模真实 v7x 链路。
- 执行 trace 记录转换前的逻辑工作量，报告输出 v7x 假设下的已建模分量时间。
  Pallas 内部成本、动态循环次数、融合/真实 HBM 流量、host 调度等尚未建模；
  报告明确标记不完整，不能将其总和或框架 CPU 墙钟时间视为真实 TPU 请求延迟。
  多设备执行仅记录工作量和设备数，时长为 null；分片前 HLO 混合全局与局部 shape，
  不能直接除以设备数得到并行性能预测。
- PJRT Profiler Extension 已接入 JAX 原生采集生命周期，输出标准 XSpace。
  XProf Trace Viewer 可显示 host 提交、传输、各设备异步完成、等待和回调。
  稳定 buffer ID 串联输入输出及 donation 依赖；现阶段所有事件均为 CPU 观测时间，
  尚未接入模拟时钟。SGLang 的原生 profiler 请求用于采集 scheduler 子进程。

本轮十次迭代的改动和验证记录见 [迭代记录](iterations.md)。

后续按目标架构扩展虚拟存储、kernel 成本模型、统一虚拟时钟和多设备通信成本。

## 2026-09-15：虚拟重放第一阶段

原始 HLO 在数值替换前保存为程序快照，PJRT 执行用 program_id 和
correlation_id 关联 XProf 采集。Python 重放器按 buffer 依赖、host 线程顺序和
设备队列构造事件图；虚拟时钟使用整数纳秒，显式占用 compute、HBM、DMA 和链路。
CPU 时间戳仅用于恢复提交顺序，不作为模拟耗时。

支持普通二维 TP matmul 的局部工作推导：列切分直接计局部计算，完整收缩维切分
增加 ring all-reduce。通信引擎还支持 all-gather/reduce-scatter 场景、参与者晚到、
多跳路由及链路争用。当前只将推导出的 dot all-reduce 接入 HLO，直接 HLO
collective 和一般重分片仍是覆盖缺口。配置中的链路速率和延迟均为假设场景。

输出独立 simulated 时钟域的 Trace Event JSON、原生 XProf XSpace、资源占用和阻塞关键链。
Pallas attention、动态控制流、完整 host 队列因果关系尚未计时；未知成本保留
依赖但按零处理，并逐项列出，因此 partial_makespan_ns 不能作为请求延迟预测。
serial-dispatch 仅在同一采集图中添加提交屏障，不等价于两次框架 overlap 开关实验。
下一阶段需补齐 kernel 成本和 host 因果关系，再让虚拟完成事件驱动真实框架调度。

模拟 XSpace 使用仓库官方 xplane.proto 的构建生成描述文件，经 Python protobuf
序列化；无需 TensorFlow。轨道分组为模拟 host、各设备、DMA、通信链路和依赖。
使用固定合成 epoch，所有事件偏移和耗时来自虚拟时钟。XProf Trace Viewer 可直接
查看，尚不提供依赖硬件计数器或额外编译信息的 TPU 专用分析页。

## 2026-09-15：在线完成通知与原生采集

原生 profiler 不再调用 Python helper。编译时由 C++ execution_plan.cc 在数值替换
之前生成可复用的 HLO 计划；runtime.cc 在运行时绑定设备、buffer 生产依赖和资源，
用单调时钟按真实时间推进 deadline。后台 timer 线程将完成通知交给独立 executor，
避免用户回调在调度器锁内或 timer 线程中执行。

不开 profiler 时这些行为仍然生效。Execute、buffer ready、H2D、copy 和 D2H
通过模拟完成 Future 控制对外可见性；CPU 功能执行仍保证控制值可用，输出就绪必须
同时满足模型和 CPU 数据要求。直接 Host 内存访问也等待就绪。源 Host buffer 的
释放仍遵循实际内存生命周期，不绑定到模型传输结束。尚未接入的导入/异步分配接口
显式拒绝，普通 executable donation 仍由 CPU 后端管理并传递模拟生产依赖。

支持均匀 identity sharding、静态 call、普通二维 dot、部分访存操作、TP dot 推导
all-reduce，以及完整 partition group 的显式 all-reduce/all-gather/reduce-scatter。
通信采用假设的有向 ring，记录参与者到达和链路争用；未模拟 collective 的归约算术
和 HBM 争用。程序内按拓扑顺序保守预留资源，程序间每设备 FIFO；不是 TPU 指令调度。

SGLang-Jax 原生 start/stop profile 的同一文件包含框架 Host 标注、PJRT 观测、
运行时模拟设备计划和单独的 CPU 就绪观测/通知延迟轨道。设备区间标记
clock_domain=simulated、clock_alignment=runtime_realtime；停止采集时裁剪未完成
区间、忽略尚未开始的工作，收集阶段仅序列化。区间是运行时预留的模型时间，
不是硬件实测。原先 helper 文件保留为离线转换工具，插件不再使用它。

Pallas attention、动态控制流和一般重分片仍有成本缺口。CPU 执行可在内部提前运行，
框架线程和定时器仍用真实时间；当前是在线实时模拟，不是全局加速的离散事件模拟。
CPU/调度/采集开销仍会影响请求延迟，不能声称已经校准为 v7x 的端到端性能。
