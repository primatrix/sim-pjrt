"""Audit a local Final LLO's classifier coverage; run through lab capped.

Static coverage is not a dynamic timing prediction or a hardware comparison.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
from sim_pjrt.llo.compiler_costs import CompilerCosts
from sim_pjrt.llo.execution import GfMapping
from sim_pjrt.llo.parser import parse_bundles

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('llo', type=Path)
p.add_argument('output', type=Path)
args = p.parse_args()
root = Path(__file__).resolve().parents[2]
data = json.loads((root / 'configs/gf_costs_libtpu_0_0_48.json').read_text())
costs = CompilerCosts(data, binary_sha256=data['binary_sha256'])
mapping = GfMapping(json.loads((root / 'configs/gf_mapping_libtpu_0_0_48.json').read_text()), costs)
raw = args.llo.read_bytes()
bundles = parse_bundles(raw.decode())
covered, uncovered = Counter(), Counter()
for bundle in bundles:
    for ins in bundle['instructions']:
        (covered if mapping.classify(ins) else uncovered)[ins['opcode']] += 1
result = dict(source=str(args.llo), source_sha256=hashlib.sha256(raw).hexdigest(),
              status='static_classifier_coverage_only', bundle_count=len(bundles),
              mapped=sum(covered.values()), unmapped=sum(uncovered.values()),
              mapped_opcodes=dict(covered.most_common()), unmapped_opcodes=dict(uncovered.most_common()),
              limitations=['Historical local GEMM, not the instrumented attention capture.',
                           'Artifact compiler identity not established; coverage is a compatibility probe.',
                           'Mapped cost does not imply all resource, dependency or runtime costs are modeled.'])
args.output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({k:result[k] for k in ['status','bundle_count','mapped','unmapped']}))
