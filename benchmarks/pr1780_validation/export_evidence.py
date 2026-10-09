"""Archive final responses and provenance; keep large raw compiler traces in /tmp."""
import json
from pathlib import Path
import shutil
import zipfile

root = Path('/tmp/pr1780-validation')
out = Path(__file__).resolve().parent
summary = json.loads((root/'summary.json').read_text())
assert len(summary['models']) == 8
assert all(m['status'] == 'passed' for m in summary['models'].values())
with zipfile.ZipFile(out/'evidence.zip', 'w', compression=zipfile.ZIP_DEFLATED) as archive:
    for name in ['summary.json', 'provenance.json', 'models.json', 'environment.txt',
                 'cpu-regressions.log', 'parser-fix-regressions.log',
                 'scenario-fix-regressions.log', 'kimi-weight-loading.patch',
                 'fused-moe-audit.json', 'flow-only-scenario.json']:
        archive.write(root/name, name)
    for name, model in summary['models'].items():
        directory = Path(model['artifacts'])
        for file in directory.iterdir():
            if file.name == 'server.log' or (file.suffix == '.json' and not file.name.startswith('execution.')):
                archive.write(file, f'results/{name}/{file.name}')
        archive.write(root/'models'/name/'config.json', f'configs/{name}.json')
    for file in out.iterdir():
        if file.suffix in ('.py', '.txt', '.patch'):
            archive.write(file, f'harness/{file.name}')
shutil.copyfile(root/'summary.json', out/'results.json')
print(out/'evidence.zip')
print(out/'results.json')
