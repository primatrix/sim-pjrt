#!/usr/bin/env python3
"""Prepare a pinned, disposable XLA build workspace without vendoring XLA."""
import argparse
import fcntl
import json
import os
from pathlib import Path
import shutil
import subprocess
import tarfile
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def git(*args, cwd=None):
    return subprocess.check_output(["git", *args], cwd=cwd, text=True).strip()


def prepare(local_git=None):
    lock = json.loads((ROOT / "third_party/xla.lock.json").read_text())
    if (ROOT / ".bazelversion").read_text().strip() != lock["bazel"]:
        raise RuntimeError("Repository Bazel version does not match XLA lock")
    build = ROOT / ".build"
    build.mkdir(exist_ok=True)
    workspace = build / "xla"
    marker = workspace / ".sim-pjrt-source.json"
    # Serialize preparation by concurrent build/test invocations.
    with (build / "prepare.lock").open("w") as guard:
        fcntl.flock(guard, fcntl.LOCK_EX)
        if workspace.exists():
            if not marker.exists() or json.loads(marker.read_text()) != lock:
                raise RuntimeError("XLA pin changed or workspace is unmanaged; move .build/xla aside and retry")
        else:
            with tempfile.TemporaryDirectory(prefix="prepare-", dir=build) as tmp:
                tmp = Path(tmp)
                if local_git:
                    source = Path(local_git).resolve()
                else:
                    source = tmp / "git"
                    subprocess.run(["git", "init", "--quiet", str(source)], check=True)
                    subprocess.run([
                        "git", "-C", str(source), "fetch", "--depth=1", "--no-tags",
                        lock["repository"], lock["commit"],
                    ], check=True)
                if git("rev-parse", lock["commit"] + "^{commit}", cwd=source) != lock["commit"]:
                    raise RuntimeError("XLA commit mismatch")
                if git("rev-parse", lock["commit"] + "^{tree}", cwd=source) != lock["tree"]:
                    raise RuntimeError("XLA source tree mismatch")
                archive = tmp / "xla.tar"
                subprocess.run([
                    "git", "-C", str(source), "archive", "--format=tar",
                    "--output=" + str(archive), lock["commit"],
                ], check=True)
                staged = tmp / "xla"
                staged.mkdir()
                with tarfile.open(archive) as contents:
                    contents.extractall(staged, filter="data")
                if (staged / ".bazelversion").read_text().strip() != lock["bazel"]:
                    raise RuntimeError("Pinned XLA Bazel version does not match lock")
                (staged / ".sim-pjrt-source.json").write_text(json.dumps(lock, indent=2) + "\n")
                staged.rename(workspace)
        overlay = workspace / "xla/pjrt/sim"
        expected = ROOT / "xla/pjrt/sim"
        if overlay.is_symlink():
            if overlay.resolve() != expected:
                raise RuntimeError("Unexpected simulator overlay: " + str(overlay))
        elif overlay.exists():
            raise RuntimeError("Pinned XLA already contains xla/pjrt/sim")
        else:
            overlay.symlink_to(os.path.relpath(expected, overlay.parent), target_is_directory=True)
        shutil.copyfile(ROOT / "build_tools/xla_configure.bazelrc", workspace / "xla_configure.bazelrc")
        # Existing Python tools discover native artifacts via this stable path.
        for name in ("bazel-bin", "bazel-testlogs"):
            link = ROOT / name
            target = Path(".build/xla") / name
            if link.is_symlink():
                if link.readlink() != target:
                    raise RuntimeError("Unexpected artifact link: " + str(link))
            elif link.exists():
                raise RuntimeError("Refusing to replace " + str(link))
            else:
                link.symlink_to(target, target_is_directory=True)
    return workspace


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--xla-git", type=Path, help="Export the pinned commit from an existing Git checkout (offline)")
    args = parser.parse_args()
    print(prepare(args.xla_git))
