"""Parse Final LLO records, call aliases and explicit execution paths."""

import re

_HEADER = re.compile(
    r"^\s*(?:(\d+):)?(0x[\da-fA-F]+|\d+)\s*(?:LH|LB|LE|PB|PF|CT)?\s*:\s*[><=]*\s*\{",
    re.M,
)


_COMMENT = re.compile(r"/\*.*?\*/", re.S)


def parse_bundles(text):
    """Return immutable-by-convention dictionaries, stripping diagnostic comments.

    Accept multiline final_bundles and single-line assembly-pre-overlay. Reject
    malformed/truncated records and duplicate addresses instead of dropping work.
    """
    # SSA address types identify the direction of descriptor-based DMA too.
    spaces = dict(re.findall(
        r'(%s\w+)\s*=\s*(?:inlined_call_operand|scalar_lea|int_to_ptr)\.(hbm|vmem|smem)\b', text))
    # Region-entry annotations identify branch targets, including empty regions.
    regions = {}
    raw_headers = list(_HEADER.finditer(text))
    for n, header in enumerate(raw_headers):
        segment = text[header.end():raw_headers[n + 1].start() if n + 1 < len(raw_headers) else len(text)]
        regions[n] = re.findall(r'Start(?:/End empty)? region (\d+)\b', segment)
    # Call targets are diagnostic annotations, but are needed before stripping.
    text = re.sub(
        r"(inlined_call\b[^;{}]*?)/\*\s*(.*?)\s*\*/",
        lambda m: m[1] + " __callee__" + (m[2].split("=", 1)[0].strip().lstrip("%")),
        text,
    )
    text = re.sub(r'(vwait\.[\w.]+\b[^;{}]*?)/\*\s*global-barrier-wait\s*\*/',
                  r'\1 __peer_wait__', text)
    # General DMA pointers can pass through scalar phi/arithmetic and lose their
    # local type spelling. The compiler prints the resolved transfer direction.
    text = re.sub(
        r'(dma\.general\b[^;{}]*?)/\*\s*(hbm|vmem|smem)-to-(hbm|vmem|smem)\s*\*/',
        lambda m: m[1] + ' __dma_direction_' + m[2] + '_to_' + m[3] + '__', text)
    text = _COMMENT.sub("", text)
    if "/*" in text or "*/" in text:
        raise ValueError("unterminated or unmatched diagnostic comment")
    headers = list(_HEADER.finditer(text))
    if len(raw_headers) != len(headers):
        raise ValueError("ambiguous bundle headers in diagnostic comments")
    candidates = re.findall(
        r"^\s*(?:(?:\d+):)?(?:0x[\da-fA-F]+|\d+)\s*[^\n{]*:\s*[^\n{]*\{", text, re.M
    )
    if len(candidates) != len(headers):
        raise ValueError("unsupported bundle record header; refusing to omit work")
    if not headers:
        raise ValueError("no bundle records found")
    result, seen = [], set()
    for i, match in enumerate(headers):
        segment = text[
            match.end() : headers[i + 1].start() if i + 1 < len(headers) else len(text)
        ]
        clean = segment
        if "}" not in clean:
            raise ValueError(f"unterminated bundle at {match.group(2)}")
        depth = 1
        for closing, char in enumerate(clean):
            depth += (char == "{") - (char == "}")
            if depth == 0:
                break
        if depth:
            raise ValueError(f"unterminated bundle at {match.group(2)}")
        body = clean[:closing].strip()
        address = f"{match.group(1) or '0'}:{int(match.group(2), 0) if match.group(2).startswith('0x') else int(match.group(2)):#x}"
        if address in seen:
            raise ValueError(
                f"duplicate address {address}; analyze each region separately"
            )
        seen.add(address)
        instructions = []
        for raw in re.split(r"\s*;;?\s*", body):
            if not raw:
                continue
            peer_wait = '__peer_wait__' in raw
            raw = raw.replace('__peer_wait__', '').strip()
            direction = re.search(r'__dma_direction_(\w+_to_\w+)__', raw)
            if direction:
                raw = raw.replace(direction[0], '').strip()
            rhs = re.sub(r"^[%\w.-]+\s*=\s*", "", raw)
            opcode = re.match(r"[\w.-]+", rhs)
            if not opcode:
                raise ValueError(f"cannot parse instruction at {address}: {raw}")
            instruction = {"opcode": opcode.group(), "text": raw}
            if peer_wait:
                instruction['peer_wait'] = True
            if opcode.group() == 'dma.general':
                args = dma_operands(raw)
                if len(args) >= 3 and args[0] in spaces and args[2] in spaces:
                    instruction['dma_direction'] = spaces[args[0]] + '_to_' + spaces[args[2]]
                if direction:
                    if instruction.get('dma_direction', direction[1]) != direction[1]:
                        raise ValueError('DMA direction annotation conflicts with pointer address spaces')
                    instruction['dma_direction'] = direction[1]
            if "__callee__" in raw:
                instruction["callee"] = raw.split("__callee__", 1)[1].strip()
                instruction["text"] = raw.split("__callee__", 1)[0].strip()
            instructions.append(instruction)
        bundle = {"address": address, "instructions": instructions}
        if re.search(r'\b(?:LH|LB)\b', match[0]):
            bundle['loop_header'] = True
        if re.search(r'\bPF\b', match[0]):
            bundle['branch_join'] = True
        if regions.get(i):
            bundle['regions'] = regions[i]
        result.append(bundle)
    # Identical printed push mnemonics can target different FIFOs. Preserve the
    # observed SSA consumer kind, rather than guessing from the destination name.
    pushes, duplicate_pushes = {}, set()
    for bundle in result:
        for ins in bundle['instructions']:
            if ins['opcode'] == 'vsyncmov':
                match = re.match(r'^(%\w+)\s*=', ins['text'])
                if match:
                    if match[1] in pushes:
                        duplicate_pushes.add(match[1])
                    pushes[match[1]] = ins
    consumers = {name: set() for name in pushes}
    if pushes:
        for bundle in result:
            for ins in bundle['instructions']:
                rhs = re.sub(r'^%\w+\s*=\s*', '', ins['text'])
                for register in re.findall(r'%\w+', rhs):
                    if register in consumers:
                        consumers[register].add(ins['opcode'])
        for register, kinds in consumers.items():
            if kinds and register not in duplicate_pushes:
                pushes[register]['result_consumer_opcodes'] = sorted(kinds)
    return tuple(result)


def dma_operands(text):
    """Scalar DMA operands, with predication/thread annotations removed."""
    rhs = text.split('=', 1)[-1].strip()
    rhs = re.sub(r'^dma\.[\w.]+\s*', '', rhs)
    rhs = re.sub(r'\[thread:[^\]]*\]|\(!?%p\w+\)\s*,?', '', rhs)
    return [value.strip() for value in rhs.split(',')]


def parse_deduplication_map(text):
    aliases = {}
    if not text.startswith("key:"):
        raise ValueError("missing libtpu deduplication map records")
    for block in text.split("key:")[1:]:
        lines = block.splitlines()
        name = lines[0].strip()
        if len(lines) < 3 or not re.fullmatch(r"ordinal:\d+", lines[1]):
            raise ValueError("malformed libtpu deduplication map")
        count = re.fullmatch(r"equivalent_hlos\[size=(\d+)\]:", lines[2])
        if not count or int(count[1]) != len(lines[3:]):
            raise ValueError("truncated libtpu deduplication map")
        for alias in lines[3:]:
            alias = alias.strip()
            if alias in aliases and aliases[alias] != name:
                raise ValueError(f"ambiguous libtpu alias: {alias}")
            aliases[alias] = name
    return aliases


def expand_path(items, limit=1_000_000):
    """Expand nested {repeat: N, body: [...]} execution blocks, preserving order."""
    result = []
    for item in items:
        if isinstance(item, str):
            block = [item]
        elif isinstance(item, dict) and set(item) == {"repeat", "body"}:
            count = item["repeat"]
            if type(count) is not int or count < 0:
                raise ValueError("repeat must be a nonnegative integer")
            body = expand_path(item["body"], limit) if count else ()
            if len(body) * count > limit - len(result):
                raise ValueError("execution path exceeds expansion limit")
            block = body * count
        else:
            raise ValueError("path entries must be addresses or repeat/body blocks")
        if len(result) + len(block) > limit:
            raise ValueError("execution path exceeds expansion limit")
        result.extend(block)
    return tuple(result)


def _number(text):
    return int(text, 0) if "x" in text.lower() else int(text)
