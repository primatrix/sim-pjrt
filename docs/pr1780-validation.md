# SGLang JAX PR 1780 请求流程验证与问题归属

2026 年 10 月 8 日，使用官方完整模型配置、dummy 主模型权重和真实多模态预处理，完成 **8 个配置、31 条 HTTP 请求**。验证覆盖服务启动、媒体处理、编码、prefill、decode 和响应返回。以下按根因归属区分 `sglang-jax`、`sim-pjrt` 以及运行配置问题；这些发现不等同于 PR 1780 新引入的回归。

验证基线为 [SGLang JAX PR 1780](https://github.com/sgl-project/sglang-jax/pull/1780) 的提交 `5f4acc7a2060571f119f5adfb7a8fa1f64d3d0c0` 和 [sim-pjrt v0.1.1](https://github.com/primatrix/sim-pjrt/releases/tag/v0.1.1)。下面的修复与发布状态均记录截至本轮验证结束时的情况。

## sglang-jax 问题

| 问题 | 根因与影响 | 处理状态 |
| --- | --- | --- |
| Kimi 权重加载调用过时接口 | `kimi_k25_vl_generation.py` 调用 `DeepseekV3Attention.post_load_weights()`，但该方法已经不存在，启动时报 `AttributeError`。当前权重加载器已有 `prepare_weight_loading()` 路径。 | 在隔离工作树移除两行过时调用，完整请求通过。[本地补丁](../benchmarks/pr1780_validation/kimi-weight-loading.patch)尚未提交到上游。 |
| Kimi 量化格式支持缺口 | 当前 SGL 代码不支持模型配置中的 `pack-quantized`，禁用量化并采用 BF16，显著增加编译器所见的权重内存需求。 | 格式支持尚未补齐。本轮保留完整模型尺寸，用 BF16 和 TP=32 完成验证。容量报错另见下节，不能将其全部归为模拟器内存错误。 |
| Qwen 视频 FPS 元数据传递不完整 | Qwen3-VL、Qwen3.5 Dense/MoE 的处理器触发 Transformers 的缺失 FPS 元数据警告，回退到 24 FPS。SGL 视频预处理读取源 FPS 和采样帧索引后返回帧数组；调用 HF processor 时传入采样参数，但没有完整 `video_metadata`。 | 归属 SGL 与 Transformers 的视频预处理集成，发生在模型设备执行之前。尚未修复；请求完成，但视频时间戳语义未验证。不是 `sim-pjrt` 的执行错误。 |

归属依据：[Kimi 加载入口](https://github.com/sgl-project/sglang-jax/blob/5f4acc7a2060571f119f5adfb7a8fa1f64d3d0c0/python/sgl_jax/srt/multimodal/models/kimi_k25/kimi_k25_vl_generation.py)、[DeepseekV3 加载接口](https://github.com/sgl-project/sglang-jax/blob/5f4acc7a2060571f119f5adfb7a8fa1f64d3d0c0/python/sgl_jax/srt/models/deepseek_v3.py)、[量化配置解析](https://github.com/sgl-project/sglang-jax/blob/5f4acc7a2060571f119f5adfb7a8fa1f64d3d0c0/python/sgl_jax/srt/configs/model_config.py)、[Qwen 视频处理器](https://github.com/sgl-project/sglang-jax/blob/5f4acc7a2060571f119f5adfb7a8fa1f64d3d0c0/python/sgl_jax/srt/multimodal/processors/qwen_vl.py)。

## sim-pjrt 问题

| 问题 | 根因与影响 | 处理状态 |
| --- | --- | --- |
| Final LLO 嵌套注释解析失败 | 解析器不能正确处理诊断文本中的嵌套注释，阻塞 Qwen3.5 等模型的编译分析。 | 已增加嵌套注释处理，保留外层调用和区域元数据，并通过回归测试。 |
| 未支持 `AllocateBuffer` | fused-MoE 生成合法的 scratch 分配 custom call，模拟器没有适配器而拒绝执行。 | 已为无操作数、无输出别名的静态数组分配增加确定性零填充适配。 |
| 拒绝 fused-MoE 内部 side effect | SGL fused-MoE v1 用 side effect 标记设备 DMA、barrier 和 scratch 写入；这是该内核的正常行为，模拟器原先不支持。 | 已按内核名称、静态数组类型和维度及无输出别名等约束增加有限适配。未知副作用仍拒绝。完整 Qwen3.5 MoE 请求已通过；没有验证实际通信或同步正确性。 |
| 自动标量路径解析能力不足 | 部分运行时循环达到访问上限；Gemma 的自动分析还触发递归错误。 | **尚未完全解决。** 本轮改用显式 no-fault 场景遍历静态 bundles，保留未解析控制流和成本的 gap。 |
| MiMo 的 Final LLO 与汇编分支对齐失败 | 自动对齐检查报告 branch mismatch，原先连显式场景也强制执行该检查。 | **只修复显式场景不必要的依赖。** 显式场景跳过自动分支重建；自动模式保留严格检查，实际对齐差异仍待解决。 |
| 新适配代码使用不兼容的 XLA API | 本次开发中使用 `Shape.rank()`，锁定的 XLA 版本没有该接口，导致候选 CI 编译失败。 | 已改为 `dimensions_size()`；后续原生构建的 16 个测试目标全部通过。这是本次修复过程中的编译问题。 |

上述模拟器修复集中在 [sim-pjrt PR 14](https://github.com/primatrix/sim-pjrt/pull/14)。验证结束时该 PR 尚未合并，修复候选尚未发布为新版本。完整候选提交为 `b09ac1549c82d18bf8c49d148521d02c39661b19`，对应[成功的原生构建](https://github.com/primatrix/sim-pjrt/actions/runs/37776656127)。

## 运行配置与容量约束

| 现象 | 归属与处理 |
| --- | --- |
| Kimi 在 TP=8 下编译 HBM 不足 | 直接拒绝来自 **libtpu 编译器的拓扑容量检查**：HLO temporaries 需要 241.46 GiB，可用 94.74 GiB。上游因素是 SGL 的量化支持缺口；本次 BF16、TP=8 配置不足以容纳完整模型。改用 TP=32 后四类请求全部通过。 |
| 模拟器设为每设备 1 TiB 仍报 HBM 不足 | `sim-pjrt` 的逻辑 HBM 预算与 libtpu 的目标硬件编译容量是两套约束；前者不改变后者。尝试 `xla_tpu_max_hbm_size_mib=1048576` 也未提高该拓扑上限。不能据此认定宿主机 RAM 耗尽或模拟器预算失效。 |
| Qwen3.5 的 recurrent buffer 与请求槽位约束 | 属于启动配置。补齐 unified radix tree、recurrent extra buffer 等参数；MoE 配置使用 16 个请求槽和 64 个 recurrent state 槽。没有缩减模型层数、隐藏维度或专家数。 |
| 拓扑名称与 libtpu 并行加载 | 属于测试环境配置。使用 `tpu7x` 拓扑；并行离线模拟设置 `ALLOW_MULTIPLE_LIBTPU_LOAD=1`，避免与已有进程的加载锁冲突，未移除其他任务的锁。 |

作为量级核对，Kimi 配置中的路由专家权重按 BF16、8 路均分计算为 `60 × 384 × 3 × 7168 × 2048 × 2 / 8 / 2^30 = 236.25 GiB/设备`。这只是专家权重的配置推算，不是实测峰值；与编译器报告的 241.46 GiB 量级一致。TP=32 后该部分约为 59.06 GiB/设备。

## 验证结果与适用范围

所有配置均使用显式流程场景。原版 v0.1.1 直接通过 4 个配置，另外 4 个使用修复；不能将结果解释为原版构建在默认自动计时模式下全部通过。

| 完整模型配置 | TP | 通过请求数 | 使用的构建或修复 |
| --- | ---: | ---: | --- |
| Qwen2.5-VL-3B-Instruct | 8 | 4 | 发布版 v0.1.1 |
| Qwen3-VL-2B-Instruct | 8 | 4 | 发布版 v0.1.1 |
| Qwen3.5-4B | 8 | 4 | v0.1.1 原生库及本地 Python 解析修复 |
| Qwen3.5-35B-A3B | 8 | 4 | PR 14 完整候选 wheel |
| Gemma4-31B-it | 8 | 3 | 发布版 v0.1.1 |
| Gemma4-26B-A4B-it | 8 | 3 | 发布版 v0.1.1 |
| MiMo-V2.5 | 8 | 5 | v0.1.1 原生库及本地 Python 解析和显式场景修复 |
| Kimi-K2.5 | 32 | 4 | v0.1.1 原生库、本地 Python 修复及独立 SGL 加载补丁 |

每个模型验证单图、不等尺寸多图和重复请求；除 Gemma4 外均验证视频，MiMo 还验证真实 WAV 预处理与音频请求。该 SGL 版本的 Gemma4 processor 明确拒绝视频和音频，因此不计入其用例。MiMo 的主模型权重为 dummy，音频 tokenizer 使用真实检查点。

每条请求均通过 `/v1/chat/completions` 返回 HTTP 200、4 个 completion tokens 和 `finish_reason=length`，并核对编码及语言模型执行 trace。重复请求通过不代表每个后端都发生缓存命中。另有 38 个 SGL CPU 回归测试、9 组模拟器 Python 回归和 16 个原生构建测试目标通过。

**这些结果只验证请求流程。** 模拟输出是占位值；模型数值正确性、真实 TPU 性能、内核同步正确性和视频时间戳语义均未验证。显式场景保留 timing gaps，宿主机初始化与编译耗时不能作为 TPU 延迟。

- [逐模型结果及构建来源](../benchmarks/pr1780_validation/results.json)
- [响应、日志、配置和补丁证据包](../benchmarks/pr1780_validation/evidence.zip)
- [复现说明](../benchmarks/pr1780_validation/README.txt)

原始编译产物和失败重试记录位于本机 `/tmp/pr1780-validation/results/`；上述证据包保留成功请求的关键结果，`results.json` 同时索引各次失败记录。
