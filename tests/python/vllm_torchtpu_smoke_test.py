"""Weight-free vLLM-TorchTPU generation through spjrt --framework torch_tpu.

Requires the isolated environment documented in docs/python-package.md.
"""

import argparse
import json
import tempfile
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--compiled", action="store_true")
    args = parser.parse_args()

    from vllm import LLM, SamplingParams
    from vllm.platforms import current_platform

    assert type(current_platform).__module__.startswith("vllm_torchtpu.")
    with tempfile.TemporaryDirectory(prefix="sim-vllm-model-") as model:
        config = {
            "architectures": ["LlamaForCausalLM"],
            "model_type": "llama",
            "hidden_size": 256,
            "intermediate_size": 512,
            "num_hidden_layers": 1,
            "num_attention_heads": 2,
            "num_key_value_heads": 2,
            "head_dim": 128,
            "vocab_size": 128,
            "max_position_embeddings": 128,
            "bos_token_id": 1,
            "eos_token_id": 127,
            "rms_norm_eps": 1e-6,
            "tie_word_embeddings": False,
            "torch_dtype": "bfloat16",
        }
        Path(model, "config.json").write_text(json.dumps(config))
        llm = LLM(
            model=model,
            load_format="dummy",
            skip_tokenizer_init=True,
            dtype="bfloat16",
            tensor_parallel_size=1,
            max_model_len=128,
            max_num_seqs=2,
            max_num_batched_tokens=128,
            block_size=128,
            kv_cache_memory_bytes=2 * 1024**2,
            distributed_executor_backend="uni",
            enforce_eager=not args.compiled,
            enable_prefix_caching=False,
            async_scheduling=False,
        )
        # Both batched generation and reuse of the engine/KV blocks must work.
        for prompts in ([[1, 2, 3, 4], [1, 5, 6]], [[1, 7, 8]]):
            outputs = llm.generate(
                [{"prompt_token_ids": prompt} for prompt in prompts],
                SamplingParams(temperature=0, max_tokens=3, ignore_eos=True),
                use_tqdm=False,
            )
            assert len(outputs) == len(prompts), outputs
            for output, prompt in zip(outputs, prompts, strict=True):
                assert output.prompt_token_ids == prompt, output
                assert output.finished and len(output.outputs) == 1, output
                result = output.outputs[0]
                tokens = list(result.token_ids)
                assert len(tokens) == 3 and all(0 <= t < 128 for t in tokens), output
                assert result.finish_reason == "length", output
                print(json.dumps({
                    "framework": "vllm_torchtpu",
                    "compiled": args.compiled,
                    "placeholder_outputs": True,
                    "prompt_token_ids": prompt,
                    "token_ids": tokens,
                    "finish_reason": result.finish_reason,
                }), flush=True)


if __name__ == "__main__":
    main()
