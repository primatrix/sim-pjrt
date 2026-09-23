# Python package and launcher

sim-pjrt is a Linux x86-64 Python package containing a native PJRT library.
It launches commands in a simulated TPU environment. SGLang-Jax remains a
separate dependency; the package has no SGLang extra and does not install it.

## Build and install

```sh
uv build --wheel
uv pip install --python /path/to/venv/bin/python dist/sim_pjrt-0.1.0-py3-none-linux_x86_64.whl
```

The setuptools build invokes `bazel build //:plugin`, then includes the resulting
library, Python analysis modules and example timing profile in the wheel.
To package an explicitly selected, already-built artifact without invoking Bazel:

```sh
SIM_PJRT_PLUGIN_PATH="$PWD/bazel-bin/pjrt_sim_plugin.so" uv build --wheel
```

The caller is responsible for ensuring that this artifact matches the source.
Source builds need the prerequisites in [building](building.md). Wheel installs
do not compile native code. Use wheel installs, or `uv run --no-editable` when
working in this repository: editable installs are not the supported route for
bundled native assets. Runtime paths never fall back to a source checkout.

The initial dependency set is JAX/jaxlib 0.11.1 and libtpu 0.0.48, with Python
3.12 as the tested interpreter. SGLang-Jax must be compatible with that set;
see [integration setup](../tests/README.md) for the tested checkout.

## Run

```sh
sim-pjrt run --topology v5e:2x2 --devices 4 --timing-profile example -- \
  python -m sgl_jax.launch_server \
  --model-path /path/to/model --tp-size 4 --load-format dummy
```

Install SGLang-Jax and its CPU dependencies in the same environment first.
Model/tokenizer files and server options belong to SGLang-Jax. The launcher
does not create model files or change its arguments. Dummy weights and simulator
placeholder outputs do not validate model accuracy.

For a workload managed by uv, run `uv add /absolute/path/to/sim_pjrt-0.1.0-py3-none-linux_x86_64.whl`
in that workload project, add SGLang-Jax there separately, then use
`uv run sim-pjrt run ...`. `uvx` uses an isolated tool environment and will not
automatically see a workload project's SGLang-Jax installation.

`run` accepts any executable after `--`. Bare `python` and `python3` select the
launcher's interpreter; its environment's executable directory is also prepended
to `PATH`. Arguments are passed literally without a shell. Linux `exec` preserves
exit codes and signals, and worker processes inherit the configured environment.
Importing `sim_pjrt` alone does not initialize JAX or change the environment.

## Configuration

CLI options override environment values. The launcher accepts:

| Option | Environment fallback | Default |
| --- | --- | --- |
| `--topology` | `PJRT_SIM_TPU_TOPOLOGY` | Required |
| `--devices` | `PJRT_SIM_DEVICE_COUNT` | 1 |
| `--timing-profile` | `PJRT_SIM_BUNDLE_PROFILE` | Required |
| `--plugin` | `SIM_PJRT_PLUGIN_PATH` | Bundled plugin |
| `--libtpu` | `PJRT_SIM_LIBTPU_PATH` | Installed libtpu library |

`--timing-profile example` explicitly selects the bundled, uncalibrated profile
that allows partial estimates. Otherwise supply a JSON path. This option does
not enable profiling. Existing options such as `PJRT_SIM_TRACE` remain available.
The native backend validates that the topology has enough devices.

The launcher sets `JAX_PLATFORMS=tpu`, the PJRT plugin mapping, disables the JAX
compilation cache, selects its interpreter for bundle analysis, and disables
TPU metadata queries. `TPU_WORKER_HOSTNAMES` defaults to `localhost`. Existing
workload-specific TPU settings are preserved.

Check resolved paths, versions and configuration without initializing JAX:

```sh
sim-pjrt doctor --topology v5e:2x2 --timing-profile example
```

This checks file presence and configuration, not binary loading or model support.
The top-level `bundle_timing` and `profile_report` modules are included for
compatibility with the native estimator subprocess and existing integration tools.

## Distribution validation

Wheels are tagged `py3-none-linux_x86_64`: the native library uses PJRT's C ABI,
not CPython's extension ABI. This is not a claim of manylinux compatibility.
Before a broader release, build against the chosen Linux baseline, run
`auditwheel show` (and repair where appropriate), and test installation and
execution in that baseline environment. `dlopen` dependencies such as libtpu
also need a runtime check. The package is not yet published to an index.

The initial local artifact's `auditwheel show` result requires at least glibc
2.27 for the bundled plugin. Its filename remains `linux_x86_64` until the full
runtime dependency set has been validated on a distribution baseline.

Launcher tests cover command arguments, interpreter selection, configuration
precedence, exit status and signals. Runtime validation should install the wheel
outside the checkout and run the existing JAX and SGLang-Jax integration tests.
The existing SGLang fixture exercises `Engine.generate()` with local dummy
models. An additional installed-package HTTP check starts a local dummy Llama
server, sends token IDs to `/generate`, checks libtpu bundle provenance, and
verifies shutdown on SIGTERM:

```sh
SIM_HTTP_TP_SIZE=4 /path/to/venv/bin/python tests/python/serving_launcher_test.py
```

SGLang-Jax must be installed in that environment. This check skips tokenizer
initialization and does not need downloaded model assets. Run libtpu integration
checks sequentially because libtpu takes a process lock.
