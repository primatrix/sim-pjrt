# Extraction validation — 2026-09-22

Verified locally for the independent repository:

- 60 C++/Python plugin source and BUILD files match the source checkout byte-for-byte.
- Offline preparation exports the pinned upstream commit from the original Git repository.
- A separate source copy under `/tmp` successfully fetches and verifies that commit
  from the public OpenXLA repository without access to the original checkout.
- Four bootstrap tests cover fetch, dirty-source isolation, repeated preparation,
  relocation, source-tree mismatch, and changed-pin rejection.
- Nine existing Python scheduling/report tests pass without native dependencies.
- `scripts/bazel query //xla/pjrt/sim:all` resolves the package targets.
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
