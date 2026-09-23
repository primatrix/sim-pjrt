"""Bazel produces the native library; setuptools assembles the platform wheel."""

import os
from pathlib import Path
import platform
import shutil
import subprocess

from setuptools import Distribution, setup
from setuptools.command.build_py import build_py
from setuptools.command.bdist_wheel import bdist_wheel

ROOT = Path(__file__).parent.resolve()


class BuildPy(build_py):
    def run(self):
        if platform.system() != "Linux" or platform.machine() != "x86_64":
            raise RuntimeError("sim-pjrt currently requires Linux x86-64")
        artifact = os.environ.get("SIM_PJRT_PLUGIN_PATH")
        if artifact:
            plugin = Path(artifact).resolve()
        else:
            subprocess.run(["bazel", "build", "//:plugin"], cwd=ROOT, check=True)
            plugin = ROOT / "bazel-bin/pjrt_sim_plugin.so"
        if not plugin.is_file():
            raise RuntimeError(f"Native plugin not found: {plugin}")
        super().run()
        package = Path(self.build_lib) / "sim_pjrt"
        for source, relative in (
            (plugin, "lib/pjrt_sim_plugin.so"),
            (ROOT / "configs/bundle_timing_example.json",
             "configs/bundle_timing_example.json"),
        ):
            target = package / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            # Bazel outputs are read-only. Do not propagate their mode into
            # setuptools' staging tree: subsequent wheel builds must overwrite it.
            target.unlink(missing_ok=True)
            shutil.copyfile(source, target)


class PlatformWheel(bdist_wheel):
    def finalize_options(self):
        super().finalize_options()
        self.root_is_pure = False

    def get_tag(self):
        # PJRT uses a C ABI, not the CPython extension ABI.
        _, _, platform_tag = super().get_tag()
        return "py3", "none", platform_tag


class NativeDistribution(Distribution):
    def has_ext_modules(self):
        return True


setup(distclass=NativeDistribution,
      cmdclass={"build_py": BuildPy, "bdist_wheel": PlatformWheel})
