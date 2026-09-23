# Building

sim-pjrt is a standalone Bazel module. All environments use the same targets:

```sh
bazel build //:plugin
bazel build //:plan_export //:xplane_descriptor
bazel test //...
```

XLA is fetched as `@xla` from the checksum-pinned archive in `MODULE.bazel`.
No source checkout preparation, source injection, or custom build wrapper is used.

## Native or existing container

Use Linux x86-64 and Bazel 8.7.0, or Bazelisk with the checked-in `.bazelversion`.
Bazel downloads the hermetic C++ and Python toolchains. Basic native build
utilities and network access are needed; the Ubuntu package list is in
`docker/Dockerfile`. This is a CPU build without CUDA/TPU hardware requirements.

Run the commands above in the repository root. In a configured existing container,
for example:

```sh
docker exec -w /workspace/sim-pjrt xla bazel build //:plugin
```

Replace the example name and mount path with your actual setup. Requirements
apply inside that container, not additionally on the Docker host.

## Repository Docker environment

The checked-in Compose service provides the tools and runs Bazel directly:

```sh
docker compose run --build --rm bazel build //:plugin
docker compose run --rm bazel test //...
```

Run Compose from the checkout root on a Linux x86-64 host with a local Docker
daemon. The image pins Ubuntu by digest and verifies Bazel's binary checksum.
APT packages receive available Ubuntu updates; this is not a byte-for-byte pin
of the complete operating system. Source changes do not rebuild the tool image.

The image defaults to UID/GID 1000. When your host user differs, configure these
once in your shell before building/running Compose, or place the values in an
ignored `.env` file:

```sh
export BUILD_UID=$(id -u)
export BUILD_GID=$(id -g)
```

Compose matches file ownership via the image's builder account. It mounts only
this checkout, at the same absolute path as on the host; this preserves artifact
symlinks. It needs neither privileged mode nor a Docker-socket mount. Remote Docker
daemons and non-Linux/ARM hosts are not supported by this configuration.

The Compose service passes standard Bazel startup options for batch mode and a
persistent output root under `.build/docker-cache/bazel`. Containers are disposable;
dependencies and compiled outputs persist across invocations. Do not run native
and Docker builds simultaneously in one checkout because they update the same
artifact symlinks; use separate checkouts for concurrent environments.

For a shell, override the service's Bazel entrypoint:

```sh
docker compose run --rm --entrypoint bash bazel -i
```

The image supplies build tools, not JAX/SGLang runtime packages. Use the plugin
guide to create the integration Python environment, or use your existing container.

## Targets and configuration

| Target | Output or checks |
| --- | --- |
| `//:plugin` | `bazel-bin/pjrt_sim_plugin.so` |
| `//:plan_export` | `bazel-bin/plan_export` |
| `//:xplane_descriptor` | `bazel-bin/xplane.descriptor.pb` |
| `//tests/python:python_tests` | Fast Python scheduling/report tests, no native compilation |
| `//...` with `bazel test` | Native unit tests and fast Python tests |

Pass standard Bazel options directly, for example `--jobs=8` or
`--remote_cache=...`. Put private machine settings in the ignored `.bazelrc.local`.
It is imported by native and Compose builds; paths and endpoints must be valid
in the selected environment. Source and module versions belong in `MODULE.bazel`,
not private configuration. Commit `MODULE.bazel.lock` updates.

Native Bazel uses its normal user cache. Docker uses `.build/docker-cache`.
A downloaded repository cache may be reused with `--repository_cache=/path`;
that path must be mounted in a container. Toolchains and downloads need network
access on first use. A host-loopback proxy is not automatically reachable from
inside Docker; configure networking in your own Compose override if needed.

After a successful build, use the plugin in a compatible Linux runtime environment.
Compiled outputs are not a universal binary distribution for other operating systems.

## CI

Push/PR checks run the fast Bazel Python suite in the Compose environment and build
the docs. The manually dispatched native workflow runs `bazel test //...` in Docker
on a sufficiently provisioned self-hosted runner labelled `sim-pjrt`. The full
JAX/SGLang matrix remains a separate check with additional runtime dependencies.
