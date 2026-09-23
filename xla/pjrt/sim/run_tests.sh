#!/usr/bin/env bash
# Run from the sim-pjrt checkout in the configured Python environment.
set -euo pipefail

sim_python=${SIM_PYTHON:-python3}
sim_python=$("$sim_python" -c 'import sys; print(sys.executable)')
sim_results=${SIM_RESULTS_DIR:-/tmp/pjrt-sim-results}
sim_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)
cd "$sim_root"
mkdir -p "$sim_results"

"$sim_root/scripts/bazel" test -c opt //xla/pjrt/sim:hlo_model_test \
  //xla/pjrt/sim:profiler_test //xla/pjrt/sim:instrumentation_test \
  //xla/pjrt/sim:runtime_test //xla/pjrt/sim:execution_plan_test \
  //xla/pjrt/sim:virtual_storage_test \
  //xla/pjrt/sim:plan_export //xla/pjrt/sim:pjrt_sim_plugin.so //xla/pjrt/sim:xplane_descriptor --jobs=8 --test_output=errors --noannounce_rc

unset PJRT_SIM_PROFILE_PYTHON PJRT_SIM_PROFILE_HELPER
export JAX_PLATFORMS=tpu
export JAX_ENABLE_COMPILATION_CACHE=false
export PJRT_NAMES_AND_LIBRARY_PATHS="tpu:$sim_root/bazel-bin/xla/pjrt/sim/pjrt_sim_plugin.so"
export PJRT_SIM_DEVICE_COUNT=1
unset PJRT_SIM_TRACE PJRT_SIM_MAX_MATERIALIZED_BYTES

"$sim_python" xla/pjrt/sim/virtual_storage_test.py -v
"$sim_python" xla/pjrt/sim/program_snapshot_test.py -v
"$sim_python" xla/pjrt/sim/online_runtime_test.py -v
"$sim_python" xla/pjrt/sim/runtime_sensitivity_test.py -v
"$sim_python" xla/pjrt/sim/smoke_test.py -v
"$sim_python" xla/pjrt/sim/pallas_smoke_test.py -v
"$sim_python" xla/pjrt/sim/pallas_cost_test.py -v
JAX_PLATFORMS=cpu "$sim_python" xla/pjrt/sim/pallas_lowering_test.py -v
"$sim_python" xla/pjrt/sim/report_test.py -v
"$sim_python" xla/pjrt/sim/profile_report_test.py -v
"$sim_python" xla/pjrt/sim/virtual_clock_test.py -v
"$sim_python" xla/pjrt/sim/execution_plan_test.py -v
"$sim_python" xla/pjrt/sim/replay_test.py -v
"$sim_python" xla/pjrt/sim/device_load_test.py -v
"$sim_python" xla/pjrt/sim/xprof_export_test.py -v
"$sim_python" xla/pjrt/sim/native_profile_test.py -v
"$sim_python" -m pip check

# Use a fresh directory per run: traces from failed/previous runs must not be
# combined with the successful request's work.
sim_run=$(mktemp -d "$sim_results/run.XXXXXX")
for sim_devices in 1 2 4 8; do
  export PJRT_SIM_DEVICE_COUNT=$sim_devices
  sim_case="$sim_run/tp$sim_devices"
  mkdir -p "$sim_case"
  sim_args=(--tp-size "$sim_devices" --profile-dir "$sim_case/profile")
  if ((sim_devices > 1)); then
    "$sim_python" xla/pjrt/sim/virtual_multidevice_test.py -v
    PJRT_SIM_MAX_MATERIALIZED_BYTES=16777216 "$sim_python" xla/pjrt/sim/multidevice_test.py -v
    "$sim_python" xla/pjrt/sim/multidevice_test.py -v
    "$sim_python" xla/pjrt/sim/profiler_smoke_test.py --output "$sim_case/runtime-profile"
    sim_args+=(--overlap)
  fi
  export PJRT_SIM_TRACE="$sim_case/execution"
  timeout --kill-after=10 "${SIM_TEST_TIMEOUT:-180}" \
    "$sim_python" xla/pjrt/sim/sglang_smoke_test.py "${sim_args[@]}" \
    2>&1 | tee "$sim_case/sglang.log"
  unset PJRT_SIM_TRACE
  "$sim_python" xla/pjrt/sim/profile_report.py "$sim_case/profile" \
    --output "$sim_case/profile.report.json"
  for sim_trace in "$sim_case"/*.jsonl; do
    "$sim_python" xla/pjrt/sim/report.py "$sim_trace" --output "${sim_trace%.jsonl}.report.json"
    if ((sim_devices == 8)); then
      "$sim_python" xla/pjrt/sim/replay.py "$sim_case/profile" "$sim_trace" \
        --output "$sim_case/replay"
      "$sim_python" xla/pjrt/sim/replay.py "$sim_case/profile" "$sim_trace" \
        --output "$sim_case/replay-serial" --serial-dispatch
    fi
  done
done
"$sim_python" -m pip freeze > "$sim_run/requirements.txt"
echo "Validation artifacts: $sim_run"
