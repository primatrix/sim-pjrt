"""Derive opt-in bundle issue floors from local matched intervals, not total runtime.

Train only on call 0/head 0 Q internals. Require consecutive static addresses in
both compilations, one modeled issue cycle, same VLD/VST lane, and repeated
support across static positions. Call 1 and head 1 are held out.
"""
import argparse
from collections import defaultdict
import gzip
import hashlib
import json
from pathlib import Path
import statistics


def main():
    p=argparse.ArgumentParser(description=__doc__)
    for name in ('pairs','bundles','model','profile','table_output','profile_output'):
        p.add_argument('--'+name.replace('_','-'),type=Path,required=True)
    a=p.parse_args();rows=json.loads(gzip.decompress(a.pairs.read_bytes()));b=json.loads(a.bundles.read_text());m=json.loads(a.model.read_text());profile=json.loads(a.profile.read_text());hz=b['frequency_hz']
    lookup={}
    for address,start,end,ids in b['bundles']:
        if not address.startswith('0:0x97/'):continue
        source=int(address.split('/')[-1].split('@')[0].split(':')[-1],16)
        key=(source,round(start/hz*1e6-m['kernel_origin_us'],6))
        lookup[key]=('|'.join(sorted(b['opcodes'][i] for i in ids)),end-start)
    groups=defaultdict(list);rejected=0
    for l,r in zip(rows,rows[1:]):
        if l[0]!=0 or l[1] not in (1,3,5,7) or l[:2]!=r[:2]:continue
        if l[7] not in ('vld','vst') or l[7]!=r[7] or r[2]!=l[2]+1 or r[3]!=l[3]+1:continue
        signature,cycles=lookup[(l[2],l[5])]
        if abs(cycles-1)>1e-8 or abs((r[5]-l[5])*hz/1e6-1)>.005:continue
        ns=(r[6]-l[6])*1000
        if not .1<ns<2:rejected+=1;continue
        groups[signature].append((ns,l[2]))
    costs={};stats={}
    for signature,samples in sorted(groups.items()):
        positions=len(set(s[1] for s in samples))
        if len(samples)<64 or positions<8:continue
        vals=sorted(v for v,_ in samples);median=statistics.median(vals)
        costs[signature]=max(1,median*hz/1e9)
        stats[signature]=dict(samples=len(vals),static_positions=positions,median_ns=median,p10_ns=vals[int(.1*len(vals))],p90_ns=vals[int(.9*len(vals))])
    assert costs
    pooled=[value for signature,samples in groups.items() if signature in costs for value,_ in samples]
    table=dict(schema_version=1,kind='empirical_bundle_issue_floor',frequency_hz=hz,
               default_floor_cycles=max(1,statistics.median(pooled)*hz/1e9),
               compiler_binary_sha256=profile['compiler_binary_sha256'],cycles_by_signature=costs,support=stats,
               provenance=dict(pairs_sha256=hashlib.sha256(a.pairs.read_bytes()).hexdigest(),
               training='XProf call0 head0 Q0-Q3 only; consecutive model/hardware bundle IDs, same VLD/VST family, one modeled issue cycle',
               held_out='All call1; call0 head1',
               scope='best kernel 2K BF16 MHA32 D256; interpolated instruction trace. Not a hardware clock or causal stall model. Unseen signatures use pooled training median: empirical generalization, not measured per-signature costs.',
               minimum_samples=64,minimum_static_positions=8,rejected_interval_samples=rejected))
    a.table_output.parent.mkdir(parents=True,exist_ok=True);a.table_output.write_text(json.dumps(table,indent=2)+'\n')
    profile['bundle_issue_calibration']=table
    profile['description']='Opt-in empirical local issue-floor calibration; unchanged nominal frequency and DMA parameters; see table provenance.'
    a.profile_output.parent.mkdir(parents=True,exist_ok=True);a.profile_output.write_text(json.dumps(profile,indent=2)+'\n')
    print('signatures',len(costs),'samples',sum(s['samples'] for s in stats.values()),'median cycles',statistics.median(costs.values()))


if __name__=='__main__':main()
