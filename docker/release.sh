#!/usr/bin/env bash
# Build, audit and exercise the release wheel inside the manylinux container.
set -euo pipefail
cd /workspace
export XDG_CACHE_HOME=/workspace/.build/manylinux-cache
# Keep credentials out of command-line arguments and the shared cache.
bazel_startup=(--batch)
cache_flags=()
if [[ -n "${BUILDBUDDY_API_KEY:-}" ]]; then
  cache_rc=$(mktemp /tmp/buildbuddy.XXXXXX.bazelrc)
  trap 'rm -f "$cache_rc"' EXIT
  printf 'build --remote_header=x-buildbuddy-api-key=%s\n' "$BUILDBUDDY_API_KEY" > "$cache_rc"
  unset BUILDBUDDY_API_KEY
  bazel_startup+=(--bazelrc="$cache_rc")
  cache_flags=(--remote_cache=grpcs://remote.buildbuddy.io
               --remote_upload_local_results="${BUILDBUDDY_UPLOAD:-true}"
               --announce_rc=false)
fi
# Stop Bazel before the hosted job limit so completed actions can be saved.
# Bazel also gates scheduling on the memory budget; CPU count is the job ceiling.
timeout --signal=INT --kill-after=2m 5h bazel "${bazel_startup[@]}" test //:plugin //... \
  --jobs="$(nproc)" --local_resources=memory="${BAZEL_MEMORY_MB:-10000}" \
  --repository_cache=/workspace/.build/bazel-cache/repository \
  --disk_cache=/workspace/.build/bazel-cache/actions \
  --experimental_disk_cache_gc_max_size=5G "${cache_flags[@]}" || {
    status=$?
    if [[ "$status" == 124 || "$status" == 137 ]]; then
      echo "::error::Bazel exceeded its build time budget; saving completed actions in CI. Rerun the workflow to reuse the cache."
    fi
    exit "$status"
  }

# Reuse the native artifact; do not invoke Bazel from setuptools again.
python -m venv /tmp/wheel-build
/tmp/wheel-build/bin/python -m pip install build auditwheel patchelf
SIM_PJRT_PLUGIN_PATH=/workspace/bazel-bin/pjrt_sim_plugin.so \
  /tmp/wheel-build/bin/python -m build --wheel --outdir /tmp/raw-wheel
/tmp/wheel-build/bin/auditwheel show /tmp/raw-wheel/*.whl
/tmp/wheel-build/bin/auditwheel repair --plat manylinux_2_34_x86_64 \
  --only-plat --wheel-dir /workspace/dist /tmp/raw-wheel/*.whl
/tmp/wheel-build/bin/auditwheel show /workspace/dist/*.whl

# Test the repaired wheel, including separately installed libtpu, on glibc 2.34.
python -m venv /tmp/wheel-test
/tmp/wheel-test/bin/python -m pip install /workspace/dist/*.whl
/tmp/wheel-test/bin/python -m pip check
cp tests/python/smoke_test.py /tmp/sim_smoke_test.py
cd /tmp
env -u PYTHONPATH /tmp/wheel-test/bin/sim-pjrt run \
  --topology v5e:2x2 --devices 1 --timing-profile example -- \
  python sim_smoke_test.py
