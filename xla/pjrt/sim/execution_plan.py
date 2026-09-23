"""Read the native execution plan, rebuilding from original HLO when needed."""

import json
import math
import os
from pathlib import Path
import subprocess


def planner_path():
    return os.environ.get(
        "PJRT_SIM_PLAN_EXPORT",
        str(Path(__file__).resolve().parents[3] / "bazel-bin/xla/pjrt/sim/plan_export"),
    )


def export_snapshot(snapshot, devices):
    """Replan using the exact same C++ builder as the online runtime."""
    try:
        result = subprocess.run(
            [planner_path(), str(devices)],
            input=json.dumps(snapshot),
            text=True,
            capture_output=True,
            check=True,
        )
    except FileNotFoundError as error:
        raise ValueError(
            "Replanning requires plan_export: build with `bazel build -c opt "
            "//xla/pjrt/sim:plan_export` or set PJRT_SIM_PLAN_EXPORT."
        ) from error
    except subprocess.CalledProcessError as error:
        raise ValueError(
            f"Native HLO planning failed: {error.stderr.strip()}"
        ) from error
    return json.loads(result.stdout)


def load_plan(snapshot, devices):
    if not devices:
        raise ValueError("At least one device is required")
    plan = snapshot.get("plan")
    if plan is None or plan.get("devices") != devices:
        plan = export_snapshot(snapshot, devices)["plan"]
    if plan.get("schema_version") != 1:
        raise ValueError("Unsupported execution plan schema")
    nodes = plan["nodes"]
    if not isinstance(plan["root"], int) or not 0 <= plan["root"] < len(nodes):
        raise ValueError("Invalid execution plan root")
    for index, node in enumerate(nodes):
        if node["kind"] not in (
            "barrier",
            "compute",
            "all-reduce",
            "all-gather",
            "reduce-scatter",
            "transfers",
        ):
            raise ValueError("Unknown execution plan node kind")
        if any(
            not isinstance(d, int) or not 0 <= d < index for d in node["dependencies"]
        ):
            raise ValueError("Execution plan dependencies must precede their users")
        for field in (
            "flops",
            "transcendentals",
            "bytes",
            "logical_read_bytes",
            "logical_write_bytes",
        ):
            value = node[field]
            if (
                not isinstance(value, (int, float))
                or not math.isfinite(value)
                or value < 0
            ):
                raise ValueError(f"Invalid execution plan {field}")
        if any(
            len(pair) != 2
            or any(not isinstance(d, int) or not 0 <= d < devices for d in pair)
            for pair in node["transfers"]
        ):
            raise ValueError("Invalid execution plan transfer")
    return plan
