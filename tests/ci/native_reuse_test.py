"""Native reuse must reject changed build inputs and invalid wheel contents."""

import hashlib
from pathlib import Path
import runpy
import subprocess
import tempfile
import unittest
import zipfile


SCRIPT = Path(__file__).resolve().parents[2] / ".github/scripts/reuse_native.py"
helpers = runpy.run_path(str(SCRIPT))
native_fingerprint = helpers["native_fingerprint"]
extract_plugin = helpers["extract_plugin"]
MARKER = helpers["PACKAGE_MARKER"].decode()
PLUGIN = helpers["PLUGIN"]


class NativeFingerprintTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.git("init", "--quiet")
        self.write("src/plugin.cc", "native source")
        self.write("docker/release.sh", "bazel test //...\n" + MARKER + "\npackage wheel\n")
        self.commit()
        self.before = native_fingerprint("HEAD", root=self.root)

    def git(self, *args):
        subprocess.run(["git", "-C", str(self.root), "-c", "user.name=Test",
                        "-c", "user.email=test@example.invalid", "-c", "commit.gpgsign=false",
                        *args], check=True, stdout=subprocess.DEVNULL)

    def write(self, path, contents):
        target = self.root / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(contents)

    def commit(self):
        self.git("add", ".")
        self.git("commit", "--quiet", "-m", "fixture")

    def test_python_and_packaging_changes_can_reuse_native_plugin(self):
        self.write("python/sim_pjrt/llo/runtime.py", "new Python timing model")
        self.write("docker/release.sh", "bazel test //...\n" + MARKER + "\nnew packaging\n")
        self.commit()
        self.assertEqual(native_fingerprint("HEAD", root=self.root), self.before)

    def test_changed_native_sources_are_rejected(self):
        self.write("src/plugin.cc", "changed native source")
        self.commit()
        self.assertNotEqual(native_fingerprint("HEAD", root=self.root), self.before)

    def test_build_flags_and_patches_are_native_inputs(self):
        for path in (".bazelrc", "third_party/patch.diff", "tests/cpp/plugin_test.cc"):
            with self.subTest(path=path):
                before = native_fingerprint("HEAD", root=self.root)
                self.write(path, "changed build input")
                self.commit()
                self.assertNotEqual(native_fingerprint("HEAD", root=self.root), before)

    def test_native_build_command_is_checked_separately_from_packaging(self):
        self.write("docker/release.sh", "bazel test //... --copt=-DCHANGED\n" + MARKER + "\npackage\n")
        self.commit()
        self.assertNotEqual(native_fingerprint("HEAD", root=self.root), self.before)

    def test_unrecognized_recipe_fails_closed(self):
        self.write("docker/release.sh", "some other native build")
        self.commit()
        with self.assertRaisesRegex(ValueError, "unknown native build recipe"):
            native_fingerprint("HEAD", root=self.root)


class NativeExtractionTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.output = self.root / "output/plugin.so"
        self.plugin = b"\x7fELF\x02\x01" + bytes(10) + b"\x03\x00\x3e\x00" + bytes(44)

    def wheel(self, plugin=None, *, extra=None):
        wheel = self.root / "sim_pjrt-0.1.1-py3-none-manylinux_2_34_x86_64.whl"
        with zipfile.ZipFile(wheel, "w") as archive:
            archive.writestr(PLUGIN, self.plugin if plugin is None else plugin)
            if extra:
                archive.writestr(extra, b"another library")
        digest = hashlib.sha256(wheel.read_bytes()).hexdigest()
        (self.root / "SHA256SUMS").write_text(digest + "  " + wheel.name + "\n")
        return wheel, digest

    def test_valid_standalone_plugin_is_extracted_with_hashes(self):
        _, digest = self.wheel()
        self.assertEqual(extract_plugin(self.root, self.output),
                         (digest, hashlib.sha256(self.plugin).hexdigest()))
        self.assertEqual(self.output.read_bytes(), self.plugin)

    def test_corrupt_wheel_is_rejected_before_writing_plugin(self):
        wheel, _ = self.wheel()
        with wheel.open("ab") as stream:
            stream.write(b"changed")
        with self.assertRaisesRegex(ValueError, "checksum mismatch"):
            extract_plugin(self.root, self.output)
        self.assertFalse(self.output.exists())

    def test_additional_bundled_libraries_require_a_full_build(self):
        self.wheel(extra="sim_pjrt.libs/libdependency.so.1")
        with self.assertRaisesRegex(ValueError, "standalone plugin"):
            extract_plugin(self.root, self.output)
        self.assertFalse(self.output.exists())

    def test_wrong_binary_format_is_rejected(self):
        self.wheel(plugin=b"not an ELF library")
        with self.assertRaisesRegex(ValueError, "ELF shared library"):
            extract_plugin(self.root, self.output)
        self.assertFalse(self.output.exists())


if __name__ == "__main__":
    unittest.main()
