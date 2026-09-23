# Performance simulation iterations

Numerical correctness is outside this work. Keep the existing placeholders and
CPU control-data execution. Prefer small changes to the current plan, runtime
and reports, with hand-computed tests and explicit model limitations.

## 1. Pallas attention costs

Implemented in this iteration:

- Read the existing author-declared Pallas cost contract, including real JAX
  FlashAttention lowering, without parsing Mosaic instructions or guessing names.
- Feed counts into online completion, replay, profiling and device-load totals.
- Model transcendental throughput separately; expose rates for later calibration.
- Preserve unknown costs for missing metadata, internal communication and
  unsupported sharding.

Still needed for attention coverage: inspect the actual serving kernel profiles
and add narrowly scoped adapters for paged/ragged variants without metadata.
Dynamic work must use per-execution sequence lengths and batch composition;
allocated KV capacity is not the number of tokens accessed. A shape-only
estimate must be labeled as such rather than silently treated as active work.

## 2. Virtual time driving scheduling

This stage is not implemented by declared Pallas costs. Online execution still
uses real-time deadlines; offline replay still uses a fixed captured workload.

The next change needs an explicit cooperative boundary between the framework
scheduler and simulator:

1. Represent request arrivals, host submissions and device completions in one
   logical clock, with a stable tie-break order.
2. Run ready host/scheduler work before advancing to the next event. Register
   modeled dependencies for waits and callbacks; do not automatically jump time
   whenever a background timer happens to wake.
3. Let virtual completions release decode steps and influence admission/batching.
   CPU data may still be needed, but CPU execution time must not become TPU time.
4. Put virtual device timestamps in a separate profile domain. Do not clip virtual
   intervals against wall-clock profiler stop times or report CPU notification
   lag relative to a virtual epoch.

Acceptance: independent devices overlap; dependent work cannot start early;
callbacks can reenter safely; a late request and unequal decode lengths produce
hand-computed batch/finish sequences; adding host CPU delay does not change the
modeled result for the same declared arrivals and host costs. Retain real-time
mode as the integration baseline until these checks pass with the serving loop.

## 3. Communication and memory

Implemented foundation (2026-09-16): opt-in scalar-backed virtual storage for
large floating arrays with single-host SPMD execution. XLA partitions before
storage substitution; local logical shapes feed costs and buffer accounting.
Integer controls remain materialized. Directed all-to-all/permute payloads and
explicit full-group ring collectives are modeled online and in replay.
See README for restrictions and ITERATIONS for the 128 GiB model-state test.
This does not yet model physical HBM capacity or validate a complete large-model
serving framework.

Extend the existing resource model incrementally:

- Bring declared routes and directed link sharing into online execution.
- Charge collective endpoint HBM traffic and reduction arithmetic; avoid
  accidentally serializing simultaneous ring sends twice on a shared endpoint.
- Add subgroup collectives and only the resharding patterns verified by tests.
- Separate allocated/live bytes, logical traffic and modeled physical traffic.
- Add explicit KV read/write counts and kernel scratch where evidence supplies
  them. Avoid counting an entire aliased cache as a write on every decode step.

Acceptance: hand-computed two/four-device collectives, simultaneous DMA/compute
contention, late participant arrival, alias-aware KV updates, and report totals
matching the resource reservations. Cache reuse, VMEM and spill models should
be added only when the input exposes those details.

## 4. Real TPU calibration through Falcon

Hardware/cluster or an existing experiment ID is needed before remote runs.
Use the `falcon-workflow` operator profiling contract and declared analyzer
outputs. Do not use simulator/CPU wall-clock measurements as TPU observations.

Start with isolated attention across sequence length, batch, head count, dtype,
causal mode and kernel tiling. Preserve kernel/source revision, JAX/libtpu
versions, device topology, costs and warmup/repetition settings. Capture XProf
custom-call regions, and Mosaic/LLO evidence when available. Compare measured
device intervals with model intervals for the same invocation and local shape.

Fit only identifiable parameters: a uniform matrix of compute-bound kernels
cannot determine HBM bandwidth. Report held-out errors by shape/regime, not just
training error. Keep raw observations and assumptions beside calibrated rates;
test a serving workload on held-out settings before making end-to-end claims.

Each stage should remain reviewable on its own. A kernel with declared costs is
an estimate with known provenance, not proof of complete latency coverage.
