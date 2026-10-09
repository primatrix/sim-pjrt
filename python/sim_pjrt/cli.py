"""Simulate TPU workloads on CPU, export compiler artifacts, or collect real TPU timings."""

import argparse
import importlib.util
from importlib.metadata import PackageNotFoundError, distribution
import json
import math
import os
from pathlib import Path
import platform
import sys


def existing_file(value, label):
    path = Path(value).expanduser().resolve()
    if not path.is_file():
        raise ValueError(f"{label} not found: {path}")
    return str(path)


def check_versions(libtpu):
    # Keep this baseline aligned with pyproject.toml and the pinned GF tables.
    for name, expected in (("jax", "0.11.1"), ("jaxlib", "0.11.1"),
                           ("libtpu", "0.0.48")):
        try:
            package = distribution(name)
        except PackageNotFoundError:
            actual = "not installed"
        else:
            actual = package.version
            if name == "libtpu" and not any(
                Path(package.locate_file(file)).resolve() == Path(libtpu)
                for file in package.files or () if file.name == "libtpu.so"
            ):
                actual = "unknown (custom library)"
        compatible = (actual.startswith(expected[:-1]) if expected.endswith(".*")
                      else actual == expected)
        if not compatible:
            detail = f"; loading {libtpu}" if name == "libtpu" else ""
            print(f"sim-pjrt: warning: {name} {actual}; expected {expected}{detail}",
                  file=sys.stderr)


def environment(args, inherited=None):
    env = dict(os.environ if inherited is None else inherited)
    if platform.system() != "Linux" or platform.machine() != "x86_64":
        raise ValueError("sim-pjrt requires Linux x86-64")
    if args.action == "collect":
        # Collection must run the ordinary real TPU backend, even when invoked
        # from a shell previously configured for simulation.
        for key in list(env):
            if key.startswith("PJRT_SIM_") or key in (
                "PJRT_NAMES_AND_LIBRARY_PATHS", "SIM_PJRT_PLUGIN_PATH"):
                env.pop(key)
        env.update(JAX_PLATFORMS="tpu", JAX_ENABLE_COMPILATION_CACHE="false")
        return env
    package = Path(__file__).resolve().parent
    plugin = existing_file(
        args.plugin or env.get("SIM_PJRT_PLUGIN_PATH")
        or package / "lib/pjrt_sim_plugin.so", "PJRT plugin")
    libtpu = args.libtpu or env.get("PJRT_SIM_LIBTPU_PATH")
    if not libtpu:
        spec = importlib.util.find_spec("libtpu")
        if spec and spec.submodule_search_locations:
            libtpu = Path(next(iter(spec.submodule_search_locations))) / "libtpu.so"
    if not libtpu:
        raise ValueError("Install libtpu in this Python environment or pass --libtpu")
    libtpu = existing_file(libtpu, "libtpu library")
    check_versions(libtpu)
    topology = args.topology or env.get("PJRT_SIM_TPU_TOPOLOGY", "tpu7x:2x2x1")
    devices = args.devices if args.devices is not None else env.get("PJRT_SIM_DEVICE_COUNT", "8")
    try:
        devices = int(devices)
    except ValueError:
        raise ValueError("Device count must be a positive integer") from None
    if devices < 1:
        raise ValueError("Device count must be a positive integer")
    if args.action == "compile":
        env["PJRT_SIM_DUMP_DIR"] = str(Path(args.output).expanduser().resolve())
        env.pop("PJRT_SIM_BUNDLE_PROFILE", None)
    else:
        env.pop("PJRT_SIM_DUMP_DIR", None)
        timing = args.timing_profile or env.get("PJRT_SIM_BUNDLE_PROFILE") or "tpu7x"
        if timing in ("tpu7x", "example"):
            filename = "tpu7x.json" if timing == "tpu7x" else "bundle_timing_example.json"
            timing = package / "configs" / filename
            if not timing.is_file():  # Source checkout.
                timing = package.parents[1] / "configs" / filename
        env["PJRT_SIM_BUNDLE_PROFILE"] = existing_file(timing, "Timing profile")
    env.update(
        JAX_PLATFORMS="tpu",
        JAX_ENABLE_COMPILATION_CACHE="false",
        PJRT_NAMES_AND_LIBRARY_PATHS=f"tpu:{plugin}",
        PJRT_SIM_LIBTPU_PATH=libtpu,
        PJRT_SIM_TPU_TOPOLOGY=topology,
        PJRT_SIM_DEVICE_COUNT=str(devices),
        PJRT_SIM_BUNDLE_PYTHON=sys.executable,
        TPU_SKIP_MDS_QUERY="1",
    )
    for field in ("capacity", "reserved"):
        value = getattr(args, f"hbm_{field}_gib", None)
        if value is not None:
            if not math.isfinite(value) or value < 0 or (field == "capacity" and value == 0):
                raise ValueError(f"Invalid HBM {field}: {value}")
            env[f"PJRT_SIM_HBM_{field.upper()}_BYTES"] = str(int(value * 1024**3))
    env.setdefault("TPU_WORKER_HOSTNAMES", "localhost")
    # Use the package environment for executable lookup and worker Python.
    env["PATH"] = str(Path(sys.executable).parent) + os.pathsep + env.get("PATH", os.defpath)
    return env


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="action", required=True)
    offline = sub.add_parser("import-profile", help="Import an existing real TPU profile offline")
    offline.add_argument("profile", help="XProf capture directory, .xplane.pb, or Trace Viewer JSON[.gz]")
    offline.add_argument("--output", required=True, help="New output database JSON file")
    offline.add_argument("--hlo", action="append", default=[],
                         help="Optional optimized HLO text/proto file or directory; may repeat")
    offline.add_argument("--identities", help="Optional compile identities for exact replay binding")
    offline.add_argument("--context", help="Optional hardware/compiler context JSON")
    offline.add_argument("--skip-first", type=int, default=1)
    for name in ("run", "compile", "doctor", "collect"):
        command = sub.add_parser(name)
        if name == "collect":
            command.add_argument("--output", required=True, metavar="DIRECTORY",
                                 help="New directory for real TPU profile and timings.json")
            command.add_argument("--skip-first", type=int, default=1,
                                 help="Discard this many device samples per executable (default: 1)")
            command.add_argument("command", nargs=argparse.REMAINDER)
            continue
        command.add_argument("--topology", help="Offline TPU topology (default: tpu7x:2x2x1)")
        command.add_argument("--devices", type=int, help="Simulated devices (default: 8)")
        command.add_argument("--hbm-capacity-gib", type=float, help="Logical HBM capacity per device")
        command.add_argument("--hbm-reserved-gib", type=float, help="Capacity reserved outside application buffers")
        if name == "compile":
            command.add_argument("--output", required=True, metavar="DIRECTORY",
                                 help="Directory for TPU compilation artifacts (no timing analysis)")
        else:
            command.add_argument("--timing-profile", help="JSON path, 'tpu7x' (default), or 'example'")
        if name == "run":
            command.add_argument("--predictor", choices=("llo", "replay"), default="llo")
            command.add_argument("--database", help="Collected timings.json; supplies compiler flags for both predictors")
            command.add_argument("--replay-miss", choices=("error", "llo"), default="error",
                                 help="Replay miss policy (default: fail)")
            command.add_argument("--report", help="New directory for execution traces and prediction coverage")
        command.add_argument("--plugin", help="Override the bundled PJRT shared library")
        command.add_argument("--libtpu", help="Override the installed libtpu shared library")
        if name != "doctor":
            command.add_argument("command", nargs=argparse.REMAINDER, metavar="SCRIPT_OR_COMMAND",
                                 help="Python script or command; following arguments are passed through")
    args = parser.parse_args(argv)
    try:
        if args.action == "import-profile":
            from sim_pjrt.profiling.importer import import_profile
            import_profile(args.profile, args.output, hlo=args.hlo, identities=args.identities,
                           context=args.context, skip_first=args.skip_first)
            return 0
        env = environment(args)
        if args.action == "doctor":
            from importlib.metadata import PackageNotFoundError, version
            versions = {}
            for name in ("sim-pjrt", "jax", "jaxlib", "libtpu"):
                try:
                    versions[name] = version(name)
                except PackageNotFoundError:
                    versions[name] = "not installed"
            print(json.dumps({"python": sys.executable, "versions": versions,
                              "environment": {key: value for key, value in env.items()
                                              if key.startswith(("PJRT_", "JAX_", "TPU_"))}}, indent=2))
            return 0
        command = args.command
        if command[:1] == ["--"]:
            command = command[1:]
        if not command:
            raise ValueError("Provide a command or script, e.g. workload.py")
        if args.action == "collect":
            if args.skip_first < 0:
                raise ValueError("--skip-first must be nonnegative")
            options = dict(output=args.output, command=command, skip_first=args.skip_first)
            command = [sys.executable, "-m", "sim_pjrt.workload", json.dumps(["collect", options])]
        elif args.action == "run":
            from sim_pjrt.prediction import ReplayPredictor, predictor
            selected = predictor(args.predictor, args.database if args.predictor == "replay" else None)
            reference = selected or (ReplayPredictor(args.database) if args.database else None)
            if reference is not None:
                for key, value in reference.compiler_environment().items():
                    env.setdefault(key, value)
            if selected is not None:
                env["PJRT_SIM_PREDICTOR"] = "replay"
                env["PJRT_SIM_REPLAY_MISS"] = args.replay_miss
            else:
                if args.replay_miss != "error":
                    raise ValueError("--replay-miss requires --predictor replay")
                env.pop("PJRT_SIM_PREDICTOR", None)
                env.pop("PJRT_SIM_REPLAY_MISS", None)
            if selected is not None or args.report:
                options = dict(command=command, predictor=args.predictor, replay_miss=args.replay_miss,
                               database=selected.path if selected else None)
                if args.report:
                    directory = Path(args.report).expanduser().resolve()
                    directory.mkdir(parents=True, exist_ok=False)
                    env["PJRT_SIM_TRACE"] = str(directory / "execution")
                    options["report"] = str(directory)
                command = [sys.executable, "-m", "sim_pjrt.workload", json.dumps(["run", options])]
        if command[0].endswith(".py"):
            command.insert(0, sys.executable)
        elif command[0] in ("python", "python3"):
            command[0] = sys.executable
        os.execvpe(command[0], command, env)
    except (ValueError, OSError) as error:
        parser.exit(2, f"sim-pjrt: {error}\n")
