import json
from collections import Counter
from pathlib import Path
root=Path('/tmp/pr1780-validation')
models=json.loads((root/'models.json').read_text())
summary={'provenance':json.loads((root/'provenance.json').read_text()),'models':{}}
for name,metadata in models.items():
 paths=list((root/'results').glob(f'{name}-dp-*/result.json'))
 attempts=[(p,json.loads(p.read_text())) for p in paths]
 passed=[item for item in attempts if item[1]['status']=='passed']
 if not attempts:continue
 path,result=max(passed or attempts,key=lambda x:x[1]['started_at'])
 expected={'image','uneven_images','repeat_cache'}
 if not name.startswith('gemma'):expected.add('video')
 if name=='mimo':expected.add('audio')
 actual={x['name'] for x in result['requests'] if x['status']=='passed'}
 if result['status']=='passed':assert expected<=actual,(name,expected,actual)
 executions=Counter()
 gap_executions=0
 for trace in path.parent.glob('*.jsonl'):
  for line in trace.read_text().splitlines():
   record=json.loads(line)
   executions[record['name']]+=1
   gap_executions+=record.get('bundle_cost_gaps',0)>0
 if result['status']=='passed':
  assert executions['jit_jitted_run_model']>=len(expected),(name,executions)
  encoder_marker='jit_conv_general_dilated' if name=='kimi' else 'jit_encode'
  assert executions[encoder_marker]>=1,(name,executions)
 d={'repo':metadata['repo'],'revision':metadata['revision'],'status':result['status'],
    'requests':result['requests'],'expected_requests':sorted(expected),'artifacts':str(path.parent),
    'flow_only_scenario':result.get('flow_only_scenario',False),
    'parser_fix': '--parser-fix' in result.get('command',[]) or result.get('parser_fix',False),
    'virtual_devices':result.get('virtual_devices',8),
    'topology':result.get('topology','tpu7x:2x2x1'),
    'compiler_flags':result.get('compiler_flags',''),
    'candidate_package':result.get('candidate_package'),
    'build_commit':result.get('build_commit'),
    'native_plugin':result.get('native_plugin','published v0.1.1'),
    'config_sha256':result.get('config_sha256'),
    'execution_counts':dict(executions),'executions_with_timing_gaps':gap_executions,
    'attempts':[{'artifacts':str(p.parent),'status':r['status'],'error':r.get('error')} for p,r in attempts]}
 if d['parser_fix']:
  d['python_fix_commits']=['2d7dec6']
  if result['started_at']>=1791460600:d['python_fix_commits'].append('31c4aa1')
 if result.get('native_plugin'):d['native_fix_commit']=result.get('build_commit') or '894dd3e'
 if result.get('candidate_package'):
  d['python_fix_commits']=['2d7dec6','31c4aa1']
  d['fix_delivery']='complete candidate wheel'
 else:
  d['fix_delivery']='local Python overlay' if d['parser_fix'] else 'published v0.1.1'
 if name=='kimi' and result['started_at']>=1791459837:d['sglang_patch']='kimi-weight-loading.patch'
 summary['models'][name]=d
 print(name,d['status'],','.join(sorted(actual)))
(root/'summary.json').write_text(json.dumps(summary,indent=2))
