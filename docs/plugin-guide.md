# Plugin guide

The plugin has one performance path: original StableHLO → libtpu offline TPU
compilation → Final LLO bundles → pure bundle timing → runtime completion.
CPU lowering provides control values and placeholder outputs with Virtual HBM.
HLO is only an internal representation for CPU output lowering; it is not a
performance model. See [compilation architecture](compilation-architecture.md).

## Setup

Build with `bazel build //:plugin`. Use Python 3.12, JAX/jaxlib 0.11.1,
Flax 0.12.9 and libtpu 0.0.48 for the tested integration environment.
SGLang-Jax checkout: `cd0b4bf6d92d8aac9ba74ca329cd8f059a3859e4`.
Install its CPU runtime dependencies and the optional XProf dependencies in
`requirements/profiling-requirements.txt`. The build container supplies build
tools; it does not install this runtime environment.

Set the environment in [README](../README.md#use) before importing JAX.
`PJRT_SIM_LIBTPU_PATH`, `PJRT_SIM_TPU_TOPOLOGY` and `PJRT_SIM_BUNDLE_PROFILE`
are required. The selected topology must contain all simulated devices.

The example bundle profile explicitly permits partial, uncalibrated estimates.
A strict profile omits `allow_partial` or sets it to false. Unresolved control
flow, DMA/wait or instruction semantics then reject compilation. There is no
fallback estimator. See [bundle timing](bundle-timing.md).

## Storage and execution

All device buffers use Virtual HBM, without a size threshold or a materialized
mode. Floating payloads use scalar placeholders. Integer and boolean control
values retain CPU shadow storage. D2H copies control values or fills floating
placeholders in a host destination; it does not reconstruct real model data.
Device pointers cannot be exported. See [compilation architecture](compilation-architecture.md).

Input dependencies, per-device execution ordering, program duration and CPU
completion all gate readiness. Program timing comes from the bundle profile.
Launch and explicit PJRT transfers use the same profile's `runtime` object. Internal
collective semantics require bundle/scenario coverage; a coarse program interval
does not reconstruct network contention between programs.

## Profiling

Use JAX's profiler for a single-process JAX program. For SGLang, use the scheduler
profiler through `SIM_PROFILE=1 bash tests/run_libtpu_tests.sh`, with the environment
in [tests](../tests/README.md). The harness warms all request shapes before capture.

Open the resulting directory with `xprof server --logdir PATH --port 8791`.
In Trace Viewer, `Simulated TPU N` contains `Bundles`, `Launch` and `DMA`.
`Host completion / device N` contains observed submit-to-ready intervals.
These use a shared clock but are distinct measurements: a long submit-to-ready
interval does not imply a long TPU transfer. CPU scheduling can delay notification.

`PJRT_SIM_TRACE=/path/execution` writes JSONL execution metadata and per-program
bundle reports. Reports retain the Final LLO source file list. No TPU HLO or plan
snapshot is produced. For a host-observation summary:

```sh
python python/profile_report.py PATH --output profile-summary.json
```

Run [the test harness](../tests/README.md) for readiness, donation, Virtual HBM,
multi-device execution, SGLang overlap and native XProf validation.
