# Tests

`bazel test //...` runs six native test targets and three pure Python targets.
It covers CPU output substitution, Virtual HBM, bundle runtime readiness,
profiling, API error ownership, compilation validation and bundle estimation.
Real libtpu native compilation cases are optional in Bazel and run with an
explicit library/profile environment; there is no fake local estimator.

## Integration

The [installed Python package](../docs/python-package.md) also provides a direct
launcher integration check. With the wheel and SGLang-Jax installed in the same
environment, run:

```sh
SIM_HTTP_TP_SIZE=4 /path/to/venv/bin/python tests/python/serving_launcher_test.py
```

It starts a dummy-model HTTP server through `sim-pjrt run`, sends a token-ID
request, checks bundle provenance, and tests SIGTERM shutdown. No tokenizer
download is needed. Artifacts remain under `/tmp/sim-pjrt-http-*`.

Use Python 3.12 with JAX/jaxlib 0.11.1, Flax 0.12.9, libtpu 0.0.48 and
SGLang-Jax checkout `cd0b4bf6d92d8aac9ba74ca329cd8f059a3859e4`.
Install `requirements/profiling-requirements.txt` for XProf validation.

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

The script builds/tests the plugin, runs JAX control/donation/transfers,
Virtual HBM, Pallas, real offline TPU compilation, multi-device execution,
and SGLang requests. It defaults to the explicitly partial
`configs/bundle_timing_example.json`; set `PJRT_SIM_BUNDLE_PROFILE` for another
profile. The compilation integration test checks delayed readiness, 32 MiB D2H,
Final LLO provenance, and strict rejection of unresolved timing semantics.
Oversized weight tests use 512 MiB total weights so the real TPU compiler can
accept the fixture within the selected topology's memory constraints.

For only the serving matrix using an already-built plugin:

```sh
bash tests/run_libtpu_tests.sh
```

This defaults to TP1/2/4, with overlap for TP2/4. Every execution must use
`libtpu_bundles`. Each overlap case completes 11 requests including prefill,
decode, unequal concurrent lengths, future-token reuse, prefix caching and flush.

A large-model profile uses the same environment:

```sh
SIM_TP_SIZES=4 SIM_HIDDEN_SIZE=4096 SIM_NUM_LAYERS=32 \
SIM_INTERMEDIATE_SIZE=11008 SIM_PROFILE=1 SIM_TEST_TIMEOUT=1800 \
  bash tests/run_libtpu_tests.sh
```

This is a Llama-sized trunk with a small test vocabulary and dummy/virtual
weights. The harness warms a full request round and flushes the cache before
profiling a second full round. It checks that capture contains no backend
compilation, async lanes do not cross, and model durations match bundle reports
inside their correlated submission-to-completion spans.

`SIM_RESULTS_DIR` selects the artifact parent directory; each run gets a fresh
subdirectory. `SIM_TP_SIZES` must fit the topology. Run libtpu cases sequentially
because the library takes a process lock even during offline compilation.

For a two-layer Qwen3 MoE case (128 experts, top-8, expert width 768):

```sh
SIM_MODEL=qwen3_moe SIM_TP_SIZES=4 SIM_HIDDEN_SIZE=2048 SIM_NUM_LAYERS=2 \
SIM_PROFILE=1 SIM_TEST_TIMEOUT=1800 bash tests/run_libtpu_tests.sh
```

This uses dummy weights and Virtual HBM. It validates serving control flow,
Final LLO compilation and profiling, not checkpoint accuracy or real expert load.
When profiling, `model_config.json` is saved alongside the XProf directory.
