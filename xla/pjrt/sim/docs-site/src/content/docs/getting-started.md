---
title: 快速开始
description: 构建插件，选择模拟后端并运行第一个 JAX 程序。
---

下面的模拟器命令均从 **仓库根目录**执行。文档站本身无需构建模拟器；只想阅读文档可直接运行文档站的 npm 命令。

## 1. 准备环境

需要可用的 Bazel 构建环境，以及与本仓库基线兼容的 JAX/jaxlib。框架集成基线为 Python 3.12、JAX/jaxlib 0.11.1、Flax 0.12.9；虚拟存储迭代也在本地 Python 3.13 / JAX 0.11.1 上验证过。

SGLang-Jax 的测试提交为 `7ebbbef498b9e484fdc5902986578a3504734e46`。如果要运行完整框架集成，在该版本的源码目录安装 CPU 依赖：

```sh
python3.12 -m venv /tmp/pjrt-sim-venv
/tmp/pjrt-sim-venv/bin/pip install -c xla/pjrt/sim/constraints.txt \
  '/path/to/sglang-jax/python[cpu]'
/tmp/pjrt-sim-venv/bin/pip install -r xla/pjrt/sim/profiling-requirements.txt
```

将 `/path/to/sglang-jax` 换成自己的源码路径。后续示例中的 `python` 应来自已配置的环境。

## 2. 构建插件

```sh
./scripts/bazel build -c opt //xla/pjrt/sim:pjrt_sim_plugin.so
```

生成文件位于 `bazel-bin/xla/pjrt/sim/pjrt_sim_plugin.so`。构建入口会自动准备固定版本的 XLA；首次只编译该插件及其传递依赖。需要 Linux x86-64、Git、Python 3.12+ 和 Bazel 8.7.0（或 Bazelisk）。

## 3. 选择模拟后端

在新的 Python 进程启动前设置：

```sh
export JAX_PLATFORMS=tpu
export JAX_ENABLE_COMPILATION_CACHE=false
export PJRT_NAMES_AND_LIBRARY_PATHS="tpu:$PWD/bazel-bin/xla/pjrt/sim/pjrt_sim_plugin.so"
export PJRT_SIM_DEVICE_COUNT=1
```

插件使用 `tpu` 名称，以便 JAX 采用 TPU/Pallas lowering。持久化可执行文件缓存不受支持。

## 4. 执行第一个程序

```python
import jax
import jax.numpy as jnp

print(jax.devices())

@jax.jit
def increment(x):
    return x + 1

result = increment(jnp.array([1, 2, 3], dtype=jnp.int32))
result.block_until_ready()
print(result)  # [2 3 4]
```

这里用整数运算验证执行路径。浮点矩阵乘法等结果遵循模拟器的占位策略，不能用于数值正确性验证。

也可以运行已有 smoke test：

```sh
python xla/pjrt/sim/smoke_test.py -v
```

## 下一步

- [虚拟存储](/guides/virtual-storage/)：了解逻辑形状、物理存储与初始化方式。
- [张量并行](/guides/tensor-parallelism/)：使用多个设备和显式分片。
- [性能分析](/guides/profiling/)：采集并解释时间线。

## 常见问题

**后端没有生效：** 检查插件是否已构建、路径是否为绝对路径，并在设置环境变量后启动新进程。

**首次运行很慢：** 编译和 CPU 执行也会消耗真实时间，不能把这一耗时当成模拟 TPU 的计算时间。

**初始化时主机内存占用过高：** 确认虚拟存储已在后端初始化前开启，并用编译后的形状初始化，避免先创建完整主机权重。
