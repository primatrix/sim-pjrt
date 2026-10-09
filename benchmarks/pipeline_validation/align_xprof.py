"""Align ordered Q/head phase boundaries; never fit time or bandwidth parameters.

XProf input is the saved gap-analysis.json and blank-gaps.json. These establish
phase anchors and a partial sync sample, not a complete DMA completion trace.
"""
import argparse
import html
import hashlib
import json
from pathlib import Path

LABELS = ['initial preparation', 'head0 Q0→Q1', 'head0 Q1→Q2', 'head0 Q2→Q3',
          'head0→head1', 'head1 Q0→Q1', 'head1 Q1→Q2', 'head1 Q2→Q3', 'final drain']


def partition(gaps, duration):
    assert len(gaps) == 9, f'Expected nine Q/head gaps; got {len(gaps)}. Refuse ordinal matching.'
    rows = []
    for i, g in enumerate(gaps):
        rows.append(dict(name=LABELS[i], kind='between_mxu', start_us=g['start_us'], end_us=g['end_us']))
        if i < 8:
            rows.append(dict(name=f'head{i//4} Q{i%4} MXU issue span', kind='mxu_span',
                             start_us=g['end_us'], end_us=gaps[i+1]['start_us']))
    assert abs(rows[0]['start_us']) < 1e-6
    assert abs(rows[-1]['end_us']-duration) < 1e-6
    return rows


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--model', type=Path, required=True)
    p.add_argument('--xprof-dir', type=Path, required=True)
    p.add_argument('--identity', type=Path, required=True)
    p.add_argument('--dma-sync', type=Path, help='DMA/sync events extracted from the full original trace')
    p.add_argument('--instruction-comparison', type=Path)
    p.add_argument('--output-dir', type=Path, required=True)
    args = p.parse_args()
    model = json.loads(args.model.read_text())
    hardware = json.loads((args.xprof_dir/'gap-analysis.json').read_text())
    blanks = json.loads((args.xprof_dir/'blank-gaps.json').read_text())
    identity = json.loads(args.identity.read_text())
    full_sync = json.loads(args.dma_sync.read_text()) if args.dma_sync else None
    if full_sync:
        assert full_sync['source_sha256'] == hardware['source_sha256']
    assert identity['source_sha256'] == hardware['source_sha256'], 'Different kernel source'
    assert identity['manifest_sha256'] == model['manifest_sha256'], 'Different model artifact'
    mrows = partition(model['mxu_gaps_over_1us'], model['kernel_duration_us'])
    result = dict(source_sha256=hardware['source_sha256'], model_profile_sha256=model['profile_sha256'],
                  method='Kernel-start translation only; chronological Q/head phase matching; no rescaling or parameter fit.',
                  model_kernel_us=model['kernel_duration_us'], model_full_program_us=model['full_program_duration_us'],
                  hardware_ordinary_reference_us=149.81437549999828, calls=[],
                  input_sha256={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in
                                (args.model, args.identity, args.xprof_dir/'gap-analysis.json', args.xprof_dir/'blank-gaps.json')},
                  limitations=['Profile calls are instrumented; ordinary 149.814 us is a different measurement.',
                               'Same kernel source, but exact compiler binary identity is not established.',
                               'Phase matching is ordinal and structural, not instruction/bundle identity.',
                               'MXU issue spans and gaps are not engine busy/idle or stall attribution.',
                               'Local hardware sync samples are incomplete; no measured DMA completion timestamps.'])
    lanes = [('Model phases', mrows)]
    if full_sync:
        result['input_sha256'][str(args.dma_sync)] = hashlib.sha256(args.dma_sync.read_bytes()).hexdigest()
        result['limitations'][-1] = 'Full original trace downloaded; instruction reconstruction may be incomplete and has no direct DMA completion lane.'
    for i, call in enumerate(hardware['calls']):
        gaps = sorted((dict(g, end_us=g['start_us']+g['duration_us'])
                       for g in call['gaps_over_100ns'] if g['duration_us'] > 1), key=lambda g:g['start_us'])
        rows = partition(gaps, call['duration_us'])
        # The first Q has a different entry than the three subsequent Qs.
        starts = [g['right']['args']['bundle_number'] for g in gaps[:-1]]
        assert starts[:4] == starts[4:] and len(set(starts[1:4])) == 1 and starts[0] != starts[1], starts
        diffs = []
        for m,h in zip(mrows,rows):
            waits = [e for e in model['events'] if e['kind']=='bundle'
                     and m['start_us'] <= e['start_us'] < m['end_us']
                     and any(op['credit_waits'] for op in e['alignment_operations'])]
            diffs.append(dict(name=h['name'], kind=h['kind'], model_start_us=m['start_us'],
                              hardware_start_us=h['start_us'], model_duration_us=m['end_us']-m['start_us'],
                              hardware_duration_us=h['end_us']-h['start_us'],
                              duration_delta_us=(h['end_us']-h['start_us'])-(m['end_us']-m['start_us']),
                              model_credit_wait_count=len(waits),
                              model_credit_wait_bundle_stall_us=sum(e['stall_cycles'] for e in waits)/model['frequency_hz']*1e6))
        sync = {}
        for g in blanks['calls'][i]['gaps']:
            for key in ('before','after'):
                e = g.get(key)
                if e and any(s in e['name'] for s in ('dma','sync','fence')):
                    sync[(e['start_us'],e['name'])] = e
        delta = call['duration_us']-model['kernel_duration_us']
        if full_sync:
            assert abs(full_sync['calls'][i]['duration_us']-call['duration_us'])<1e-6
            sync = {(e['start_us'],e['name']):dict(e,dur_us=e['duration_us'])
                    for e in full_sync['calls'][i]['events'] if e['track'].endswith('Instructions')}
        assert abs(sum(d['duration_delta_us'] for d in diffs)-delta)<1e-6
        result['calls'].append(dict(duration_us=call['duration_us'], delta_us=delta, phases=diffs,
                                    observed_sync_events=sorted(sync.values(), key=lambda e:e['start_us']),
                                    sync_source='full_trace' if full_sync else 'partial_gap_summary',
                                    delta_by_kind_us={k:sum(d['duration_delta_us'] for d in diffs if d['kind']==k)
                                                      for k in ('between_mxu','mxu_span')}))
        lanes.append((f'XProf call {i}',rows))
    args.output_dir.mkdir(parents=True,exist_ok=True)
    (args.output_dir/'alignment.json').write_text(json.dumps(result,indent=2)+'\n')
    # A standalone SVG-backed HTML: identical absolute time scale for every lane.
    scale=8
    lanes.append(('Model DMA service', [dict(name=f"{e['direction']} {e['bytes']} bytes", kind='dma',
                  start_us=e['start_us'], end_us=e['end_us']) for e in model['events'] if e['kind']=='dma']))
    lanes.append(('Model credit waits', [dict(name=', '.join(op['name'] for op in e['alignment_operations']),kind='sync',
                  start_us=e['start_us'],end_us=e['end_us']) for e in model['events'] if e['kind']=='bundle'
                  and any(op['credit_waits'] for op in e['alignment_operations'])]))
    for i,c in enumerate(result['calls']):
        for name,prefix,kind in [('DMA issue','dma.general','dma'),('sync issue','sync','sync')]:
            lanes.append((f'XProf {i} {name}', [dict(name=e['name'],kind=kind,start_us=e['start_us'],
                          end_us=e['start_us']+e['dur_us']) for e in c['observed_sync_events']
                          if (e['name'].startswith('dma.general') if prefix=='dma.general' else not e['name'].startswith('dma.general'))]))
    height=70+65*len(lanes)
    svg=[f'<svg xmlns="http://www.w3.org/2000/svg" width="1550" height="{height}" viewBox="0 0 1550 {height}">']
    for t in range(0,161,10):
        x=180+t*scale
        svg.append(f'<path d="M{x},25 V{height-20}" stroke="#ddd"/><text x="{x}" y="20" font-size="12">{t} μs</text>')
    for row,(name,spans) in enumerate(lanes):
        y=50+row*65
        svg.append(f'<text x="5" y="{y+20}" font-size="14">{name}</text>')
        for span in spans:
            x=180+span['start_us']*scale; w=(span['end_us']-span['start_us'])*scale
            color={'mxu_span':'#4169a8','between_mxu':'#d99a32','dma':'#389779','sync':'#b44b73'}[span['kind']]
            tip=f"{span['name']}: {span['start_us']:.3f}–{span['end_us']:.3f} μs ({span['end_us']-span['start_us']:.3f} μs)"
            svg.append(f'<rect x="{x}" y="{y}" width="{max(w,1)}" height="32" fill="{color}" stroke="white" stroke-width=".3"><title>{html.escape(tip)}</title></rect>')
    svg.append('</svg>')
    table='<table><tr><th>Phase</th><th>Model μs</th><th>XProf 0 μs</th><th>Delta μs</th></tr>'
    for d in result['calls'][0]['phases']:
        table+=f"<tr><td>{html.escape(d['name'])}</td><td>{d['model_duration_us']:.3f}</td><td>{d['hardware_duration_us']:.3f}</td><td>{d['duration_delta_us']:+.3f}</td></tr>"
    table+='</table>'
    if args.instruction_comparison:
        comparison=json.loads(args.instruction_comparison.read_text())
        if full_sync:
            assert comparison['trace_sha256']==full_sync['trace_sha256']
        table+='<h2>Q-internal instruction checks (call 0)</h2><p>Observed spacing is reconstructed trace timing, not an independent clock or stall measurement.</p><table><tr><th>Phase</th><th>Model ops</th><th>Observed ops</th><th>Model VLD adjacent bundle median ns</th><th>XProf median ns</th><th>Wait→vsyncadd spacing sum μs</th></tr>'
        for row in comparison['calls'][0]['phases']:
            if row['kind']!='mxu_span':continue
            table+=f"<tr><td>{html.escape(row['name'])}</td><td>{sum(row['model_opcode_counts'].values())}</td><td>{sum(row['hardware_opcode_counts'].values())}</td><td>{row['model_adjacent_vld_bundle_steps']['median_ns']:.3f}</td><td>{row['observed_adjacent_bundle_steps']['VLD Instructions']['median_ns']:.3f}</td><td>{row['wait_pair_spacing_sum_us']:.6f}</td></tr>"
        table+='</table>'
    page='''<!doctype html><meta charset="utf-8"><title>XProf / model alignment</title>
<style>body{font:15px system-ui;margin:24px;color:#26313d}table{border-collapse:collapse}td,th{padding:6px 16px;text-align:right;border-bottom:1px solid #ddd}td:first-child{text-align:left}.chart{overflow:auto}li{margin:6px}</style>
<h1>XProf / unified model: Q/head phase alignment</h1>
<p>Kernel starts aligned to 0; no time scaling, bandwidth adjustment, or fitting. Hover for exact times. Blue: MXU issue span; amber: interval between spans. Neither color is engine utilization.</p>
<p>Green: modeled DMA service or XProf DMA issue markers on their separate lanes. Pink: modeled wait intervals or observed XProf sync instructions. Hardware instruction duration is not DMA service/wait duration. Markers have a minimum display width of 1 px.</p>
<label>Zoom <input type="range" min="1" max="4" step=".25" value="1" oninput="document.querySelector('svg').style.width=(1550*this.value)+'px'"></label>
<div class="chart">'''+''.join(svg)+'</div>'+table+'<ul>'+''.join('<li>'+html.escape(s)+'</li>' for s in result['limitations'])+'</ul>'
    (args.output_dir/'alignment.html').write_text(page)
    print(json.dumps({k:v for k,v in result.items() if k!='calls'},indent=2))
    for c in result['calls']:print(c['duration_us'],c['delta_us'],c['delta_by_kind_us'])


if __name__ == '__main__':
    main()
