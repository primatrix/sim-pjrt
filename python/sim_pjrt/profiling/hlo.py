"""Read operation metadata without initializing a JAX backend.

Trace expressions often contain operand shapes already. A complete HLO module
additionally identifies called computations, which is needed to distinguish
fusion/call bodies when grouping observations across shapes.
"""

import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys


def fingerprint(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True).encode()).hexdigest()


def split_top_level(text):
    parts, start, stack = [], 0, []
    quoted, escaped = False, False
    for index, char in enumerate(text):
        if quoted:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                quoted = False
        elif char == '"':
            quoted = True
        elif char in "([{":
            stack.append(char)
        elif char in ")]}":
            if not stack or "([{".index(stack.pop()) != ")]}".index(char):
                raise ValueError("Unbalanced HLO expression")
        elif char == "," and not stack:
            parts.append(text[start:index].strip())
            start = index + 1
    if stack or quoted:
        raise ValueError("Unbalanced HLO expression")
    if text[start:].strip():
        parts.append(text[start:].strip())
    return parts


def shape_prefix(text):
    """Return a shape and its unconsumed suffix, including tuples and layouts."""
    text = text.strip()
    if text.startswith("("):
        depth = 0
        for index, char in enumerate(text):
            depth += (char == "(") - (char == ")")
            if depth == 0:
                body = text[1:index]
                children = [shape_prefix(part) for part in split_top_level(body)]
                if any(rest for _, rest in children):
                    raise ValueError("Invalid tuple shape")
                return {"kind": "tuple", "elements": [s for s, _ in children],
                        "text": text[:index + 1]}, text[index + 1:].strip()
        raise ValueError("Unterminated tuple shape")
    match = re.match(r"([a-z][a-z0-9]*)\[([^\]]*)\](\{[^{}]*\})?", text)
    if not match:
        raise ValueError("Missing HLO shape")
    dimensions = []
    for value in filter(None, match[2].split(",")):
        value = value.strip()
        dimensions.append(int(value) if value.isdigit() else value)
    return {"kind": "array", "dtype": match[1], "dimensions": dimensions,
            "layout": match[3] or "", "text": match[0]}, text[match.end():].strip()


def expression_metadata(text):
    """Extract input shapes separately from the result shape in HLO text."""
    match = re.match(r"\s*(?:ROOT\s+)?%?([\w.\-]+)\s*=\s*(.*)", text, re.S)
    if not match:
        raise ValueError("Not an HLO instruction")
    result, rest = shape_prefix(match[2])
    call = re.match(r"([\w-]+)\(", rest)
    if not call:
        raise ValueError("Missing HLO opcode")
    start, depth, quoted, escaped = call.end(), 1, False, False
    for index in range(start, len(rest)):
        char = rest[index]
        if quoted:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                quoted = False
        elif char == '"':
            quoted = True
        else:
            depth += (char == "(") - (char == ")")
        if depth == 0:
            operands = split_top_level(rest[start:index])
            attributes = rest[index + 1:].lstrip(", ")
            break
    else:
        raise ValueError("Unterminated HLO operands")
    inputs, input_names = [], []
    # Literals and parameter numbers are not input operands.
    if call[1] not in ("parameter", "constant", "iota", "replica-id", "partition-id"):
        for operand in operands:
            reference = re.search(r"%([\w.\-]+)\s*$", operand)
            input_names.append(reference[1] if reference else None)
            try:
                shape, suffix = shape_prefix(operand)
            except ValueError:
                inputs.append(None)
            else:
                inputs.append(shape if suffix else None)
    attrs = {}
    for part in split_top_level(attributes):
        key, sep, value = part.partition("=")
        if sep:
            attrs[key.strip()] = value.strip()
    return {"name": match[1], "opcode": call[1], "input_shapes": inputs,
            "input_names": input_names,
            "literal_value": rest[start:index] if call[1] in ("parameter", "constant") else None,
            "output_shape": result, "attributes": attrs, "hlo_text": text,
            "shape_source": "trace_expression", "structure_complete": False}


def shape_class(shape, *, dtype=False):
    if shape is None:
        return None
    if shape["kind"] == "tuple":
        return [shape_class(s, dtype=dtype) for s in shape["elements"]]
    if dtype:
        return shape["dtype"]
    return {"rank": len(shape["dimensions"]), "layout": shape.get("layout", "")}


def shape_size(shape):
    """Logical elements/bytes, excluding physical padding and network traffic."""
    if shape is None:
        return {"elements": None, "bytes": None}
    if shape["kind"] == "tuple":
        children = [shape_size(child) for child in shape["elements"]]
        return {key: sum(c[key] for c in children) if all(c[key] is not None for c in children)
                else None for key in ("elements", "bytes")}
    from math import prod
    count = prod(shape["dimensions"]) if all(type(d) is int for d in shape["dimensions"]) else None
    dtype = shape["dtype"]
    match = re.fullmatch(r"(?:u|s|f|bf|c)(\d+)(?:[a-z0-9]*)", dtype)
    bits = 8 if dtype == "pred" else int(match[1]) if match else None
    return {"elements": count,
            "bytes": (count * bits + 7) // 8 if count is not None and bits is not None else None}


def module_metadata(text, *, source="hlo_dump"):
    # jaxlib's parser preserves tuples, layouts, backend configs, and called
    # computations. Importing it does not create a CPU/TPU client.
    from jaxlib import xla_client

    # Some TPU dumps declare a schedule while printing async computations in
    # a different order. We need graph metadata, not schedule reconstruction.
    # Keep the original text in the result and do not ask jaxlib to validate it.
    parse_text = re.sub(r", is_scheduled=true(?=,|\n|$)", "", text, count=1)
    module = xla_client.hlo.hlo_module_from_text(parse_text)
    options = xla_client.hlo.HloPrintOptions()
    options.print_operand_shape = True
    options.print_metadata = False
    options.print_large_constants = True
    options.print_backend_config = True
    computations = {c.name: list(c.instructions()) for c in module.computations()}
    printed = module.to_string(options)
    expressions, current = {}, None
    for line in printed.splitlines():
        match = re.match(r"  (?:ROOT )?%([\w.\-]+) = ", line)
        if match:
            current = match[1]
            expressions[current] = line.strip()
        elif current and line.startswith(" "):
            expressions[current] += " " + line.strip()
        else:
            current = None
    parsed = {name: expression_metadata(expression) for name, expression in expressions.items()}
    # The parser expands sugared call-start/update/done into internal async
    # computations that the module printer may hide. Include those nodes too.
    for instructions in computations.values():
        for instruction in instructions:
            if instruction.name not in parsed:
                record = expression_metadata(instruction.to_string())
                record["input_shapes"] = [expression_metadata(o.to_string())["output_shape"]
                                          for o in instruction.operands()]
                parsed[instruction.name] = record

    def structural_operation(instruction, visiting):
        record = parsed[instruction.name]
        attributes = dict(record["attributes"])
        attributes.pop("metadata", None)
        # Backend configs contain shape-dependent window sizes and even cost
        # estimates. Keep them as point features, not semantic family identity.
        if record["opcode"] != "custom-call":
            attributes.pop("backend_config", None)
        # References to computations are renamed by traversal order, while
        # their complete bodies (including constants) remain in the identity.
        bodies, dtypes = [], []
        for key, value in sorted(attributes.items()):
            for target in re.findall(r"%([\w.\-]+)", value):
                if target not in computations:
                    continue
                if target in visiting:
                    raise ValueError("Recursive HLO computations cannot be grouped")
                refs = {i.name: n for n, i in enumerate(computations[target])}
                body = []
                for child in computations[target]:
                    structure, types = structural_operation(child, visiting | {target})
                    body.append({"operation": structure,
                                 "operands": [refs[o.name] for o in child.operands()]})
                    dtypes.append(types)
                attributes[key] = attributes[key].replace("%" + target, f"@body{len(bodies)}")
                bodies.append(body)
        shapes = [*record["input_shapes"], record["output_shape"]]
        result = {"opcode": record["opcode"], "attributes": attributes,
                  "shapes": [shape_class(s) for s in shapes], "bodies": bodies}
        if record["opcode"].endswith(("-done", "-update")):
            operands = instruction.operands()
            if operands and parsed[operands[0].name]["opcode"].endswith(("-start", "-update")):
                start, start_types = structural_operation(operands[0], visiting)
                result["async_start"] = start
                dtypes.append(start_types)
        # Parameter positions and constant contents are meaningful even though
        # neither appears in the operation's input_shapes.
        if record["opcode"] in ("parameter", "constant"):
            result["literal"] = record["literal_value"]
        return result, [[shape_class(s, dtype=True) for s in shapes], dtypes]

    operations = {}
    for computation, instructions in computations.items():
        for instruction in instructions:
            record = parsed[instruction.name]
            structure, types = structural_operation(instruction, {computation})
            def collect_operations(node):
                if isinstance(node, dict):
                    if "opcode" in node:
                        yield node
                    for value in node.values():
                        yield from collect_operations(value)
                elif isinstance(node, list):
                    for value in node:
                        yield from collect_operations(value)
            nodes = list(collect_operations(structure))
            record.update(shape_source=source, structure_complete=True,
                          structure_key=fingerprint(structure), dtype_key=fingerprint(types),
                          implementation_key=fingerprint([printed, instruction.name]),
                          contained_opcodes=sorted({node["opcode"] for node in nodes}),
                          contained_communication=[{"opcode": node["opcode"], "attributes": node["attributes"]}
                                                   for node in nodes if any(attr in node["attributes"]
                                                       for attr in ("replica_groups", "source_target_pairs"))],
                          computation=computation)
            operations[instruction.name] = record
    return {"name": module.name, "hlo_fingerprint": fingerprint(printed),
            "hlo_text": text, "source": source, "operations": operations}


def parse_hlo(text, *, source):
    """Isolate native parser CHECK failures from the timing importer."""
    try:
        result = subprocess.run([sys.executable, "-m", "sim_pjrt.profiling.hlo"],
                                input=json.dumps({"text": text, "source": source}),
                                text=True, capture_output=True, timeout=60)
    except subprocess.TimeoutExpired as error:
        raise ValueError("HLO metadata parser exceeded 60 seconds") from error
    if result.returncode:
        raise ValueError(f"HLO metadata parser exited {result.returncode}: {result.stderr[-2000:]}")
    return json.loads(result.stdout)


def read_hlo(path):
    path = Path(path)
    if path.suffix == ".pb":
        # Parse protobufs in the same isolated process as text input.
        result = subprocess.run([sys.executable, "-m", "sim_pjrt.profiling.hlo"],
                                input=json.dumps({"proto_path": str(path.resolve())}),
                                text=True, capture_output=True, timeout=60)
        if result.returncode:
            raise ValueError(f"HLO proto parser exited {result.returncode}: {result.stderr[-2000:]}")
        return json.loads(result.stdout)
    else:
        text = path.read_text()
    return parse_hlo(text, source=str(path))


if __name__ == "__main__":
    import resource
    resource.setrlimit(resource.RLIMIT_CORE, (0, 0))
    request = json.load(sys.stdin)
    try:
        if "proto_path" in request:
            from jaxlib import xla_client
            path = Path(request["proto_path"])
            module = xla_client.hlo.HloModule.from_serialized_hlo_module_proto(path.read_bytes())
            data = module_metadata(module.to_string(), source=str(path))
        else:
            data = module_metadata(request["text"], source=request["source"])
        json.dump(data, sys.stdout)
    except Exception as error:
        print(str(error), file=sys.stderr)
        sys.exit(2)
