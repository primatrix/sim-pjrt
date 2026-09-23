"""Configure a simulated TPU backend before executing a workload."""

import argparse
import importlib.util
import json
import os
from pathlib import Path
import platform
import sys


def existing_file(value, label):
    path = Path(value).expanduser().resolve()
    if not path.is_file():
        raise ValueError(f"{label} not found: {path}")
    return str(path)


def environment(args, inherited=None):
    env = dict(os.environ if inherited is None else inherited)
    if platform.system() != "Linux" or platform.machine() != "x86_64":
        raise ValueError("sim-pjrt requires Linux x86-64")
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
    topology = args.topology or env.get("PJRT_SIM_TPU_TOPOLOGY")
    if not topology:
        raise ValueError("Specify --topology (for example v5e:2x2)")
    devices = args.devices if args.devices is not None else env.get("PJRT_SIM_DEVICE_COUNT", "1")
    try:
        devices = int(devices)
    except ValueError:
        raise ValueError("Device count must be a positive integer") from None
    if devices < 1:
        raise ValueError("Device count must be a positive integer")
    timing = args.timing_profile or env.get("PJRT_SIM_BUNDLE_PROFILE")
    if not timing:
        raise ValueError("Specify --timing-profile PATH or --timing-profile example "
                         "(uncalibrated partial estimates)")
    if timing == "example":
        timing = package / "configs/bundle_timing_example.json"
    timing = existing_file(timing, "Timing profile")
    env.update(
        JAX_PLATFORMS="tpu",
        JAX_ENABLE_COMPILATION_CACHE="false",
        PJRT_NAMES_AND_LIBRARY_PATHS=f"tpu:{plugin}",
        PJRT_SIM_LIBTPU_PATH=libtpu,
        PJRT_SIM_TPU_TOPOLOGY=topology,
        PJRT_SIM_DEVICE_COUNT=str(devices),
        PJRT_SIM_BUNDLE_PROFILE=timing,
        PJRT_SIM_BUNDLE_PYTHON=sys.executable,
        TPU_SKIP_MDS_QUERY="1",
    )
    env.setdefault("TPU_WORKER_HOSTNAMES", "localhost")
    # Use the package environment for executable lookup and worker Python.
    env["PATH"] = str(Path(sys.executable).parent) + os.pathsep + env.get("PATH", os.defpath)
    return env


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="action", required=True)
    for name in ("run", "doctor"):
        command = sub.add_parser(name)
        command.add_argument("--topology", help="Offline TPU topology, e.g. v5e:2x2")
        command.add_argument("--devices", type=int, help="Simulated devices (default: 1)")
        command.add_argument("--timing-profile", help="JSON path or 'example' for uncalibrated partial estimates")
        command.add_argument("--plugin", help="Override the bundled PJRT shared library")
        command.add_argument("--libtpu", help="Override the installed libtpu shared library")
        if name == "run":
            command.add_argument("command", nargs=argparse.REMAINDER)
    args = parser.parse_args(argv)
    try:
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
            raise ValueError("Provide a command after --, e.g. -- python script.py")
        if command[0] in ("python", "python3"):
            command[0] = sys.executable
        os.execvpe(command[0], command, env)
    except (ValueError, OSError) as error:
        parser.exit(2, f"sim-pjrt: {error}\n")
