#!/usr/bin/env bash
# Run against an already-built plugin and a configured SGLang-Jax environment.
set -euo pipefail
sim_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$sim_root"
: "${PJRT_SIM_LIBTPU_PATH:?Set the absolute path to libtpu.so}"
: "${PJRT_SIM_TPU_TOPOLOGY:?Set the offline TPU topology, e.g. v5e:2x2}"
sim_python=${SIM_PYTHON:-python3}
export PYTHONPATH="$sim_root/python${PYTHONPATH:+:$PYTHONPATH}"
export JAX_PLATFORMS=tpu JAX_ENABLE_COMPILATION_CACHE=false
export PJRT_NAMES_AND_LIBRARY_PATHS="tpu:$sim_root/bazel-bin/pjrt_sim_plugin.so"
export TPU_SKIP_MDS_QUERY=1
export PJRT_SIM_BUNDLE_PYTHON=${PJRT_SIM_BUNDLE_PYTHON:-$sim_python}
# This named example explicitly opts into uncalibrated partial bundle estimates.
export PJRT_SIM_BUNDLE_PROFILE=${PJRT_SIM_BUNDLE_PROFILE:-$sim_root/configs/bundle_timing_example.json}
unset PJRT_SIM_MAX_MATERIALIZED_BYTES
sim_results=${SIM_RESULTS_DIR:-/tmp/pjrt-sim-libtpu-results}
mkdir -p "$sim_results"
sim_run=$(mktemp -d "$sim_results/run.XXXXXX")
# The selected topology must have at least as many devices as each TP case.
for sim_devices in ${SIM_TP_SIZES:-1 2 4}; do
  sim_case="$sim_run/tp$sim_devices"
  mkdir -p "$sim_case"
  export PJRT_SIM_DEVICE_COUNT=$sim_devices
  export PJRT_SIM_TRACE="$sim_case/execution"
  sim_args=(--tp-size "$sim_devices" --model "${SIM_MODEL:-llama}")
  if [[ -n ${SIM_HIDDEN_SIZE:-} ]]; then
    sim_args+=(--hidden-size "$SIM_HIDDEN_SIZE")
  fi
  if ((sim_devices > 1)); then sim_args+=(--overlap); fi
  if [[ -n ${SIM_NUM_LAYERS:-} ]]; then sim_args+=(--num-layers "$SIM_NUM_LAYERS"); fi
  if [[ -n ${SIM_INTERMEDIATE_SIZE:-} ]]; then sim_args+=(--intermediate-size "$SIM_INTERMEDIATE_SIZE"); fi
  if [[ ${SIM_PROFILE:-0} == 1 ]]; then sim_args+=(--profile-dir "$sim_case/xprof"); fi
  timeout --kill-after=10 "${SIM_TEST_TIMEOUT:-300}" \
    "$sim_python" tests/python/sglang_smoke_test.py "${sim_args[@]}" \
    2>&1 | tee "$sim_case/sglang.log"
done
echo "Validation artifacts: $sim_run"
