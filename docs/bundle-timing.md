# Bundle timing

`python/bundle_timing.py` is a standalone, standard-library-only estimator. Its
core functions have no file access, global runtime state or classes:

```python
program = parse_bundles(dump_text)
path = expand_path([{"repeat": 4, "body": ["0:0x10", "0:0x11"]}])
report = estimate_bundles(program, hardware_profile, scenario)
```

The libtpu PJRT route now uses this estimator directly through a small subprocess
IO adapter; program timing uses only Final LLO bundles, with no HLO plan or local HLO timing route.
See [runtime integration](compilation-architecture.md) for configuration and the
strict/explicit-partial policy.

## Reproduce the checked example

```sh
PYTHONPATH=python python3 python/bundle_timing.py \
  tests/fixtures/bundles/pallas_add.txt \
  --profile tests/fixtures/bundles/example_profile.json \
  --scenario tests/fixtures/bundles/no_faults.json \
  --output /tmp/pallas-bundle-timing.json

PYTHONPATH=python python3 tests/python/bundle_timing_test.py -v
```

The fixture is the unedited final-bundle dump for `llo_demo_pallas_add`, produced
by `examples/dump_libtpu.py` with libtpu 0.0.48, JAX 0.11.1 and a compile-only
`v4:2x2x1` topology. The compiler's companion schedule analysis reports **34
scheduled bundles**. There are two transfers, each with size 8 granules; the
compiler comments independently give 4096 bytes for each array window.

The **illustrative, uncalibrated** profile assumes 1 GHz, one issue cycle per
bundle, 512 bytes per DMA granule, 100 GB/s HBM, 20 cycles of DMA latency, and
zero extra completion tail. Under those assumptions the result is:

- 34 issue cycles, 8192 bytes transferred.
- 118 additional wait cycles, after accounting for overlap.
- 152 modeled cycles / 152 ns. This is not a measured TPU latency.

Without the explicit `assume_no_faults` scenario, the conditional bounds-check
halts are reported as gaps. The dump's Python source line annotations refer to
the source at dump time, not a promise that future edits preserve those lines.

## Model

The parser accepts multiline `final_bundles` and `assembly-pre-overlay` syntax,
hex/decimal addresses, multiple instruction slots, empty bundles and multiline
comments. Addresses identify bundles: address gaps are **not** cycle gaps.
Malformed records and duplicate addresses are errors. Analyze each address
space/region in a single file; do not concatenate dumps with restarted numbering.

The estimator charges once per issued bundle, not once per instruction slot.
It assumes the compiler schedule covers internal instruction dependencies.
`bundle_issue_cycles`, `completion_tail_cycles`, and exact-opcode
`instruction_extra_cycles` are explicit hardware/model parameters. Extra delays
in parallel slots use the maximum, and overlap with blocking waits rather than
being added twice. `vdelay_semantics` must explicitly select `additional_cycles`
or `total_cycles`; this tool does not assert the hardware meaning of that opcode.

For final-bundle `dma.hbm_to_vmem` and `dma.vmem_to_hbm`, the estimator extracts a
constant granule count and destination completion flag. Each configured DMA
resource serializes transfers, while bundle execution can overlap the transfer.
A matching `dma.done.wait` stalls only until completion; outstanding transfers
also contribute to completion at the end. Constant `vsyncadd` credit decrements
allow reuse of flags. Unknown/partial credits, register-sized transfers, general
semaphore protocols and assembly `vwait` need additional information and remain
gaps. Configure `dma.<direction>.resource` to share or separate transfer engines.

The runtime consumes a manifest of `*-final_bundles.txt` files from one compile.
It expands reachable kernels at each TLP call site, including repeated calls,
and does not charge the inlined-call placeholder as an issued bundle. The report
records `bundle_stage=final_bundles`, `entry_file` and `final_bundle_files`.
Missing callees, recursion and unsupported co-issued calls fail explicitly.
Allocation identifiers are isolated per invocation; unresolved cross-call operand
bindings remain timing gaps, as do dynamic control flow and synchronization.

## Execution scenarios

Control flow is supplied as an executed path, not guessed from static addresses.
For loops and branches, `path` is an ordered address list and can contain nested
`{"repeat": N, "body": [...]}` blocks. Zero repetitions are allowed. Expansion
is bounded to one million visits. A path is user-supplied evidence/assumption;
the estimator does not prove it is feasible or execute scalar predicate code.

Optional scenario inputs:

- `predicates`: maps `"visit_index:instruction_index"` to a boolean indicating
  whether that predicated instruction executes. Missing decisions produce gaps.
- `inactive`: explicit instruction visits to skip.
- `assume_no_faults`: assume conditional bounds-check halts do not fire.
- `call_cycles`: additional callee cycles keyed by instruction visit; obtain
  these by analyzing the callee with its appropriate scenario.
- `wait_until_cycles`: absolute completion cycles for external synchronization,
  keyed by instruction visit. These can come from a separate communication model.

Indices are zero-based and refer to the expanded path and parsed slot list.
Every referenced path address and inactive visit is checked. Without a path,
the report describes a linear scan; encountered branches make it partial.

`status=modeled` means the supplied scenario and timing assumptions cover the
recognized operations. It does **not** mean hardware-calibrated or cycle-accurate.
With any semantic gap, `status=partial` and `estimated_seconds=null`;
`modeled_cycles`/`modeled_seconds` remain available as the accounted work, not
as a bound or a complete execution time. Reports include the profile, scenario,
per-bundle/per-DMA timeline, instruction counts and explicit gaps.

Current missing pieces include automatic scalar control-flow interpretation,
ISA-validated latency tables, general DMA/collective semaphore protocols,
branch/loop scenarios derived from model inputs, and cross-call operand bindings.
Until these are addressed, strict profiles reject affected programs; explicitly
partial profiles time only the accounted work.

The compiler’s `deduplication-map` associates call names with shared kernels.
This mapping is metadata only; all timing instructions come from Final LLO.
