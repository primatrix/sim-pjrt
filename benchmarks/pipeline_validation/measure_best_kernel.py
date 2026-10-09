"""Measure a lab kernel through the unified bundle_timing entry.

Invoke through tpu-kernel-lab/lab capped. This scenario is a single
sequence (default 2048 tokens), causal BF16 MHA32 D256 request, Q512/KV256 and guard-pass. Virtual
HBM addresses are aligned scenario inputs, not captured device addresses.
"""
import argparse
import hashlib,json,re,sys,time,subprocess
from pathlib import Path
from sim_pjrt.llo.program import load_final_modules
from sim_pjrt.llo.parser import dma_operands
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--lab-root',type=Path,default=Path.home()/'lab/tpu-kernel-lab')
parser.add_argument('--output',type=Path,required=True)
parser.add_argument('--kernel',type=Path,default=Path('best_kernel.py'))
parser.add_argument('--tokens',type=int,default=2048)
parser.add_argument('--run',type=Path,help='Explicit compiled run directory with metadata.json')
parser.add_argument('--issue-calibration',type=Path,help='Optional empirical issue-cost JSON; used unchanged')
opts=parser.parse_args()
root=opts.lab_root.resolve();out=opts.output.resolve();out.mkdir(parents=True,exist_ok=True)
sim=Path(__file__).resolve().parents[2]
source=(root/opts.kernel).resolve()
sha=hashlib.sha256(source.read_bytes()).hexdigest()
runs=[]
for m in ([opts.run/'metadata.json'] if opts.run else (root/'runs').glob('*/metadata.json')):
 data=json.loads(m.read_text())
 if data.get('source_sha256')==sha and data.get('status')=='compiled' and data.get('tokens')==opts.tokens:runs.append(m.parent)
assert len(runs)==1,runs
run=runs[0]
metadata=json.loads((run/'metadata.json').read_text())
assert metadata['versions']['libtpu']=='0.0.48', 'cost table requires libtpu 0.0.48'
assert {k:metadata[k] for k in ('tokens','heads','kv_heads','dim','q_block','kv_block')}==dict(tokens=opts.tokens,heads=32,kv_heads=32,dim=256,q_block=512,kv_block=256)
assert hashlib.sha256((run/'kernel.py').read_bytes()).hexdigest()==sha
manifest=next((run/'dump').glob('*/*.manifest.json'))
modules,aliases,provenance=load_final_modules(manifest)
name=next(k for k in modules if k.startswith('varlen_attention_mha_native'))
p=modules[name];defs={};sources={};smem={};predicates={}
for bundle in p:
 for ins in bundle['instructions']:
  match=re.match(r'(%[sp]\w+)\s*=\s*([\w.]+)\s*(.*)',ins['text'])
  if match:
   dest,op,args=match.groups();defs[dest]=(op,args)
   if op.startswith('inlined_call_operand.'):
    idx=re.search(r'index: (\d+),',args);sources[dest]=int(idx[1])
  if ins['opcode']=='dma.hbm_to_smem':
   args=dma_operands(ins['text'])
   if len(args)>=3 and args[0] in sources:
    idx=sources[args[0]]
    if idx not in (0,2,3):continue
    target=args[2]
    if target in defs and defs[target][0]=='smov':target=defs[target][1]
    assert re.fullmatch(r'\[#allocation\d+\]',target),target
    smem[target[1:-1]]={0:[0,opts.tokens],2:[0,0,0],3:[-1,-1,-1,-1]}[idx]
  if ins['opcode']=='sbr.rel':
   guard=re.search(r'\(!?(%p\w+)\)',ins['text'])
   if guard and defs.get(guard[1],('',''))[0]=='scmp.ne.f32.partialorder':
    assert defs[guard[1]][1].endswith(', 0.0')
    predicates[guard[1]]=False
assert len(smem)==3,smem
assert len(predicates)==1,predicates
profile=json.loads((sim/'configs/tpu7x.json').read_text())
profile['module_inputs']={name:dict(smem=smem,scalar_inputs={str(i):(1 if i==1 else 0x10000000+i*0x4000000) for i in range(8)},predicates=predicates,valid_addresses=True),'TLP':{'valid_addresses':True}}
profile['compiler_binary_sha256']='13fe4b883a085db3bce929eea75d0c93dab8ad245694e2d4598826765dbdb951'
if opts.issue_calibration:
 profile['bundle_issue_calibration']=json.loads(opts.issue_calibration.read_text())
(out/'profile.json').write_text(json.dumps(profile,indent=2))
meta=dict(source_sha256=sha,source=str(source),manifest=str(manifest),manifest_sha256=hashlib.sha256(manifest.read_bytes()).hexdigest(),module=name)
(out/'identity.json').write_text(json.dumps(meta,indent=2));print(json.dumps(meta),flush=True)
del modules,p,defs
t=time.monotonic()
result=subprocess.run([sys.executable,'-m','bundle_timing',str(manifest),'--profile',str(out/'profile.json'),'--summary','--output',str(out/'report.json')])
print('Exit',result.returncode,'elapsed',time.monotonic()-t,flush=True)
if result.returncode==0:
 report=json.loads((out/'report.json').read_text())
 summary={k:report[k] for k in ('execution_engine','status','modeled_cycles','modeled_seconds','estimated_seconds')}
 summary.update({k:report[k] for k in ('scheduled_bundle_count','modeled_bundle_visits','dma_bytes') if k in report})
 summary['unresolved_gap_count']=len(report['gaps'])
 summary.update(meta,modeled_microseconds=report['modeled_seconds']*1e6,
                source_still_current=hashlib.sha256(source.read_bytes()).hexdigest()==sha,
                scope='full compiled program, two 16-head iterations; includes modeled resource completion',
                scenario=f'single {opts.tokens}-token sequence, MHA32 D256 BF16 Q512 KV256, guard-pass; aligned virtual addresses',
                compiler_identity_basis='artifact records libtpu 0.0.48; original producing binary hash was not recorded',
                hardware_validation=False)
 assert hashlib.sha256(manifest.read_bytes()).hexdigest()==meta['manifest_sha256']
 scopes=[e for e in report['activity_timeline'] if e['track']=='XLA Ops' and name in e['name']]
 assert scopes, 'Missing kernel scope'
 summary['kernel_microseconds']=(max(e['end_ns'] for e in scopes)-min(e['start_ns'] for e in scopes))/1000
 summary['kernel_modeled_cycles']=summary['kernel_microseconds']*profile['frequency_hz']/1e6
 summary['issue_calibration']=str(opts.issue_calibration.resolve()) if opts.issue_calibration else None
 (out/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
 print(json.dumps(summary),flush=True)
raise SystemExit(result.returncode)
