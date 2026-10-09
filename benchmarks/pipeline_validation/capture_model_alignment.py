"""Capture selected-path DMA/sync and MXU issue anchors from the unified model.

Run with lab capped. Costs and bandwidth are taken unchanged from --profile.
"""
import argparse
from dataclasses import asdict
import hashlib
import json
from pathlib import Path
from sim_pjrt.llo import runtime
from sim_pjrt.llo.program import load_final_modules, estimate_final_program


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('manifest', type=Path)
    p.add_argument('--profile', required=True, type=Path)
    p.add_argument('--output', required=True, type=Path)
    p.add_argument('--bundle-output', type=Path, help='Compact selected-path bundle/opcode issue trace')
    args = p.parse_args()
    original = runtime.simulate

    def capture(bundles, **kwargs):
        result = original(bundles, **kwargs)
        for bundle, event in zip(bundles, result['events']):
            if args.bundle_output:
                event['alignment_opcodes'] = [op.name for op in bundle.operations]
            selected = [op for op in bundle.operations if op.name.startswith(('dma.', 'vsync', 'sfence'))]
            if selected:
                event['alignment_operations'] = [asdict(op) for op in selected]
            if any(op.name.startswith('vmatmul') for op in bundle.operations):
                event['mxu_issue'] = True
        return result

    runtime.simulate = capture
    try:
        modules, aliases, provenance = load_final_modules(args.manifest)
        profile = json.loads(args.profile.read_text())
        report = estimate_final_program(modules, profile, aliases, retain_events=True)
    finally:
        runtime.simulate = original
    # Runtime has already discarded unselected alternatives and applied global offsets.
    selected = [e for e in report['events'] if e.get('alignment_operations') or e['kind'] == 'dma']
    mats = [e for e in report['events'] if e.get('mxu_issue')]
    hz = profile['frequency_hz']
    if args.bundle_output:
        names = sorted({op for e in report['events'] for op in e.get('alignment_opcodes', [])})
        ids = {op:i for i,op in enumerate(names)}
        rows = [[e['address'], e['start_cycle'], e['end_cycle'],
                 [ids[op] for op in e['alignment_opcodes']]] for e in report['events'] if 'alignment_opcodes' in e]
        args.bundle_output.write_text(json.dumps(dict(frequency_hz=hz, opcodes=names,
            columns=['address','start_cycle','end_cycle','opcode_ids'], bundles=rows)))
        for e in report['events']:
            e.pop('alignment_opcodes', None)
    scopes = [e for e in report['activity_timeline'] if e['track'] == 'XLA Ops'
              and 'varlen_attention_mha_native' in e['name']]
    assert scopes, 'Missing kernel scope'
    origin = min(e['start_ns'] for e in scopes) / 1000
    for e in selected:
        e['start_us'] = e['start_cycle'] / hz * 1e6 - origin
        e['end_us'] = e['end_cycle'] / hz * 1e6 - origin
    gaps = []
    kernel_end = max(e['end_ns'] for e in scopes) / 1000 - origin
    for left, right in zip([None] + mats, mats + [None]):
        lo = left['start_cycle'] / hz * 1e6 - origin if left else 0
        hi = right['start_cycle'] / hz * 1e6 - origin if right else kernel_end
        if hi - lo > 1:
            gaps.append(dict(start_us=lo, end_us=hi, duration_us=hi-lo,
                             left_address=left['address'] if left else None,
                             right_address=right['address'] if right else None))
    result = dict(profile_sha256=hashlib.sha256(args.profile.read_bytes()).hexdigest(),
                  manifest_sha256=hashlib.sha256(args.manifest.read_bytes()).hexdigest(),
                  profile=str(args.profile), manifest=str(args.manifest), frequency_hz=hz,
                  kernel_origin_us=origin, kernel_duration_us=kernel_end,
                  full_program_duration_us=report['modeled_seconds']*1e6,
                  events=selected, mxu_issue_bundle_count=len(mats), mxu_gaps_over_1us=gaps,
                  runtime_segments=report['runtime_segments'], limitations=report['gaps'])
    args.output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k not in ('events','limitations','runtime_segments')}))


if __name__ == '__main__':
    main()
