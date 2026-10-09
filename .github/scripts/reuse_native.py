"""Reuse a validated native plugin only when its native build inputs match."""

import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tempfile
import zipfile


INPUTS = ("src", "tests/cpp", "tests/fixtures", "BUILD.bazel", ".bazelrc",
          ".bazelversion", "MODULE.bazel", "MODULE.bazel.lock", "third_party",
          "docker/Dockerfile.manylinux", "docker/bazel.sha256")
PACKAGE_MARKER = b"# Reuse the native artifact; do not invoke Bazel from setuptools again."
PLUGIN = "sim_pjrt/lib/pjrt_sim_plugin.so"


def native_fingerprint(ref, *, root="."):
    def git(*args):
        return subprocess.check_output(["git", "-C", str(root), *args])

    tree = git("ls-tree", "-r", "-z", ref, "--", *INPUTS)
    recipe = git("show", ref + ":docker/release.sh")
    if recipe.count(PACKAGE_MARKER) != 1:
        raise ValueError("unknown native build recipe")
    native_recipe = recipe.split(PACKAGE_MARKER)[0]
    return hashlib.sha256(tree + b"\0native-recipe\0" + native_recipe).hexdigest()


def extract_plugin(directory, output):
    directory, output = Path(directory), Path(output)
    wheels = list(directory.glob("*.whl"))
    if len(wheels) != 1:
        raise ValueError("expected exactly one source wheel")
    wheel = wheels[0]
    checksums = (directory / "SHA256SUMS").read_text().splitlines()
    matching = [line.split() for line in checksums if line.split()[-1:] == [wheel.name]]
    if (len(matching) != 1 or len(matching[0]) != 2
            or not re.fullmatch(r"[0-9a-f]{64}", matching[0][0])):
        raise ValueError("missing or invalid source wheel checksum")
    with wheel.open("rb") as stream:
        digest = hashlib.file_digest(stream, "sha256").hexdigest()
    if digest != matching[0][0]:
        raise ValueError("source wheel checksum mismatch")
    with zipfile.ZipFile(wheel) as archive:
        libraries = [name for name in archive.namelist()
                     if name.endswith(".so") or ".so." in name]
        if libraries != [PLUGIN]:
            raise ValueError("source wheel must contain only the standalone plugin")
        plugin = archive.read(PLUGIN)
    if (plugin[:6] != b"\x7fELF\x02\x01" or len(plugin) < 20
            or int.from_bytes(plugin[16:18], "little") != 3
            or int.from_bytes(plugin[18:20], "little") != 62):
        raise ValueError("expected a Linux x86-64 ELF shared library")
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(plugin)
    return digest, hashlib.sha256(plugin).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", required=True)
    parser.add_argument("--run-id", required=True, type=int)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    if not re.fullmatch(r"[\w.-]+/[\w.-]+", args.repo) or args.run_id <= 0:
        parser.error("expected OWNER/REPO and a positive run ID")
    run = json.loads(subprocess.check_output(
        ["gh", "api", f"repos/{args.repo}/actions/runs/{args.run_id}"], text=True))
    if (run["conclusion"] != "success" or run["status"] != "completed"
            or run["head_repository"]["full_name"] != args.repo
            or run["path"].split("@")[0] != ".github/workflows/native.yml"):
        raise ValueError("source must be a successful native workflow in this repository")
    source = run["head_sha"]
    if not re.fullmatch(r"[0-9a-f]{40}", source):
        raise ValueError("invalid source commit")
    subprocess.run(["git", "fetch", "--no-tags", "origin", source], check=True)
    fingerprint = native_fingerprint("HEAD")
    if native_fingerprint(source) != fingerprint:
        raise ValueError("native build inputs differ; use the full native build")
    with tempfile.TemporaryDirectory() as staging:
        subprocess.run(["gh", "run", "download", str(args.run_id), "--repo", args.repo,
                        "--name", "manylinux-2-34-x86_64-wheel", "--dir", staging], check=True)
        wheel_hash, plugin_hash = extract_plugin(staging, args.output)
    provenance = dict(source_run_id=args.run_id, source_commit=source,
                      assembled_commit=subprocess.check_output(
                          ["git", "rev-parse", "HEAD"], text=True).strip(),
                      native_inputs_sha256=fingerprint, source_wheel_sha256=wheel_hash,
                      plugin_sha256=plugin_hash)
    args.output.with_suffix(".json").write_text(json.dumps(provenance, indent=2) + "\n")
    print(json.dumps(provenance, indent=2))


if __name__ == "__main__":
    main()
