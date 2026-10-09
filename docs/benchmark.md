# Read reports and compare predictions

## Check a workload

```sh
spjrt run --report ./run workload.py
cat ./run/summary.json
```

Choose a new report directory. Start with these fields in `summary.json`:

| Field | What to look for |
| --- | --- |
| `programs` | Predicted duration in nanoseconds for each compiled program |
| `replay_hit_rate` | Fraction of replay lookups that found a measurement |
| `executions_with_cost_gaps` | Executions with incomplete estimates; inspect the per-program reports |
| `device_memory` | Current and peak logical memory use per device |

A missing-cost count does not tell you how much time is missing. Device predictions
also omit host overhead. See [collection](collection.md) to use measured replay.

## Set the memory budget

```sh
spjrt run --hbm-capacity-gib 96 --hbm-reserved-gib 4 workload.py
```

These values apply per device. Defaults are 96 GiB capacity and no reservation.
Exceeding the available budget fails with `RESOURCE_EXHAUSTED`. This accounts
for logical application allocations; compiler scratch space and fragmentation
are outside the model.

## Recorded 7B validation

This experiment used pretrained `Qwen/Qwen2.5-7B-Instruct` in BF16 with ordinary
JAX/XLA attention, a donated KV cache, batch one and one device. Each request was
one prefill plus 32 decode calls. Downloads, compilation and two warmup sequences
were excluded. Three profiled sequences supplied calibration, five unprofiled
sequences measured host latency, and two held-out profiles validated device timing.

Hardware baseline: 2026-09-29, one TPU7x device in a v7x 2x2x1 host,
JAX/jaxlib 0.11.1, libtpu 0.0.48, 7,615,616,512 parameters, model revision
`a09a35458c702b33eeacc393d103063234e8bc28`. The LLO column reanalyzes the same
cached compilation with the conservative segment policy and `configs/tpu7x.json`.

| Phase | Replay | LLO modeled cost | Held-out device median | Unprofiled host median |
| --- | ---: | ---: | ---: | ---: |
| Prefill, 1,024 tokens | 22.253371 ms | 15.262076 ms | 22.257090 ms | 23.718287 ms |
| One decode step | 5.822982 ms | 4.206781 ms | 5.822254 ms | 6.426703 ms |

Replay's complete device-only request is 208.589 ms, versus 230.282 ms measured
from the host. Host dispatch/synchronization costs are omitted and the remaining
gap is not fully attributed. These samples validate reuse for this exact workload
and environment, not accuracy across different workloads or contention.

Both LLO estimates remain partial: missing instruction, synchronization and DMA
semantics prevent a hardware upper bound. The locally selected branches may
not form one feasible input path. See [timing semantics](bundle-timing.md#model).

## Multimodal request validation

See the [PR 1780 validation report](pr1780-validation.md) for full-configuration
multimodal request results, issue ownership between SGLang JAX and sim-pjrt,
required fixes, and remaining timing and video metadata limitations.

## TPU pipeline validation

See the [TPU7x pipeline validation report](tpu-pipeline-validation.md) for copied
XProf captures, instruction/counter coverage, pipeline scheduling improvements,
repeatability checks, and the remaining gaps before independent hardware prediction.
