#!/usr/bin/env bash
# Native checks plus integration against the mandatory libtpu compiler.
set -euo pipefail
sim_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$sim_root"
sim_python=${SIM_PYTHON:-python3}
sim_python=$("$sim_python" -c 'import sys; print(sys.executable)')
: "${PJRT_SIM_LIBTPU_PATH:?Set the absolute path to libtpu.so}"
: "${PJRT_SIM_TPU_TOPOLOGY:?Set the offline TPU topology, e.g. v5e:2x2}"
export PYTHONPATH="$sim_root/python${PYTHONPATH:+:$PYTHONPATH}"
export PJRT_SIM_BUNDLE_PYTHON=${PJRT_SIM_BUNDLE_PYTHON:-$sim_python}
export PJRT_SIM_BUNDLE_PROFILE=${PJRT_SIM_BUNDLE_PROFILE:-$sim_root/configs/bundle_timing_example.json}
export TPU_SKIP_MDS_QUERY=1
bazel test //... --jobs="${SIM_BUILD_JOBS:-32}" --noannounce_rc
export JAX_PLATFORMS=tpu JAX_ENABLE_COMPILATION_CACHE=false
export PJRT_NAMES_AND_LIBRARY_PATHS="tpu:$sim_root/bazel-bin/pjrt_sim_plugin.so"
export PJRT_SIM_DEVICE_COUNT=1
unset PJRT_SIM_TRACE
"$sim_python" tests/python/smoke_test.py -v
PJRT_SIM_TEST_LIBTPU_PATH="$PJRT_SIM_LIBTPU_PATH" "$sim_python" tests/python/tpu_compilation_test.py -v
"$sim_python" tests/python/online_runtime_test.py -v
"$sim_python" tests/python/virtual_hbm_test.py -v
"$sim_python" tests/python/pallas_smoke_test.py -v
for sim_devices in ${SIM_TP_SIZES:-2 4}; do
  if ((sim_devices < 2)); then continue; fi
  export PJRT_SIM_DEVICE_COUNT=$sim_devices
  "$sim_python" tests/python/multidevice_test.py -v
  "$sim_python" tests/python/virtual_multidevice_test.py -v
  "$sim_python" tests/python/profiler_smoke_test.py \
    --output "$(mktemp -d /tmp/pjrt-sim-profile.XXXXXX)"
done
SIM_PYTHON="$sim_python" bash tests/run_libtpu_tests.sh
