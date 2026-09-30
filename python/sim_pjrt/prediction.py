"""Executable identities and measured-duration prediction (no JAX import)."""

import hashlib
import json
import math
from pathlib import Path
import statistics


SCHEMA_VERSION = 1
TIMING_ATTRIBUTE = "sim_pjrt.timing"
KEY_ATTRIBUTE = "sim_pjrt.execution_key"
MISS_ATTRIBUTE = "sim_pjrt.replay_miss"


class ReplayMiss(ValueError):
    pass


def execution_key(module_text, options_bytes, context):
    """Exact identity, excluding MLIR debug locations supplied by the caller.

    Shapes, constants, sharding and compiler options remain significant. This
    deliberately prefers a miss to reusing a measurement for a different program.
    Runtime input values are not part of this identity.
    """
    payload = {
        "schema_version": SCHEMA_VERSION,
        "module": module_text,
        "compile_options": options_bytes.hex(),
        "context": context,
    }
    return hashlib.sha256(json.dumps(payload, sort_keys=True).encode()).hexdigest()


class ReplayPredictor:
    name = "replay"

    def __init__(self, database):
        self.path = str(Path(database).resolve())
        self.database = json.loads(Path(database).read_text())
        if (self.database.get("schema_version") != SCHEMA_VERSION
                or self.database.get("measurement") != "tpu_xprof_module_duration"):
            raise ValueError("Expected a sim-pjrt TPU collection database (schema 1)")
        if not isinstance(self.database.get("executables"), dict):
            raise ValueError("Collection database is missing executables")
        if not self.database["executables"]:
            raise ValueError("No exact replay identities in this profile database; "
                             "use collect or import-profile --identities FILE. "
                             "Capture-local program IDs cannot identify a new compilation.")

    def predict(self, key):
        record = self.database["executables"].get(key)
        if record is None:
            raise ReplayMiss(f"Replay miss for executable {key}; collect this configuration on TPU")
        if not isinstance(record, dict):
            raise ValueError(f"Invalid executable record for {key}")
        samples = record.get("samples_ns", [])
        if (not isinstance(samples, list) or not samples
                or any(type(s) not in (int, float) or not math.isfinite(s)
                               or s <= 0 or s > 1e18 for s in samples)):
            raise ValueError(f"No valid device-duration samples for executable {key}")
        return {
            "schema_version": SCHEMA_VERSION,
            "predictor": self.name,
            "analysis_source": "tpu_replay",
            "execution_key": key,
            "duration_ns": math.ceil(statistics.median(samples)),
            "sample_count": len(samples),
            "num_devices": record.get("num_replicas", 1) * record.get("num_partitions", 1),
            "database": self.path,
            "measurement": self.database["measurement"],
            "activity_timeline": [],
        }

    def compiler_environment(self):
        """Use the capture's explicit compiler flags unless the user overrides.

        A database mixing flag sets cannot choose one process-global target.
        """
        variants = {json.dumps(r.get("context", {}).get("compiler_flags", {}), sort_keys=True)
                    for r in self.database["executables"].values() if isinstance(r, dict)}
        if len(variants) > 1:
            raise ValueError("Replay database mixes compiler flag sets; select one capture")
        flags = json.loads(next(iter(variants))) if variants else {}
        if (not isinstance(flags, dict) or any(k not in ("XLA_FLAGS", "LIBTPU_INIT_ARGS")
                                              or not isinstance(v, str) for k, v in flags.items())):
            raise ValueError("Invalid compiler flags in replay database")
        return flags


def predictor(name, database=None):
    """LLO stays in the native compilation route; measured predictors run here."""
    if name == "llo":
        if database:
            raise ValueError("--database requires --predictor replay")
        return None
    if name == "replay":
        if not database:
            raise ValueError("--predictor replay requires --database")
        return ReplayPredictor(database)
    raise ValueError(f"Unknown timing predictor: {name}")


class CompilationPredictor:
    """Select a compile-time timing source and retain every lookup outcome."""

    def __init__(self, name, database=None, replay_miss="error"):
        self.replay = predictor(name, database)
        self.replay_miss = replay_miss
        self.queries = []

    def predict(self, key):
        query = {"execution_key": key, "source": "llo", "replay_lookup": None}
        self.queries.append(query)
        if self.replay is not None:
            try:
                result = self.replay.predict(key)
            except ReplayMiss:
                query["replay_lookup"] = "miss"
                if self.replay_miss != "llo":
                    query["source"] = None
                    raise
            except ValueError:
                query.update(source=None, replay_lookup="invalid")
                raise
            else:
                query.update(source="replay", replay_lookup="hit")
                return result
        return {"predictor": "llo", "execution_key": key,
                "replay_miss": query["replay_lookup"] == "miss"}
