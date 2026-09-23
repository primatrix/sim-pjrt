# sim-pjrt

A PJRT plugin for simulating TPU workloads on CPU.

Run JAX and supported SGLang-Jax workloads without TPU hardware or `libtpu`.
The plugin uses XLA's CPU runtime, models HLO work, and provides profiling,
offline replay, and optional virtual storage. Floating-point results can be
placeholders; this is not a TPU compiler or a calibrated latency predictor.

## Build

```sh
bazel build //:plugin
bazel test //...
```

Requires Linux x86-64 and Bazel 8.7.0 (or Bazelisk). Bazel downloads the pinned XLA
source, Python and C++ toolchains, and dependencies automatically. First builds
need network access and native build prerequisites; `docker/Dockerfile` lists
the Ubuntu packages. No TPU, GPU, CUDA, or `libtpu` is required.

The plugin is `bazel-bin/pjrt_sim_plugin.so`.
For offline analysis tools, also build:

```sh
bazel build //:plan_export //:xplane_descriptor
```

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
python tests/python/smoke_test.py -v
```

The backend name `tpu`, `PJRT_SIM_*` settings, and plugin filename remain compatible.
See the [plugin guide](docs/plugin-guide.md) for supported semantics and the
SGLang-Jax integration environment. The build image does not install that runtime.

## Layout

```text
src/             C++ plugin and native planner
python/          Analysis, replay, and profiling tools
tests/cpp/       Native unit tests
tests/python/    Python model and JAX/SGLang tests
configs/         Example hardware and replay settings
requirements/    Python integration environment constraints
docs/            Guides, design notes, and documentation site
docker/          Bazel development image
third_party/     Pinned XLA dependency overrides and patches
```

Native targets are declared in the root `BUILD.bazel`. Python tools and tests
have their own Bazel packages. To run Python tests directly, set
`PYTHONPATH="$PWD/python${PYTHONPATH:+:$PYTHONPATH}"` from the repository root.
Analysis CLIs can be invoked directly, for example `python python/replay.py --help`.

## Development

- [Building, Docker, and caches](docs/building.md)
- [clangd setup](docs/building.md#clangd): `bazel run //:refresh_compile_commands`
- [XLA pin and dependency maintenance](docs/dependencies.md)
- [Chinese documentation site](docs/site/README.md)
- [Validation record](docs/migration-validation.md)

`bazel test //...` runs native unit tests and fast Python model tests. The complete
JAX/SGLang matrix requires its documented Python environment and is run separately:

```sh
SIM_PYTHON=/path/to/python bash tests/run_tests.sh
```

## License

Apache-2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).
