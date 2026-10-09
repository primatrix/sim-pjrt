"""Audit raw XPlane clock/line provenance without treating opaque blobs as ISA."""
import json
from pathlib import Path
import sys

from sim_pjrt.profiling.xplane_pb2 import XSpace

root, output = map(Path, sys.argv[1:])
result = {}
for variant in ('baseline', 'single_raw', 'dual_acc'):
    path = next((root / variant / 'capture/profile').rglob('*.xplane.pb'))
    space = XSpace.FromString(path.read_bytes())
    planes = []
    for plane in space.planes:
        if not plane.name.startswith('/device:TPU:'):
            continue
        clocks = {}
        for stat in plane.stats:
            name = plane.stat_metadata[stat.metadata_id].name
            kind = stat.WhichOneof('value')
            if any(x in name.lower() for x in ('clock', 'freq', 'gtc')) and kind:
                clocks[name] = (plane.stat_metadata[stat.ref_value].name if kind == 'ref_value'
                                else str(getattr(stat, kind)))
        planes.append({'name': plane.name, 'id': plane.id,
                       'lines': [{'name': l.name, 'events': len(l.events),
                                  'timestamp_ns': l.timestamp_ns} for l in plane.lines],
                       'plane_clock_stats': clocks,
                       'clock_stat_names': sorted({m.name for m in plane.stat_metadata.values()
                                                  if any(w in m.name.lower() for w in ('clock', 'frequency', 'gtc'))}),
                       'has_instruction_lanes': any(l.name.endswith(' Instructions') for l in plane.lines)})
    result[variant] = {'planes': planes, 'warnings': list(space.warnings), 'errors': list(space.errors)}
    del space
output.write_text(json.dumps(result, indent=2))
print(json.dumps({v: [{'device': p['name'], 'instruction_lanes': p['has_instruction_lanes'],
                       'clocks': p['plane_clock_stats']} for p in r['planes']]
                  for v, r in result.items()}))
