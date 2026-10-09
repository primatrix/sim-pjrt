import json
from pathlib import Path
from huggingface_hub import HfApi, snapshot_download
MODELS = {
 'qwen25vl': 'Qwen/Qwen2.5-VL-3B-Instruct',
 'qwen3vl': 'Qwen/Qwen3-VL-2B-Instruct',
 'qwen35': 'Qwen/Qwen3.5-4B',
 'qwen35moe': 'Qwen/Qwen3.5-35B-A3B',
 'gemma4': 'google/gemma-4-31B-it',
 'gemma4moe': 'google/gemma-4-26B-A4B-it',
 'mimo': 'XiaomiMiMo/MiMo-V2.5',
 'kimi': 'moonshotai/Kimi-K2.5',
}
root = Path('/tmp/pr1780-validation/models')
root.mkdir(parents=True, exist_ok=True)
manifest = {}
for name, repo in MODELS.items():
 try:
  info = HfApi().model_info(repo)
  path = snapshot_download(repo, revision=info.sha, local_dir=root/name,
       allow_patterns=['*.json','*.model','*.txt','*.jinja','*.py','*.tiktoken'],
       ignore_patterns=['*.safetensors.index.json','*.bin.index.json'], max_workers=4)
  manifest[name] = {'repo':repo, 'revision': info.sha, 'path':path}
  print(name, 'OK', info.sha, flush=True)
 except Exception as e:
  manifest[name] = {'repo':repo,'error':str(e)}
  print(name, type(e).__name__, str(e)[:500], flush=True)
 (root.parent/'models.json').write_text(json.dumps(manifest,indent=2))
