from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
import subprocess
import json
root=Path('/tmp/pr1780-validation')
script=Path(__file__).with_name('run_model.py').resolve()
models=['qwen35','qwen35moe','gemma4','gemma4moe','mimo','kimi']
def run(item):
 i,model=item
 with (root/f'{model}-driver.log').open('w') as log:
  code=subprocess.call([str(root/'venv/bin/python'),str(script),model,'--port',str(31802+i),'--startup-timeout','3600'],stdout=log,stderr=subprocess.STDOUT)
 print(json.dumps({'model':model,'returncode':code}),flush=True)
 return model,code
with ThreadPoolExecutor(max_workers=3) as pool:
 results=dict(pool.map(run,enumerate(models)))
(root/'remaining-results.json').write_text(json.dumps(results,indent=2))
