#!/usr/bin/env bash
# Build, audit and exercise the release wheel inside the manylinux container.
set -euo pipefail
cd /workspace
export XDG_CACHE_HOME=/workspace/.build/manylinux-cache
bazel --batch test //:plugin //... \
  --jobs=2 --local_resources=memory=10000 \
  --repository_cache=/workspace/.build/bazel-cache/repository \
  --disk_cache=/workspace/.build/bazel-cache/actions \
  --experimental_disk_cache_gc_max_size=5G

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
