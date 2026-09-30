---
title: 快速开始
description: 安装后，用 spjrt 运行已有的 JAX 程序。
---

模拟运行只需要 CPU。源码安装要求 Linux x86-64、Python 3.12 或 3.13。

## 1. 安装

本文对应当前源码；旧版 `0.1.0.dev1` wheel 没有采集、replay 和 `--report`。
准备好[构建工具](https://github.com/primatrix/sim-pjrt/blob/main/docs/building.md)，
在仓库根目录、运行工作负载的 Python 环境里安装：

```sh
python -m pip install .
spjrt doctor
```

`doctor` 检查插件、libtpu 和配置路径。已有插件时可按
[打包说明](https://github.com/primatrix/sim-pjrt/blob/main/docs/python-package.md#build-and-install)复用构建产物。
正常使用无需手配 PJRT 环境变量。

## 2. 确认后端

```sh
spjrt run python -c "import jax; print(jax.devices())"
```

应看到模拟 TPU 设备。默认模拟 TPU v7x 的 8 个设备。

## 3. 运行你的程序

将 `workload.py` 换成已有的 JAX 程序：

```sh
spjrt run --report ./run workload.py
cat ./run/summary.json
```

报告包含程序预测耗时、未建模成本和显存统计。每次运行使用新的报告目录。
浮点输出是占位值；模拟耗时用于估计性能，不能据此验证模型数值正确性。

需要其他拓扑，或需要向程序传参数时：

```sh
spjrt run --topology v5e:2x2 --devices 4 --timing-profile example \
  workload.py --batch-size 4
```

脚本名之前是模拟器选项，之后是程序自己的参数。`spjrt run --help` 可查看全部选项。

## 常见问题

| 问题 | 处理方式 |
| --- | --- |
| 找不到插件或 libtpu | 在同一个 Python 环境运行 `spjrt doctor`；从源码使用时可指定 `--plugin` |
| 找不到工作负载依赖 | 把依赖安装到 `spjrt` 所在的环境 |
| 浮点结果全是零 | 这是占位输出，属于预期行为 |
| 第一次运行很慢 | 包含编译时间；预测耗时看报告，不能直接用 CPU 墙钟代替 |
| 出现成本缺口或循环解析失败 | 查看[支持范围](/reference/limitations/)，当前模型仍有未支持的路径 |

## 下一步

- [性能分析](/guides/profiling/)：采集并查看执行时间线。
- [张量并行](/guides/tensor-parallelism/)：使用多个设备和分片。
- [Virtual HBM](/guides/virtual-hbm/)：理解显存占用和输出行为。
