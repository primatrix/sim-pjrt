#!/usr/bin/env bash
# Assemble and validate a wheel using an already-built native plugin.
set -euo pipefail
cd /workspace
: "${SIM_PJRT_PLUGIN_PATH:?A validated native plugin is required}"
test -f "$SIM_PJRT_PLUGIN_PATH"

python -m venv /tmp/wheel-build
/tmp/wheel-build/bin/python -m pip install build auditwheel patchelf
export SIM_PJRT_PLUGIN_PATH
/tmp/wheel-build/bin/python -m build --wheel --outdir /tmp/raw-wheel
/tmp/wheel-build/bin/auditwheel show /tmp/raw-wheel/*.whl
/tmp/wheel-build/bin/auditwheel repair --plat manylinux_2_34_x86_64 \
  --only-plat --wheel-dir /workspace/dist /tmp/raw-wheel/*.whl
/tmp/wheel-build/bin/auditwheel show /workspace/dist/*.whl

# Test installed modules outside the checkout, including all offline regressions.
python -m venv /tmp/wheel-test
/tmp/wheel-test/bin/python -m pip install /workspace/dist/*.whl 'protobuf>=6.32.1'
/tmp/wheel-test/bin/python -m pip check
cp tests/python/smoke_test.py /tmp/sim_smoke_test.py
cd /tmp
env -u PYTHONPATH /tmp/wheel-test/bin/python - <<'PY'
import importlib.util
import json
import os
from pathlib import Path
import re
import unittest

from sim_pjrt.llo import gf_rules
from sim_pjrt.llo.runtime import compiler_mapping

package = Path(gf_rules.__file__).resolve().parents[1]
assert str(package).startswith('/tmp/wheel-test/'), package
assert not (package / 'llo/cost.py').exists()
for name in ('tpu7x.json', 'bundle_timing_example.json',
             'gf_costs_libtpu_0_0_48.json', 'gf_mapping_libtpu_0_0_48.json'):
    assert json.loads((package / 'configs' / name).read_text()) == json.loads(
        (Path('/workspace/configs') / name).read_text()), name
spec = importlib.util.find_spec('libtpu')
os.environ['PJRT_SIM_LIBTPU_PATH'] = str(
    Path(next(iter(spec.submodule_search_locations))) / 'libtpu.so')
mapping, gaps = compiler_mapping({})
assert not gaps, gaps
assert len(mapping.costs.xlu_conflicts) == 56
suite = unittest.TestSuite()
build = Path('/workspace/tests/python/BUILD.bazel').read_text()
for name in re.findall(r'name = "([^"]+)"', build):
    if Path('/workspace/tests/python', name + '.py').is_file():
        suite.addTests(unittest.defaultTestLoader.discover(
            '/workspace/tests/python', pattern=name + '.py'))
result = unittest.TextTestRunner(verbosity=1).run(suite)
raise SystemExit(not result.wasSuccessful())
PY
env -u PYTHONPATH /tmp/wheel-test/bin/sim-pjrt run \
  --topology v5e:2x2 --devices 1 --timing-profile example -- \
  python sim_smoke_test.py
