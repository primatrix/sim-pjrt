# sim-pjrt

Explore how a TPU workload might run, using only a CPU.

sim-pjrt compiles supported JAX and SGLang-Jax programs with libtpu's offline
TPU compiler, estimates time from Final LLO bundles, and simulates
outputs on CPU. TPU hardware is not required; **libtpu is required at runtime**.

![sim-pjrt architecture](docs/images/architecture.svg)

There is one timing route. Missing libtpu configuration, compilation failures,
and missing bundle artifacts are errors. There is no local HLO estimator or
Plan/replay fallback. CPU lowering still uses HLO internally for output simulation.

All device buffers use Virtual HBM, without a payload-size threshold. Floating
payloads use scalar placeholders; integer and boolean control values retain CPU
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
compatible `libtpu.so` (tested with 0.0.48).

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
