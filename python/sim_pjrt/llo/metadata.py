"""Compiler labels for XProf and operation descriptions for calibration matching."""

import ast
import re


def hlo_loop_bounds(text):
    """Prove i = input; while i < input + N: i += 1 has at most N trips.

    The invariant input must survive unchanged in the tuple. For signed or
    unsigned 32-bit addition, wrapping the stop value makes the entry test false.
    Only entry-computation loops are considered, so no outer multiplier is lost.
    Returns bounds on individual body operations, not timing estimates.
    """
    computations, roots, nodes, entry, current = {}, {}, {}, None, None
    for line in re.sub(r'/\*.*?\*/', '', text, flags=re.S).splitlines():
        header = re.match(r'^(ENTRY )?%([\w.-]+)\s*\(', line)
        if header:
            current = header[2]
            computations[current] = []
            if header[1]:
                entry = current
        match = re.match(r'\s*(ROOT )?%([\w.-]+) = (.*)', line)
        if not match or current is None:
            continue
        operation = re.search(r'\b([a-z][\w-]*)\(([^)]*)\)', match[3])
        if operation:
            name = match[2]
            nodes[name] = (operation[1], re.findall(r'%([\w.-]+)', operation[2]),
                           operation[2], match[3])
            computations[current].append(name)
            if match[1]:
                roots[current] = name

    def unwrap(name):
        while name in nodes and nodes[name][0] == 'copy':
            name = nodes[name][1][0]
        return name

    def index(name):
        node = nodes[unwrap(name)]
        match = re.search(r'\bindex=(\d+)', node[3])
        if node[0] == 'get-tuple-element' and match and nodes[node[1][0]][0] == 'parameter':
            return int(match[1])
        return None

    def increment(name):
        node = nodes[unwrap(name)]
        if node[0] != 'add' or not re.match(r'[su]32\[\]', node[3]):
            return None
        left, right = node[1]
        if nodes[unwrap(left)][0] == 'constant':
            left, right = right, left
        const = nodes[unwrap(right)]
        if const[0] == 'constant' and const[2].isdigit():
            return index(left), int(const[2])
        return None

    bounds = {}
    for name in computations.get(entry, []):
        node = nodes[name]
        body = re.search(r'\bbody=%([\w.-]+)', node[3])
        cond = re.search(r'\bcondition=%([\w.-]+)', node[3])
        if node[0] != 'while' or not body or not cond:
            continue
        initial, result, test = nodes[unwrap(node[1][0])], nodes[roots[body[1]]], nodes[roots[cond[1]]]
        if initial[0] != 'tuple' or result[0] != 'tuple' or test[0] != 'compare' or 'direction=LT' not in test[3]:
            continue
        counter = index(test[1][0])
        stop = increment(test[1][1])
        if counter is None or stop is None:
            continue
        invariant, count = stop
        if invariant is None or not 0 < count < 2**31 or max(counter, invariant) >= len(initial[1]):
            continue
        if (unwrap(initial[1][counter]) != unwrap(initial[1][invariant])
                or increment(result[1][counter]) != (counter, 1)
                or index(result[1][invariant]) != invariant):
            continue
        for operation in computations[body[1]]:
            bounds[operation] = max(bounds.get(operation, 0), count)
    return bounds


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
                    tables[section][int(key)] = ast.literal_eval(value)
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
                    # HLO uses C escapes, including \' in dictionary parameter
                    # names. JSON rejects those; Python string literals accept
                    # the emitted quote, backslash, octal and hex escapes.
                    info[key] = ast.literal_eval(match[1])
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
