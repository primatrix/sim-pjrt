"""Inspect copied trace schema without printing the full capture."""
import collections
import gzip
import json
import sys
from pathlib import Path

root = Path(sys.argv[1])
path = next((root / 'baseline/capture/profile').rglob('*.trace.json.gz'))
with gzip.open(path, 'rt') as f:
    data = json.load(f)
events = data['traceEvents']
tracks = {(e.get('pid'), e.get('tid')): e.get('args', {}).get('name')
          for e in events if e.get('ph') == 'M' and e.get('name') == 'thread_name'}
counts = collections.Counter()
samples = collections.defaultdict(list)
for e in events:
    if e.get('ph') != 'X':
        continue
    track = tracks.get((e.get('pid'), e.get('tid')), '?')
    counts[track] += 1
    key = track + ':' + e.get('name', '').split('.')[0]
    if len(samples[key]) < 1:
        samples[key].append(e)
result = {'tracks': dict(counts), 'samples': dict(samples)}
(root.parent / 'probe.json').write_text(json.dumps(result, indent=2))
print(json.dumps({'tracks': dict(counts), 'sample_keys': [k for k in samples if 'Instructions' in k]}, indent=2))
