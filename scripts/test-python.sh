#!/usr/bin/env bash
set -euo pipefail
sim_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
"${SIM_PYTHON:-python3}" -m unittest discover -s "$sim_root/tests" -v
cd "$sim_root/xla/pjrt/sim"
exec "${SIM_PYTHON:-python3}" -m unittest -v \
  virtual_clock_test report_test profile_report_test
