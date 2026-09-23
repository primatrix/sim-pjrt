---
title: 测试与验证
---

在仓库根目录运行：

```sh
bazel test //...
```

包含六个原生目标和两个纯 Python 目标：CPU 输出替换、Virtual HBM、bundle runtime、profiler、API 错误、编译校验、bundle 估时和 profile 报告。真实 libtpu 编译测试需要显式环境。

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

本次 Virtual HBM 去阈值改动未运行构建或测试；上述命令是复现入口，不能视为当前工作区的通过记录。
