"""A local, weight-free SGLang-Jax request through the simulated TPU backend."""

import argparse
import json
import os
import tempfile
from pathlib import Path


def check_output(output, tokens, emit=True):
    assert len(output["output_ids"]) == tokens, output
    assert all(0 <= token < 128 for token in output["output_ids"]), output
    assert output["meta_info"]["finish_reason"]["type"] == "length", output
    if emit:
        print(json.dumps({"cpu_wall_time_not_tpu_prediction": True, **output}))


def trace_files(prefix):
    return set(prefix.parent.glob(f"{prefix.name}.*.jsonl"))


def check_trace(paths, tp_size, overlap):
    records = [
        json.loads(line) for path in paths for line in path.read_text().splitlines()
    ]
    source = "libtpu_bundles"
    assert records and all(r["analysis_source"] == source for r in records)
    bundle_gaps = 0
    assert all(r["bundle_count"] > 0 and r["bundle_duration_ns"] > 0 for r in records)
    bundle_gaps = sum(r["bundle_cost_gaps"] for r in records)
    for path in paths:
        ids = {r["program_id"] for r in map(json.loads, path.read_text().splitlines())}
        for program_id in ids:
            snapshot = json.loads(
                path.with_suffix(f".program{program_id}.json").read_text()
            )
            assert "hlo" not in snapshot and "plan" not in snapshot
            assert snapshot["analysis_source"] == source
            assert snapshot["bundle_stage"] == "final_bundles"
            assert Path(snapshot["entry_file"]).is_file()
            assert all(
                Path(f).is_file() and f.endswith("-final_bundles.txt")
                for f in snapshot["final_bundle_files"]
            )
    required = ["jit_jitted_run_model"]
    if overlap:
        required += ["jit_resolve_future_token_ids", "jit_set_future_token_ids"]
    counts = {}
    for name in required:
        executions = [r for r in records if r["name"] == name]
        assert len(executions) >= 3, (name, executions)
        assert all(r["num_devices"] == tp_size for r in executions), executions
        counts[name] = len(executions)
    print(
        json.dumps(
            {
                "verified_device_count": tp_size,
                "executions": counts,
                "analysis_source": source,
                "bundle_cost_gaps": bundle_gaps,
            }
        )
    )


def check_profile(directory, tp_size, overlap, paths=None):
    from collections import defaultdict
    from profile_report import load_trace, simulator_events

    trace = load_trace(directory)
    assert not any(
        e.get("name") == "backend_compile_and_load" for e in trace["traceEvents"]
    ), "Capture includes compilation; warm all request shapes first"
    events = simulator_events(trace)
    model = [
        e
        for e in events
        if e["name"] == "Execute submit-to-ready"
        and e["args"].get("detail") == "jit_jitted_run_model"
    ]
    assert len({int(e["args"]["device_id"]) for e in model}) == tp_size
    if overlap:
        assert any(
            e.get("name", "").startswith("forward_batch_generation")
            for e in trace["traceEvents"]
        )
    simulated = [
        e
        for e in trace["traceEvents"]
        if e.get("args", {}).get("clock_domain") == "simulated"
    ]
    process_names = {
        e["pid"]: e["args"]["name"]
        for e in trace["traceEvents"]
        if e.get("name") == "process_name"
    }
    lanes = defaultdict(list)
    for event in trace["traceEvents"]:
        if event.get("ph") != "X":
            continue
        plane = process_names.get(event["pid"], "")
        if "/device:TPU:" in plane and event.get("args", {}).get("clock_domain") == "simulated":
            lanes[event["pid"], event["tid"]].append(event)
        assert event["name"] != "Host source releasable"
    assert lanes, "No simulator timeline lanes found"
    assert not any(int(e.get("args", {}).get("dropped_events", 0)) for e in trace["traceEvents"]), "Simulator profile dropped events"
    for lane in lanes.values():
        end = float("-inf")
        for event in sorted(lane, key=lambda e: e["ts"]):
            assert event["ts"] >= end - 1e-3, event
            end = event["ts"] + event.get("dur", 0)
    bundle_tracks = {
        (e.get("pid"), e.get("tid"))
        for e in trace["traceEvents"]
        if e.get("ph") == "M" and e.get("args", {}).get("name") == "XLA Modules"
    }
    scopes = [
        e
        for e in simulated
        if e.get("args", {}).get("annotation_kind") == "executable_scope"
        or (e.get("pid"), e.get("tid")) in bundle_tracks
    ]
    model_scopes = [e for e in scopes if e["name"] == "jit_jitted_run_model"]
    assert len(model_scopes) == len(model), (len(model_scopes), len(model))
    assert all(int(e["args"]["sim_program_id"]) > 0 for e in model_scopes)
    assert {int(e["args"]["device"]) for e in model_scopes} == set(range(tp_size))
    assert all(e["args"]["clock_alignment"] == "runtime_realtime" for e in simulated)
    scope_by_execution = {
        (e["args"]["correlation_id"], int(e["args"]["device"])): e for e in scopes
    }
    internal = [e for e in simulated if e["args"].get("annotation_kind") in {
        "compilation_scope", "unresolved_cost"
    }]
    assert any(e["args"]["annotation_kind"] == "compilation_scope" for e in internal)
    for event in internal:
        scope = scope_by_execution[event["args"]["correlation_id"], int(event["args"]["device"])]
        assert event["ts"] >= scope["ts"] - 1e-3
        assert event["ts"] + event.get("dur", 0) <= scope["ts"] + scope["dur"] + 1e-3
    durations = {
        r["program_id"]: r["bundle_duration_ns"] / 1000
        for path in (paths if paths is not None else trace_files(Path(os.environ["PJRT_SIM_TRACE"])))
        for r in map(json.loads, path.read_text().splitlines())
    }
    ready = {
        (e["args"]["correlation_id"], int(e["args"]["device_id"])): e for e in model
    }
    for event in model_scopes:
        stats = event["args"]
        assert abs(event["dur"] - durations[int(stats["sim_program_id"])]) < 1e-3
        completion = ready[stats["correlation_id"], int(stats["device"])]
        assert event["ts"] >= completion["ts"] - 1e-3
        assert event["ts"] + event["dur"] <= (
            completion["ts"] + completion["dur"] + 1e-3
        )
    assert any(
        e.get("ph") == "M" and "XLA Modules" in e.get("args", {}).get("name", "")
        for e in trace["traceEvents"]
    )
    print(
        json.dumps(
            {
                "native_simulated_xprof_verified": True,
                "simulated_events": len(simulated),
                "model_scopes": len(model_scopes),
            }
        )
    )
    print(json.dumps({"xprof_verified": True, "model_ready_events": len(model)}))


def run_requests(engine, overlap, emit=True):
    for request in range(2):
        output = engine.generate(
            input_ids=list(range(1, 33)),
            sampling_params={
                "temperature": 0,
                "max_new_tokens": 4,
                "ignore_eos": True,
            },
        )
        check_output(output, 4, emit)
        if request == 1:
            assert output["meta_info"]["cached_tokens"] >= 16, output
    if overlap:
        # Unequal decode lengths release and reuse request/future-token
        # slots while other requests are still running.
        lengths = [3, 5, 7, 4]
        for _ in range(2):
            outputs = engine.generate(
                input_ids=[list(range(1, size + 1)) for size in (16, 32, 48, 24)],
                sampling_params=[
                    {"temperature": 0, "max_new_tokens": n, "ignore_eos": True}
                    for n in lengths
                ],
            )
            assert len(outputs) == len(lengths), outputs
            assert len({o["meta_info"]["id"] for o in outputs}) == len(lengths)
            for output, length in zip(outputs, lengths, strict=True):
                check_output(output, length, emit)
    engine.flush_cache()
    output = engine.generate(
        input_ids=list(range(1, 33)),
        sampling_params={
            "temperature": 0,
            "max_new_tokens": 4,
            "ignore_eos": True,
        },
    )
    check_output(output, 4, emit)
    assert output["meta_info"]["cached_tokens"] == 0, output


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tp-size", type=int, default=1)
    parser.add_argument("--model", choices=("llama", "qwen3_moe"), default="llama")
    parser.add_argument(
        "--hidden-size",
        type=int,
        help="Override model width to exercise large virtual weights",
    )
    parser.add_argument("--overlap", action="store_true")
    parser.add_argument("--num-layers", type=int, default=1)
    parser.add_argument("--intermediate-size", type=int)
    parser.add_argument("--profile-dir", type=Path)
    args = parser.parse_args()
    hidden_size = (
        args.hidden_size if args.hidden_size is not None else 256 * args.tp_size
    )
    if hidden_size <= 0 or hidden_size % (128 * args.tp_size):
        parser.error("hidden size must be a positive multiple of 128 * tp-size")
    intermediate_size = (
        args.intermediate_size
        if args.intermediate_size is not None
        else 2 * hidden_size
    )
    if args.num_layers <= 0 or intermediate_size <= 0:
        parser.error("layer count and intermediate size must be positive")
    if args.profile_dir:
        args.profile_dir.mkdir(parents=True, exist_ok=True)
        os.environ["SGLANG_JAX_PROFILER_DIR"] = str(args.profile_dir)
    from sgl_jax.srt.entrypoints.engine import Engine

    with tempfile.TemporaryDirectory(prefix="pjrt-sim-model-") as directory:
        prefix = Path(os.environ.setdefault("PJRT_SIM_TRACE", f"{directory}/execution"))
        previous_traces = trace_files(prefix)
        config = {
            "architectures": ["LlamaForCausalLM"],
            "model_type": "llama",
            "hidden_size": hidden_size,
            "intermediate_size": intermediate_size,
            "num_hidden_layers": args.num_layers,
            "num_attention_heads": hidden_size // 128,
            "num_key_value_heads": hidden_size // 128,
            "head_dim": 128,
            "vocab_size": 128,
            "max_position_embeddings": 256,
            "rms_norm_eps": 1e-5,
            "rope_theta": 10000.0,
            "bos_token_id": 1,
            "eos_token_id": 2,
            "torch_dtype": "bfloat16",
        }
        if args.model == "qwen3_moe":
            config.update(
                architectures=["Qwen3MoeForCausalLM"],
                model_type="qwen3_moe",
                num_experts=128,
                num_experts_per_tok=8,
                moe_intermediate_size=768,
                decoder_sparse_step=1,
                norm_topk_prob=True,
                mlp_only_layers=[],
                hidden_act="silu",
            )
        if args.profile_dir:
            (args.profile_dir.parent / "model_config.json").write_text(
                json.dumps(config, indent=2)
            )
        Path(directory, "config.json").write_text(json.dumps(config))
        engine = Engine(
            model_path=directory,
            load_format="dummy",
            skip_tokenizer_init=True,
            device="tpu",
            tp_size=args.tp_size,
            max_total_tokens=256,
            max_running_requests=4,
            context_length=128,
            chunked_prefill_size=128,
            max_prefill_tokens=128,
            page_size=16,
            disable_precompile=True,
            disable_overlap_schedule=not args.overlap,
            skip_server_warmup=True,
            log_level="info",
        )
        profiling = False
        try:
            if args.profile_dir:
                # Exercise every request shape before collecting the steady-state
                # timeline. Never compress out compile gaps after capture.
                run_requests(engine, args.overlap, emit=False)
                engine.flush_cache()
                print(json.dumps({"profile_warmup_complete": True}), flush=True)
                engine.loop.run_until_complete(
                    engine.tokenizer_manager.start_profile(
                        host_tracer_level=1, python_tracer_level=0
                    )
                )
                profiling = True
            run_requests(engine, args.overlap)
        finally:
            try:
                if profiling:
                    engine.stop_profile()
            finally:
                engine.shutdown()
        check_trace(trace_files(prefix) - previous_traces, args.tp_size, args.overlap)
        if args.profile_dir:
            check_profile(args.profile_dir, args.tp_size, args.overlap,
                          trace_files(prefix) - previous_traces)
        print(
            json.dumps(
                {
                    "validation_passed": True,
                    "model": args.model,
                    "tp_size": args.tp_size,
                    "hidden_size": hidden_size,
                    "num_layers": args.num_layers,
                    "intermediate_size": intermediate_size,
                    "overlap": args.overlap,
                    "completed_requests": 11 if args.overlap else 3,
                }
            )
        )


if __name__ == "__main__":
    main()
