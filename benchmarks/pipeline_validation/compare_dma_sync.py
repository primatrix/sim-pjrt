"""Compare observed wait/credit-decrement pairs without calling their spacing stalls."""
import argparse
from collections import Counter
import json
from pathlib import Path


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--hardware',type=Path,required=True)
    p.add_argument('--model',type=Path,required=True)
    p.add_argument('--alignment',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();h=json.loads(a.hardware.read_text());m=json.loads(a.model.read_text());align=json.loads(a.alignment.read_text())
    assert h['source_sha256']==align['source_sha256']
    result=dict(trace_sha256=h['trace_sha256'],calls=[],
                method='Pair dma.done.wait with next vsyncadd of same flag AND next bundle number, within 1 us.',
                limitations=['Spacing is between reconstructed instruction timestamps, not independently measured wait/stall cycles.',
                             'Q2/Q3 observed dynamic wait counts differ from model; ordinal DMA matching is invalid.',
                             'No explicit DMA-engine completion lane in this profile; sync points only constrain completion indirectly.'])
    for ci,c in enumerate(h['calls']):
        events=[e for e in c['events'] if e['track'].endswith('Instructions')]
        pairs=[];unmatched=[]
        for i,e in enumerate(events):
            if e['name']!='dma.done.wait':continue
            flag=e['args']['details'].split()[1];bundle=int(e['args']['bundle_number'])
            next_event=None
            for n in events[i+1:]:
                if n['start_us']-e['start_us']>1:break
                if n['name']=='vsyncadd' and n['args']['details'].split()[1]==flag and int(n['args']['bundle_number'])==bundle+1:
                    next_event=n;break
            if next_event:
                pairs.append(dict(start_us=e['start_us'],following_us=next_event['start_us'],
                                  spacing_us=next_event['start_us']-e['start_us'],bundle_number=bundle,flag_operand=flag))
            else:unmatched.append(e)
        phases=[]
        for phase in align['calls'][ci]['phases']:
            lo=phase['hardware_start_us'];hi=lo+phase['hardware_duration_us']
            subset=[e for e in events if lo<=e['start_us']<hi]
            pp=[e for e in pairs if lo<=e['start_us']<hi]
            ml=phase['model_start_us'];mh=ml+phase['model_duration_us']
            model_counts=Counter(op['name'] for e in m['events'] if e['kind']=='bundle' and ml<=e['start_us']<mh
                                 for op in e['alignment_operations'])
            phases.append(dict(name=phase['name'],kind=phase['kind'],observed_counts=dict(Counter(e['name'] for e in subset)),
                               model_counts=dict(model_counts),wait_pairs=pp,wait_pair_spacing_sum_us=sum(e['spacing_us'] for e in pp),
                               wait_pair_spacing_max_us=max((e['spacing_us'] for e in pp),default=0)))
        result['calls'].append(dict(duration_us=c['duration_us'],phases=phases,unmatched_waits=unmatched,
                                    q_internal_pair_spacing_sum_us=sum(p['wait_pair_spacing_sum_us'] for p in phases if p['kind']=='mxu_span')))
    a.output.write_text(json.dumps(result,indent=2)+'\n')
    print([(c['duration_us'],c['q_internal_pair_spacing_sum_us'],len(c['unmatched_waits'])) for c in result['calls']])


if __name__=='__main__':main()
