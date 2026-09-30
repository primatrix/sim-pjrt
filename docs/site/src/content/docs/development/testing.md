---
title: 测试与验证
---

在仓库根目录运行：

```sh
bazel test //...
```

包含七个 C++ 目标和七个 Python 目标，覆盖 CPU 输出替换、Virtual HBM、运行时、profiling、编译校验、LLO/DMA/分支估时、采集与 replay、profile 导入和启动器。真实 libtpu 编译测试需要显式环境；HLO 解析用例在 CI 中另用安装了 jaxlib 的 Python 执行。

使用[快速开始](/getting-started/)的环境，配置 SGLang-Jax 源码路径后运行：

```sh
SIM_PYTHON=.venv/bin/python bash tests/run_tests.sh
```

只跑已构建插件的 SGLang 请求：

```sh
SIM_PYTHON=.venv/bin/python SIM_PROFILE=1 bash tests/run_libtpu_tests.sh
```

默认 TP1/2/4，TP2/4 开启 overlap。包含 prefill、decode、不同输出长度的并发请求、future-token 槽位复用、前缀缓存及 flush。采集前完成预热，验证无编译事件、异步轨道不交叉、模型区间与 bundle 报告及完成事件一致。

32 层测试可设置 `SIM_TP_SIZES=4 SIM_HIDDEN_SIZE=4096 SIM_NUM_LAYERS=32 SIM_INTERMEDIATE_SIZE=11008 SIM_TEST_TIMEOUT=1800`。它采用 dummy/虚拟权重与小词表；通过不代表数值或性能校准完成。

Qwen3 MoE 的 TP4 overlap 与 XProf 流程：

```sh
SIM_PYTHON=.venv/bin/python SIM_MODEL=qwen3_moe SIM_TP_SIZES=4 \
  SIM_PROFILE=1 SIM_TEST_TIMEOUT=1800 bash tests/run_libtpu_tests.sh
```

模型尺寸和专家配置以输出的 `model_config.json` 为准。使用 dummy 权重验证的是请求调度、编译和执行流程，不是生成质量。

2026-09-30 验证：JAX/jaxlib 0.11.1、libtpu 0.0.48、模拟 TPU7x 拓扑，Virtual HBM 9/9 通过，多设备在 TP2、TP4 下均为 9/9，覆盖 decode、collective、resharding 和 Pallas。配置显式假设其他设备已就绪，额外同步等待按 0 计，DMA 仍计时；这不代表真实耗时已校准。显存额度测试在 2026-09-29 为 2/2。完整 SGLang serving 尚未重跑。
