"""Run a user Python workload in the current process."""

from pathlib import Path
import runpy
import sys


def _run_python(command):
    """Run a Python script/module with normal argv and import-path semantics."""
    if command[:1] in (["python"], ["python3"], [sys.executable]):
        command = command[1:]
    if command[:1] == ["-m"] and len(command) >= 2:
        sys.argv = command[1:]
        sys.path.insert(0, str(Path.cwd()))
        runpy.run_module(command[1], run_name="__main__", alter_sys=True)
    elif command and command[0].endswith(".py"):
        sys.argv = command
        sys.path.insert(0, str(Path(command[0]).resolve().parent))
        runpy.run_path(command[0], run_name="__main__")
    else:
        raise ValueError("Collection/replay requires a Python script or python -m MODULE")


def run_python(command):
    try:
        _run_python(command)
    except SystemExit as exit_status:
        if exit_status.code not in (None, 0):
            raise


if __name__ == "__main__":
    # CLI parsing happens once, before exec sets the backend environment.
    import json

    action, options = json.loads(sys.argv[1])
    if action == "collect":
        from sim_pjrt.profiling.capture import collect
        collect(**options)
    else:
        from sim_pjrt.run import run
        run(**options)
