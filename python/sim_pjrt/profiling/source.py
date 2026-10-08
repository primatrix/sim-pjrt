"""Source provenance is separate from executable timing identity."""

from functools import cache
import hashlib
from pathlib import Path
import re
import subprocess


def file_hash(path):
    try:
        return hashlib.sha256(path.read_bytes()).hexdigest() if path.is_file() else None
    except OSError:
        return None


def capture_sources(mlir):
    """Snapshot debug-location files before compilation, never during import."""
    files = {}
    for encoded in re.findall(r'"((?:\\.|[^"\\])*)":\d+:\d+', mlir):
        # MLIR escapes bytes as \XX, including quotes and UTF-8 path characters.
        filename = re.sub(rb'\\([0-9a-fA-F]{2})',
                          lambda m: bytes.fromhex(m[1].decode()), encoded.encode()).decode()
        if filename in files:
            continue
        path = Path(filename)
        record = {"sha256": file_hash(path)}
        if record["sha256"]:
            try:
                tracked = subprocess.run(
                    ["git", "-C", str(path.absolute().parent), "ls-files",
                     "--error-unmatch", "--", path.name], capture_output=True)
                if tracked.returncode == 0:
                    revision = subprocess.run(
                        ["git", "-C", str(path.absolute().parent), "rev-parse", "HEAD"],
                        capture_output=True, text=True)
                    if revision.returncode == 0:
                        record["git_commit"] = revision.stdout.strip()
            except FileNotFoundError:
                pass  # A content hash also identifies source outside Git checkouts.
        files[filename] = record
    return files


def replay_sources(timeline, files):
    """Allow live source links only when the captured file content still matches."""
    @cache
    def check(location):
        filename = re.sub(r':\d+(?::\d+)?$', '', location)
        recorded = files.get(filename, {})
        expected = recorded.get("sha256")
        revision = " ".join(f"{k}={recorded[k]}" for k in ("git_commit", "sha256")
                            if recorded.get(k))
        if not expected:
            return "unverified", revision
        current = file_hash(Path(filename))
        return ("missing" if current is None else
                "verified" if current == expected else "changed"), revision

    result = []
    for original in timeline:
        event = dict(original)
        source = event.get("source")
        stack = event.get("source_stack", "")
        if source or stack:
            status, revision = check(source or stack.splitlines()[0])
            event.update(source_status=status, source_revision=revision)
            # Validate the stack independently: an unknown caller must not hide
            # a verified top-level file, nor acquire a link through that file.
            if stack:
                states = [check(frame)[0] for frame in stack.splitlines()]
                event['source_stack_status'] = next(
                    (s for s in states if s != 'verified'), 'verified')
        result.append(event)
    return result
