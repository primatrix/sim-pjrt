# XLA dependency and source provenance

The simulator was extracted from `Yanko-7/pjrt-sim` revision
`eb544c640d` and initially used XLA's in-tree build layout. It is now a standalone
Bazel module; no prepared XLA workspace or parent checkout is needed.

The simulator sources were introduced in project-specific commits beginning with
`a960b92dc0`; the pinned upstream XLA revision contains no `xla/pjrt/sim` directory.
The OpenXLA attribution and per-file license headers added with those project
files have been removed. The project license is maintained in the root `LICENSE`
file.

`MODULE.bazel` declares the plugin's direct dependencies and pins XLA commit
`4426f247713c9f46bad35775cc032265d5795f04` with an archive integrity checksum.
XLA's own module declares its transitive dependencies and toolchains.
`MODULE.bazel.lock` records Bazel's resolved dependency metadata.

Bazel ignores dependency modules' root-only overrides. Therefore
`third_party/xla_overrides.MODULE.bazel` repeats the overrides required by this
XLA revision, and `third_party/xla_patches/` retains their upstream patches.
Bazel requires these module patches to reside in the root repository; their
contents are copied unchanged from the pinned upstream source. XLA itself is
not patched. Copyright and license notices in these upstream patches are retained.

The root module also repeats XLA's Python pip repository override and exposes
the repository names used by XLA's C++ macros. `.bazelrc` carries the CPU build
settings needed by those targets. GPU repository mappings exist for upstream
select expressions; they do not enable a GPU build.

## Python runtime baseline

The package follows SGLang-Jax main as of 2026-09-23, commit
[`d966db449817692b566ee646bdd3ae15964265a7`](https://github.com/sgl-project/sglang-jax/blob/d966db449817692b566ee646bdd3ae15964265a7/python/pyproject.toml):
Python >=3.12,<3.14 and `jax[tpu]==0.11.1`. JAX's TPU extra requires
jaxlib 0.11.1 and libtpu 0.0.46.*. The package uses this extra directly rather
than maintaining a separate libtpu version pin. Upstream leaves Flax unpinned.

This dependency alignment has not yet been validated with a full simulator
integration run. Previous integration results and checked-in LLO fixtures used
libtpu 0.0.48; their provenance remains unchanged. `requirements/constraints.txt`
is a historical environment snapshot, not a lockfile for current upstream
SGLang-Jax. Revalidate integration before replacing that snapshot.

## Updating

1. Select an upstream XLA commit and calculate its archive checksum.
2. Update the archive pin in `MODULE.bazel`, then compare upstream module overrides
   and refresh the corresponding checked-in patches.
3. Update `.bazelversion` and `docker/bazel.sha256` if that source needs a new Bazel.
4. Run `bazel build //:plugin` and `bazel test //...`, then validate the Docker path.
5. Run the JAX/SGLang matrix before accepting changes to the runtime baseline.
6. Commit the resulting module lockfile and record the tested environment.

Historical framework baseline: SGLang-Jax
`7ebbbef498b9e484fdc5902986578a3504734e46`, JAX/jaxlib 0.11.1,
Flax 0.12.9, Python 3.12. `requirements/constraints.txt` records the tested
framework environment, not a minimal build dependency manifest.
