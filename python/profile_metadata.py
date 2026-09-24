"""Compiler labels for XProf and operation descriptions for calibration matching."""

import json
import re


def hlo_profile_metadata(text):
    """Read optional debug labels from libtpu's final TLP HLO text dump.

    This is not an HLO execution plan. Unknown/missing debug fields stay absent.
    Only exact instruction names are used, never deduplicated kernel identities.
    """
    tables = {name: {} for name in ('FileNames', 'FileLocations', 'StackFrames')}
    section = None
    result = {}
    for line in text.splitlines():
        stripped = line.strip()
        if stripped in tables:
            section = stripped
            continue
        entry = re.fullmatch(r'(\d+) (.+)', stripped)
        if entry and section:
            key, value = entry.groups()
            if section == 'FileNames':
                if value.startswith('"'):
                    tables[section][int(key)] = json.loads(value)
            else:
                tables[section][int(key)] = {
                    k: int(v) for k, v in re.findall(r'(\w+)=(\d+)', value)
                }
            continue
        if not stripped:
            section = None
        op = re.match(r'\s*(?:ROOT )?%([\w.-]+) = ', line)
        if not op:
            continue
        attributes = re.search(r'\bmetadata=\{([^}]*)\}', line)
        info = {'hlo_text': stripped}
        if attributes:
            attrs = attributes[1]
            for key in ('op_name', 'op_type', 'source_file'):
                match = re.search(r'\b' + key + r'=("(?:\\.|[^"\\])*")', attrs)
                if match:
                    info[key] = json.loads(match[1])
            if info.get('op_name'):
                info['tf_op'] = info.pop('op_name') + ':' + info.pop('op_type', '')
            frame = re.search(r'\bstack_frame_id=(\d+)', attrs)
            location = tables['FileLocations'].get(
                tables['StackFrames'].get(int(frame[1]) if frame else 0, {}).get('file_location_id'), {}
            )
            filename = info.pop('source_file', '') or tables['FileNames'].get(location.get('file_name_id'), '')
            source_line = re.search(r'\bsource_line=(\d+)', attrs)
            lineno = int(source_line[1]) if source_line else location.get('line', 0)
            if filename:
                info['source'] = f'{filename}:{lineno}' if lineno else filename
            info.pop('op_type', None)
        result[op[1]] = info
    return result


def annotate_timeline(timeline, metadata):
    for event in timeline:
        if event['track'] == 'XLA Ops':
            event.update(metadata.get(event['name'], {}))
