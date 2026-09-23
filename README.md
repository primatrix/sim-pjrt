# sim-pjrt

Explore how a TPU workload might run, using only a CPU.

sim-pjrt compiles supported JAX and SGLang-Jax programs with libtpu, supports
runtime JIT and ahead-of-time compilation, estimates time from Final LLO bundles,
and simulates outputs on CPU. TPU hardware is not required;
**libtpu is required at runtime**.
It can also export JIT compilation artifacts without estimating execution time.

![sim-pjrt architecture](docs/images/architecture.svg)

There is one timing route. Missing libtpu configuration, compilation failures,
and missing bundle artifacts are errors. There is no local HLO estimator or
Plan/replay fallback. CPU lowering still uses HLO internally for output simulation.

All device buffers use Virtual HBM, without a payload-size threshold. Floating
payloads use scalar placeholders; integer, boolean and single-value float control state retains CPU
shadow storage. D2H allocates host output on demand and models transfer time.
This does not validate numerical model accuracy or physical HBM behavior.
Bundle timing is partial and uncalibrated; strict profiles reject unresolved
semantics, while the named example explicitly allows partial estimates.

Launch and transfer timing use the same profile's `runtime` object.

See [compilation and configuration](docs/compilation-architecture.md),
[bundle timing](docs/bundle-timing.md), and [integration tests](tests/README.md).

## Build

```sh
bazel build //:plugin
bazel test //...
```

Requires Linux x86-64 and Bazel 8.7.0 (or Bazelisk). Bazel downloads the pinned XLA
source, Python and C++ toolchains, and dependencies automatically. First builds
need network access and native build prerequisites; `docker/Dockerfile` lists
the Ubuntu packages. Building requires no TPU/GPU hardware or CUDA. Running the plugin requires a
compatible `libtpu.so`. Package dependencies follow SGLang-Jax's TPU extra;
see the [current baseline and validation status](docs/dependencies.md#python-runtime-baseline).

The plugin is `bazel-bin/pjrt_sim_plugin.so`.
### Docker

Use the included development environment with Docker Compose:

```sh
docker compose run --build --rm bazel build //:plugin
docker compose run --rm bazel test //...
```

Run from the repository root on Linux x86-64. The image defaults to UID/GID 1000.
To match a different host user, set `BUILD_UID` and `BUILD_GID` in your environment
or a local `.env` file; see [building](docs/building.md). Caches persist under
`.build/docker-cache`, and outputs remain accessible in the checkout.

In an existing development container, run the same `bazel build //:plugin`
command from the mounted repository. No wrapper scripts are required.

## Use

### Python package launcher

Build a Linux x86-64 wheel (requires uv and the native build prerequisites):

```sh
uv build --wheel
uv pip install --python /path/to/venv/bin/python dist/sim_pjrt-0.1.0-py3-none-linux_x86_64.whl
```

The wheel includes the native plugin, timing tools and example configuration.
Its dependencies install the tested JAX/jaxlib and libtpu versions. No Bazel or
source checkout is needed to run an installed wheel. The package is not yet
published to a package index; use the local wheel above.

`spjrt` and `sim-pjrt` share the same CLI, defaulting to TPU v7x with 8 devices
(`tpu7x:2x2x1`). Override with `--topology` and `--devices`. Run a Python workload with:

```sh
spjrt run --timing-profile example your_script.py
```

`example` explicitly selects uncalibrated partial timing estimates. Pass a JSON
file instead for your own profile. The launcher locates its plugin and libtpu,
sets the backend environment before JAX starts, and uses its own Python environment.
Tool options go before the script; arguments after it are passed through unchanged.
The `--` separator is optional.

To export TPU Final LLO and per-compilation manifests without timing analysis or
simulated delays:

```sh
spjrt compile --output ./llo workload.py --batch-size 4
```

No workload code changes or timing profile are needed. Artifacts are grouped by
process under `./llo`; the output path must not contain whitespace or quotes.
Only reached JIT compilations are captured. Execution still uses virtual outputs,
so data-dependent paths may differ from real model execution.

SGLang-Jax is installed separately in the same environment; there is no extra:

```sh
spjrt run --topology v5e:2x2 --devices 4 --timing-profile example \
  python -m sgl_jax.launch_server --model-path /path/to/model --tp-size 4 --load-format dummy
```

With uv, add the wheel to your workload project using `uv add /path/to/wheel.whl`,
then use `uv run spjrt run ...` or `uv run spjrt compile ...`. Install SGLang-Jax as a dependency of that
project as well. See [Python packaging](docs/python-package.md) for configuration,
build options and validation boundaries.

### Manual environment

In a Python environment with JAX/jaxlib 0.11.1:

```sh
export PYTHONPATH="$PWD/python${PYTHONPATH:+:$PYTHONPATH}"
export JAX_PLATFORMS=tpu
export JAX_ENABLE_COMPILATION_CACHE=false
export PJRT_NAMES_AND_LIBRARY_PATHS="tpu:$PWD/bazel-bin/pjrt_sim_plugin.so"
export PJRT_SIM_DEVICE_COUNT=1
export PJRT_SIM_LIBTPU_PATH="$PWD/.venv/lib/python3.12/site-packages/libtpu/libtpu.so"
export PJRT_SIM_TPU_TOPOLOGY=v5e:2x2
export PJRT_SIM_BUNDLE_PROFILE="$PWD/configs/bundle_timing_example.json"
export PJRT_SIM_BUNDLE_PYTHON="$PWD/.venv/bin/python"
export TPU_SKIP_MDS_QUERY=1
export TPU_WORKER_HOSTNAMES=localhost
export TPU_ACCELERATOR_TYPE=v5litepod-4
python tests/python/smoke_test.py -v
```

The `tpu` setting tells JAX to use the simulator; it does not require a real TPU.
See the [plugin guide](docs/plugin-guide.md) for supported workloads, configuration,
and SGLang-Jax setup. The Docker image includes build tools; install the Python
runtime separately to run workloads.

## Layout

```text
src/             C++ plugin, libtpu adapter and runtime
python/          Pure bundle estimator and XProf report reader
tests/cpp/       Native unit tests
tests/python/    Python model and JAX/SGLang tests
configs/         Example bundle timing profile
requirements/    Python integration environment constraints
docs/            Guides, design notes, and documentation site
docker/          Bazel development image
third_party/     Pinned XLA dependency overrides and patches
```

Native targets are declared in the root `BUILD.bazel`. Python tools and tests
have their own Bazel packages. To run Python tests directly, set
`PYTHONPATH="$PWD/python${PYTHONPATH:+:$PYTHONPATH}"` from the repository root.
Analysis CLIs can be invoked directly, for example `python python/bundle_timing.py --help`.

## Development

- [Building, Docker, and caches](docs/building.md)
- [clangd setup](docs/building.md#clangd): `bazel run //:refresh_compile_commands`
- [XLA pin and dependency maintenance](docs/dependencies.md)
- [Chinese documentation site](docs/site/README.md)

`bazel test //...` runs native unit tests and fast Python model tests. The complete
JAX/SGLang matrix requires its documented Python environment and is run separately:

```sh
SIM_PYTHON=/path/to/python bash tests/run_tests.sh
```

## License

Apache-2.0. See [LICENSE](LICENSE). Third-party dependency provenance is documented
in [dependencies](docs/dependencies.md).
