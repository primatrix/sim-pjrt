---
title: 测试与验证
description: 执行 C++、JAX、框架与性能重放验证。
---

所有模拟器命令从仓库根目录执行，并使用配置好的 Python / Bazel 环境。

## 完整测试

```sh
SIM_PYTHON=/path/to/python bash xla/pjrt/sim/run_tests.sh
```

脚本构建插件、六个 C++ 测试目标和 XPlane descriptor，然后运行 JAX、Pallas、profile、replay 和框架集成检查。SGLang 使用本地微型 Llama 配置和 dummy 权重，不需要下载真实模型或 tokenizer。

| 设备 / TP | 框架验证 |
| --- | --- |
| 1 | 关闭 overlap；3 个请求、prefix-cache 复用、flush 后再生成 |
| 2 / 4 / 8 | 开启 overlap；每配置 11 个请求，包括不同 decode 长度的并发 batch |

输出写入 `/tmp/pjrt-sim-results` 下的新目录，包括日志、profile、执行快照、报告和环境版本。

## 按功能验证

先按[快速开始](/getting-started/)构建并设置插件环境。

```sh
# 单设备虚拟存储。
PJRT_SIM_DEVICE_COUNT=1 python xla/pjrt/sim/virtual_storage_test.py -v

# 虚拟张量并行；可换成 4 或 8。
PJRT_SIM_DEVICE_COUNT=2 python xla/pjrt/sim/virtual_multidevice_test.py -v

# 独立 Python 成本与重放测试。
python xla/pjrt/sim/replay_test.py -v
python xla/pjrt/sim/virtual_clock_test.py -v
python xla/pjrt/sim/device_load_test.py -v
```

## 已记录的迭代结果

2026-09-16 的开发记录覆盖虚拟权重与 cache、三步 donated decode、列/行/复制分片转换、阈值切换、整数 collectives，以及 `shard_map` 中的 Pallas FlashAttention。

测试配置、主机内存观察和完整验证记录保留在 `xla/pjrt/sim/ITERATIONS.md`。主机内存与耗时观察不能作为 TPU 性能数据。

## 文档站验证

文档站独立于 Bazel：

```sh
cd xla/pjrt/sim/docs-site
npm ci
npm run build
npm run preview
```

构建会校验文档 frontmatter，并生成静态页面和搜索索引。需要实时编辑时使用 `npm run dev`。
