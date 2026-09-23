"""Build real HLO snapshots for native/offline integration tests."""

import json
import subprocess

from execution_plan import planner_path


def snapshot_from_hlo(text, devices=1, *, embedded=False):
    result = subprocess.run(
        [planner_path(), str(devices), "--hlo-text"],
        input=text,
        text=True,
        capture_output=True,
        check=True,
    )
    snapshot = json.loads(result.stdout)
    if not embedded:
        snapshot.pop("plan")
    return snapshot


def entry(snapshot):
    return next(
        c
        for c in snapshot["hlo"]["computations"]
        if c.get("id", "0") == snapshot["hlo"].get("entry_computation_id", "0")
    )
