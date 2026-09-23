# Source provenance and dependency maintenance

Simulator sources were extracted from `Yanko-7/pjrt-sim` commit `eb544c640d63509b0bcb40fb7898a1d330864320`.
The upstream XLA baseline is `4426f247713c9f46bad35775cc032265d5795f04`.
At extraction, changes relative to that baseline were confined to
`xla/pjrt/sim/` and `docs/tpu_simulator_design.md`.

The independent repository starts a new history. Historical design/iteration
notes describe earlier validation; they are not a claim that those experiments
were rerun during extraction.

## Reproducibility

`third_party/xla.lock.json` records the upstream Git URL, full commit ID, Git tree
ID, and Bazel version. `scripts/prepare.py` fetches that exact commit or exports
it from a supplied local Git repository, then verifies both identities.
The upstream `.bazelversion` and root `MODULE.bazel` are retained. XLA supplies
the compiler/toolchain and transitive dependency pins; this repository supplies
the CPU flags in `build_tools/xla_configure.bazelrc`.

The generated workspace is local state, ignored by Git. Simulator source is a
symlink to this checkout, so edits are immediately visible to incremental builds.
Do not edit downloaded XLA in place. If an upstream patch becomes necessary,
check it into this repository and apply it deterministically during preparation.

The wrapper deliberately runs Bazel with XLA as the root module. Converting it
to an external Bzlmod dependency would require reproducing XLA's root-only
module overrides and validating internal target visibility. A short but incomplete
`bazel_dep` declaration would not preserve the current build.

## Updating

1. Choose an upstream commit and obtain its tree with `git rev-parse COMMIT^{tree}`.
2. Update `third_party/xla.lock.json` and `.bazelversion` to match that source.
3. Move `.build/xla` aside, prepare the new dependency, then build and run tests.
4. Run the JAX/SGLang matrix from the plugin guide, recording Python/package versions.
5. Review changes to outputs, modeling semantics, and supported PJRT interfaces.

Framework validation baseline: SGLang-Jax
`7ebbbef498b9e484fdc5902986578a3504734e46`, JAX/jaxlib 0.11.1,
Flax 0.12.9, Python 3.12. See `xla/pjrt/sim/constraints.txt` for the
historically tested environment; it is not a minimal plugin install manifest.
