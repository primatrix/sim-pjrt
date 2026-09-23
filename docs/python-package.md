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

Runtime dependencies follow SGLang-Jax's `jax[tpu]==0.11.1` extra, which selects
JAX/jaxlib 0.11.1 and libtpu 0.0.46.*, with Python >=3.12,<3.14.
See [dependency baseline](dependencies.md#python-runtime-baseline) for the upstream
revision and validation status; [integration setup](../tests/README.md) records
the previously tested environment.

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

Release wheels target `py3-none-manylinux_2_34_x86_64` (glibc >=2.34).
The native library uses PJRT's C ABI, not CPython's extension ABI. Local builds
still produce `linux_x86_64` wheels; only the release pipeline applies a manylinux
tag after `auditwheel repair --plat manylinux_2_34_x86_64 --only-plat` succeeds.
Unsupported symbol versions or missing required libraries fail the release.

The release image is based on PyPA's manylinux_2_34 x86-64 image. libtpu remains
a separate Python dependency; its wheels require glibc >=2.31, so the older
manylinux_2_28 runtime would not support the full dependency set. The repaired
wheel is installed and exercised with libtpu inside the glibc 2.34 container.
This also checks dependencies loaded through `dlopen`, which auditwheel cannot
fully validate. The package is not yet published to an index.

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

## Automated releases

The **Native build and release** GitHub Actions workflow runs on GitHub-hosted
Ubuntu 24.04 x86-64 runners; no self-hosted server or custom token is needed.
It builds the plugin in the manylinux container, runs native and Python tests,
packages and repairs the wheel, then installs it in a clean virtual environment
outside the checkout in the same container and runs the JAX simulation smoke
tests.

Pushes to `main` also run this workflow and save Bazel download and compiled-action
caches after successful validation. Tags and manual runs restore matching caches;
only runs on `main` update the shared cache. Keep `main` as the repository's default
branch so tag builds can access its caches.

The cache prefix tracks the manylinux platform/image, Bazel version/options,
dependency manifests and upstream patches. Each commit gets an immutable snapshot,
with a prefix fallback to earlier snapshots. Project source and release-script
changes do not invalidate that prefix: Bazel checks individual action inputs and
rebuilds only missing or changed actions. Cache eviction can still cause a cold
build; this is not a permanent prebuilt SDK.
The first hosted build still needs to establish that XLA fits the runner's
resource and time limits.

Use **Run workflow** on a branch to validate the pipeline and download its wheel
artifact without publishing. To release, update `pyproject.toml`'s version,
commit it, then push a matching tag, for example:

```sh
git tag v0.1.0
git push origin v0.1.0
```

A tag/version mismatch fails before compilation. After all checks pass, the
workflow creates a GitHub Release containing the Linux wheel and `SHA256SUMS`.
Prerelease tags such as `v0.2.0rc1` require the same version spelling
in `pyproject.toml` and are published as prereleases. Manual runs never publish.
The release job alone receives `contents: write` permission. The host runner
uses Ubuntu 24.04, while compilation, auditwheel repair and
runtime checks all run inside the manylinux_2_34 container. macOS is not supported.
The first hosted manylinux build has not yet been run.
