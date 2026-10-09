"""Exercise published sim-pjrt wheel through the real HTTP multimodal server."""
import argparse
import base64
import hashlib
import io
import json
import os
from pathlib import Path
import signal
import subprocess
import time
import traceback

import requests
from PIL import Image, ImageDraw

ROOT = Path('/tmp/pr1780-validation')
PYTHON = ROOT/'venv/bin/python'


def image_url(width, height, color):
    image = Image.new('RGB', (width, height), color)
    ImageDraw.Draw(image).rectangle((10, 10, width//2, height//2), fill='white')
    buf = io.BytesIO()
    image.save(buf, format='PNG')
    return 'data:image/png;base64,' + base64.b64encode(buf.getvalue()).decode()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('model')
    parser.add_argument('--parallel', choices=['dp', 'tp'], default='dp')
    parser.add_argument('--parser-fix', action='store_true', help='Use local parser fix with the released native library')
    parser.add_argument('--build-commit', help='Candidate wheel source commit')
    parser.add_argument('--package', type=Path, help='Unpacked candidate wheel package root')
    parser.add_argument('--plugin', type=Path, help='Explicit candidate native plugin; recorded with its digest')
    parser.add_argument('--flow-only', action='store_true', default=True, help='Explicit static scenario; timings incomplete, only request flow validated')
    parser.add_argument('--port', type=int, default=31800)
    parser.add_argument('--startup-timeout', type=int, default=1800)
    parser.add_argument('--request-timeout', type=int, default=1800)
    parser.add_argument('--extra', nargs='*', default=[])
    args = parser.parse_args()
    model = json.loads((ROOT/'models.json').read_text())[args.model]
    output = ROOT/'results'/f'{args.model}-{args.parallel}-{int(time.time())}'
    output.mkdir(parents=True)
    config = Path(model['path'])/'config.json'
    devices = 32 if args.model == 'kimi' else 8
    topology = 'tpu7x:4x4x1' if devices == 32 else 'tpu7x:2x2x1'
    command = [str(PYTHON), '-m', 'sim_pjrt', 'run', '--topology', topology,
        '--devices', str(devices), '--hbm-capacity-gib', '1024', '--timing-profile', 'example',
        str(PYTHON), '-m', 'sgl_jax.launch_server', '--model-path', model['path'],
        '--load-format', 'dummy', '--trust-remote-code', '--device', 'tpu',
        '--tp-size', str(devices), '--dtype', 'bfloat16', '--max-total-tokens', '8192',
        '--max-running-requests', '4', '--context-length', '8192',
        '--chunked-prefill-size', '1024', '--max-prefill-tokens', '4096',
        '--watchdog-timeout', '3600', '--page-size', '128', '--disable-precompile', '--skip-server-warmup',
        '--vision-encoder-parallel', args.parallel, '--mm-processor-worker-num', '1',
        '--host', '127.0.0.1', '--port', str(args.port), *args.extra]
    if args.model in ('qwen35','qwen35moe'):
        command += ['--enable-unified-radix-tree', '--enable-recurrent-extra-buffer', '--max-recurrent-state-size', '32']
    if args.model=='qwen35moe':
        command += ['--max-running-requests', '16', '--max-recurrent-state-size', '64']
    env = dict(os.environ, PYTHONPATH='/tmp/sglang-pr1780/python',
               NUMBA_CACHE_DIR=str(ROOT/'numba-cache'), HF_HOME=str(ROOT/'hf-cache'),
               OMP_NUM_THREADS='4', MKL_NUM_THREADS='4', TOKENIZERS_PARALLELISM='false',
               ALLOW_MULTIPLE_LIBTPU_LOAD='1',
               PJRT_SIM_TRACE=str(output/'execution'),
               JAX_COMPILATION_CACHE_DIR=str(ROOT/'jax-cache'))
    if args.parser_fix:
        env['PYTHONPATH']='/tmp/sim-pjrt-pr1780-fixes/python:'+env['PYTHONPATH']
        env['SIM_PJRT_PLUGIN_PATH']=str(ROOT/'venv/lib/python3.12/site-packages/sim_pjrt/lib/pjrt_sim_plugin.so')
    if args.package:
        env['PYTHONPATH']=str(args.package.resolve())+':/tmp/sglang-pr1780/python'
    if args.plugin:
        env['SIM_PJRT_PLUGIN_PATH'] = str(args.plugin.resolve())
    if args.flow_only:
        env['PJRT_SIM_BUNDLE_SCENARIO']=str(ROOT/'flow-only-scenario.json')
    result = {'build_commit':args.build_commit,'virtual_devices':devices,'topology':topology,'parser_fix':args.parser_fix, 'flow_only_scenario':args.flow_only, 'model':model, 'parallel':args.parallel, 'command':command,
              'config_sha256':hashlib.sha256(config.read_bytes()).hexdigest(),
              'compiler_flags':env.get('LIBTPU_INIT_ARGS', ''), 'requests':[], 'started_at':time.time(), 'status':'running'}
    if args.package:
        result['candidate_package']=str(args.package.resolve())
    if args.plugin:
        result['native_plugin'] = {'path':str(args.plugin.resolve()), 'sha256':hashlib.sha256(args.plugin.read_bytes()).hexdigest()}
    (output/'result.json').write_text(json.dumps(result,indent=2))
    session = requests.Session()
    session.trust_env = False
    url = f'http://127.0.0.1:{args.port}'
    process = None
    print('OUTPUT', output, flush=True)
    try:
        with (output/'server.log').open('w') as log:
            process = subprocess.Popen(command, env=env, stdout=log, stderr=subprocess.STDOUT,
                                       start_new_session=True, cwd=ROOT)
        deadline = time.monotonic()+args.startup_timeout
        while time.monotonic()<deadline:
            if process.poll() is not None:
                raise RuntimeError(f'server exited {process.returncode}')
            try:
                if session.get(url+'/health', timeout=3).status_code == 200:
                    break
            except requests.RequestException:
                pass
            time.sleep(2)
        else:
            raise TimeoutError('server startup deadline exceeded')
        print('SERVER_READY', flush=True)
        a, b = image_url(112,112,'red'), image_url(224,112,'blue')
        cases = [('image', [a]), ('uneven_images', [a,b]), ('repeat_cache', [a,b])]
        for name, images in cases:
            body = {'model':model['path'], 'messages':[{'role':'user','content':[
                *[{'type':'image_url','image_url':{'url':im}} for im in images],
                {'type':'text','text':'Describe the image briefly.'}]}],
                'max_tokens':4, 'temperature':0, 'ignore_eos':True}
            start=time.monotonic()
            response=session.post(url+'/v1/chat/completions', json=body, timeout=args.request_timeout)
            (output/f'{name}.json').write_text(response.text)
            response.raise_for_status()
            data=response.json()
            assert data['usage']['completion_tokens']==4, data
            assert data['choices'][0]['finish_reason']=='length', data
            result['requests'].append({'name':name,'seconds':time.monotonic()-start,
                                       'usage':data['usage'], 'status':'passed'})
            (output/'result.json').write_text(json.dumps(result,indent=2))
            print('REQUEST_PASS', name, data['usage'], flush=True)
        if not args.model.startswith('gemma'):
            import imageio.v2 as imageio
            import numpy as np
            video_path=output/'input.mp4'
            frames=[np.full((112,224,3), fill_value=(i*50,30,150), dtype=np.uint8) for i in range(4)]
            imageio.mimwrite(video_path,frames,fps=2,macro_block_size=1)
            video='data:video/mp4;base64,'+base64.b64encode(video_path.read_bytes()).decode()
            media=[('video','video_url',video)]
            if args.model=='mimo':
                import soundfile as sf
                buf=io.BytesIO()
                wave=(0.1*np.sin(2*np.pi*440*np.arange(24000)/24000)).astype(np.float32)
                sf.write(buf,wave,24000,format='WAV')
                media.append(('audio','audio_url','data:audio/wav;base64,'+base64.b64encode(buf.getvalue()).decode()))
            for name,kind,data_url in media:
                body={'model':model['path'],'messages':[{'role':'user','content':[
                    {'type':kind,kind:{'url':data_url}},
                    {'type':'text','text':'Describe this briefly.'}]}],
                    'max_tokens':4,'temperature':0,'ignore_eos':True}
                start=time.monotonic()
                response=session.post(url+'/v1/chat/completions',json=body,timeout=args.request_timeout)
                (output/f'{name}.json').write_text(response.text)
                response.raise_for_status()
                data=response.json()
                assert data['usage']['completion_tokens']==4, data
                assert data['choices'][0]['finish_reason']=='length', data
                result['requests'].append({'name':name,'seconds':time.monotonic()-start,
                                           'usage':data['usage'],'status':'passed'})
                (output/'result.json').write_text(json.dumps(result,indent=2))
                print('REQUEST_PASS',name,data['usage'],flush=True)
        result['status']='passed'
    except Exception as exc:
        result.update(status='failed',error=str(exc),traceback=traceback.format_exc())
        print(result['traceback'],flush=True)
    finally:
        if process and process.poll() is None:
            os.killpg(process.pid, signal.SIGTERM)
            try:
                process.wait(timeout=20)
            except subprocess.TimeoutExpired:
                os.killpg(process.pid,signal.SIGKILL)
                process.wait()
        result['elapsed_seconds']=time.time()-result['started_at']
        (output/'result.json').write_text(json.dumps(result,indent=2))
    print('RESULT',result['status'],output,flush=True)
    raise SystemExit(0 if result['status']=='passed' else 1)

if __name__=='__main__':
    main()
