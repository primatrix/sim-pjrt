"""JAX compile identities recorded during collection and matched during replay."""

from contextlib import contextmanager
from importlib.metadata import version
import json
import os
import threading

from sim_pjrt.prediction import KEY_ATTRIBUTE, MISS_ATTRIBUTE, TIMING_ATTRIBUTE, execution_key


def hardware_context(backend):
    devices = backend.devices()
    context = {
        "versions": {p: version(p) for p in ("jax", "jaxlib", "libtpu")},
        "devices": sorted([
            {"id": d.id, "kind": d.device_kind,
             "coords": list(d.coords), "core_on_chip": d.core_on_chip}
            for d in devices
        ], key=lambda d: d["id"]),
    }
    flags = {name: os.environ[name] for name in ("XLA_FLAGS", "LIBTPU_INIT_ARGS")
             if os.environ.get(name)}
    if flags:
        context["compiler_flags"] = flags
    return context


def identity_options(options):
    from jaxlib import xla_client

    copy = xla_client.CompileOptions.ParseFromString(options.SerializeAsString())
    # JAX fills this with a machine-local CUDA installation path (or "None").
    # It has no meaning for TPU code generation and differs on CPU-only hosts.
    copy.executable_build_options.debug_options.xla_gpu_cuda_data_dir = ""
    return copy.SerializeAsString()


def hlo_module_id(data):
    # HloModuleProto.id is field 5 in XLA's hlo.proto. Read only top-level
    # fields so collection needs neither TensorFlow nor generated XLA protos.
    pos = 0

    def varint():
        nonlocal pos
        value = 0
        for shift in range(0, 70, 7):
            if pos >= len(data):
                raise ValueError("Truncated HloModuleProto")
            byte = data[pos]
            pos += 1
            value |= (byte & 127) << shift
            if byte < 128:
                return value
        raise ValueError("Invalid protobuf varint")

    while pos < len(data):
        tag = varint()
        wire = tag & 7
        if wire == 0:
            value = varint()
            if tag >> 3 == 5:
                return value
        elif wire == 2:
            size = varint()
            pos += size
        elif wire in (1, 5):
            pos += 8 if wire == 1 else 4
        else:
            raise ValueError("Unsupported HloModuleProto wire type")
        if pos > len(data):
            raise ValueError("Truncated HloModuleProto")
    # Proto3 omits the default-valued id.
    return 0


@contextmanager
def compilation_observer(records, timing_predictor=None):
    from jax._src import compiler
    from jaxlib.mlir import ir

    original = compiler.backend_compile_and_load
    lock = threading.Lock()

    def compile_and_record(backend, module, executable_devices, options, host_callbacks):
        if backend.platform != "tpu":
            return original(backend, module, executable_devices, options, host_callbacks)
        if host_callbacks:
            raise ValueError("Collection/replay does not support host callbacks")
        text = module.operation.get_asm(enable_debug_info=False)
        context = hardware_context(backend)
        key = execution_key(text, identity_options(options), context)
        name = ir.StringAttr(module.operation.attributes["sym_name"]).value
        original_name = module.operation.attributes["sym_name"]
        # TPU Trace Viewer uses a runtime program fingerprint, not necessarily
        # HloModuleProto.id. Carry our identity in the module label so repeated
        # function names across shapes remain unambiguous in the device trace.
        if timing_predictor is None:
            with module.context:
                module.operation.attributes["sym_name"] = ir.StringAttr.get(
                    name + "__spjrt_" + key)
        if timing_predictor is not None:
            prediction = timing_predictor.predict(key)
            # The simulator consumes this before CPU output lowering. Remove it
            # afterwards, including on errors, so it cannot affect another compile.
            with module.context:
                module.operation.attributes[KEY_ATTRIBUTE] = ir.StringAttr.get(key)
                if prediction["predictor"] == "replay":
                    module.operation.attributes[TIMING_ATTRIBUTE] = ir.StringAttr.get(
                        json.dumps(prediction))
                if prediction.get("replay_miss"):
                    module.operation.attributes[MISS_ATTRIBUTE] = ir.BoolAttr.get(True)
        try:
            executable = original(backend, module, executable_devices, options, host_callbacks)
        finally:
            module.operation.attributes["sym_name"] = original_name
            if timing_predictor is not None:
                for attr in (KEY_ATTRIBUTE, MISS_ATTRIBUTE, TIMING_ATTRIBUTE):
                    if attr in module.operation.attributes:
                        del module.operation.attributes[attr]
        if timing_predictor is None:
            record = {"name": name, "context": context, "modules": [],
                      "identity": {"stablehlo": text,
                                   "compile_options_hex": options.SerializeAsString().hex()},
                      "num_replicas": options.num_replicas,
                      "num_partitions": options.num_partitions}
            for hlo in executable.hlo_modules():
                record["modules"].append({"name": hlo.name, "program_id": hlo_module_id(
                    hlo.as_serialized_hlo_module_proto()), "hlo_text": hlo.to_string()})
            with lock:
                if key in records:
                    records[key]["modules"].extend(record["modules"])
                else:
                    records[key] = record
        return executable

    compiler.backend_compile_and_load = compile_and_record
    try:
        yield
    finally:
        compiler.backend_compile_and_load = original
