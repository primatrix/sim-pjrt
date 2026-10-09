"""Generate standalone figures from audited results (matplotlib, no network)."""
import json
from pathlib import Path
import sys

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

root = Path(sys.argv[1])
variants = ['baseline', 'single_raw', 'dual_acc']
reports = [json.loads((root / (v + '.json')).read_text()) for v in variants]
fig, axes = plt.subplots(3, 1, figsize=(13, 8), constrained_layout=True)
lanes = ['SALU', 'VALU', 'VLD', 'VST', 'MXU0', 'MXU1', 'XLU', 'EUP']
for ax, report in zip(axes, reports):
    call = report['calls'][0]
    rows = [call['event_count_bins_500ns'][lane + ' Instructions'] for lane in lanes]
    array = np.log1p(np.array(rows))
    im = ax.imshow(array, aspect='auto', origin='lower', extent=(0, len(rows[0]) * .5, -.5, 7.5),
                   cmap='viridis', vmin=0, vmax=8)
    ax.set_yticks(range(8), lanes)
    ax.set_xlim(0, 510)
    ax.set_title(f"{report['variant']} — instrumented call 0, {call['duration_us']:.3f} us")
    ax.set_xlabel('Time from kernel start (us)')
fig.colorbar(im, ax=axes, label='log(1 + reconstructed instruction events / 500 ns)')
fig.suptitle('Observed XProf instruction streams — event density, NOT hardware utilization')
fig.savefig(root / 'observed-pipelines.svg')
fig.savefig(root / 'observed-pipelines.png', dpi=150)
plt.close(fig)

fig, ax = plt.subplots(figsize=(9, 4), constrained_layout=True)
x = np.arange(3)
observed = [r['calls'][1]['duration_us'] for r in reports]
floors = [r['calls'][1]['count_resource_floor_us'] for r in reports]
ax.bar(x - .19, observed, .38, label='Measured instrumented call 1')
ax.bar(x + .19, floors, .38, label='Count resource floor (8 cycles, assumed 2.2 GHz)')
ax.set_xticks(x, variants)
ax.set_ylabel('us')
ax.set_title('Resource floor misses full latency — not a calibrated kernel prediction')
ax.legend()
fig.savefig(root / 'resource-floor.svg')
plt.close(fig)

example = json.loads((root / 'example-report.json').read_text())
tracks = sorted({e['track'] for e in example['timeline']})
fig, ax = plt.subplots(figsize=(11, 5), constrained_layout=True)
for e in example['timeline']:
    y = tracks.index(e['track'])
    ax.broken_barh([(e['start_cycle'], e['end_cycle'] - e['start_cycle'])], (y - .35, .7))
ax.set_yticks(range(len(tracks)), tracks)
ax.set_xlabel('Cycles (illustrative costs)')
ax.set_title('Synthetic example: reservations, result latency and waits are distinct')
fig.savefig(root / 'example-pipeline.svg')
plt.close(fig)
print('Wrote 4 standalone plots')
