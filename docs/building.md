# Building sim-pjrt

The native entry point is `scripts/build.sh`. It builds three targets: the PJRT
plugin, native plan exporter, and XSpace descriptor. Docker changes the execution
environment, not the source pin, targets, or compiler flags.

## Repository Docker environment

On Linux x86-64 with a local Docker daemon:

```sh
./scripts/docker.sh ./scripts/build.sh --jobs=8
./scripts/docker.sh ./scripts/bazel test -c opt //xla/pjrt/sim:all --jobs=8 --test_output=errors
```

`./scripts/docker.sh` without arguments defaults to the build command. Any supplied
command executes from the repository root inside the environment image:

```sh
./scripts/docker.sh ./scripts/test-python.sh
./scripts/docker.sh bash
```

The image contains Git, Python 3.12, Bazel 8.7.0, and basic native build utilities.
XLA supplies its hermetic C++ toolchain. JAX, SGLang, and the documentation's Node
packages are separate runtime/development dependencies, not part of this image.
For framework integration, create a Python environment following the plugin
guide, or use your existing framework container.

`docker/Dockerfile` pins the Ubuntu base digest. Bazel's version comes from
`.bazelversion` and its binary is verified against `docker/bazel.sha256`.
APT packages receive the selected Ubuntu repository's available updates; the
image recipe is not a byte-for-byte pin of all OS packages. To refresh OS packages,
rebuild the image without Docker's layer cache, using the same UID/GID build args
shown in `scripts/docker.sh`. Review base digest and checksum updates in Git.

The helper builds a local image, then starts an ephemeral container with the
caller's UID/GID (non-root for a normal user). It mounts only this repository,
using the same absolute path inside and outside the container so Bazel's output
symlinks also resolve on the host. It does not mount the Docker socket or require
privileged mode. A remote Docker daemon is not supported by this bind-mount helper.

## Existing container

Use the native entry point in your configured container. For example:

```sh
docker exec -w /workspace/sim-pjrt xla ./scripts/build.sh --jobs=8
```

The container name and path are examples. If the original project is mounted at
`/xla` and sim-pjrt is still nested within it, the working directory is
`/xla/sim-pjrt`. The container must have Git, Python 3.12+, Bazel 8.7.0/Bazelisk,
and native build prerequisites. Configure its networking/cache mounts as usual.

For the complete integration suite, point to that container's Python environment:

```sh
docker exec -w /workspace/sim-pjrt \
  -e SIM_PYTHON=/path/in/container/to/python \
  xla bash xla/pjrt/sim/run_tests.sh
```

## Native build

On Linux x86-64, install Git, Python 3.12+, Bazel 8.7.0 or Bazelisk, and basic C++
build utilities. `docker/Dockerfile` documents the Ubuntu prerequisite packages.

```sh
./scripts/build.sh --jobs=8
./scripts/bazel test -c opt //xla/pjrt/sim:all --jobs=8 --test_output=errors
```

Both native and container builds require network access on first use to fetch
XLA and its transitive dependencies. Export the pinned XLA commit from an existing
local Git checkout with `scripts/prepare.py --xla-git /path/to/xla` to avoid that
source fetch; this does not prepopulate Bazel's dependency/toolchain downloads.

## State, cache, and outputs

| Location | Purpose |
| --- | --- |
| `.build/xla` | Disposable pinned XLA workspace, with simulator source linked in |
| `.build/docker-cache` | Persistent Docker build/tool cache, owned by the invoking user |
| `bazel-bin/xla/pjrt/sim/` | Latest build's plugin, planner, and descriptor |
| `bazel-testlogs/` | Latest native test logs |

Native builds use Bazel's normal user cache; the Docker helper uses a separate
output root under `.build/docker-cache/bazel`. Docker uses Bazel batch mode
(`SIM_BAZEL_BATCH=1`) so a persistent server is not left in an ephemeral container.
The optional absolute-path variable
`SIM_BAZEL_OUTPUT_ROOT` lets the native wrapper choose a custom output root too.

Switching modes is supported sequentially. They share the prepared XLA workspace
and artifact symlinks, so use separate checkouts for simultaneous builds in
different environments. Preserve the relevant cache when recreating a container.
Do not assume switching compilers/environments will reuse compiled objects.

Pass options such as `--jobs=4`, `--remote_cache=...`, or `--repository_cache=...`
to the underlying Bazel command. Remote-cache credentials and proxy configuration
belong in your local environment; the helper does not mount your host home or
implicitly forward its credentials. Container proxies must be reachable from
inside the container, not just from host loopback.

## CI

Push/PR checks run Python tests, build the docs, and build/smoke-test the Docker
environment. The manually dispatched native workflow offers `docker` (default)
and `native` choices on a suitably provisioned self-hosted `sim-pjrt` runner.
Neither the image smoke tests nor Bazel analysis substitutes for compilation,
native test execution, or the full JAX/SGLang matrix.
