#!/usr/bin/env bash
# Run the same build/test entry points in a disposable, versioned environment.
set -euo pipefail
sim_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
if [[ ${1:-} == --help ]]; then
  cat <<'HELP'
Usage: scripts/docker.sh [COMMAND [ARG...]]

Builds the development image and runs COMMAND in this checkout.
Default command: ./scripts/build.sh

Examples:
  ./scripts/docker.sh ./scripts/build.sh --jobs=8
  ./scripts/docker.sh ./scripts/test-python.sh
  ./scripts/docker.sh ./scripts/bazel test -c opt //xla/pjrt/sim:all --jobs=8
  ./scripts/docker.sh bash

Requires a local Docker daemon on Linux x86-64. No GPU is required.
Build state persists in .build/; containers are removed after each invocation.
HELP
  exit 0
fi
if [[ $(uname -s) != Linux || $(uname -m) != x86_64 ]]; then
  echo 'The Docker build environment currently supports Linux x86-64 hosts.' >&2
  exit 1
fi
sim_uid=$(id -u)
sim_gid=$(id -g)
sim_version=$(cat "$sim_root/.bazelversion")
sim_image="sim-pjrt-build:bazel-${sim_version}-${sim_uid}-${sim_gid}"
sim_cache="$sim_root/.build/docker-cache"
mkdir -p "$sim_cache"
docker build --platform linux/amd64 \
  --build-arg "BUILD_UID=$sim_uid" --build-arg "BUILD_GID=$sim_gid" \
  --tag "$sim_image" --file "$sim_root/docker/Dockerfile" "$sim_root"
if (( $# == 0 )); then
  set -- ./scripts/build.sh
fi
sim_terminal=()
if [[ -t 0 && -t 1 ]]; then sim_terminal=(-it); fi
# Identical absolute paths keep Bazel output symlinks valid on the host too.
exec docker run --rm --init "${sim_terminal[@]}" \
  --platform linux/amd64 \
  --mount "type=bind,source=$sim_root,target=$sim_root" \
  --workdir "$sim_root" \
  --env "XDG_CACHE_HOME=$sim_cache" \
  --env "SIM_BAZEL_OUTPUT_ROOT=$sim_cache/bazel" \
  --env SIM_BAZEL_BATCH=1 \
  "$sim_image" "$@"
