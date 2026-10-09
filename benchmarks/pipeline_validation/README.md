# TPU pipeline validation evidence

Read [the report](../../docs/tpu-pipeline-validation.md) before interpreting the numbers.
Independent hardware prediction has **not** passed validation.

## Current model and XProf alignment

The CLI now uses `sim_pjrt.llo.runtime` and the unified GF instruction pipeline;
the former `llo.cost` estimator is removed. Compiler costs and opcode mappings
are pinned to libtpu 0.0.48 under `configs/`.

For the current 2K best-kernel scenario:

| Mode | Kernel duration | Validation scope |
|---|---:|---|
| Default model | 119.766 μs | Uncalibrated issue costs |
| Optional empirical issue calibration | 153.335 μs | Same-capture held-out call; XProf 155.47 μs |

Use `best-kernel-xprof-calibrated-profile.json` explicitly for the calibrated
scenario. The cost source is `configs/tpu7x_xprof_issue_calibration.json`.
The generic default is unchanged. This is not independent hardware validation,
nor a measured hardware clock or causal stall model.

The reproducible analysis sequence is:

1. `capture_model_alignment.py`: export the selected model path and bundle times.
2. `match_xprof_timeline.py`: infer static opcode-context and dynamic occurrence
   correspondence; export matched and unmatched events plus an interactive chart.
3. `calibrate_issue_costs.py`: derive local issue floors from call 0/head 0 only.
4. Rerun the model with the generated profile; `validate_issue_alignment.py`
   evaluates the original fixed correspondences on held-out heads/calls.
5. `render_calibrated_timeline.py` and `export_model_trace.py`: render the rerun
   and export its own Chrome trace, without rematching hardware events.

Each script documents arguments with `--help`. Model runs and full LLO parsing
must use the lab's capped runner. Large raw captures and detailed timelines stay
in `.build/pipeline-validation/xprof-alignment/`; checked-in provenance, static
maps, coverage and validation summaries are in `results/xprof-alignment/`.
Absolute paths in evidence JSON are capture provenance, not portable fixtures.
See [the detailed report](../../docs/gf-compiler-costs.md) for scope, limitations,
matching checks and remaining initialization/head-transition errors.

## Earlier validation evidence

The subsequent [GF cost-table work](../../docs/gf-compiler-costs.md) adds a
binary-pinned extractor and asymmetric resource constraints. Reproduce with
`extract_gf_costs.py`; `compiler-cost-example.json` exercises table-backed costs
with explicitly illustrative footprints. Raw LLO opcode IDs are not table IDs.

- `input_manifest.json`: copied input SHA256 and source paths; large files stay in `.build/pipeline-validation/inputs/`.
- `plan.json`: work status and outstanding input requirements.
- `compiler-inventory*.json`: read-only Falcon inventory and its reproducible analysis specification.
- `analyze.py`: per-call/lane/phase audit, physical operand coverage, counter comparison and repeatability reference.
- `audit_xplane.py`: raw XPlane line/clock metadata audit.
- `results/{baseline,single_raw,dual_acc}.json`: independently parsed raw trace results.
- `results/hardware-counters.json`: capture-wide counters, with original descriptions.
- `results/observed-pipelines.{svg,png}`: reconstructed instruction event density, not occupancy or utilization.
- `example.json`, `results/example-*`: synthetic asynchronous scheduling demonstration, not hardware calibration.

Run large analysis through `~/lab/tpu-kernel-lab/lab capped` using commands in the report.
Render small result files using `python render.py results` with matplotlib/numpy.
CPU tests: `PYTHONPATH=python .venv/bin/python -m unittest discover -s tests/python -p 'pipeline*_test.py'` from the repository root.

The initial full remote LLO export was rejected by automatic approval review and
was not executed at that stage. The later explicitly authorized XProf download
used for the alignment above is recorded in `results/xprof-alignment/hardware-source.json`.

`extract_gf_mapping.py` produces the binary-pinned GF classifier map.
`execution-example.llo` runs directly through `sim_pjrt.llo.execution`, including
loop/phi/register/MRB dependencies; see `results/execution-example-{report,trace}.json`.
`audit_gf_mapping.py` measures static coverage under `lab capped`; the historical
GEMM result is not a matching attention capture or a timing validation.

`memory-push-example.llo` and `results/memory-push-example-*` demonstrate
pack, BF16 matpush and configured asynchronous DMA service; costs remain partial.
