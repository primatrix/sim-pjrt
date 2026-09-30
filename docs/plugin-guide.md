# Run workloads and inspect profiles

Install sim-pjrt in your workload's Python environment, then start with
`spjrt run workload.py`. See [installation](../README.md#installation).
The launcher sets up the simulated backend; manual PJRT environment variables
are unnecessary for normal use.

## SGLang-Jax

Install SGLang-Jax separately in the same environment; see the tested
[dependency versions](dependencies.md#python-runtime-baseline). Then run:

```sh
spjrt run python -m sgl_jax.launch_server \
  --model-path /path/to/model --tp-size 8 --load-format dummy
```

Replace `/path/to/model` with your model configuration/tokenizer directory.
`--tp-size` must fit the simulated device count. Dummy weights avoid loading
model weights; simulated outputs do not validate model quality.

## View a simulated XProf trace

Install `xprof==2.23.1`. In a single-process JAX workload, warm up the function
before tracing and wait for its results before ending the capture:

```python
with jax.profiler.trace("./profile"):
    result = compiled(*inputs)
    jax.block_until_ready(result)
```

Run the workload with `spjrt run`, then open the trace:

```sh
xprof server --logdir ./profile --port 8791
```

Open `http://localhost:8791` and select Trace Viewer.

| Track | What it shows |
| --- | --- |
| XLA Modules | Predicted duration of each compiled program |
| XLA Ops | Predicted operation intervals and missing-cost annotations |
| Host / PJRT | Time observed on the CPU running the simulator |

These views overlap; do not add their durations together. Host waits include
CPU scheduling and are not measured TPU delays. Add `--report ./run` to
`spjrt run` to save JSON reports for inspecting unresolved costs.

For SGLang capture, use its scheduler profiler; the configured
[integration runner](../tests/README.md#native-integration) supports
`SIM_PROFILE=1 bash tests/run_libtpu_tests.sh`. For real TPU measurements, use
[collection](collection.md).

## Troubleshooting

| Problem | What to check |
| --- | --- |
| Plugin or libtpu not found | Run `spjrt doctor` in the same environment; source builds can pass `--plugin` |
| Workload module not found | Install its dependencies in the environment containing `spjrt` |
| Floating outputs are zero | These are expected placeholders; simulation checks execution and timing |
| First run is slow | Compilation is included in CPU wall time; inspect the predicted durations in the report |
| Virtual HBM OOM | Reduce logical allocations or set the target's `--hbm-capacity-gib` / `--hbm-reserved-gib` |
| Bundle timing has unresolved semantics | Inspect the cost gaps; strict profiles reject them, partial profiles only time covered work |
| Unknown loop bound or analysis limit | This path is currently unsupported even with partial timing; simplify the workload |

For implementation details, see [architecture](compilation-architecture.md)
and the [timing reference](bundle-timing.md).
