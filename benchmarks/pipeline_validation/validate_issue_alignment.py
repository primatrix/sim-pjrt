"""Evaluate changed model times on FIXED correspondences, including held-out data.

No rematching and no time scale/offset fit. Only each kernel's start is zeroed.
"""
import argparse
from collections import defaultdict
import gzip
import json
from pathlib import Path
import statistics


def metrics(values):
    values=sorted(values)
    return dict(count=len(values),mae_us=statistics.mean(abs(v) for v in values),
                signed_mean_us=statistics.mean(values),p95_abs_us=sorted(map(abs,values))[int(.95*(len(values)-1))],
                max_abs_us=max(map(abs,values))) if values else None


def main():
    p=argparse.ArgumentParser(description=__doc__)
    for key in ('baseline_bundles','calibrated_bundles','baseline_model','calibrated_model','pairs','alignment','output'):
        p.add_argument('--'+key.replace('_','-'),required=True,type=Path)
    a=p.parse_args();base=json.loads(a.baseline_bundles.read_text());cal=json.loads(a.calibrated_bundles.read_text());bm=json.loads(a.baseline_model.read_text());cm=json.loads(a.calibrated_model.read_text());al=json.loads(a.alignment.read_text())
    assert [(b[0],b[3]) for b in base['bundles']]==[(b[0],b[3]) for b in cal['bundles']], 'Execution path changed'
    assert base['opcodes']==cal['opcodes'] and base['frequency_hz']==cal['frequency_hz']
    times={b[0]:b[1]/cal['frequency_hz']*1e6-cm['kernel_origin_us'] for b in cal['bundles']}
    values=defaultdict(lambda:dict(baseline=[],calibrated=[]));sample=defaultdict(list)
    with gzip.open(a.pairs,'rt') as f:
        for line in f:
            r=json.loads(line);key=(r['call'],r['phase']);ct=times[r['model_address']]
            values[key]['baseline'].append(r['model_us']-r['hardware_us']);values[key]['calibrated'].append(ct-r['hardware_us'])
            sample[key].append((r['model_address'],ct))
    report=dict(baseline_kernel_us=bm['kernel_duration_us'],calibrated_kernel_us=cm['kernel_duration_us'],
                baseline_full_program_us=bm['full_program_duration_us'],calibrated_full_program_us=cm['full_program_duration_us'],
                ordinary_hardware_reference_us=149.81437549999828,phases=[],groups={},
                validation='Fixed instruction correspondences; exact same model addresses/opcodes/path; unchanged frequency and DMA; kernel origins only.',
                limitation='Held-out head/call from SAME capture, not an independent hardware experiment. Empirical issue floor, not causal attribution.')
    grouped=defaultdict(lambda:dict(baseline=[],calibrated=[]))
    for ci,c in enumerate(al['calls']):
        for pi,phase in enumerate(c['phases']):
            key=(ci,phase['name']);v=values[key]
            group='training_head0_Q_interiors' if ci==0 and pi in (1,3,5,7) else 'held_out_call1' if ci==1 else 'held_out_call0_other'
            for k in ('baseline','calibrated'):grouped[group][k].extend(v[k])
            report['phases'].append(dict(call=ci,name=phase['name'],group=group,baseline=metrics(v['baseline']),calibrated=metrics(v['calibrated'])))
    report['groups']={k:{mode:metrics(vals) for mode,vals in v.items()} for k,v in grouped.items()}
    report['kernel_error_us']=[cm['kernel_duration_us']-c['duration_us'] for c in al['calls']]
    a.output.parent.mkdir(parents=True,exist_ok=True);a.output.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({k:v for k,v in report.items() if k!='phases'},indent=2))


if __name__=='__main__':main()
