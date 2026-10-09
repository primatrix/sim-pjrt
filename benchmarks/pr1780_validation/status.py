import json,time
from pathlib import Path
root=Path('/tmp/pr1780-validation')
for p in sorted((root/'results').glob('*/result.json')):
 d=json.loads(p.read_text())
 print(p.parent.name, d['status'], 'flow-only='+str(d.get('flow_only_scenario',False)),
       [r['name'] for r in d['requests']], d.get('error',''))
 if d['status']=='running':
  log=(p.parent/'server.log').read_text().splitlines()
  print('  '+' | '.join(log[-2:])[:700])
