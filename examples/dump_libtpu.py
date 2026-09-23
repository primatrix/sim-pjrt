"""Compile for an offline TPU and dump LLO/bundles; no TPU hardware required.

  .venv/bin/python examples/dump_libtpu.py --output /tmp/libtpu-demo

Requires compatible jax, jaxlib and libtpu packages. Run in a fresh process.
"""

import argparse
import json
import os
from pathlib import Path
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--topology", default="v4:2x2x1")
    args = parser.parse_args()
    output = (args.output or Path(tempfile.mkdtemp(prefix="libtpu-llo-"))).resolve()
    output.mkdir(parents=True, exist_ok=True)
    if any(output.iterdir()):
        parser.error("output directory must be empty so old dumps cannot count as evidence")
    if any(c.isspace() for c in str(output)):
        parser.error("dump directory must not contain whitespace")

    # CPU is the default *runtime*. Explicit compile-only TPU shardings below
    # select libtpu's offline compiler without creating a hardware TPU client.
    os.environ["JAX_PLATFORMS"] = "cpu"
    os.environ["JAX_ENABLE_COMPILATION_CACHE"] = "false"
    os.environ["TPU_SKIP_MDS_QUERY"] = "1"
    os.environ.setdefault("TPU_WORKER_HOSTNAMES", "localhost")
    os.environ["LIBTPU_INIT_ARGS"] = " ".join([
        os.environ.get("LIBTPU_INIT_ARGS", ""),
        f"--xla_jf_dump_to={output}",
        "--xla_jf_dump_hlo_text=true",
        "--xla_jf_dump_llo_text=true",
        "--xla_jf_emit_annotations=true",
        "--xla_jf_debug_level=2",
        "--xla_mosaic_enable_llo_source_annotations=true",
    ])

    import jax
    import jax.numpy as jnp
    from jax.experimental import pallas as pl, topologies
    from jax.sharding import SingleDeviceSharding

    topology = topologies.get_topology_desc(args.topology, platform="tpu")
    device = topology.devices[0]
    assert device.platform == "tpu", device
    sharding = SingleDeviceSharding(device)
    evidence = {
        "default_runtime": jax.default_backend(),
        "compile_target_platform": device.platform,
        "compile_target_kind": device.device_kind,
        "compile_target_device_type": type(device).__name__,
        "topology": args.topology,
    }
    print(json.dumps(evidence, indent=2), flush=True)

    def matmul(x, w):
        return jax.nn.relu(x @ w)

    def vector_add(x_ref, y_ref):
        y_ref[...] = x_ref[...] + 1

    pallas = pl.pallas_call(
        vector_add,
        out_shape=jax.ShapeDtypeStruct((8, 128), jnp.float32),
        name="llo_demo_pallas_add",
    )
    cases = {
        "matmul": (matmul, [(128, 64), (64, 256)]),
        "pallas": (pallas, [(8, 128)]),
    }
    for name, (function, shapes) in cases.items():
        fn = jax.jit(function, in_shardings=(sharding,) * len(shapes), out_shardings=sharding)
        inputs = [jax.ShapeDtypeStruct(shape, jnp.float32) for shape in shapes]
        lowered = fn.lower(*inputs)
        (output / f"{name}.stablehlo.mlir").write_text(str(lowered.compiler_ir()))
        compiled = lowered.compile()
        assert all(d.platform == "tpu" for d in compiled.output_shardings.device_set)
        (output / f"{name}.optimized.hlo.txt").write_text(compiled.as_text())
        print(f"Compiled {name} for {device.device_kind}", flush=True)

    bundles = sorted(output.rglob("*-final_bundles.txt"))
    assembly = sorted(output.rglob("*-assembly-pre-overlay.txt"))
    evidence["final_bundles"] = [str(p.relative_to(output)) for p in bundles]
    evidence["assembly"] = [str(p.relative_to(output)) for p in assembly]
    (output / "evidence.json").write_text(json.dumps(evidence, indent=2) + "\n")
    if not bundles or not assembly:
        raise RuntimeError(f"This libtpu did not emit the expected dumps; inspect {output}")
    print(f"Dumped {len(bundles)} final-bundle files and {len(assembly)} assembly files to {output}")


if __name__ == "__main__":
    main()
