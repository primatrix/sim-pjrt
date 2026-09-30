# Collect and replay TPU timings

Use your existing JAX workload. Collection runs on real TPU; importing a saved
profile and replaying it can run on CPU. For XProf capture/conversion, install:

```sh
python -m pip install 'xprof==2.23.1'
```

## Collect a workload

On the TPU host:

```sh
spjrt collect --output ./capture workload.py
```

Use a new output directory. Results are `capture/timings.json`, the raw
`capture/profile/` and hardware/compiler information in `capture/context.json`.
The database contains measured program and operation times, plus available
shapes and dtypes. Run each compiled program repeatedly: the first invocation
is excluded from statistics by default (`--skip-first 0` keeps it).

## Import an existing profile

```sh
spjrt import-profile ./profile --output timings.json
```

The input can be an XProf directory, `.xplane.pb`, or Trace Viewer JSON/gzipped
JSON. Use a new output file. Plain JSON import does not require XProf.
If shapes or computation bodies are missing, add optimized HLO from that run:

```sh
spjrt import-profile ./profile --hlo ./optimized-hlo --output enriched.json
```

## Replay measured timings

On TPU, record the compilation identities needed for matching:

```sh
spjrt collect --record-identities --output ./capture workload.py
```

Copy `capture/` to the CPU host, then run the same workload:

```sh
spjrt run --predictor replay --database capture/timings.json \
  --report ./replay workload.py
```

Match the capture's TPU topology/device count and JAX/jaxlib/libtpu versions.
Add `--topology` and `--devices` before the script if the defaults differ.
Replay uses median device timings; inspect `replay/summary.json` for hits and
missing costs. Host dispatch and synchronization overhead are separate.

## Common issues

| Problem | What to do |
| --- | --- |
| Output already exists | Choose a new output path |
| No retained samples | Execute the compiled program more than once, or use `--skip-first 0` |
| No exact replay identities | Collect with `--record-identities`; ordinary profile IDs are insufficient |
| Replay miss | Match shapes, compiler options and target, or collect that configuration |
| Want LLO fallback on a miss | Add `--replay-miss llo` before the script; invalid measurements still fail |

Collection supports one process and keeps each device's samples separate.
Exact replay currently requires each executable to use one device. New-shape
prediction, cross-host alignment and SparseCore import are not implemented.
Use `spjrt collect --help` or `spjrt import-profile --help` for additional options.
