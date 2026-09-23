#!/usr/bin/env bash
set -euo pipefail
sim_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
exec "$sim_root/scripts/bazel" build -c opt \
  //xla/pjrt/sim:pjrt_sim_plugin.so \
  //xla/pjrt/sim:plan_export \
  //xla/pjrt/sim:xplane_descriptor "$@"
