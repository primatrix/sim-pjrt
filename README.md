<h1><img src="docs/images/logo.svg" alt="" width="28" height="28" align="absmiddle"> sim-pjrt</h1>

A PJRT plugin for simulating TPU workload execution and estimating performance
on CPU, without TPU hardware.

sim-pjrt uses libtpu to compile workloads (both JIT and AOT) for a target TPU
topology. It supports Final LLO timing estimates, measured timing replay,
Virtual HBM, and XProf traces. The `spjrt` launcher configures the backend for
existing Python programs, including supported JAX and SGLang-Jax workloads.

![sim-pjrt architecture](docs/images/architecture.svg)

## Installation

Requires **Linux x86-64** and **Python 3.12 or 3.13**. macOS, Windows, and ARM
are not currently supported. Release wheels require **glibc 2.34 or newer**;
local builds depend on the build environment.

For the current source version, install the [build tools](docs/building.md),
then run in the checkout root using your workload's Python environment:

```sh
python -m pip install .
spjrt doctor
```

`doctor` checks paths and configuration. See [Releases](https://github.com/primatrix/sim-pjrt/releases)
for prebuilt wheels; the older `0.1.0.dev1` wheel lacks collection, replay and
`--report`. See [package installation](docs/python-package.md#build-and-install)
to reuse an already-built plugin or build a wheel, and
[dependency compatibility](docs/dependencies.md) for the runtime baseline.

## Usage

`spjrt` defaults to **TPU v7x with 8 devices** (`tpu7x:2x2x1`). Launcher options
go before the script; arguments after it are passed through to your program.
Replace `workload.py` with your existing JAX program.

### Simulate execution

```sh
spjrt run workload.py
```

Add `--report` to save predicted durations, missing timing costs and memory use:

```sh
spjrt run --report ./run workload.py
cat ./run/summary.json
```

Use a new report directory for each run. The default `tpu7x` timing profile
provides approximate v7x estimates. Use `--timing-profile PATH` for your own
configuration, or `example` for the uncalibrated example. To change the target:

```sh
spjrt run --topology v5e:2x2 --devices 4 --timing-profile example \
  workload.py --batch-size 4
```

See [reports and measurements](docs/benchmark.md) for report fields, per-device
memory budgets and recorded TPU validation results.

### Export compilation artifacts

```sh
spjrt compile --output ./llo workload.py --batch-size 4
```

This exports Final LLO files and manifests for programs reached during simulated
execution, grouped by process. It requires no timing profile and applies no
simulated timing delays. Use an output path without spaces or quotes.

### Collect and replay measured timings

On a real TPU, install `xprof==2.23.1` and record a workload:

```sh
spjrt collect --record-identities --output ./capture workload.py
```

Copy the capture to the CPU host, then replay its measured device timings:

```sh
spjrt run --predictor replay --database ./capture/timings.json \
  --report ./replay workload.py
```

Use the same topology, device count and compiler versions as the capture.
Exact replay currently supports single-device executables. See
[collection and replay](docs/collection.md) for warmup, profile import and matching requirements.

### Run SGLang-Jax

Install SGLang-Jax separately in the same Python environment:

```sh
spjrt run python -m sgl_jax.launch_server \
  --model-path /path/to/model --tp-size 8 --load-format dummy
```

See the [workload guide](docs/plugin-guide.md) for model setup and XProf capture,
and [Python packaging](docs/python-package.md) for uv integration and launcher
configuration. Use `spjrt COMMAND --help` for all options.

## Scope and limitations

- **Timing:** estimates remain approximate. Instruction, DMA, synchronization
  and communication coverage is partial. Bundled profiles assume peers are
  ready, with no additional peer wait. CPU wall time is not a TPU measurement.
- **Outputs and memory:** Virtual HBM uses placeholders for floating-point
  payloads and retains CPU storage for control values. Simulation does not
  validate numerical results or model quality; data-dependent paths may differ.
- **Compatibility:** unsupported operations, unresolved control flow and missing
  compiler artifacts can prevent workloads from running.
- **Profiling:** simulated XProf traces display modeled activity. Replay uses
  captured device timings and does not include host dispatch overhead.

For details, see [bundle timing](docs/bundle-timing.md) and
[support boundaries](docs/site/src/content/docs/reference/limitations.md).
If a run fails, start with `spjrt doctor` and [troubleshooting](docs/plugin-guide.md#troubleshooting).
To [report an issue](https://github.com/primatrix/sim-pjrt/issues/new), include a
minimal reproducer, package versions, target topology and relevant error logs.

## Development

Build with Bazel 8.7.0 or Bazelisk on Linux x86-64:

```sh
bazel build //:plugin
bazel test //...
```

Bazel downloads the pinned XLA sources and toolchains and writes the native
plugin to `bazel-bin/pjrt_sim_plugin.so`. For a Docker build environment:

```sh
docker compose run --build --rm bazel build //:plugin
```

The Bazel suite covers native unit tests and Python model tests. Workload
integration tests require their documented Python environment; see [testing](tests/README.md).

- [Build prerequisites, Docker, and caches](docs/building.md)
- [Architecture](docs/compilation-architecture.md) and [timing reference](docs/bundle-timing.md)
- [Packaging and releases](docs/python-package.md)
- [Dependency versions](docs/dependencies.md)
- [中文文档](docs/site/README.md)

## TODO

- [ ] Extend real TPU validation to held-out shapes, topologies and serving workloads,
      and publish estimation errors.
- [ ] Complete DMA and synchronization coverage, model shared-link contention,
      and calibrate timing parameters.
- [ ] Fit operation timing models from collected samples and validate predictions
      for new shapes.

See the [detailed roadmap](docs/site/src/content/docs/development/roadmap.md).

## License

[Apache-2.0](LICENSE). See [dependency provenance](docs/dependencies.md).
