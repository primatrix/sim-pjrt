#!/usr/bin/env bash
# Run from the sim-pjrt checkout in the configured Python environment.
set -euo pipefail

sim_python=${SIM_PYTHON:-python3}
sim_python=$("$sim_python" -c 'import sys; print(sys.executable)')
sim_results=${SIM_RESULTS_DIR:-/tmp/pjrt-sim-results}
sim_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$sim_root"
export PYTHONPATH="$sim_root/python${PYTHONPATH:+:$PYTHONPATH}"
mkdir -p "$sim_results"

bazel test -c opt //:hlo_model_test \
  //:profiler_test //:instrumentation_test \
  //:runtime_test //:execution_plan_test \
  //:virtual_storage_test \
  //:plan_export //:pjrt_sim_plugin.so //:xplane_descriptor --jobs=8 --test_output=errors --noannounce_rc

unset PJRT_SIM_PROFILE_PYTHON PJRT_SIM_PROFILE_HELPER
export JAX_PLATFORMS=tpu
export JAX_ENABLE_COMPILATION_CACHE=false
export PJRT_NAMES_AND_LIBRARY_PATHS="tpu:$sim_root/bazel-bin/pjrt_sim_plugin.so"
export PJRT_SIM_DEVICE_COUNT=1
unset PJRT_SIM_TRACE PJRT_SIM_MAX_MATERIALIZED_BYTES

"$sim_python" tests/python/virtual_storage_test.py -v
"$sim_python" tests/python/program_snapshot_test.py -v
"$sim_python" tests/python/online_runtime_test.py -v
"$sim_python" tests/python/runtime_sensitivity_test.py -v
"$sim_python" tests/python/smoke_test.py -v
"$sim_python" tests/python/pallas_smoke_test.py -v
"$sim_python" tests/python/pallas_cost_test.py -v
JAX_PLATFORMS=cpu "$sim_python" tests/python/pallas_lowering_test.py -v
"$sim_python" tests/python/report_test.py -v
"$sim_python" tests/python/profile_report_test.py -v
"$sim_python" tests/python/virtual_clock_test.py -v
"$sim_python" tests/python/execution_plan_test.py -v
"$sim_python" tests/python/replay_test.py -v
"$sim_python" tests/python/device_load_test.py -v
"$sim_python" tests/python/xprof_export_test.py -v
"$sim_python" tests/python/native_profile_test.py -v
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
    "$sim_python" tests/python/virtual_multidevice_test.py -v
    PJRT_SIM_MAX_MATERIALIZED_BYTES=16777216 "$sim_python" tests/python/multidevice_test.py -v
    "$sim_python" tests/python/multidevice_test.py -v
    "$sim_python" tests/python/profiler_smoke_test.py --output "$sim_case/runtime-profile"
    sim_args+=(--overlap)
  fi
  export PJRT_SIM_TRACE="$sim_case/execution"
  timeout --kill-after=10 "${SIM_TEST_TIMEOUT:-180}" \
    "$sim_python" tests/python/sglang_smoke_test.py "${sim_args[@]}" \
    2>&1 | tee "$sim_case/sglang.log"
  unset PJRT_SIM_TRACE
  "$sim_python" python/profile_report.py "$sim_case/profile" \
    --output "$sim_case/profile.report.json"
  for sim_trace in "$sim_case"/*.jsonl; do
    "$sim_python" python/report.py "$sim_trace" --output "${sim_trace%.jsonl}.report.json"
    if ((sim_devices == 8)); then
      "$sim_python" python/replay.py "$sim_case/profile" "$sim_trace" \
        --output "$sim_case/replay"
      "$sim_python" python/replay.py "$sim_case/profile" "$sim_trace" \
        --output "$sim_case/replay-serial" --serial-dispatch
    fi
  done
done
"$sim_python" -m pip freeze > "$sim_run/requirements.txt"
echo "Validation artifacts: $sim_run"
