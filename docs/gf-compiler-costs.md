# GF 编译器成本表与资源约束

本轮从本地 **libtpu 0.0.48 二进制**提取了 GF 成本表，并接入显式流水线模拟入口。它提供可复查的编译器参数，**不代表三个 attention kernel 已通过硬件精度验收**。

## 成本表是什么

编译器使用成本表决定指令间隔。两个主要维度分别是结果延迟与资源约束：一条计算可能很久以后才产生结果，但下一条独立计算可以更早进入同一流水线。

当前提取的是 `GfcCycleTable` 所拥有的性能表，不是完整硬件模型，也不是一个实测 profile。

| 数据 | 本次提取结果 |
|---|---|
| 内部性能指令类别 | 465 行，全部有显式延迟赋值 |
| 资源索引空间 | 32 列 |
| 显式资源表赋值 | 303 个，分布在 110 行；包含值为零的赋值 |
| 表格入口 | `GfcCycleTable` 构造函数 `0x193450f0` |
| 性能表构造函数 | 从上述调用链确认：`0x1937a450` |
| libtpu GNU Build ID | `3310a7c8c137cd515c7a2ba1ce2ea38c` |
| 二进制 SHA256 | `13fe4b883a085db3bce929eea75d0c93dab8ad245694e2d4598826765dbdb951` |

[提取表格](../configs/gf_costs_libtpu_0_0_48.json)、[提取脚本](../benchmarks/pipeline_validation/extract_gf_costs.py)、[每个赋值的反汇编地址](../benchmarks/pipeline_validation/results/reverse/gf-store-addresses.json)、[构造函数反汇编](../benchmarks/pipeline_validation/results/reverse/gf-constructor.asm)。

提取脚本不加载、不执行 libtpu，只使用 SHA256 与 objdump 静态读取。它检查构造函数分配尺寸、465 个延迟赋值、303 个资源赋值及索引范围。二进制不同即拒绝继续，不能只看 wheel 版本号复用地址。

## 这轮排除的几个错误解释

1. **旧版本资源列数不能照搬。** 旧逆向记录是 31 列，本地构造函数分配的是 `0x80` 字节，即 32 个 int32。
2. **性能表行号不是原始 LLO opcode。** 本地原始 opcode 297 的名称是 `kVectorPow2F32` / `vpow2.f32`，但性能表同号行是 211-cycle 表项。直接按同号索引会错配。Ghostlite 分类函数本身也有显式的 opcode→内部类别转换，不能将它未经核实地用作 GF 自动分类器。
3. **资源表不是一个统一的占用集合。** 前一条指令留下的资源约束与后一条发射时检查的集合必须分开。将所有非零表项当作相同的互斥端口，会过度串行化。
4. **不能把 memset 的字节值当成 int32。** `memset(..., 0xff, ...)` 的 int32 结果是 `0xffffffff`，不是 255；本次确认 465 个延迟最终都被显式赋值，不依赖这个初始值。

[编号审计记录](../benchmarks/pipeline_validation/results/reverse/id-namespace-audit.json) 单独标明 Ghostlite 分类结果仅用于审计，未绑定到 GF 模型。

## 新增模拟能力

`pipeline.Operation` 现在除了独占区间 `reservations`、数据依赖 `depends_on`，还有两组不同的结构约束：

- `resource_holds`：本条发射后，对哪些资源建立多长的等待期限。
- `issue_checks`：本条发射前，需要检查哪些资源的等待期限。

时序按最大值合并，不逐项求和：

```text
start(B) = max(bundle cursor, producer result readiness,
               hold_ready[r] for r in B.issue_checks,
               exclusive reservation constraints)
hold_ready[r] = max(old hold_ready[r], start(B) + B.resource_holds[r])
```

数据依赖与资源约束可以重叠；不同资源命名空间独立。结构 hold 不会自动加入自己的 issue-check 集合。最后仍按显式模型排空在途操作与资源，因此完成尾部也是模型假设，不能直接当硬件 kernel 结束时间。

例如当前表中性能 ID 295 的延迟为 211，资源值为 `{4:20, 5:8, 6:13, 7:7}`。
如果明确指定下一条只检查资源 5，它等待的是 8 cycles，而不是最大表项 20，更不是把四个值加起来。这是结构约束示例，**没有据此声称真实指令的 footprint 就是 `[5]`**。

`compiler_costs.CompilerCosts` 提供表格到 `Operation` 的绑定。调用者必须提供：

- 与表格匹配的编译器二进制 SHA256；
- **内部性能表 ID**，不能传入 mnemonic 让程序猜；
- 明确的 consumer issue footprint；
- 资源命名空间，例如相互独立的两个单元；
- 分类与 footprint 的来源说明。

CLI 使用编译器表后仍报告 `partial`，保留 `estimated_seconds=null`。当前 API 已可执行明确指定的约束，但完整的 GF ISA 分类、footprint 分派与真实 kernel 动态路径仍待补齐。表格数据已加入 wheel 打包清单；原生默认估时入口现已使用该执行模型。

## 复现与验证

```bash
.venv/bin/python benchmarks/pipeline_validation/extract_gf_costs.py \
  .venv/lib/python3.12/site-packages/libtpu/libtpu.so \
  configs/gf_costs_libtpu_0_0_48.json \
  --evidence-dir benchmarks/pipeline_validation/results/reverse

PYTHONPATH=python .venv/bin/python -m sim_pjrt.llo.pipeline \
  benchmarks/pipeline_validation/compiler-cost-example.json \
  --compiler-costs configs/gf_costs_libtpu_0_0_48.json \
  --report /tmp/gf-report.json --trace /tmp/gf-trace.json
```

[示例报告](../benchmarks/pipeline_validation/results/compiler-cost-example-report.json) 的四个 bundle 在 `[0, 1, 8, 211]` cycles 发射，模型结束于 219 cycles；独立单元重叠、8-cycle 结构约束与 211-cycle 数据依赖分别生效。示例的 footprint 和资源范围是人为指定的测试输入，不是 attention kernel 的硬件验证。

本轮新增 10 项测试，包括二进制错配、指令编号误用、遗漏 footprint、资源集合不对称、多个约束取最大值、历史长占用不被后续短占用覆盖，以及与逐历史指令枚举算法对照。加上此前 12 项流水线/导入测试、21 项 bundle timing 和 16 项 profile 导入，当前工作区共 59 项 Python 检查通过；3 个相关 Bazel 目标通过。

## 资料定位

[GF 性能表逆向笔记](https://gh.evko.io/crucible-notes/libtpu/cost/performance-gf-ghperf.html) 用于定位构造函数及数组布局；[MXU 结构等待递推](https://gh.evko.io/crucible-notes/libtpu/cost/mxu-opholdissues-stall.html) 提供“生产者资源值 + 消费者检查集合”的分析线索。这些资料面向旧 libtpu，作者明确标记为非保证的逆向记录；本轮表格数值取自当前二进制，不直接复制网页标签或跨代参数。

后续本地执行模型进展见下节。此前被拒绝的远端导出没有重试。

## GF 指令映射与动态执行模型（后续实现）

执行模型现已直接接受 Final LLO，不再要求逐条手写依赖或性能 ID：

- [GF 映射数据](../configs/gf_mapping_libtpu_0_0_48.json) 包含同一 0.0.48 二进制提取的 **274 组直接映射**。真正的 GF 分类函数位于 `0x19360660`；其调用者的性能对象由 `0x1935f8a0` 构造函数创建，调用的是已提取的 `0x1937a450` 成本表构造函数。不能根据 objdump 最近的符号标签判断归属。
- [提取器](../benchmarks/pipeline_validation/extract_gf_mapping.py) 解析 ELF 重定位字符串、274 对 uint16，以及资源分派跳转表。原始指令 297 `vpow2.f32` 映射 GF 性能 ID **264**，334 `vpop.eup` 映射 **416**，338 `vpop` 映射 **418**。
- 对已核对的全局资源以及显式同单元资源，按两条指令非零资源项的交集计算等待。其余专用分派单独报告缺口，不能泛化成全部资源相互排斥。
- [执行模型](../python/sim_pjrt/llo/execution.py) 接入已有标量解释器，处理可解析分支、延迟槽和循环；选定 phi 前驱，按动态访问版本化寄存器 RAW/WAW 依赖，并保留同 bundle 读取旧状态的语义。物理寄存器复用也有保守的 WAW 约束。
- BF16 matmul/pop 追踪每台 MXU 的 MRB 生产、消费和释放；EUP pop 可跟踪隐式 FIFO 生产者。内存/同步访问目前采用保守顺序依赖，尚未建模实际 DMA 服务时间和 bank 冲突。

标量比较的多个分类分支成本完全相同，因此报告记录候选 ID 集合，而不伪造已经识别出唯一 ID。matmul 的格式索引表来自当前二进制；格式名称与发射间隔沿用 `mxu.py` 中此前 0.0.46.1 的核对结果，在报告中保留跨版本假设。BF16 MRB 宽度默认 **4 槽**，可通过 `--bf16-result-slots` 修改，并明确标为待核验假设。

未知指令保留操作和依赖，以 **1-cycle 未知成本占位**生成部分模型报告；不是完整延迟预测，也不是严格上界或下界。无法决定的分支/谓词和未展开的循环摘要拒绝执行。保守 WAW、内存排序可能高估，遗漏运行时成本可能低估。

### 复现动态执行

```bash
.venv/bin/python benchmarks/pipeline_validation/extract_gf_mapping.py \
  .venv/lib/python3.12/site-packages/libtpu/libtpu.so \
  configs/gf_mapping_libtpu_0_0_48.json \
  --evidence-dir benchmarks/pipeline_validation/results/reverse

PYTHONPATH=python .venv/bin/python -m sim_pjrt.llo.execution \
  benchmarks/pipeline_validation/execution-example.llo \
  --costs configs/gf_costs_libtpu_0_0_48.json \
  --mapping configs/gf_mapping_libtpu_0_0_48.json \
  --binary-sha256 13fe4b883a085db3bce929eea75d0c93dab8ad245694e2d4598826765dbdb951 \
  --frequency-hz 2200000000 --branch-delay-slots 0 \
  --live-in %input0 --live-in %input1 \
  --report /tmp/gf-execution.json --trace /tmp/gf-execution-trace.json
```

[执行示例报告](../benchmarks/pipeline_validation/results/execution-example-report.json) / [Chrome trace](../benchmarks/pipeline_validation/results/execution-example-trace.json)：两轮循环、双 MXU 共 **24 次 bundle 访问，33 次有效操作全部关联成本，部分模型为 448 cycles**。这是构造的回归示例，不是 attention 的实测对齐结果；仍为 `partial`、`estimated_seconds=null`。

[本地历史 GEMM 静态覆盖审计](../benchmarks/pipeline_validation/results/historical-gemm-mapping.json)：303 个 bundle、919 条指令，其中 **835 条（90.9%）**关联成本。余下包括 32 条 pack、32 条 matpush 和 20 条伪指令/选择操作。审计通过 `lab capped` 执行，源文件 SHA 在报告中；历史产物的编译器身份尚未建立，不能把它当作当前 attention profile 的匹配 LLO，也不能把静态覆盖率当作动态时间精度。

初版 17 项执行模型测试覆盖命名空间、歧义拒绝、RAW 与并行、循环 phi、分支延迟槽、假谓词、物理寄存器复用、访存、MRB 消费/释放/覆写、EUP FIFO 等。相关 Python 回归共 105 项通过；5 个相关 Bazel 目标通过。两个 JSON 数据文件都随 Python 包打包。

尚待实现的工作是剩余指令的专用分类与资源规则、权重装载/转置等隐式状态、内存服务及硬件校准。它们是执行模型的实现任务，不应笼统称为需要用户补充的信息。

## 文档复查后的 pack、matpush 与 DMA 补充

此前这些项目是尚未接入的实现，不是资料不存在。本轮参考 [GF MXU 逆向记录](https://gh.evko.io/crucible-notes/libtpu/cost/mxu-latency-gf.html) 定位专用分派，再读取本地 0.0.48 的函数、跳转表和立即数。网页针对旧版本，dtype 标签也有已知差异；项目 JSON 中新增值来自当前二进制。

- **`vpack.c.bf16`**：当前 `VpackCBf16` 的实际构建分支在 `0x199b2de0`，`0x199b2e1a` 传入原始 opcode `0x126=294`。GF 直接表映射到性能 ID 136，延迟 2 cycles。裸 `vpack` 仍有歧义，不能不看格式就选这个 ID。
- **BF16 非转置 matpush**：`GainLatchModeString` 的跳转表证实模式 11 为 `NoXposePackedBf16`，GF 分类表给出未 masked ID 326。当前表的 8-cycle 延迟，经 `0x19360000` 的非转置规则 `ceil(latency/2)` 得到 **4 cycles**。MXU 构造函数 `0x19361701/0x19361705` 设置资源 8 为 **4-cycle 发射间隔**。已支持 `vmatpush[1–3].bf16.msr[a|b].mxu[0|1]` 这些明确形式；未知修饰符仍拒绝猜测。其余 staging/latch 资源分派继续列为缺口。
- **DMA 服务成本接入**：执行 CLI 增加 `--memory-profile configs/tpu7x.json`，复用现有近似参数，按已解析传输粒度、事务对齐、配置带宽和启动延迟计算服务时间；有 VMEM 带宽时同时考虑该接口限制。零/负/非有限速率拒绝；未知方向或大小单独报告。

[访存成本逆向资料](https://gh.evko.io/crucible-notes/libtpu/cost/memory-bandwidth-latency-model.html) 描述的是编译器的资源成本归约：startup lane 和 bandwidth lane 各自累计/归约。这个规则不能直接充当每条运行时 DMA 的完成时刻。本实现沿用项目已有的近似服务模型 `startup + ceil(bytes/rate)`，保留配置来源与未校准标记。[JAX TPU pipelining 文档](https://docs.jax.dev/en/latest/pallas/tpu/pipelining.html) 则提供异步搬运与计算重叠的语义依据。DMA 同步信用现已接入统一调度器；真实 bank 仲裁、队列深度和内存别名关系仍未完整实现。

[组合示例](../benchmarks/pipeline_validation/memory-push-example.llo) / [报告](../benchmarks/pipeline_validation/results/memory-push-example-report.json) / [trace](../benchmarks/pipeline_validation/results/memory-push-example-trace.json)：DMA 在后台进行，BF16 pack 和双 MXU matpush 可以先执行，wait 再等待传输完成。这个例子使用现有 `tpu7x.json` 的近似参数，不是硬件测量。

上述 pack/matpush/DMA 补充阶段新增 5 项测试，当时执行模型测试合计 22 项，覆盖 pack 歧义、matpush 单元独立性与发射间隔、未知修饰符、DMA 服务时间/计算重叠、缺失或非法带宽配置。全量历史 LLO 复查首次遇到共享实验锁占用（退出 75），没有绕过限制；此前 90.9% 是上一轮实际审计结果，不能未经复测直接替换。

## 接入完整性审计：还有哪些已有能力未接入

[机器可读清单](../benchmarks/pipeline_validation/integration-audit.json) 记录优先级、现状和代码证据。此次是新执行模型与已有项目路径的对照审计，不是完整 ISA 覆盖证明。

| 项目 | 当前接入情况 | 仍有的限制 |
|---|---|---|
| 主估时入口 | `bundle_timing` → `runtime` → `execution` → `pipeline`；旧 `cost.py` 和早期 `mxu_path` 已删除 | 不再提供旧估时开关或自动回退 |
| DMA flag/credit | 异步服务队列、完成 credit、指定 flag/阈值等待、部分 credit、signed `vsyncadd`、underflow | 队列容量、跨核协议和真实服务参数未校准 |
| `vdelay` | 立即数应用于发射游标，支持显式 total/additional 语义 | 未指定语义时保留 gap |
| 整程序调用 | manifest、别名、调用展开、标量实参及调用内 SSA/flag 隔离 | 跨调用缓冲区绑定不完整 |
| 分支/循环 | assembly 延迟槽、HLO 界、未知分支局部最大段、大循环乘法摘要 | 边界排空资源，跨段 SSA/MRB/内存关系仍有 gap；不是硬件时间上界 |
| 外部同步 | 显式 wait-until 和标注的 peer-ready 假设 | 未知跨核完成事件不视作已满足 |
| SparseCore | offload 标注及可选保守校准仍走统一入口 | 尚无完整 SparseCore 指令执行模型 |

专用规则仍只接了一部分：matpush→MSR/GMR→matmul 的隐式权重状态、XLU/TRF→pop 完整依赖、专用资源分派、MRB/EUP 容量与反压、其他 dtype、VMEM bank 和 IMEM refill。它们保留在机器可读审计中，不能把入口接通说成硬件仿真已精确。

[最小探针](../benchmarks/pipeline_validation/results/execution-gap-probes.json) 已更新：显式 `total_cycles` 下，`vdelay 100` 后的 ALU 在 cycle 100 发射；DMA 到 flag 0、等待 flag 9 会明确报告未知/不足 credit，不再被无关 DMA 完成错误满足。报告继续为 `partial`。

验证包括 GF 调度、DMA credit、vdelay、调用/循环、SparseCore 和原生 CLI JSON 格式的回归。实际 PJRT 加法与矩阵乘 smoke 产生的 4 份估时报表均使用新引擎，摘要见 [运行验证](../benchmarks/pipeline_validation/results/unified-runtime-smoke.json)。这不是 PR1780 全模型矩阵重跑，也不是 attention XProf 对齐结果。

成本及分类表要求 libtpu 0.0.48 的已记录 SHA256。原生入口读取 `PJRT_SIM_LIBTPU_PATH` 并核对实际文件；不匹配会拒绝执行。离线未提供编译器身份时明确记录目标假设。Python 安装依赖同步固定为 JAX/jaxlib 0.11.1 + libtpu 0.0.48，兼容范围见 [依赖说明](dependencies.md)。

原生 report 默认保留 kernel 范围和等待时间；在 timing profile 中设置 `"instruction_timeline": true` 可输出逐指令结果、资源及等待轨道。完整指令轨道可能明显增大 JSON，因此默认关闭；这不切换执行算法。

## 当前 best kernel 的统一入口测量

测量期间实验室把 `best_kernel.py` 晋升到了 SHA256
`9cc5da3be6c569af9e07f064471d41fadcf7a51b051ad877e744b2c614e204ec`。
重新核对该源码与 `runs/vmem-prefetch-output-h8-2k-01` 的快照后，使用
`python -m bundle_timing MANIFEST --profile PROFILE --summary --output REPORT`
完整跑通同一个主入口，未使用旧 issue model，也没有手动相加 Q-block 时间。

结果为 **256,752.866502 cycles / 116.70584841 μs**（配置时钟 2.2 GHz）。
范围是完整编译程序：2K 单序列、causal BF16 MHA32 D256、Q512/KV256，
包含两个 16-head 迭代、初始化和已建模的资源完成时间。场景显式提供
`cu_seqlens=[0,2048]`、`num_seqs=1`、对齐虚拟 HBM 地址和正常数值 guard。
报告仍为 `partial`，`estimated_seconds=null`；结果不代表硬件实测或已校准预测。
未解决项包括部分 DMA 完成 flag、HBM/SMEM/host-I/O 服务、专用资源和 bank/别名约束。

[结果摘要](../benchmarks/pipeline_validation/results/best-kernel-unified-summary.json)
保存源码/manifest SHA、统计范围、参数与报告路径。
此前 **135.70995885 μs** 属于被替换的 `e6cf6a…` 版本，保存在
[旧 best 摘要](../benchmarks/pipeline_validation/results/previous-best-kernel-unified-summary.json)，
不作为当前 best 的结果。

本次实际 workload 暴露并修复了通用标量解释器的三个缺口：
`pnand(false, unknown)` 等确定性谓词短路、间接 SMEM 地址读取/写入、
以及编译器指针转换。`profile.module_inputs` 现在支持按模块提供
`smem`、`scalar_inputs`、`predicates` 和显式 `valid_addresses` 假设。
这些是执行场景数据，不是改写成本表；未提供变量序列长度时不能默认推断完整请求的分支。

复现工具从当前源码匹配编译产物，并重新提取其分配和寄存器编号：

```bash
~/lab/tpu-kernel-lab/lab capped .venv/bin/python \
  benchmarks/pipeline_validation/measure_best_kernel.py \
  --output .build/pipeline-validation/current-best-recheck
```

工具最后直接打印 `modeled_cycles` 和 `modeled_microseconds`，同时记录源码是否在分析期间改变。
该工具当前只接受上述固定形状与 libtpu 0.0.48 的编译记录。产物记录了版本，但原始编译器
二进制 SHA 未随该次编译保存，摘要明确保留这一身份核验限制。

## 与当前 best 的 149.814 μs 实测对照

同源码 SHA 的硬件记录给出 **149.8143755 μs**：XProf XLA Ops kernel 时间，
三轮交错实验的轮内中位数再取中位数，每轮 10 次调用，关闭细粒度指令 tracing。
模型 **116.7058484 μs**，低估 **33.1085271 μs / 22.10%**。
[差距审计](../benchmarks/pipeline_validation/results/best-kernel-timing-gap.json)
保存证据位置、动态未映射指令计数和敏感性实验结果。

模型时间中 bundle 发射占 **110.9709 μs**，已建模等待占 **4.6513 μs**，
尾部完成占 **1.0836 μs**。仍有 **150,990 次动态指令执行未映射成本**，
包括转置 BF16 matpush、XLU 归约/pop 和部分 pack/unpack；这些使用占位成本，
缺少相应专用资源约束。部分 DMA wait 的完成 credit 不完整并出现 underflow，
MSR/GMR 隐式状态依赖、XLU producer/pop 和 VMEM bank 竞争也不完整。
这些是 sim-pjrt 模型缺口，当前证据没有将差距归因于 sglang-jax。

另跑一次完整统一模型，仅将 DMA 带宽从 **3.7 TB/s 减半至 1.85 TB/s**，
得到 **137.8908679 μs**，增加 **21.1850195 μs**，距实测仍差 **11.9235076 μs**。
这证明结果对带宽参数敏感；它不是实际有效带宽的测量，也不能算作已解释了 21.19 μs。
正式 profile 未改变，没有通过调参拟合 149 μs。

目前不能把 33.11 μs 逐项分账：这份实测关闭了细粒度指令 tracing，
原始编译器二进制及最终 LLO 的完全一致性也未核验，2.2 GHz 仍是配置假设。
动态指令次数乘延迟不能直接相加成墙钟时间；需要在依赖和资源重叠中计算。
硬件指标是 kernel 时间，未把 host 调用耗时加入解释。

## 修复当前 best 的指令映射

同一份 LLO、相同 profile（带宽和时钟均未调整）完整重跑后，动态未映射数从
**150,990 降到 3**，总动态指令数 **1,540,924**，成本映射覆盖率 **99.9998%**。
剩下 3 次均为 `sfence`，保留未知成本与同步完成模型缺口，未强行映射成零延迟。
[本轮结果及前后清单](../benchmarks/pipeline_validation/results/best-kernel-mapping-fix.json)。

规则已写入项目 [GF 映射 JSON](../configs/gf_mapping_libtpu_0_0_48.json)，
[提取器](../benchmarks/pipeline_validation/extract_gf_mapping.py) 能从固定 SHA 的
libtpu 0.0.48 二进制重建，并检查关键机器码：

- pack/unpack 与 `vweird.f32`：由 builder/predicate 中的原始 opcode 消除格式歧义。
- XLU：识别 `.xlu0/.xlu1`，读取归约及 pop 成本，保留各单元资源 17 的独立约束。
- 转置 BF16 matpush：模式 10 的表延迟 8 cycles；构造函数 `0x1936175f` 起的
  资源 8 设置给出 8-cycle 发射间隔。非转置仍使用 4 cycles。
- 比较及 IAR：补 vector compare 成本等价类、scalar partial-order 和 raw IAR 分支。
  等价类仅在所有候选的延迟与资源值完全一致时采用，否则仍拒绝猜测。
- 伪指令：GF 的 `0x19360070` 专用分支将参数地址映射到 ID 27，
  `scalar_select` 延迟为该行的两倍。后者的 assembly 发射展开仍保留独立缺口。
- `vsyncmov`：根据 SSA 消费者 `spop` / `vpop.sfrf` 区分 raw opcode 11 / 15，
  对应 49 / 3 cycles；无消费者或存在歧义时仍不映射。

新结果 **259,784.866502 cycles / 118.0840302 μs**，相较修复前增加
**1.3781818 μs**，距实测仍差 **31.7303453 μs**。映射补齐后增加时间较少，
说明不能把未映射指令数量直接换算成缺失的墙钟时间。
资源分派、DMA credit、同步和校准仍不完整，报告继续为 `partial`。
回归验证：107 项 unittest、2 个相关 Bazel 目标通过；完整 workload 重跑耗时
78 秒，内存峰值 3.9 GiB。修复前摘要另存，不覆盖原始比较证据。

## DMA 传输量核对与漏算修复

实验室新采集 `exp-1u7fcp3z1s` 的同源码细粒度 profile 已在本地可读，
两次插桩 kernel 时间为 155.479 / 155.467 μs，不能替代普通实测 149.814 μs。
其 CMN DMA 两引擎 VC0+VC2 的 capture-wide 字节计数除以两次调用，
为 **234,882,080 bytes**；旧模型仅 **184,550,432 bytes**，恰差 **48 MiB**。
源码预期 Q 32 MiB、K/V 160 MiB、输出 32 MiB，另有初始化小传输。
[本轮原始计数摘录、样本及结果](../benchmarks/pipeline_validation/results/best-kernel-dma-evidence.json)。

已逐指令确认：48 次跨 Q 预取 `dma.general` 各有 32,768 个 32-byte granule，
但指针经过标量运算后无法从局部类型推断传输方向。编译器输出中的
`/* hbm-to-vmem */` 注释此前又被解析器删除，导致这些 DMA 的服务时间和
完成 credit 未进入模型。现在保留该注释；若与显式指针类型冲突则拒绝解析。

修复后模型字节数与上述计数合计精确一致，未知/不足 credit 位置从 **15 降到 3**。
固定 3.7 TB/s 与 2.2 GHz 重跑，时间仍为 **118.084 μs**：补回的预取在当前
模型中被计算覆盖。此缺陷确实存在，但不能据此宣称已解释剩余 31.73 μs。
8 次 4-MiB 输出 DMA 的目的完成 flag 仍未解析，另有 HBM/SMEM 服务缺口。
109 项 unittest 与三个相关 Bazel 目标通过。

[官方 TPU7x 架构](https://docs.cloud.google.com/tpu/docs/tpu7x) 给出整芯片
7.38 TB/s、两个独立芯粒；当前 3.7 TB/s 约为整芯片的一半，没有发现把整芯片
峰值重复赋给一个核的 factor-of-two 错误。实际有效带宽、stride、队列与反压仍需校准。
硬件 `VMEM2HBM_DMA_REQUEST_STALLED` 有非零计数，但它记录请求受阻次数，
不是可以直接换算成 kernel 独占等待时间的周期数。

### 输出完成 flag 修复与更新后的带宽敏感性

8 次输出 DMA 的 flag 来自 `scalar_lea.sflag %base, 6 [#allocation6]`，
其中 `%base` 本身已有动态偏移，计算结果随后经过 SMEM spill/reload。
解释器此前把尾部 allocation 标注混入偏移表达式，且只支持无偏移的 flag 基址。
现已剥离该标注并支持累加 allocation-relative 偏移，输出完成 credit、等待及
扣减完整闭合。未解析的 credit 位置只剩 HBM→SMEM 初始化一处。

同一份 LLO、同样动态指令数与 234,882,080 bytes，完整重跑结果：

| DMA 带宽参数 | 模型耗时 | 与普通实测 149.814 μs 的差距 |
|---|---:|---:|
| 3.7 TB/s（正式 profile 保持此值） | **120.051145 μs** | 低估 **29.763230 μs** |
| 1.85 TB/s（仅敏感性实验） | **155.283584 μs** | 高估 **5.469208 μs** |

输出 flag 修复本身增加约 **1.967115 μs**。在传输量和 flag 修正之后，带宽减半
增加约 **35.232439 μs**，取代此前漏算 48 MiB 时的敏感性数字。
这只证明结果对该参数敏感，不能确定缺失时间的原因，也不能证明真实带宽恰为
1.85 TB/s；正式参数未修改。需要通过 XProf 阶段、DMA 和同步事件定位误差。
插桩调用的 155.47 μs 是另一种测量范围，
不能用其与敏感性结果接近来宣称验证通过。

结果与路径更新在 [DMA 审计](../benchmarks/pipeline_validation/results/best-kernel-dma-evidence.json)。
110 项 unittest 与三个相关 Bazel 目标通过，两组完整仿真串行耗时 162.77 秒，
峰值内存 3.8 GiB。报告仍为 `partial`，保留 HBM/SMEM 服务、descriptor、
外部同步及其他资源模型缺口。

### XProf 与模型的阶段对齐（2026-10-09）

[交互对照图](../benchmarks/pipeline_validation/results/xprof-alignment/alignment.html)、
[分段数据](../benchmarks/pipeline_validation/results/xprof-alignment/alignment.json)、
[模型 DMA/同步事件](../benchmarks/pipeline_validation/results/xprof-alignment/model.json)。
使用本地保存的 `exp-1u7fcp3z1s` XProf，源码 SHA 与当前 best 一致。
模型保持 3.7 TB/s、2.2 GHz。仅将 kernel 起点平移到零，不缩放时间、不拟合参数。
以两组 head、每组四个 Q 块的顺序及重复入口模式，对齐九个长间隔与八个 MXU
指令发起区间；没有将硬件与模型的 bundle 编号直接等同。

模型完整程序为 120.051145 μs，其中 `XLA Ops` kernel 范围为 **119.766 μs**。
本次应与带指令追踪的两次 kernel **155.478841 / 155.466986 μs** 比较，
不能混用普通测量的 149.8143755 μs。

| 差值所在区间 | XProf call 0 − 模型 | XProf call 1 − 模型 |
|---|---:|---:|
| 八个 Q 块内部的 MXU 指令发起区间 | 23.510023 μs | 23.612817 μs |
| 首段、六次跨 Q、跨 head、末尾区间 | 12.202818 μs | 12.088169 μs |
| 总差值 | 35.712841 μs | 35.700986 μs |

以 call 0 第一组 head 为例，Q0–Q3 内部区间的差值依次为
**1.196、2.454、3.644、4.773 μs**。模型在这些区间确实发起了 DMA credit wait，
但对应 wait bundle 的停顿均为零。这把后续验证重点落到了随 KV 工作量增长的
区间：需检查硬件是否真的等待了 DMA、模型的依赖/资源约束是否过松。
**上述时间分区不等于 stall 归因，也不能排除区间内部的 DMA 等待。**

最初本地摘要每次调用只有 12 条 DMA/sync 相关边界事件。后续用户明确授权下载后，
通过 Falcon 分析 `an-t0xq2ncarc` 取回了完整 trace（70,180,623 bytes）和
XPlane（259,378,825 bytes），逐文件 SHA-256 验证通过。
[下载来源与本地路径](../benchmarks/pipeline_validation/results/xprof-alignment/hardware-source.json)。
原始文件保存在 `.build/pipeline-validation/xprof-alignment/hardware/profile/`，
避免将约 330 MB 二进制提交到仓库。导出脚本只包含 profile，不导出编译器 LLO。

图已更新为完整 trace 中的 DMA/sync 事件；
[事件数据](../benchmarks/pipeline_validation/results/xprof-alignment/hardware-dma-sync.json)
含每次 884/877 条相关事件（包括 Pallas primitive），
[逐阶段 wait 核对](../benchmarks/pipeline_validation/results/xprof-alignment/dma-comparison.json)
按相同 flag operand、紧邻 bundle 编号匹配 `dma.done.wait` 和后续 `vsyncadd`。
所有观察到的 wait 均能配对；Q 内部这些相邻指令的间距总和仅
**0.109548 / 0.105269 μs**，没有在这些配对点看到对应 23.5 μs 差值的长间隔。
但这是重建指令之间的间距，**不能直接称为硬件 DMA stall 总时长，也不能排除 DMA**。

另一个关键限制是动态计数不一致：Q0/Q1 内部两边均为 4/12 个 wait；
Q2 模型为 20，trace 为 24–28；Q3 模型为 28，trace 为 40–44。
这需要区分插桩/编译路径差异与 trace 重建误差，不能按 DMA 事件序号硬配。
XPlane 没有显式 DMA engine completion lane，也没有可直接读取的 plane clock/frequency
元数据；不能把指令条目的 duration 当成传输完成时间。
因此当前是**阶段及同步点核对完成，逐 DMA 实际完成时间归因仍受证据限制**。
另有插桩差异、原始编译器 binary identity 未记录及 XProf 指令插值误差的限制。

复现：在 `lab capped` 下运行 `capture_model_alignment.py`，随后运行
`align_xprof.py --model <model.json> --identity <identity.json> --xprof-dir <本地 evidence/best-vmem-overlap> --output-dir <结果目录>`。
导出保留 runtime 已选中的分支与全局时间偏移，不会把未执行的替代分支拼接进时间线。
本次完整导出耗时 78.5 秒、峰值内存 3.9 GiB；分段脚本验证源码/manifest hash、
两组重复入口模式及全部区间差值之和。

完整 trace 的本地逐指令解析已完成（27.2 秒、峰值 4.7 GiB），
[明细](../benchmarks/pipeline_validation/results/xprof-alignment/instruction-comparison.json)
包含每个阶段的 opcode 计数、全部 wait 配对和各 instruction lane 的相邻 bundle 间隔。
第一组 head 的 Q 内部指令数量如下（按阶段起点包含、终点不包含统计）：

| Q 块 | 模型指令数 | XProf 观察数 |
|---|---:|---:|
| Q0 | 48,182 | 48,003 |
| Q1 | 110,059 | 109,010 |
| Q2 | 171,949 | 170,360 |
| Q3 | 233,867 | 230,621 |

总工作量接近，但局部同步计数仍不一致，不能宣称逐指令路径已经完全验证。
在两个调用、所有 Q 块中，VLD lane 相邻 bundle 编号的观察时间间隔中位数均为
约 **0.600 ns**；模型同样筛选得到 **0.454545 ns**，对应配置的 2.2 GHz、
一周期发起间隔。VALU/VST/MXU 等多个 lane 也出现约 0.600 ns 的中位数。
这将检查范围推进到**发起节拍、周期到时间换算及 trace 插值语义**，
而不是继续通过调整 DMA 带宽追总时间。
这些统计含动态停顿和插值影响，不能用 0.600 ns 的倒数宣称实际频率，
也没有据此修改 `frequency_hz` 或 issue 参数。

### 模型自身的 trace 与逐事件对应

`export_model_trace.py` 从统一执行模型选中的路径导出 **243,912 个 kernel bundle**
事件，保存于 `.build/pipeline-validation/xprof-alignment/matched/model.trace.json.gz`。
事件表示 bundle 的发起/等待区间，不把它冒充为所有功能单元的执行完成区间。

`match_xprof_timeline.py` 不通过时间接近来选择匹配：先用唯一的连续 11-bundle
指令组合建立跨编译产物的静态映射，在两个唯一上下文之间只补充唯一的短序列；
再按 Q/head 阶段、bundle、opcode 和执行次数生成动态对应。重复次数不等、
同 bundle 内同族指令多发及缺少静态映射的事件保留为未匹配。
时间只用于最后的顺序冲突检查（允许 10 ns 的重建时间抖动），不用于寻找替代匹配、
调整频率或拟合带宽。静态地址映射属于指令上下文推断，不能视为二进制身份验证。

输出集中在 `.build/pipeline-validation/xprof-alignment/matched/`：

- `timeline.html`：自包含交互图，两条绝对时间线通过对应线连接；默认打开 Q0。
  可选择调用与阶段，点击指令查看地址/执行次数/时间偏差，放大并导出本段 CSV。
- `instruction-pairs.jsonl.gz`：所有通过检查的逐指令对应及原始时间戳。
- `bundle-pairs.json.gz`：每个已匹配动态 bundle 的代表指令，优先选择 VLD/VST。
- `unmatched-events.jsonl.gz`：两边的未匹配事件，逐条记录时间、地址和原因。
- `static-map.json`、`summary.json`：静态映射的上下文证据和每段覆盖率。

这些产物让差值能沿执行位置逐点检查，而不只比较阶段总长度。模型指令的
插入/删除与重复上下文歧义测试通过；图的嵌入数据解压、阶段切换、绘图、点选
和缩放交互完成 Node DOM/canvas stub 冒烟验证，未进行真实浏览器截图验收。

最终结果包含 **28,899 个静态 bundle 地址对应**，两次调用分别匹配
**615,744 / 614,444 对指令**，交互图共 **329,125 个动态 bundle 代表点**。
[覆盖率与产物路径](../benchmarks/pipeline_validation/results/xprof-alignment/matched-summary.json)、
[静态地址映射](../benchmarks/pipeline_validation/results/xprof-alignment/static-bundle-map.json.gz)。
四项匹配测试通过，代表点不存在超过 10 ns 容差的顺序倒置；未匹配部分仍明确保留，
不能称为全部指令已对齐。

第一组 head 的 Q0，以首个已匹配指令为相对起点，沿实际对应点得到：

| 模型 bundle → XProf bundle | 模型已过时间 | XProf 已过时间 | 累积差值 |
|---|---:|---:|---:|
| `0x2ebe` → `12648` | 0.870000 μs | 1.203631 μs | 0.333631 μs |
| `0x35ca` → `14452` | 1.690000 μs | 2.317452 μs | 0.627452 μs |
| `0x8adb` → `37548` | 2.690909 μs | 3.609994 μs | 0.919085 μs |
| `0x9205` → `39387` | 3.526818 μs | 4.723214 μs | 1.196396 μs |

这是对应指令之间的直接时间差，未拟合斜率。它显示 Q0 的误差在执行过程中累积，
并非全部集中在某一个已观察的 DMA wait 点上；具体原因仍需区分发起节拍、
资源/依赖、时钟换算和 XProf 插值，不能把曲线差值直接归因给其中某一项。

### 可选的局部发起成本校准与固定对应点验证

已实现 `bundle_issue_calibration`：以实际 bundle 的完整 opcode 组合查找经验发起
时间下限，不改 GF 指令依赖、资源约束、DMA 队列和完成 credit。
该下限与已有 issue/显式 delay 取最大值，避免把同一段等待再加一次。
表的 schema、编译器 hash、频率和所有成本值均做校验；报告继续标为 `partial`。

项目中的成本表为
[`configs/tpu7x_xprof_issue_calibration.json`](../configs/tpu7x_xprof_issue_calibration.json)，
可复现 profile 为
[`best-kernel-xprof-calibrated-profile.json`](../benchmarks/pipeline_validation/best-kernel-xprof-calibrated-profile.json)。
**通用 `configs/tpu7x.json` 未改，经验表只用于当前 2K best-kernel 场景。**

校准样本仅来自 call 0/head 0 的 Q 内部：两边静态 bundle 地址必须连续，代表指令
必须同为 VLD 或 VST，模型该段必须恰好一周期、没有模型已计入的等待。
每个组合至少 64 个样本且来自至少 8 个不同静态位置。
最终得到 18 类 opcode 组合、2,158 个局部间隔样本；默认有效下限约为
1.32 模型周期，部分组合为 1.155–1.157 周期。未见组合使用训练样本的混合中位数，
属于需要验证的泛化假设。**没有使用总耗时反推系数，也没有把 0.600 ns 倒数当硬件时钟。**
这是包含 trace 插值/插桩及尚未归因成本的经验下限，不是硬件物理周期表。

完整重新执行统一模型后：

| 范围 | 原模型 | 校准模型 | XProf |
|---|---:|---:|---:|
| kernel | 119.766 μs | **153.335 μs** | 155.478841 / 155.466986 μs |
| 完整编译程序（含模型 wrapper） | 120.051145 μs | **153.639865 μs** | 不与 kernel 范围混比 |

kernel 总时间误差为 **1.379% / 1.371%**。
新旧执行路径的全部地址、opcode 和顺序完全一致，时钟、DMA 参数及输入保持不变。
验证复用了原有的全部指令对应关系，只替换模型重跑后的时间戳，没有重新选择更好看的匹配。
未参与校准的 call 1，逐点 MAE 从 **18.202363 μs → 1.919195 μs**，
P95 绝对误差从 **33.931833 μs → 2.964556 μs**。
这是同一次 capture 内的保留样本验证，不是独立硬件实验验证。

[校准结果](../benchmarks/pipeline_validation/results/xprof-alignment/calibrated-model-summary.json)、
[逐段固定对应点验证](../benchmarks/pipeline_validation/results/xprof-alignment/calibrated-validation.json)。
校准后的交互图和模型 trace 位于
`.build/pipeline-validation/xprof-alignment/calibrated/timeline.html` 与
`model.trace.json.gz`。仍有约 1.8 μs 的初始准备差值、约 1.7 μs 的 head 切换阶段差值，
部分切换阶段的相反方向误差会抵消，不能把总时间接近称为逐周期精确复现。

相关 113 项 unittest 通过。新增回归检查了经验下限不能绕过 RAW 依赖、不能重复
累加显式 delay，并拒绝编译器/频率不匹配及无效成本。校准重跑耗时 81.7 秒，
峰值内存 3.9 GiB。
