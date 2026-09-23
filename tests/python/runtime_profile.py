"""Create a process-lifetime timing profile for integration-test delays."""

import atexit
import json
import os
from pathlib import Path
import tempfile


def configure_runtime(**settings):
    source = Path(os.environ["PJRT_SIM_BUNDLE_PROFILE"])
    profile = json.loads(source.read_text())
    profile.setdefault("runtime", {}).update(settings)
    with tempfile.NamedTemporaryFile(mode="w", suffix=".json", delete=False) as output:
        json.dump(profile, output)
    path = Path(output.name)
    atexit.register(path.unlink, missing_ok=True)
    os.environ["PJRT_SIM_BUNDLE_PROFILE"] = str(path)
