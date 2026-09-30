"""Command-line entry point for Final LLO timing, also invoked by the PJRT plugin."""

import argparse
import json
from pathlib import Path

from sim_pjrt.llo.parser import parse_bundles
from sim_pjrt.llo.program import load_final_modules, estimate_final_program, iter_final_bundles
from sim_pjrt.llo.cost import estimate_bundles


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("dump", type=Path)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--scenario", type=Path)
    parser.add_argument("--output", type=Path)
    parser.add_argument(
        "--summary", action="store_true", help="Omit the per-event timeline"
    )
    args = parser.parse_args()
    profile = json.loads(args.profile.read_text())
    if args.dump.suffix == ".json":
        modules, aliases, provenance = load_final_modules(args.dump)
    else:
        modules, aliases = {'TLP': parse_bundles(args.dump.read_text())}, {}
        provenance = {
            "entry_file": str(args.dump.resolve())
        }
    from sim_pjrt.llo.metadata import annotate_timeline, hlo_profile_metadata

    from sim_pjrt.llo.sparsecore import (control_flow_metadata, mark_unmodeled,
                            offload_inventory, bound_offloads)

    sparsecore_calls, sparsecore_nodes, debug_metadata = [], {}, {}
    for filename in provenance.get("profile_metadata_files", []):
        text = Path(filename).read_text()
        labels = hlo_profile_metadata(text)
        debug_metadata.update(labels)
        sparsecore_nodes.update(control_flow_metadata(text))
        sparsecore_calls.extend(offload_inventory(text))
    def finalize_report(result):
        annotate_timeline(result['activity_timeline'], debug_metadata)
        mark_unmodeled(result, sparsecore_calls, provenance.get('sparsecore_bundle_files', []))
        calibration = profile.get('sparsecore', {}).get('operation_timings', {})
        if sparsecore_calls and calibration:
            bound_offloads(result, sparsecore_calls, sparsecore_nodes, debug_metadata, calibration)

    if args.scenario:
        result = estimate_bundles(iter_final_bundles(modules, aliases), profile,
                                  json.loads(args.scenario.read_text()),
                                  retain_events=not args.summary)
        finalize_report(result)
    else:
        result = estimate_final_program(modules, profile, aliases,
                                         retain_events=not args.summary, finalize_report=finalize_report)
    result["analysis_source"] = "libtpu_bundles"
    result.update(provenance)
    if args.summary:
        result.pop("events")
    text = json.dumps(result, indent=2) + "\n"
    if args.output:
        args.output.write_text(text)
    else:
        print(text, end="")


if __name__ == "__main__":
    main()
