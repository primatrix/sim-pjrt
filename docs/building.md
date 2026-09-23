# Building

sim-pjrt is a standalone Bazel module. All environments use the same targets:

```sh
bazel build //:plugin
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

The Compose service runs Bazel in batch mode and sets `XDG_CACHE_HOME` so both
Bazel and nested tooling use `.build/docker-cache/bazel/_bazel_builder`. Containers are disposable;
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

For a distributable Python wheel, run `uv build --wheel`. This invokes the same
Bazel plugin target and packages its output with the launcher. See
[Python packaging](python-package.md) for installation and artifact overrides.

| Target | Output or checks |
| --- | --- |
| `//:plugin` | `bazel-bin/pjrt_sim_plugin.so` |
| `//tests/python:python_tests` | Fast Python bundle-timing/report tests, no native compilation |
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

## clangd

After the first successful build, generate the editor compilation database from
the same Bazel targets and flags:

```sh
bazel run //:refresh_compile_commands
```

This uses the pinned [Hedron compilation database extractor](https://github.com/hedronvision/bazel-compile-commands-extractor).
It writes `compile_commands.json` in the checkout root. Run the normal build first
to materialize generated XLA/Protobuf/MLIR headers; extraction itself does not
compile the plugin or produce these headers. It includes this project's C++
sources, headers, and unit tests, while retaining the XLA/toolchain include paths.
External C++ source targets are excluded to keep indexing focused on the plugin.
Headers used by project sources, including XLA and generated headers, remain
available for parsing and navigation.

Open the checkout root in an editor with clangd enabled. The checked-in `.clangd`
selects the database; no handwritten include paths are needed. The database,
`external` dependency link, and clangd cache are generated and ignored by Git.
Rerun the command after changing build dependencies, flags, or the checkout path.
Normal source edits do not need a refresh. Building the plugin still uses
`bazel build //:plugin`.

With the Compose environment:

```sh
docker compose run --build --rm bazel run //:refresh_compile_commands
```

Run clangd in the same environment as the compiler for reliable access to its
system headers and toolchain. For a container-based editor, attach the editor to
the development container. The build image does not install clangd; provide it
through the editor's language-server installation or your development image.
The native and Compose environments have separate caches: refresh the database
after switching between them.

## CI

Push/PR checks run the fast Bazel Python suite in the Compose environment and build
the docs. The manually dispatched native workflow runs `bazel test //...` in Docker
on a sufficiently provisioned self-hosted runner labelled `sim-pjrt`. The full
JAX/SGLang matrix remains a separate check with additional runtime dependencies.
