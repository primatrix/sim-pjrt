# Tests

Run from the repository root:

```sh
bazel test //...
```

`cpp/` contains the six native unit test targets declared in the root
`BUILD.bazel`. `python/` contains model tests and framework integration tests;
Bazel runs the three fast model test targets without JAX.

For direct Python invocation, first set:

```sh
export PYTHONPATH="$PWD/python${PYTHONPATH:+:$PYTHONPATH}"
```

Offline planner tests need `bazel build //:plan_export //:xplane_descriptor`.
JAX and SGLang tests additionally need the plugin and their runtime environment;
see [the plugin guide](../docs/plugin-guide.md). XProf tests require
`requirements/profiling-requirements.txt`.

`run_tests.sh` is the full integration test harness, invoked with
`SIM_PYTHON=/path/to/python bash tests/run_tests.sh`.
