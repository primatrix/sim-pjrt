"""Apply conservative order checks to existing matches without reparsing XProf."""
import argparse
import gzip
import itertools
import json
from pathlib import Path
from match_xprof_timeline import chronology_conflicts, render


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',type=Path,required=True);p.add_argument('--alignment',type=Path,required=True);a=p.parse_args();root=a.directory
    report=json.loads((root/'summary.json').read_text());display=[];removed=0
    target=root/'instruction-pairs.validated.jsonl.gz'
    with gzip.open(root/'instruction-pairs.jsonl.gz','rt') as src,gzip.open(target,'wt') as dst,gzip.open(root/'unmatched-events.jsonl.gz','at') as unmatched:
        rows=(json.loads(line) for line in src)
        for (ci,name),group in itertools.groupby(rows,key=lambda r:(r['call'],r['phase'])):
            entries=list(group);candidates=[((r['model_address'].split('@')[0],r['opcode']),r) for r in entries]
            bad=chronology_conflicts(candidates);pi=next(i for i,p in enumerate(report['calls'][ci]['phases']) if p['name']==name)
            phase=report['calls'][ci]['phases'][pi];points={}
            for key,row in candidates:
                if key in bad:
                    removed+=1;phase['matched_instructions']-=1;report['calls'][ci]['matched_instructions']-=1
                    ex=phase['excluded_model'];ex['cross_family_order_conflict']=ex.get('cross_family_order_conflict',0)+1
                    for side,t,b in [('model',row['model_us'],row['model_address']),('hardware',row['hardware_us'],row['hardware_bundle'])]:
                        unmatched.write(json.dumps(dict(call=ci,phase=name,side=side,time_us=t,bundle=b,opcode=row['opcode'],reason='cross_family_order_conflict'),separators=(',',':'))+'\n')
                    continue
                dst.write(json.dumps(row,separators=(',',':'))+'\n')
                rank=0 if row['opcode']=='vld' else 1 if row['opcode']=='vst' else 2
                address=row['model_address'];source=int(address.split('/')[-1].split('@')[0].split(':')[-1],16)
                point=[ci,pi,source,row['hardware_bundle'],row['occurrence'],round(row['model_us'],6),round(row['hardware_us'],6),row['opcode'],rank]
                if address not in points or rank<points[address][-1]:points[address]=point
            phase['represented_dynamic_bundles']=len(points)
            display.extend(p[:-1] for p in sorted(points.values(),key=lambda p:p[5]))
    target.replace(root/'instruction-pairs.jsonl.gz')
    report['ordering_validation']='Reject entire phase/bundle/opcode keys on VLD-anchor and representative chronological conflicts (both endpoints); tolerate 10 ns reconstruction jitter. Time never selects replacement matches.'
    (root/'summary.json').write_text(json.dumps(report,indent=2)+'\n')
    (root/'bundle-pairs.json.gz').write_bytes(gzip.compress(json.dumps(display,separators=(',',':')).encode()))
    render(root,display,report,json.loads(a.alignment.read_text()))
    print('Removed order-conflicting instruction matches:',removed,'bundle points:',len(display))


if __name__=='__main__':main()
