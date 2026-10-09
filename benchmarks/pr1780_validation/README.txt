PR 1780 full-configuration request validation

SGL source: 5f4acc7a2060571f119f5adfb7a8fa1f64d3d0c0.
Published simulator baseline: sim-pjrt v0.1.1, commit 9b21d0331551b99858632ba393218ba99757b22d.
Model revisions and downloaded metadata: /tmp/pr1780-validation/models.json.
Dependencies: /tmp/pr1780-validation/environment.txt.

The harness retains official model dimensions and uses dummy main-model weights.
It runs actual processors/tokenizers and HTTP /v1/chat/completions requests:
one image, unequal images, repeated images, supported video, and MiMo audio.
Each successful request must return HTTP 200, four completion tokens, and
finish_reason=length. The summary also checks encoder and decoder execution traces.
Gemma4's processor rejects video/audio in this SGL revision, so its cases are images.
MiMo uses its real audio tokenizer checkpoint for WAV preprocessing.

These are request-flow checks. Simulator output placeholders do not establish
numerical correctness. The explicit no-fault timing scenario retains timing gaps;
no measured or predicted hardware latency is validated. Wall times are host
initialization/compilation/request durations, not TPU latency.

The default topology is tpu7x:2x2x1, TP=8, logical HBM=1024 GiB/device.
Kimi uses tpu7x:4x4x1, TP=32 because this SGL version disables unsupported
pack-quantized weights and its full BF16 experts exceed the compiler HBM limit
at TP=8. Increasing xla_tpu_max_hbm_size_mib did not override the hardware limit.
Kimi also needs the separately recorded SGL weight-loading patch.

Run examples (requires the prepared environment and source worktree):
  /tmp/pr1780-validation/venv/bin/python benchmarks/pr1780_validation/run_model.py qwen25vl --port 31800
  /tmp/pr1780-validation/venv/bin/python benchmarks/pr1780_validation/run_model.py kimi --parser-fix --port 31807
  python benchmarks/pr1780_validation/summarize.py

Candidate runs can select an unpacked wheel with --package, its native plugin
with --plugin, and record the exact source revision with --build-commit.
The published package is never overwritten by a candidate run.

Results and all failed attempts live in /tmp/pr1780-validation/results/.
The aggregate /tmp/pr1780-validation/summary.json records per-model source fixes,
compiler flags, native artifact identity, response usage, and trace counts.

The harness terminates its server process group after collecting responses.
SIGTERM/libtpu shutdown diagnostics after the final response are cleanup output;
the recorded result status is determined before shutdown from request checks.
The case named repeat_cache repeats the same image request; success verifies
repeat-request completion, not a guaranteed cache hit for every model/backend.
Qwen3-VL and Qwen3.5 emit an FPS metadata warning for video inputs and fall back
to 24 FPS. These tests establish video request completion, not correct frame
timestamps. The warning is retained in the archived server logs.
