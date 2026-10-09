"""Download declared Falcon XProf export parts and verify original file hashes."""
import argparse
import base64
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
from pathlib import Path
import subprocess


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('analysis_id')
    p.add_argument('--output', type=Path, required=True)
    a=p.parse_args(); a.output.mkdir(parents=True,exist_ok=True)
    def call(verb, *args):
        r=subprocess.run(['falcon','workflow','analysis',verb,a.analysis_id,*args,'--output','json'],
                         capture_output=True,text=True,check=True,timeout=90)
        d=json.loads(r.stdout)
        if not d.get('ok'):raise RuntimeError(d.get('error'))
        return d
    outputs=call('outputs')
    (a.output/'outputs.json').write_text(json.dumps(outputs,indent=2))
    declared={x['path'] for x in outputs['data']['outputs']}
    def get(name):
        assert name in declared, name
        saved=a.output/'parts'/name
        if saved.exists():return json.loads(saved.read_text())
        d=call('cat',name)
        content=d['data']['content']; obj=json.loads(content)
        saved.parent.mkdir(parents=True,exist_ok=True); saved.write_text(content)
        return obj
    inventory=get('inventory.json')
    (a.output/'inventory.json').write_text(json.dumps(inventory,indent=2))
    names=[p for f in inventory['files'] for p in f['parts']]
    print(f'Downloading {len(names)} parts; {sum(f["bytes"] for f in inventory["files"])} bytes',flush=True)
    with ThreadPoolExecutor(max_workers=6) as pool:
        for i,_ in enumerate(pool.map(get,names)):
            if i%12==0:print(f'{i+1}/{len(names)}',flush=True)
    for f in inventory['files']:
        relative=Path(f['path']);assert not relative.is_absolute() and '..' not in relative.parts
        target=a.output/'profile'/relative;target.parent.mkdir(parents=True,exist_ok=True)
        digest=hashlib.sha256();total=0
        with target.open('wb') as stream:
            for name in f['parts']:
                chunk=base64.b64decode(get(name)['base64'],validate=True)
                stream.write(chunk);digest.update(chunk);total+=len(chunk)
        assert total==f['bytes'] and digest.hexdigest()==f['sha256'],f['path']
        print('Verified',target,total,flush=True)
    (a.output/'dma-sync.json').write_text(json.dumps(get('dma-sync.json'),indent=2))
    # Encoded parts are redundant once each reconstructed file has passed hashing.
    for name in names:(a.output/'parts'/name).unlink()


if __name__=='__main__':main()
