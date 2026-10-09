"""Retimestamp fixed correspondences using a rerun model; never rematch XProf."""
import argparse
import gzip
import json
from pathlib import Path
from match_xprof_timeline import render


def main():
    p=argparse.ArgumentParser(description=__doc__)
    for key in ('baseline_bundles','calibrated_bundles','baseline_model','calibrated_model','matched','alignment','output'):
        p.add_argument('--'+key.replace('_','-'),required=True,type=Path)
    a=p.parse_args();base=json.loads(a.baseline_bundles.read_text());cal=json.loads(a.calibrated_bundles.read_text());bm=json.loads(a.baseline_model.read_text());cm=json.loads(a.calibrated_model.read_text())
    assert [(r[0],r[3]) for r in base['bundles']]==[(r[0],r[3]) for r in cal['bundles']]
    lookup={}
    for l,r in zip(base['bundles'],cal['bundles']):
        if not l[0].startswith('0:0x97/'):continue
        source=int(l[0].split('/')[-1].split('@')[0].split(':')[-1],16)
        key=(source,round(l[1]/base['frequency_hz']*1e6-bm['kernel_origin_us'],6))
        assert key not in lookup
        lookup[key]=round(r[1]/cal['frequency_hz']*1e6-cm['kernel_origin_us'],6)
    points=json.loads(gzip.decompress((a.matched/'bundle-pairs.json.gz').read_bytes()))
    for point in points:point[5]=lookup[(point[2],point[5])]
    report=json.loads((a.matched/'summary.json').read_text())
    report['model_variant']='Empirical local issue-floor calibration; fixed original correspondences'
    report['limitations'].insert(0,'Calibrated model: trained on call0/head0 Q internals only. Unseen opcode mixes use pooled training median. Same-capture validation, not independent hardware validation.')
    a.output.mkdir(parents=True,exist_ok=True)
    (a.output/'bundle-pairs.json.gz').write_bytes(gzip.compress(json.dumps(points,separators=(',',':')).encode()))
    render(a.output,points,report,json.loads(a.alignment.read_text()))
    page=a.output/'timeline.html';text=page.read_text();text=text.replace('<h1>逐 bundle 对应：模型与 XProf</h1>',f'<h1>校准后逐 bundle 对应：模型与 XProf</h1><p>Kernel：原模型 {bm["kernel_duration_us"]:.3f} μs → 校准模型 {cm["kernel_duration_us"]:.3f} μs；XProf ≈155.47 μs。固定原有对应关系；时钟和 DMA 参数未改。</p>');page.write_text(text)
    print('Retimed',len(points),'fixed bundle correspondences')


if __name__=='__main__':main()
