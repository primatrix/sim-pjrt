# sim-pjrt

A PJRT plugin for simulating TPU workloads on CPU.

Run JAX and supported SGLang-Jax workloads without TPU hardware or `libtpu`.
The plugin uses XLA's CPU runtime for functional execution and models work from
HLO, with profiling, offline replay, and optional virtual storage for large tensors.
Floating-point results can be placeholders. This is a single-host simulator,
not a TPU compiler or a calibrated latency predictor.

## Build in your existing Docker container

Run the build inside the development container. Git, Python, Bazel, and the
build toolchain requirements below apply **inside the container**; they do not
need to be installed separately on the Docker host.

If your container is named `xla` and the original checkout is mounted at `/xla`,
the new nested repository is available at `/xla/sim-pjrt`:

```sh
docker exec -w /xla/sim-pjrt xla ./scripts/build.sh --jobs=8
```

Replace the container name and working directory with your actual setup. If
sim-pjrt is mounted separately at `/workspace/sim-pjrt`, use that path instead.
The container must be running and able to reach the dependency download sites.
Keep its Bazel cache persistent across container recreation to avoid repeated
cold builds. No GPU passthrough, TPU, CUDA, or `libtpu` is required.

For the full integration suite, use the Python environment inside that container:

```sh
docker exec -w /xla/sim-pjrt \
  -e SIM_PYTHON=/path/in/container/to/python \
  xla bash xla/pjrt/sim/run_tests.sh
```

The paths above are examples based on the earlier development guide, not a
verified description of a currently running container. The extraction checks
in `docs/migration-validation.md` ran on the host, not in Docker.

## Build directly (or from a container shell)

Supported build environment: Linux x86-64, Git, Python 3.12+, and Bazel 8.7.0
(or Bazelisk, which reads `.bazelversion`). The initial build needs network access,
a C++ build environment, and substantial disk/RAM for the XLA CPU dependency graph.

```sh
./scripts/build.sh --jobs=8
```

This fetches the exact upstream XLA commit in
[`third_party/xla.lock.json`](third_party/xla.lock.json), verifies its commit/tree,
and creates an ignored `.build/xla` workspace. It builds only the plugin,
`plan_export`, the XSpace descriptor, and their transitive dependencies.
It does not build all XLA targets. Repeated builds reuse Bazel's local cache.
The binaries are exposed at `bazel-bin/xla/pjrt/sim/`.

For an existing local XLA Git checkout containing the pinned commit, avoid fetching
XLA itself (Bazel's other dependencies may still need downloading):

```sh
python3 scripts/prepare.py --xla-git /path/to/xla-checkout
./scripts/build.sh --jobs=8
```

Only committed upstream content is exported; local changes in that checkout are
not copied. No parent checkout is required by this repository.

## Use

Use a Python environment with JAX/jaxlib 0.11.1. See the
[detailed guide](xla/pjrt/sim/README.md) for the tested SGLang-Jax revision and
pinned framework dependencies.

```sh
export JAX_PLATFORMS=tpu
export JAX_ENABLE_COMPILATION_CACHE=false
export PJRT_NAMES_AND_LIBRARY_PATHS="tpu:$PWD/bazel-bin/xla/pjrt/sim/pjrt_sim_plugin.so"
export PJRT_SIM_DEVICE_COUNT=1
python xla/pjrt/sim/smoke_test.py -v
```

The backend name `tpu`, `PJRT_SIM_*` settings, and `pjrt_sim_plugin.so` filename
are retained for compatibility. The project/repository name is **sim-pjrt**.

## Develop and test

```sh
# Fast Python tests: no XLA download, native build, or JAX required.
./scripts/test-python.sh

# Native unit tests (builds only this package's test targets and dependencies).
./scripts/bazel test -c opt //xla/pjrt/sim:all --jobs=8 --test_output=errors

# Full JAX/SGLang integration matrix; requires the documented Python environment.
SIM_PYTHON=/path/to/python bash xla/pjrt/sim/run_tests.sh
```

CI runs the fast tests and builds the documentation on pushes and pull requests.
The manually triggered native workflow builds and tests the plugin on a
self-hosted Linux x86-64 runner labelled `sim-pjrt` with sufficient resources and
Bazel 8.7.0 available. The full SGLang matrix is a separate environment-dependent
check; the fast tests do not substitute for it.

Pass Bazel options through `scripts/bazel` or `scripts/build.sh`, including
`--remote_cache=...` when a team cache is available. Configure credentials locally.
Do not commit machine-specific paths or credentials.

## Repository layout and XLA dependency

- `xla/pjrt/sim/`: plugin, analysis tools, tests, example hardware configurations,
  and Chinese documentation site.
- `scripts/`: source preparation and local build/test entry points.
- `third_party/xla.lock.json`: immutable upstream source pin, without vendored code.
- `build_tools/`: portable CPU build configuration.
- `docs/`: architecture and repository maintenance notes.

The source package retains `xla/pjrt/sim` so C++ includes and Bazel package
visibility work without rewriting XLA internals. Preparation links that package
into the disposable XLA workspace. XLA remains the Bazel root module: its
root-only dependency overrides, patches, and hermetic toolchains stay intact.
This is an intentional build integration, not a standalone `@xla` module migration.
No XLA source or history is tracked in this repository.

To upgrade XLA, update the commit, tree, and Bazel version together, move the old
`.build/xla` workspace aside, and run native and framework regression tests before
accepting the new pin. Changing XLA/toolchains may invalidate compilation caches.
See [dependency maintenance](docs/dependencies.md).

## Documentation

- [Plugin guide](xla/pjrt/sim/README.md)
- [Chinese documentation site](xla/pjrt/sim/docs-site/README.md)
- [Original design notes](docs/tpu_simulator_design.md)

## License

Apache-2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).
