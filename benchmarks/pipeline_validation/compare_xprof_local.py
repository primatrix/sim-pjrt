"""Compare local original XProf against modeled Q phases without clock fitting."""
import argparse
import bisect
from collections import Counter, defaultdict
import gzip
import hashlib
import json
from pathlib import Path
import statistics


def model_vld_steps(bundles, opcodes, hz):
    selected=[b for b in bundles if any(opcodes[op].split('.')[0]=='vld' for op in b[3])]
    values=[]
    for left,right in zip(selected,selected[1:]):
        la=left[0].split('@')[0];ra=right[0].split('@')[0]
        if la.rsplit(':',1)[0]==ra.rsplit(':',1)[0] and int(ra.rsplit(':',1)[1],16)==int(la.rsplit(':',1)[1],16)+1:
            values.append((right[1]-left[1])/hz*1e9)
    return dict(count=len(values),median_ns=statistics.median(values)) if values else None


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--hardware',type=Path,required=True)
    p.add_argument('--model-bundles',type=Path,required=True)
    p.add_argument('--model',type=Path,required=True)
    p.add_argument('--alignment',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args()
    path=next((a.hardware/'profile').rglob('*.trace.json.gz'))
    with gzip.open(path,'rt') as f:trace=json.load(f)
    threads={(e.get('pid'),e.get('tid')):e.get('args',{}).get('name','') for e in trace['traceEvents']
             if e.get('ph')=='M' and e.get('name')=='thread_name'}
    kernels=sorted([e for e in trace['traceEvents'] if e.get('ph')=='X'
                    and threads.get((e.get('pid'),e.get('tid')))=='XLA Ops'
                    and 'varlen_attention_mha_native' in e['name']],key=lambda e:e['ts'])
    model=json.loads(a.model_bundles.read_text());align=json.loads(a.alignment.read_text())
    origin=json.loads(a.model.read_text())['kernel_origin_us']
    model_times=[b[1]/model['frequency_hz']*1e6-origin for b in model['bundles']]
    output=dict(trace_sha256=hashlib.sha256(path.read_bytes()).hexdigest(),calls=[],
                limitations=['Observed wait→vsyncadd spacing is not a direct hardware stall measurement.',
                             'Instruction times can be reconstructed/interpolated; dynamic counts may be incomplete.',
                             'Different instrumentation/compilation: no cross-binary bundle-number equality assumed.',
                             'Time-step statistics are observed trace slopes, not an independent clock measurement.'])
    for ci,kernel in enumerate(kernels):
        lanes=defaultdict(list)
        for e in trace['traceEvents']:
            if e.get('ph')!='X' or e.get('pid')!=kernel['pid']:continue
            t=e['ts']-kernel['ts']
            if not 0<=t<kernel['dur']:continue
            lane=threads.get((e.get('pid'),e.get('tid')),'')
            if 'Instructions' not in lane:continue
            lanes[lane].append((t,e))
        for es in lanes.values():es.sort(key=lambda x:x[0])
        phase_rows=[]
        for phase in align['calls'][ci]['phases']:
            lo=phase['hardware_start_us'];hi=lo+phase['hardware_duration_us']
            counts=Counter();samples=defaultdict(list);all_events=[]
            for lane,es in lanes.items():
                times=[e[0] for e in es]
                selected=es[bisect.bisect_left(times,lo):bisect.bisect_left(times,hi)]
                all_events.extend(selected)
                counts.update(e['name'] for _,e in selected)
                for (lt,l),(rt,r) in zip(selected,selected[1:]):
                    lb=l.get('args',{}).get('bundle_number');rb=r.get('args',{}).get('bundle_number')
                    if lb and rb and int(rb)==int(lb)+1:
                        samples[lane].append((rt-lt)*1000)
            all_events.sort(key=lambda x:x[0]);times=[e[0] for e in all_events]
            # Pair explicit wait and credit decrement with the same flag operand.
            # Only pair adjacent bundle numbers; reject missing/reordered samples.
            waits=[]
            for ix,(t,e) in enumerate(all_events):
                if e['name']!='dma.done.wait':continue
                flag=e['args']['details'].split()[1];bundle=int(e['args']['bundle_number'])
                following=None
                for nt,n in all_events[ix+1:]:
                    if nt-t>.5:break
                    if n['name']=='vsyncadd' and n['args']['details'].split()[1]==flag and int(n['args']['bundle_number'])==bundle+1:
                        following=(nt,n);break
                if following:
                    nt,n=following
                    waits.append(dict(start_us=t,following_vsyncadd_us=nt,spacing_us=nt-t,
                                      bundle_number=bundle,flag_operand=flag,details=e['args']['details']))
            mlo=phase['model_start_us'];mhi=mlo+phase['model_duration_us']
            mb=model['bundles'][bisect.bisect_left(model_times,mlo):bisect.bisect_left(model_times,mhi)]
            mc=Counter(model['opcodes'][op] for b in mb for op in b[3])
            stats={lane:dict(count=len(v),median_ns=statistics.median(v),p10_ns=sorted(v)[int(.1*len(v))],
                            p90_ns=sorted(v)[int(.9*len(v))]) for lane,v in samples.items() if v}
            phase_rows.append(dict(name=phase['name'],kind=phase['kind'],hardware_opcode_counts=dict(counts),
                                   model_opcode_counts=dict(mc),hardware_wait_pairs=waits,
                                   wait_pair_spacing_sum_us=sum(w['spacing_us'] for w in waits),
                                   model_adjacent_vld_bundle_steps=model_vld_steps(mb,model['opcodes'],model['frequency_hz']),
                                   observed_adjacent_bundle_steps=stats))
        output['calls'].append(dict(duration_us=kernel['dur'],phases=phase_rows))
    a.output.write_text(json.dumps(output,indent=2)+'\n')
    print('sha256',output['trace_sha256'])
    for c in output['calls']:
        print('call',c['duration_us'])
        for p in c['phases']:
            if p['kind']!='mxu_span':continue
            print(p['name'],'wait pairs',len(p['hardware_wait_pairs']),'sum_us',p['wait_pair_spacing_sum_us'],
                  'vld steps',p['observed_adjacent_bundle_steps'].get('VLD Instructions'))


if __name__=='__main__':main()
