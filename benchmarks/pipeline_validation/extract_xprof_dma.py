"""Falcon analyzer: export compact DMA/sync and MXU boundary XProf evidence."""
import gzip
import hashlib
import json
import os
from pathlib import Path

src = Path(os.environ['ARTIFACT_LOCAL_DIR'])
out = Path(os.environ['RESULT_LOCAL_DIR'])
source_sha = hashlib.sha256((src / 'source/kernels/prefetch.py').read_bytes()).hexdigest()
paths = list((src / 'rank-0/profiling/xprof').rglob('*.trace.json.gz'))
assert len(paths) == 1, paths
with gzip.open(paths[0], 'rt') as f:
    trace = json.load(f)
threads = {(e.get('pid'), e.get('tid')): e.get('args', {}).get('name', '')
           for e in trace['traceEvents'] if e.get('ph') == 'M' and e.get('name') == 'thread_name'}
events = [e for e in trace['traceEvents'] if e.get('ph') == 'X']
calls = sorted((e for e in events if threads.get((e.get('pid'), e.get('tid'))) == 'XLA Ops'
                and 'varlen_attention_mha_native' in e.get('name', '')), key=lambda e: e['ts'])
result = dict(source_sha256=source_sha, trace_sha256=hashlib.sha256(paths[0].read_bytes()).hexdigest(),
              calls=[], tracks=sorted(set(threads.values())),
              limitations=['Instruction timestamps can be interpolated between hardware anchors.',
                           'Instruction issue/duration does not establish DMA completion.'])
for call in calls:
    selected, mats = [], []
    for e in events:
        if e.get('pid') != call['pid'] or not call['ts'] <= e['ts'] < call['ts'] + call['dur']:
            continue
        track = threads.get((e.get('pid'), e.get('tid')), '')
        name = e.get('name', '')
        row = dict(start_us=e['ts'] - call['ts'], duration_us=e.get('dur', 0),
                   name=name, track=track, args=e.get('args', {}))
        if any(s in name.lower() for s in ('dma', 'sync', 'fence')) or 'dma' in track.lower():
            selected.append(row)
        if track.startswith('MXU') and name.startswith('vmatmul'):
            mats.append(row)
    mats.sort(key=lambda e: e['start_us'])
    gaps = []
    for left, right in zip([None] + mats, mats + [None]):
        lo = left['start_us'] if left else 0
        hi = right['start_us'] if right else call['dur']
        if hi - lo > 1:
            gaps.append(dict(start_us=lo, end_us=hi, duration_us=hi-lo, left=left, right=right))
    result['calls'].append(dict(duration_us=call['dur'], events=sorted(selected, key=lambda e: e['start_us']),
                                matmul_count=len(mats), mxu_gaps_over_1us=gaps))
assert calls, 'No kernel calls'
out.mkdir(parents=True, exist_ok=True)
(out / 'dma-sync.json').write_text(json.dumps(result, indent=2))
print([(c['duration_us'], len(c['events'])) for c in result['calls']])
