# Plugin guide

The plugin has one performance path: original StableHLO → libtpu TPU
compilation → Final LLO bundles → pure bundle timing → runtime completion.
CPU lowering provides control values and placeholder outputs with Virtual HBM.
HLO is only an internal representation for CPU output lowering; it is not a
performance model. See [compilation architecture](compilation-architecture.md).

This path supports runtime JIT during JAX/SGLang-Jax execution and explicit
ahead-of-time compilation via `.lower(...).compile()`. Both use libtpu without
requiring physical TPU hardware.

## Setup

Build with `bazel build //:plugin`. Use Python 3.12, JAX/jaxlib 0.11.1,
Flax 0.12.9 and libtpu 0.0.48 for the tested integration environment.
SGLang-Jax checkout: `cd0b4bf6d92d8aac9ba74ca329cd8f059a3859e4`.
Install its CPU runtime dependencies and the optional XProf dependencies in
`requirements/profiling-requirements.txt`. The build container supplies build
tools; it does not install this runtime environment.

Set the environment in [README](../README.md#use) before importing JAX.
`PJRT_SIM_LIBTPU_PATH` and `PJRT_SIM_TPU_TOPOLOGY` are required. Timing mode also
requires `PJRT_SIM_BUNDLE_PROFILE`. The selected topology must contain all simulated devices.

The example bundle profile explicitly permits partial, uncalibrated estimates.
A strict profile omits `allow_partial` or sets it to false. Unresolved control
flow, DMA/wait or instruction semantics then reject compilation. There is no
fallback estimator. See [bundle timing](bundle-timing.md).

## Export JIT artifacts without timing

```sh
spjrt compile --output ./llo workload.py --batch-size 4
```

`spjrt` is an alias for `sim-pjrt`; CLI defaults are `tpu7x:2x2x1` and 8 devices.
Tool options precede the script; all arguments after it are passed through.
`.py` files use the current Python interpreter; `--` is an optional separator.
The workload needs no code changes. Each process writes TPU Final LLO and a
per-compilation `*.manifest.json` under the output directory (no whitespace or quotes). Timing analysis,
launch delays and transfer delays are skipped; no timing profile is required.
Direct plugin users can set `PJRT_SIM_DUMP_DIR` to enable the same mode.
Only reached JIT compilations are captured. Execution still uses Virtual HBM
placeholders, so data-dependent paths need not match real model execution.

## Storage and execution

All device buffers use Virtual HBM, without a size threshold or a materialized
mode. Floating payloads use scalar placeholders. Integer, boolean and single-value float control
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
In Trace Viewer, `/device:TPU:N` contains native `XLA Modules`, `XLA Ops` and
`XLA TraceMe` lines. XProf derives `Framework Name Scope`, `Framework Ops` and
`Source code` from compiler debug labels when available. Observed submit-to-ready
intervals appear on PJRT lines in `/host:CPU`.
These use a shared clock but are distinct measurements: a long submit-to-ready
interval does not imply a long TPU transfer. CPU scheduling can delay notification.

`PJRT_SIM_TRACE=/path/execution` writes JSONL execution metadata and per-program
bundle reports. Reports retain the Final LLO source file list and optional TLP
HLO debug-label file paths. TensorCore timing uses Final LLO bundles. HLO supplies debug labels and
SparseCore dependency links; optional SparseCore operation timing uses explicitly
provided hardware calibration. For a host-observation summary:

```sh
python python/profile_report.py PATH --output profile-summary.json
```

Run [the test harness](../tests/README.md) for readiness, donation, Virtual HBM,
multi-device execution, SGLang overlap and native XProf validation.
