# Validation record

## Directory organization — 2026-09-22

- Sources, Python tools, tests, configs, runtime requirements, and documentation
  now live in separate directories. Public build commands remain unchanged;
  native outputs are directly under `bazel-bin/`.
- `bazel test //... --jobs=32`: all nine targets passed in **26.839 seconds**,
  with 19,262 action cache hits and 137 actions. XLA dependencies were reused.
- JAX smoke tests: all five passed using the relocated plugin.
- Additional offline tests: 31 of 32 passed. The XProf converter test could not
  run because host Python lacks `xprof`; install the documented profiling
  requirements to run it. The full SGLang matrix was not rerun.
- Documentation production build passed (14 pages).

## Standalone Bazel — 2026-09-22

- Native cold compilation/linking completed with `bazel test //... --jobs=32`:
  **1,518.646 seconds (25 min 19 sec)**, 19,356 actions. Existing downloaded
  dependency archives were cached; this is not an uncached network benchmark.
  The command builds the plugin, tools, and tests, not only the plugin.
- That first run passed all six C++ test targets and exposed three Python import
  failures. After declaring their runfiles import path, the final full suite
  passed **all nine targets** (35 C++ cases plus nine Python cases). The cached
  rerun took **1.801 seconds**; native results were reused, Python tests reran.
- The newly linked plugin passed all **five JAX smoke tests** on the host with
  JAX/jaxlib 0.11.1, including device discovery, transfers/control values,
  donation, memory accounting, and simulated matmul.
- Docker Compose: three Python targets pass; complete plugin/planner/descriptor
  dependency analysis passes in a separate checkout. Native compilation was
  validated on the host, not repeated as another Docker cold build.
- Documentation production build passes (14 pages). The full SGLang integration
  matrix has not been rerun during this build-system migration.

The sections below preserve earlier migration checks and describe superseded
build wrappers where explicitly noted.

## Historical extraction — 2026-09-22

The preparation scripts described in this section were subsequently removed in
favor of the standalone Bazel module. These are historical results, not current
build instructions.

Verified locally for the independent repository:

- 60 C++/Python plugin source and BUILD files match the source checkout byte-for-byte.
- Offline preparation exports the pinned upstream commit from the original Git repository.
- A separate source copy under `/tmp` successfully fetches and verifies that commit
  from the public OpenXLA repository without access to the original checkout.
- Four bootstrap tests cover fetch, dirty-source isolation, repeated preparation,
  relocation, source-tree mismatch, and changed-pin rejection.
- Nine existing Python scheduling/report tests pass without native dependencies.
- `scripts/bazel query //:all` resolves the package targets.
- Bazel `build --nobuild` successfully analyzes the plugin, native planner, and
  XSpace descriptor with their complete dependency graph. This is analysis only,
  not successful compilation or linking.
- Shell syntax and Python compilation checks pass.
- Documentation: clean `npm ci` with npm 10.8.2 and production build pass,
  generating 14 pages and a search index. The inherited duplicate `/404` route
  produces a nonfatal warning. The lockfile repair adds missing optional/platform
  dependency records without changing any existing dependency versions.

Not rerun during extraction: native cold compilation, native test execution,
JAX/SGLang integration matrix, and CI on GitHub. Previous validation described
in the plugin guide and iteration notes predates this extraction.

## Build modes follow-up — 2026-09-22

- Built the pinned Ubuntu/Bazel development image from its Dockerfile; Bazel's
  downloaded binary passed the checked-in SHA-256 verification.
- All 13 bootstrap/scheduling/report tests passed on the host and inside Docker
  with the host user's UID/GID.
- Docker Bazel analysis completed for all three build outputs (39,105 configured
  targets). Some upstream mirrors were unreachable from the container, so this
  check used an isolated copy of the host's existing repository download cache.
- Documentation production build still passes (14 pages); workflow YAML and
  shell syntax checks pass.
- Native cold compilation/linking and the full framework matrix remain untested
  for this independent checkout. The Docker image is a build environment, not a
  precompiled plugin or a preconfigured SGLang runtime.

## Standalone Bazel migration — 2026-09-22

The repository is now the Bazel root module. XLA is an integrity-pinned external
archive; preparation/build wrapper scripts and their bootstrap tests are removed.
Eleven required upstream dependency patches are copied unchanged into the root
module, as required by Bazel's override rules. XLA itself is unmodified.

Verified for the new layout:

- Native and Docker Compose dependency analysis succeeds for plugin, planner,
  and descriptor targets.
- Compose executes the three Bazel Python test targets successfully (nine cases).
  Their import paths are explicitly declared for Bazel runfiles.
- The Chinese documentation site builds all 14 pages.
- Compose/workflow configuration parses, and patch contents match pinned upstream.

Docker validation used a separate checkout and a populated repository download
cache. This tests the new module/Compose path without touching the native build's
artifact symlinks. Download-cache reuse is distinct from compiled-action reuse.
