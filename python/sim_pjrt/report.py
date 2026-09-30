"""Summarize compile lookups separately from executed timing predictions."""

from collections import Counter, defaultdict
import json
from pathlib import Path
import statistics


def summarize(directory, queries=(), status="complete"):
    directory = Path(directory)
    executions = [dict(json.loads(line), process=path.stem) for path in sorted(directory.glob("execution.*.jsonl"))
                  for line in path.read_text().splitlines()]
    by_key = defaultdict(list)
    for record in executions:
        key = record.get("execution_key") or f"unbound:{record['process']}:{record['program_id']}"
        by_key[key].append(record)
    programs = {}
    for key, records in by_key.items():
        durations = [r["duration_ns"] if "duration_ns" in r else r["bundle_duration_ns"]
                     for r in records]
        programs[key] = {
            "name": records[0]["name"], "executions": len(records),
            "num_devices": records[0]["num_devices"],
            "duration_ns": statistics.median(durations),
            "min_ns": min(durations), "max_ns": max(durations),
            "sources": dict(Counter(r["analysis_source"] for r in records)),
            "cost_gaps": max(r["bundle_cost_gaps"] for r in records),
        }
    lookups = Counter(q["replay_lookup"] for q in queries if q["replay_lookup"])
    return {
        "schema_version": 1, "status": status,
        "compile_queries": len(queries), "replay_lookups": dict(lookups),
        "replay_hit_rate": lookups["hit"] / sum(lookups.values()) if lookups else None,
        "executions": len(executions),
        "execution_sources": dict(Counter(r["analysis_source"] for r in executions)),
        "fallback_executions": sum(bool(r.get("replay_miss")) for r in executions),
        "executions_with_cost_gaps": sum(r["bundle_cost_gaps"] > 0 for r in executions),
        "unbound_executions": sum(not r.get("execution_key") for r in executions),
        "programs": programs,
        "notes": ["Compile lookup counts are not execution counts.",
                  "Cost gaps indicate incomplete estimates; missing time is unknown.",
                  "Durations are predictions, not CPU wall time or measured TPU accuracy."],
    }
