"""Exercise source pinning, idempotence, and relocation with a tiny Git fixture."""
import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
import unittest

spec = importlib.util.spec_from_file_location("prepare", Path(__file__).resolve().parents[1] / "scripts/prepare.py")
prepare = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prepare)


class PrepareTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.source = self.base / "upstream"
        self.source.mkdir()
        self.git("init", "--quiet")
        (self.source / ".bazelversion").write_text("8.7.0\n")
        (self.source / "xla/pjrt").mkdir(parents=True)
        (self.source / "xla/pjrt/BUILD").write_text("# pinned upstream\n")
        self.git("add", ".")
        self.git("-c", "user.name=Fixture", "-c", "user.email=fixture@example.invalid", "-c", "commit.gpgsign=false", "commit", "--quiet", "-m", "fixture")
        self.root = self.base / "plugin"
        for sub in ("third_party", "build_tools", "xla/pjrt/sim"):
            (self.root / sub).mkdir(parents=True)
        (self.root / ".bazelversion").write_text("8.7.0\n")
        (self.root / "build_tools/xla_configure.bazelrc").write_text("# test\n")
        self.lock = {"repository": str(self.source), "commit": self.git("rev-parse", "HEAD"),
                     "tree": self.git("rev-parse", "HEAD^{tree}"), "bazel": "8.7.0"}
        self.write_lock()
        original = prepare.ROOT
        prepare.ROOT = self.root
        self.addCleanup(setattr, prepare, "ROOT", original)

    def git(self, *args):
        return subprocess.check_output(["git", "-C", str(self.source), *args], text=True).strip()

    def write_lock(self):
        (self.root / "third_party/xla.lock.json").write_text(json.dumps(self.lock))

    def test_pinned_export_ignores_dirty_files_and_survives_move(self):
        (self.source / "xla/pjrt/BUILD").write_text("dirty\n")
        workspace = prepare.prepare(self.source)
        self.assertEqual((workspace / "xla/pjrt/BUILD").read_text(), "# pinned upstream\n")
        self.assertEqual(prepare.prepare(), workspace)
        moved = self.base / "moved"
        self.root.rename(moved)
        prepare.ROOT = moved
        workspace = prepare.prepare()
        self.assertEqual((workspace / "xla/pjrt/sim").resolve(), moved / "xla/pjrt/sim")

    def test_fetch_without_local_override(self):
        workspace = prepare.prepare()
        self.assertTrue((workspace / "xla/pjrt/BUILD").is_file())

    def test_tree_mismatch_does_not_publish_workspace(self):
        self.lock["tree"] = "0" * 40
        self.write_lock()
        with self.assertRaisesRegex(RuntimeError, "tree mismatch"):
            prepare.prepare(self.source)
        self.assertFalse((self.root / ".build/xla").exists())

    def test_changed_pin_requires_explicit_workspace_replacement(self):
        prepare.prepare(self.source)
        self.lock["tree"] = "0" * 40
        self.write_lock()
        with self.assertRaisesRegex(RuntimeError, "pin changed"):
            prepare.prepare()


if __name__ == "__main__":
    unittest.main()
