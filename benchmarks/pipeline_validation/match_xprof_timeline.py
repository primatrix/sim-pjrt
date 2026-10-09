"""Static opcode-context matching followed by phase-local occurrence matching.

No timing is used to choose a correspondence. Ambiguous static windows and
unequal dynamic multiplicities remain unmatched. Correspondences are inferred
across compiler variants; they are not an assertion of binary identity.
"""
import argparse
import base64
from bisect import bisect_left
from collections import Counter, defaultdict
import difflib
import gzip
import hashlib
import json
from pathlib import Path


def norm(op):
    for prefix in ('vmatmul','vmatprep','vmatpush','vpop','vpack','vunpack','vcmp','scmp','scalar_lea','vweird'):
        if op.startswith(prefix):return prefix
    return op.replace('.xlu0','').replace('.xlu1','')


def static_match(left, right, width=11):
    # Unique opcode-context seeds, then monotone longest-increasing subsequence.
    def windows(seq):
        positions=defaultdict(list)
        for i in range(len(seq)-width+1):positions[tuple(seq[i:i+width])].append(i)
        return positions
    lwin,rwin=windows(left),windows(right)
    candidates=sorted((v[0],rwin[k][0]) for k,v in lwin.items() if len(v)==1 and len(rwin.get(k,[]))==1)
    tails=[];ends=[];previous=[]
    for idx,(_,j) in enumerate(candidates):
        pos=bisect_left(tails,j);previous.append(ends[pos-1] if pos else -1)
        if pos==len(tails):tails.append(j);ends.append(idx)
        else:tails[pos]=j;ends[pos]=idx
    anchors=[];idx=ends[-1] if ends else -1
    while idx>=0:
        anchors.append(candidates[idx]);idx=previous[idx]
    anchors.reverse()
    pairs={};proof={};last=(-width,-width)
    for i,j in anchors:
        if i<last[0]+width or j<last[1]+width:continue
        for offset in range(width):pairs[i+offset]=j+offset;proof[i+offset]='unique_11_bundle_context'
        last=(i,j)
    # Only fill short intervals bounded on BOTH sides by independently unique seeds.
    ordered=sorted(pairs.items());fills=[]
    for (li,ri),(lj,rj) in zip(ordered,ordered[1:]):
        if 1<lj-li<=256 and 1<rj-ri<=256:
            a,b=left[li+1:lj],right[ri+1:rj]
            matcher=difflib.SequenceMatcher(None,a,b,autojunk=False)
            for block in matcher.get_matching_blocks():
                # Short/repeated fragments inside a gap remain ambiguous.
                if block.size<5:continue
                token=tuple(a[block.a:block.a+block.size])
                if sum(tuple(a[k:k+block.size])==token for k in range(len(a)-block.size+1))!=1:continue
                if sum(tuple(b[k:k+block.size])==token for k in range(len(b)-block.size+1))!=1:continue
                for z in range(block.size):fills.append((li+1+block.a+z,ri+1+block.b+z))
    for i,j in fills:pairs[i]=j;proof[i]='unique_bounded_sequence'
    assert len(set(pairs.values()))==len(pairs)
    return pairs,proof,len(candidates)


def chronology_conflicts(candidates):
    """Reject both endpoints of order conflicts, including fallback representatives."""
    bad=set()
    while True:
        representatives={}
        for key,row in candidates:
            if key in bad:continue
            rank=0 if key[1]=='vld' else 1 if key[1]=='vst' else 2
            old=representatives.get(row['model_address'])
            if old is None or rank<old[0]:representatives[row['model_address']]=(rank,key,row)
        found=set();maximum=None
        for _,key,row in sorted(representatives.values(),key=lambda item:item[2]['model_us']):
            if maximum and row['hardware_us']<maximum[1]-.01:
                found.add(key);found.add(maximum[0])
            if maximum is None or row['hardware_us']>maximum[1]:maximum=(key,row['hardware_us'])
        if not found:return bad
        bad.update(found)


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--hardware',type=Path,required=True)
    p.add_argument('--model-bundles',type=Path,required=True)
    p.add_argument('--model',type=Path,required=True)
    p.add_argument('--alignment',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    args=p.parse_args();args.output.mkdir(parents=True,exist_ok=True)
    model=json.loads(args.model_bundles.read_text());meta=json.loads(args.model.read_text());alignment=json.loads(args.alignment.read_text())
    trace_path=next((args.hardware/'profile').rglob('*.trace.json.gz'))
    with gzip.open(trace_path,'rt') as f:trace=json.load(f)
    threads={(e.get('pid'),e.get('tid')):e.get('args',{}).get('name','') for e in trace['traceEvents'] if e.get('ph')=='M' and e.get('name')=='thread_name'}
    calls=sorted([e for e in trace['traceEvents'] if e.get('ph')=='X' and threads.get((e.get('pid'),e.get('tid')))=='XLA Ops' and 'varlen_attention_mha_native' in e.get('name','')],key=lambda e:e['ts'])
    # Compiler-only records and tracing instructions have no cross-export identity.
    def eligible(op):
        return not op.startswith(('vtrace','vdelay','vsetiar','vsettm','vwait')) and op not in (
            'reloc','sbr.rel','scalar_parameter_address','sphi','int_to_ptr','inlined_call_operand')
    mstatic=defaultdict(set);mrows=[]
    for address,start,end,ops in model['bundles']:
        if not address.startswith('0:0x97/'):continue
        source=int(address.split('/')[-1].split('@')[0].split(':')[-1],16)
        counts=Counter(norm(model['opcodes'][op]) for op in ops if eligible(norm(model['opcodes'][op])))
        if not counts:continue
        mstatic[source].update(counts)
        mrows.append((start/model['frequency_hz']*1e6-meta['kernel_origin_us'],source,dict(counts),address))
    hstatic=defaultdict(set);hrows=[[] for _ in calls]
    for e in trace['traceEvents']:
        if e.get('ph')!='X':continue
        track=threads.get((e.get('pid'),e.get('tid')),'')
        if not track.endswith('Instructions'):continue
        op=norm(e['name']);number=e.get('args',{}).get('bundle_number')
        if not eligible(op) or number is None:continue
        for ci,call in enumerate(calls):
            t=e['ts']-call['ts']
            if e.get('pid')==call['pid'] and 0<=t<call['dur']:
                number=int(number);hstatic[number].add(op)
                hrows[ci].append((t,number,op,track,e.get('args',{}).get('instruction_ordinal','')))
                break
    del trace
    common=set().union(*mstatic.values()) & set().union(*hstatic.values())
    mid,hid=sorted(mstatic),sorted(hstatic)
    ms=[tuple(sorted(mstatic[i] & common)) for i in mid];hs=[tuple(sorted(hstatic[i] & common)) for i in hid]
    pairs,proof,seeds=static_match(ms,hs)
    mapping={mid[i]:hid[j] for i,j in pairs.items()};inverse={v:k for k,v in mapping.items()}
    static_rows=[dict(model_bundle=mid[i],hardware_bundle=hid[j],evidence=proof[i],signature=ms[i]) for i,j in sorted(pairs.items())]
    (args.output/'static-map.json').write_text(json.dumps(static_rows,separators=(',',':')))
    report=dict(trace_sha256=hashlib.sha256(trace_path.read_bytes()).hexdigest(),model_manifest_sha256=meta['manifest_sha256'],
                unique_context_seed_count=seeds,static_model_bundles=len(mid),static_hardware_bundles=len(hid),static_matched_bundles=len(mapping),calls=[],
                method='Unique 11-bundle common-vocabulary opcode-set contexts, monotone ordering, unique bounded gap sequences; phase-local family occurrence matching only with equal multiplicities. No time fitting.',
                ordering_validation='Reject an entire phase/bundle/opcode key on cross-family order conflict against VLD anchors; allow 10 ns of reconstructed timestamp jitter. Time never chooses replacement matches.',
                limitations=['Cross-binary inferred correspondence, not exact instruction identity.',
                             'Opcode normalization discards operand types and some unit selectors; context and dynamic checks constrain but cannot prove identity.',
                             'Unmapped contexts, unequal occurrence counts, and same-family coissue multiplicity >1 are excluded.',
                             'Time deltas include interpolation/instrumentation differences and are not causal stall measurements.'])
    display=[]
    with gzip.open(args.output/'instruction-pairs.jsonl.gz','wt') as detailed, gzip.open(args.output/'unmatched-events.jsonl.gz','wt') as unmatched:
        for ci,call in enumerate(calls):
            cr=[]
            for pi,phase in enumerate(alignment['calls'][ci]['phases']):
                ml=phase['model_start_us'];mh=ml+phase['model_duration_us'];hl=phase['hardware_start_us'];hh=hl+phase['hardware_duration_us']
                mg=defaultdict(list);hg=defaultdict(list);mc=hc=0;excluded=Counter();matched_hw=set();phase_hw=[]
                def miss(side,t,b,op,reason):
                    unmatched.write(json.dumps(dict(call=ci,phase=phase['name'],side=side,time_us=t,bundle=b,opcode=op,reason=reason),separators=(',',':'))+'\n')
                for t,b,ops,address in mrows:
                    if ml<=t<mh:
                        mc+=sum(ops.values())
                        for op,n in ops.items():
                            if n==1:mg[(b,op)].append((t,address))
                            else:
                                excluded['model_coissue_family_multiplicity']+=n
                                miss('model',t,address,op,'coissue_family_multiplicity')
                for t,b,op,track,ordinal in hrows[ci]:
                    if hl<=t<hh:
                        hc+=1
                        phase_hw.append((t,b,op,track,ordinal))
                        if b in inverse:hg[(inverse[b],op)].append((t,b,track,ordinal))
                matched=0;points={};unequal=[];candidates=[]
                for key,values in mg.items():
                    if key[0] not in mapping:
                        excluded['no_static_mapping']+=len(values)
                        for t,address in values:miss('model',t,address,key[1],'no_static_mapping')
                        continue
                    other=sorted(hg.get(key,[]));values.sort()
                    if len(values)!=len(other):
                        excluded['unequal_dynamic_counts']+=len(values)
                        unequal.append(dict(model_bundle=key[0],hardware_bundle=mapping[key[0]],opcode=key[1],model_count=len(values),observed_count=len(other)))
                        for t,address in values:miss('model',t,address,key[1],'unequal_dynamic_counts')
                        continue
                    for occurrence,((mt,address),(ht,hb,track,ordinal)) in enumerate(zip(values,other)):
                        row=dict(call=ci,phase=phase['name'],model_address=address,hardware_bundle=hb,opcode=key[1],occurrence=occurrence,
                                 model_us=mt,hardware_us=ht,delta_us=ht-mt,phase_relative_delta_us=(ht-hl)-(mt-ml),hardware_track=track,hardware_ordinal=ordinal)
                        candidates.append((key,row))
                # Cross-family validation catches equal-count traces that omitted
                # different loop occurrences. Time is only a rejection check,
                # never used to select a different match or fit a clock.
                anchors=sorted((r['model_us'],r['hardware_us']) for key,r in candidates if key[1]=='vld')
                at=[t for t,_ in anchors];bad=set()
                if any(b[1]<a[1]-.01 for a,b in zip(anchors,anchors[1:])):
                    bad.update(key for key,_ in candidates) # Fail closed for this phase.
                else:
                    for key,r in candidates:
                        j=bisect_left(at,r['model_us'])
                        lower=anchors[j-1][1]-.01 if j else float('-inf')
                        upper=anchors[j][1]+.01 if j<len(anchors) else float('inf')
                        if not lower<=r['hardware_us']<=upper:bad.add(key)
                bad.update(chronology_conflicts([(key,r) for key,r in candidates if key not in bad]))
                for key,row in candidates:
                    if key in bad:
                        excluded['cross_family_order_conflict']+=1
                        miss('model',row['model_us'],row['model_address'],key[1],'cross_family_order_conflict')
                        continue
                    detailed.write(json.dumps(row,separators=(',',':'))+'\n');matched+=1
                    identity=(row['hardware_us'],row['hardware_bundle'],row['hardware_track'],row['hardware_ordinal'])
                    assert identity not in matched_hw, 'Hardware event reused'
                    matched_hw.add(identity)
                    rank=0 if key[1]=='vld' else 1 if key[1]=='vst' else 2
                    point=[ci,pi,key[0],row['hardware_bundle'],row['occurrence'],round(row['model_us'],6),round(row['hardware_us'],6),key[1],rank]
                    address=row['model_address']
                    if address not in points or rank<points[address][-1]:points[address]=point
                display.extend([point[:-1] for point in sorted(points.values(),key=lambda p:p[5])])
                for t,b,op,track,ordinal in phase_hw:
                    if (t,b,track,ordinal) not in matched_hw:miss('hardware',t,b,op,'no_static_mapping' if b not in inverse else 'no_unambiguous_dynamic_match')
                cr.append(dict(name=phase['name'],model_eligible_instructions=mc,hardware_eligible_instructions=hc,matched_instructions=matched,
                               represented_dynamic_bundles=len(points),excluded_model=dict(excluded),unequal_dynamic_counts=unequal))
            report['calls'].append(dict(duration_us=call['dur'],phases=cr,matched_instructions=sum(p['matched_instructions'] for p in cr)))
    (args.output/'summary.json').write_text(json.dumps(report,indent=2)+'\n')
    (args.output/'bundle-pairs.json.gz').write_bytes(gzip.compress(json.dumps(display,separators=(',',':')).encode()))
    render(args.output,display,report,alignment)
    print(json.dumps({k:v for k,v in report.items() if k!='calls'}))
    print('Matched instructions per call', [c['matched_instructions'] for c in report['calls']], 'bundle points',len(display))


def render(out,points,report,alignment):
    packed=base64.b64encode(gzip.compress(json.dumps(points,separators=(',',':')).encode())).decode()
    template=Path(__file__).with_name('matched_timeline.html').read_text()
    page=template.replace('__PACKED__',packed).replace('__PHASES__',json.dumps([p['name'] for p in alignment['calls'][0]['phases']]))
    info={k:v for k,v in report.items() if k!='calls'}
    info['coverage']=[[{k:v for k,v in p.items() if k!='unequal_dynamic_counts'} for p in c['phases']] for c in report['calls']]
    page=page.replace('__SUMMARY__',json.dumps(info))
    (out/'timeline.html').write_text(page)


if __name__=='__main__':main()
