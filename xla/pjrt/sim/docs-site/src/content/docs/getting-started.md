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

三种方式共用固定的 XLA 版本和同一套构建目标，选择适合当前环境的一种即可。

### 使用仓库提供的 Docker 环境

宿主机只需 Linux x86-64、Bash 和可用的本地 Docker 服务：

```sh
./scripts/docker.sh ./scripts/build.sh --jobs=8
```

脚本构建固定基础镜像和 Bazel 版本的开发镜像，以当前用户的 UID/GID 运行。
XLA 源码和编译缓存保留在 `.build/` 下，容器退出后不会丢失。

### 使用已有容器

在已配置好的容器内运行 `./scripts/build.sh --jobs=8`。例如：

```sh
docker exec -w /workspace/sim-pjrt xla ./scripts/build.sh --jobs=8
```

将 `xla` 和 `/workspace/sim-pjrt` 替换为实际容器名和挂载路径。
Git、Python、Bazel 等依赖只需在容器中准备。

### 直接在宿主机构建

需要 Linux x86-64、Git、Python 3.12+、Bazel 8.7.0（或 Bazelisk）和基础 C++ 构建工具：

```sh
./scripts/build.sh --jobs=8
```

三种方式均生成 `bazel-bin/xla/pjrt/sim/pjrt_sim_plugin.so`。
首次自动准备固定版本的 XLA，仅构建插件、原生规划工具、描述文件及其传递依赖。
无需 TPU、GPU、CUDA 或 `libtpu`。同一仓库在不同构建环境间应顺序使用，
需要并发构建时使用不同 checkout。

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
