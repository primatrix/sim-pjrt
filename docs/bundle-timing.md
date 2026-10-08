# Bundle timing

`python/bundle_timing.py` is the CLI entry point; `python/sim_pjrt/llo/` contains
parsing, control-flow analysis and timing. C++ invokes the entry point once during compilation, validates the report and retains
the duration and activities for execution. See [architecture](compilation-architecture.md).

## Reproduce the checked example

```sh
PYTHONPATH=python python3 python/bundle_timing.py \
  tests/fixtures/bundles/pallas_add.txt \
  --profile tests/fixtures/bundles/example_profile.json \
  --scenario tests/fixtures/bundles/no_faults.json \
  --output /tmp/pallas-bundle-timing.json
```

The Pallas vector-add fixture has 34 scheduled bundles and 8,192 DMA bytes.
Its illustrative profile assumes 1 GHz, one issue cycle per bundle, 512-byte DMA
units, 100 GB/s HBM and 20-cycle DMA startup. The result is 34 issue cycles plus
118 exposed wait cycles: 152 ns of modeled work, not a TPU measurement.
Without the no-faults scenario, conditional bounds-check halts remain gaps.

## TPU7x profile

`configs/tpu7x.json` assumes 2.2 GHz, 3.70 TB/s HBM bandwidth, 32-byte DMA units
and 512-byte transaction rounding. `dma_bytes` is payload; `dma_bus_bytes` is
rounded traffic. Address alignment, stride behavior, DMA startup, bundle issue
and runtime parameters are not independently calibrated.

Branch delay slots come from each instruction's `assembly-pre-overlay` output;
compiler compaction can shorten them. For v5e, the manifest's topology supplies
the four fixed slots omitted from assembly. Other captures without explicit
delays need a `branch_delay_slots` profile assumption. Assembly and target values
take precedence over the profile.

## Model

A compilation manifest contains Final LLO, assembly and the deduplication map.
Starting at TLP, the estimator expands reachable calls, including repeated calls;
inlined-call placeholders have no issue cost. Shared kernels retain call-site
identity and separate allocation names per invocation. Missing callees, recursion
and unsupported co-issued calls fail. HLO supplies metadata and provable loop
bounds, never TensorCore instruction costs.

Assembly alignment checks bundle counts, predicates and kernel-local targets
before loop expansion. Top-level far targets can wrap before overlays and are
excluded from address validation. Malformed records and alignment mismatches fail.
Bundle addresses identify locations; address gaps are not cycle gaps.

Known scalar values resolve arithmetic, phi nodes, spills/reloads, branches and
bounded loops. Allocation-relative VMEM pointers and clamped unsigned indices
can also prove loop bounds without knowing physical addresses or input values.
Pointer comparisons assume valid, nonwrapping VMEM addresses.
Predicates are sampled at branch issue, followed by the emitted
delay slots. Branches inside a pending delay window are unsupported. Named DMA
descriptor stores preserve distinct scalar spills; unresolved stores invalidate
scalar memory knowledge. Cross-call scalar argument bindings remain a gap.

Unknown runtime conditions use **conservative segment bounds**:

- Analyze both arms up to their first common continuation.
- Drain modeled DMA and MXU reservations at branch entry and each arm's end;
  charge the longer arm.
- Merge only scalar/spill facts and completion credits shared by every normally
  completing arm, then analyze the common suffix once.
- Exclude proven error-halt arms. Keep gaps from all analyzed arms, including
  those not selected. Unknown DMA sizes or synchronization remain gaps.

Separate segments can choose incompatible predicate outcomes and discard DMA
overlap. The result bounds covered model costs; missing costs prevent a hardware
bound. Even a complete modeled bound is not a certified hardware worst case.
The timeline and instruction/byte counts describe local choices, which may not
form one feasible input. Known predicates continue to follow their known outcome.

No complete path combinations are enumerated. `max_scalar_visits` defaults to
1,000,000 interpreted bundles per kernel analysis, including alternative arms.
Large loops with a proven constant trip count use an arbitrary iteration's
segment bound multiplied by the count, draining modeled resources between iterations. The
report records `runtime_loops`; the timeline shows one bounded iteration and an
aggregate for the rest. Loop-varying DMA operands remain explicit gaps.
The optimized HLO also proves the upper bound for `i = input; while i < input + N:
i += 1` when the input is invariant. A unique, unconditional body call binds
that bound to its LLO loop; unmatched loops keep the strict behavior.
The visit limit is an analysis budget, not a loop bound. Unknown trip counts,
repeated loop states and exhausted budgets still fail in partial mode.
Unknown phi data alone does not prevent analysis when
the loop's control remains provable.

The bundled profiles set `assume_peers_ready=true`: compiler-marked
`global-barrier-wait` polling loops run one protocol pass with zero external
readiness wait. Instruction issue, branch delay slots and modeled DMA still
count. The timing JSON records this assumption. Omit or disable the setting to
require a finite wait bound; it never bypasses unmarked compute loops.

### Issue, DMA and waits

The estimator charges once per issued bundle and assumes the compiler schedule
covers internal instruction dependencies. `bundle_issue_cycles`,
`completion_tail_cycles` and `instruction_extra_cycles` are profile parameters.
Parallel instruction extras use the maximum and overlap with waits.
`vdelay_semantics` must explicitly select `additional_cycles` or `total_cycles`.

The TPU7x profile also tracks **matmul throughput per MXU** (`mxu_model=gf`).
Ordinary F32, BF16 and native FP8 matmuls reserve their unit's throughput port
for 4, 8 and 8 cycles respectively. Independent MXUs overlap; existing bundle
spacing, delays and DMA waits hide reservations. Only the remaining wait is
added before the next conflicting bundle, including its co-issued DMA.
Branch/loop bounds drain these reservations along with DMA. Reports expose
`mxu_stall_cycles` (included in `wait_stall_cycles`) and
`mxu_completion_cycles` (included in `completion_cycles`).

These are throughput constraints, **not** per-instruction result latencies.
The [GF reservation analysis](https://gh.evko.io/crucible-notes/libtpu/cost/mxu-latency-gf.html)
describes libtpu 0.0.40. We checked its constants against libtpu 0.0.46.1:
`MatmulDataFormat` 1 is F32 and 2 is BF16, unlike the page's labels.
The model does not add 211/204 cycles to each matmul. Result dependencies still
rely on compiler scheduling. Full MXU sub-resource conflicts, staging/latch
sequences and MRB result availability remain future work. Unsupported formats,
modifiers or missing unit IDs remain gaps; other targets keep their existing
profile behavior. These compiler-derived constants are not hardware calibration.

For `dma.hbm_to_vmem` and `dma.vmem_to_hbm`, resolved granule counts and completion
flags determine transfers. Each configured DMA resource serializes its work,
while bundle execution can overlap transfers. Startup is charged per transfer;
transaction rounding changes traffic, not completion credits. `dma.done.wait`
waits for enough credits, including primed flags and partial completions.
Transfers sharing a resource contend; distinct resource names model independent
engines. Outstanding DMA completes before the program ends. Unresolved flag
updates or waits remain gaps, but a known transfer still consumes bandwidth
and contends for its resource even when its completion flag is unresolved.
An optional per-direction `vmem_bytes_per_second` limits the VMEM side;
transfer time uses the slower interface. All rates are per modeled core.

For `dma.general`, typed addresses identify memory spaces. A known payload size
uses the same directional bandwidth model. Detailed DMA events retain source
and destination flags, descriptor address and overrides for diagnosis. Descriptor
stride/padding and source completion remain gaps; contiguous transfer semantics
are not assumed for the whole descriptor.
The reference's [window-cost model](https://gh.evko.io/crucible-notes/libtpu/cost/memory-bandwidth-latency-model.html)
motivates the two-interface limit. Its HLO-level fragmentation multipliers and
startup amortization are not applied to individual Final LLO instructions.

### Reports

Reports include the profile, scenario, counts, gaps and `activity_timeline`.
`runtime_branch_policy=segment_bound` and
`timing_semantics=conservative_modeled_cost` identify the default policy.
`runtime_segments` records joins, alternative costs and selected local maxima.

`status=modeled` means the recognized work is covered by the supplied assumptions.
With gaps, `status=partial` and `estimated_seconds=null`; `modeled_seconds` remains
the accounted work. Strict profiles reject gaps; `allow_partial` permits partial
estimates. Missing ISA/latency, DMA/synchronization and operand-binding semantics
are not replaced with guessed costs.

`--summary` streams call expansion and groups gaps by module, bundle and reason,
retaining occurrence counts and compact activities. Detailed mode keeps individual
events. Neither unique gap sites nor occurrence counts measure missing time.
Static bundle counts and dynamic visits are reported separately.

## Execution scenarios

An explicit scenario overrides automatic scalar path resolution. `path` lists
bundle addresses, optionally with nested `{"repeat": N, "body": [...]}` blocks.
Zero repetitions are allowed; expansion is limited to one million visits.
A supplied path is an assumption whose feasibility the estimator does not prove.
Explicit scenarios do not reconstruct branch delays from assembly; that alignment
is required only for automatic path resolution. Reports record whether assembly
branch resolution was requested. Missing path decisions still produce gaps and
prevent a complete timing estimate.

| Input | Meaning |
| --- | --- |
| `predicates` | Boolean execution decisions keyed by `visit_index:instruction_index` |
| `inactive` | Instruction visits to skip |
| `assume_no_faults` | Assume conditional bounds-check halts do not fire |
| `call_cycles` | Additional callee costs keyed by instruction visit |
| `wait_until_cycles` | Absolute completion cycles for external synchronization |

Indices are zero-based on the expanded path and parsed slots. Invalid references
fail; missing decisions or costs remain gaps. Explicit scenarios preserve their
supplied path and overlap semantics. Without one, the segment policy above applies.

## XProf activities

`activity_timeline` uses executable-relative nanoseconds and survives `--summary`.
Native XProf projects it into XLA Modules/Ops/TraceMe; unresolved costs annotate
scopes. DMA, waits and control costs stay inside those scopes. Overlapping views
must not be summed as independent costs. Timing is never invented for display.

## SparseCore

Optional `sparsecore.operation_timings` supplies measured operation durations,
keyed by shape, layout, collective groups and core IDs. Calibration uses matching
**Sparse Core Ops** samples; module spans may contain input waits. SparseCore
instruction execution, startup, internal DMA and cross-device contention remain
unmodeled. Missing calibration or loop/call multiplicities remain gaps.

The default policy adds calibrated SparseCore work serially after TensorCore.
Each HLO conditional independently contributes its largest calibrated branch
cost, regardless of the selected TensorCore arm. It discards TC/SC overlap and
records choices in `sparsecore.runtime_segments`, with status
`serialized_calibrated_partial`. Measured durations are model parameters, not
proven hardware worst cases.

Explicit scenarios use the same SparseCore policy. `modeled_seconds` includes
added calibrated work; `tensorcore_base_modeled_seconds` and per-bundle events
retain the TensorCore cost.
