"""Falcon analyzer: export original compressed XProf files via declared outputs.

Each JSON part is at most 1 MiB of original bytes; the inventory carries hashes
and paths. No compiler dumps are included.
"""
import base64
import hashlib
import json
import os
from pathlib import Path

src = Path(os.environ['ARTIFACT_LOCAL_DIR']) / 'rank-0/profiling/xprof'
out = Path(os.environ['RESULT_LOCAL_DIR'])
out.mkdir(parents=True, exist_ok=True)
files = sorted(p for p in src.rglob('*') if p.name.endswith(('.trace.json.gz', '.xplane.pb')))
assert files, 'No XProf files'
inventory = dict(files=[])
index = 0
for path in files:
    digest = hashlib.sha256()
    row = dict(path=str(path.relative_to(src)), bytes=path.stat().st_size, parts=[])
    with path.open('rb') as f:
        while chunk := f.read(1024*1024):
            assert index < 512, 'Profile exceeds declared export size limit'
            name = f'part-{index:04d}.json'
            digest.update(chunk)
            (out/name).write_text(json.dumps(dict(base64=base64.b64encode(chunk).decode())))
            row['parts'].append(name)
            index += 1
    row['sha256'] = digest.hexdigest()
    inventory['files'].append(row)
(out/'inventory.json').write_text(json.dumps(inventory, indent=2))
print([(f['path'], f['bytes']) for f in inventory['files']])
