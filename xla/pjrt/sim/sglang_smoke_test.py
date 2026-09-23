"""A local, weight-free SGLang-Jax request through the simulated TPU backend."""

import argparse
import json
import os
import tempfile
from pathlib import Path


def check_output(output, tokens):
    assert len(output["output_ids"]) == tokens, output
    assert all(0 <= token < 128 for token in output["output_ids"]), output
    assert output["meta_info"]["finish_reason"]["type"] == "length", output
    print(json.dumps({"cpu_wall_time_not_tpu_prediction": True, **output}))


def trace_files(prefix):
    return set(prefix.parent.glob(f"{prefix.name}.*.jsonl"))


def check_trace(paths, tp_size, overlap):
    records = [
        json.loads(line) for path in paths for line in path.read_text().splitlines()
    ]
    required = ["jit_jitted_run_model"]
    if overlap:
        required += ["jit_resolve_future_token_ids", "jit_set_future_token_ids"]
    counts = {}
    for name in required:
        executions = [r for r in records if r["name"] == name]
        assert len(executions) >= 3, (name, executions)
        assert all(r["num_devices"] == tp_size for r in executions), executions
        counts[name] = len(executions)
    print(json.dumps({"verified_device_count": tp_size, "executions": counts}))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tp-size", type=int, default=1)
    parser.add_argument("--overlap", action="store_true")
    parser.add_argument("--profile-dir", type=Path)
    args = parser.parse_args()
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
            "hidden_size": 256 * args.tp_size,
            "intermediate_size": 512 * args.tp_size,
            "num_hidden_layers": 1,
            "num_attention_heads": 2 * args.tp_size,
            "num_key_value_heads": 2 * args.tp_size,
            "head_dim": 128,
            "vocab_size": 128,
            "max_position_embeddings": 256,
            "rms_norm_eps": 1e-5,
            "rope_theta": 10000.0,
            "bos_token_id": 1,
            "eos_token_id": 2,
            "torch_dtype": "bfloat16",
        }
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
                # Use the framework's native profiler request with bounded
                # host detail. Python compilation traces can exhaust XProf's
                # viewer event budget before inference events are displayed.
                engine.loop.run_until_complete(
                    engine.tokenizer_manager.start_profile(
                        host_tracer_level=1, python_tracer_level=0
                    )
                )
                profiling = True
            for request in range(2):
                output = engine.generate(
                    input_ids=list(range(1, 33)),
                    sampling_params={
                        "temperature": 0,
                        "max_new_tokens": 4,
                        "ignore_eos": True,
                    },
                )
                check_output(output, 4)
                if request == 1:
                    assert output["meta_info"]["cached_tokens"] >= 16, output
            if args.overlap:
                # Unequal decode lengths release and reuse request/future-token
                # slots while other requests are still running.
                lengths = [3, 5, 7, 4]
                for _ in range(2):
                    outputs = engine.generate(
                        input_ids=[
                            list(range(1, size + 1)) for size in (16, 32, 48, 24)
                        ],
                        sampling_params=[
                            {"temperature": 0, "max_new_tokens": n, "ignore_eos": True}
                            for n in lengths
                        ],
                    )
                    assert len(outputs) == len(lengths), outputs
                    assert len({o["meta_info"]["id"] for o in outputs}) == len(lengths)
                    for output, length in zip(outputs, lengths, strict=True):
                        check_output(output, length)
            engine.flush_cache()
            output = engine.generate(
                input_ids=list(range(1, 33)),
                sampling_params={
                    "temperature": 0,
                    "max_new_tokens": 4,
                    "ignore_eos": True,
                },
            )
            check_output(output, 4)
            assert output["meta_info"]["cached_tokens"] == 0, output
        finally:
            try:
                if profiling:
                    engine.stop_profile()
            finally:
                engine.shutdown()
        check_trace(trace_files(prefix) - previous_traces, args.tp_size, args.overlap)
        if args.profile_dir:
            from profile_report import load_trace, simulator_events

            trace = load_trace(args.profile_dir)
            events = simulator_events(trace)
            model = [
                e
                for e in events
                if e["name"] == "Execute submit-to-ready"
                and e["args"].get("detail") == "jit_jitted_run_model"
            ]
            assert len({int(e["args"]["device_id"]) for e in model}) == args.tp_size
            if args.overlap:
                assert any(
                    e.get("name", "").startswith("forward_batch_generation")
                    for e in trace["traceEvents"]
                )
            simulated = [
                e
                for e in trace["traceEvents"]
                if e.get("args", {}).get("clock_domain") == "simulated"
            ]
            scopes = [
                e
                for e in simulated
                if e.get("args", {}).get("annotation_kind") == "executable_scope"
            ]
            model_scopes = [e for e in scopes if e["name"] == "jit_jitted_run_model"]
            assert len(model_scopes) == len(model), (len(model_scopes), len(model))
            assert all(int(e["args"]["sim_program_id"]) > 0 for e in model_scopes)
            assert {int(e["args"]["device"]) for e in model_scopes} == set(
                range(args.tp_size)
            )
            assert all(
                e["args"]["clock_alignment"] == "runtime_realtime" for e in simulated
            )
            assert any(
                "FlashAttention" in e["args"].get("framework_op", "") for e in simulated
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
            print(
                json.dumps({"xprof_verified": True, "model_ready_events": len(model)})
            )
        print(
            json.dumps(
                {
                    "validation_passed": True,
                    "tp_size": args.tp_size,
                    "overlap": args.overlap,
                    "completed_requests": 11 if args.overlap else 3,
                }
            )
        )


if __name__ == "__main__":
    main()
