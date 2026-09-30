# Tests

## Fast regression suite

```sh
bazel test //...
```

Seven C++ targets cover compilation, CPU output substitution, Virtual HBM,
raw-buffer ownership, runtime readiness, profiling and API error ownership.
Nine Python targets cover LLO program loading, control flow and timing, SparseCore,
profile metadata/import/reporting, collection and replay, the launcher. The collection suite also checks predictor fallback
and the difference between compile lookups and execution counts.

These targets need no hardware, captured profile or SGLang installation.
Native libtpu cases skip unless their explicit library environment is supplied.
The HLO-parser cases need installed jaxlib and can be run separately:

```sh
PYTHONPATH=python .venv/bin/python tests/python/profile_import_test.py -v
```

## Native integration

Use Python 3.12, JAX/jaxlib 0.11.1 and libtpu 0.0.48. Install
`requirements/profiling-requirements.txt` for XProf conversion and configure
SGLang-Jax as described in [dependencies](../docs/dependencies.md).

```sh
export SIM_PYTHON="$PWD/.venv/bin/python"
export PYTHONPATH="/path/to/sglang-jax/python${PYTHONPATH:+:$PYTHONPATH}"
export PJRT_SIM_LIBTPU_PATH="$PWD/.venv/lib/python3.12/site-packages/libtpu/libtpu.so"
export PJRT_SIM_TPU_TOPOLOGY=v5e:2x2
export TPU_WORKER_HOSTNAMES=localhost
export TPU_ACCELERATOR_TYPE=v5litepod-4
export NUMBA_CACHE_DIR=/tmp/sim-numba-cache
bash tests/run_tests.sh
```

The runner builds/tests the plugin and runs these integration checks sequentially
because libtpu takes a process lock even during offline compilation:

| File | Coverage |
| --- | --- |
| `smoke_test.py` | Device discovery, placeholder outputs, integer control, transfers and donation; also used to verify the release wheel |
| `tpu_compilation_test.py` | Real Final LLO compilation, delayed readiness, provenance, strict unresolved-cost rejection and conservative segment timing |
| `virtual_hbm_test.py` | Large logical tensors, Pallas, control flow, transfer lifetime and asynchronous completion |
| `memory_budget_test.py` | Per-device OOM, donation, copies and release with a self-configured tiny capacity |
| `multidevice_test.py` | Topology, integer collectives, virtual tensor parallelism, resharding and distributed Pallas |
| `profiler_smoke_test.py` | Real PJRT events through XProf conversion, correlation, device tracks and session isolation |
| `sglang_smoke_test.py` | Serving requests, overlap, future-token reuse, prefix cache and optional XProf validation |

The default `configs/bundle_timing_example.json` is explicitly uncalibrated and
allows partial cost estimates. Missing branch delays need an explicit profile
value; the v5e compilation check supplies a six-slot assumption. Unknown loop
bounds and scalar-analysis work limits still fail rather than returning a truncated estimate. Large-model
integration may hit these limits; see [timing limitations](../docs/bundle-timing.md#model).
Bundled profiles assume peers are ready: marked readiness polls run once with
zero external wait, while modeled DMA still counts. The timing JSON records this
assumption; it does not establish hardware timing accuracy.

On 2026-09-30, JAX/jaxlib 0.11.1 and libtpu 0.0.48 passed Virtual HBM 9/9 and
multi-device 9/9 at both TP2 and TP4 on the simulated TPU7x topology. This covers
decode, collectives, resharding and Pallas. Both memory-budget tests passed in
the 2026-09-29 audit. The full SGLang serving suite has not been rerun.

For just SGLang against an already-built plugin:

```sh
SIM_PROFILE=1 bash tests/run_libtpu_tests.sh
```

This defaults to TP1/2/4, with overlap for TP2/4. `SIM_TP_SIZES` must fit the
configured topology. `SIM_RESULTS_DIR` selects the artifact directory.
`SIM_MODEL=qwen3_moe`, `SIM_HIDDEN_SIZE`, `SIM_NUM_LAYERS`,
`SIM_INTERMEDIATE_SIZE` and `SIM_TEST_TIMEOUT` select larger serving experiments.
Dummy weights validate serving and simulator behavior, not numerical accuracy.

## Hardware measurements

See [collection](../docs/collection.md) for profiling your workloads and
[benchmark](../docs/benchmark.md) for prediction comparisons and recorded TPU
measurements. Keep captures, local paths, credentials and internal experiment
identifiers out of source control.
