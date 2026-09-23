"""Installed-wheel HTTP smoke test; requires SGLang-Jax in the same environment.

Run with that environment's Python. SIM_HTTP_TP_SIZE defaults to 1.
Artifacts remain in a fresh /tmp/sim-pjrt-http-* directory for inspection.
"""

import json
import os
from pathlib import Path
import signal
import socket
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.request


def main():
    directory = Path(tempfile.mkdtemp(prefix="sim-pjrt-http-"))
    print(f"HTTP integration artifacts: {directory}", flush=True)
    devices = int(os.environ.get("SIM_HTTP_TP_SIZE", "1"))
    model = directory / "model"
    model.mkdir()
    (model / "config.json").write_text(json.dumps({
        "architectures": ["LlamaForCausalLM"], "model_type": "llama",
        "hidden_size": 256 * devices, "intermediate_size": 512 * devices,
        "num_hidden_layers": 1, "num_attention_heads": 2 * devices,
        "num_key_value_heads": 2 * devices, "head_dim": 128,
        "vocab_size": 128, "max_position_embeddings": 256,
        "rms_norm_eps": 1e-5, "rope_theta": 10000.0,
        "bos_token_id": 1, "eos_token_id": 2, "torch_dtype": "bfloat16",
    }))
    with socket.socket() as reserved:
        reserved.bind(("127.0.0.1", 0))
        port = reserved.getsockname()[1]
    env = dict(os.environ, PJRT_SIM_TRACE=str(directory / "execution"))
    command = [sys.executable, "-m", "sim_pjrt", "run",
               "--topology", os.environ.get("PJRT_SIM_TPU_TOPOLOGY", "v5e:2x2"),
               "--devices", str(devices), "--timing-profile", "example", "--",
               "python", "-m", "sgl_jax.launch_server",
               "--host", "127.0.0.1", "--port", str(port),
               "--model-path", str(model), "--load-format", "dummy",
               "--skip-tokenizer-init", "--device", "tpu", "--tp-size", str(devices),
               "--max-total-tokens", "256", "--max-running-requests", "4",
               "--context-length", "128", "--chunked-prefill-size", "128",
               "--max-prefill-tokens", "128", "--page-size", "16",
               "--disable-precompile", "--skip-server-warmup"]
    if devices == 1:
        command.append("--disable-overlap-schedule")
    with (directory / "server.log").open("w") as log:
        process = subprocess.Popen(command, env=env, cwd=directory, stdout=log,
                                   stderr=subprocess.STDOUT, start_new_session=True)
        try:
            deadline = time.monotonic() + 240
            while True:
                if process.poll() is not None:
                    raise RuntimeError(f"Server exited with {process.returncode}; see {directory}")
                try:
                    with urllib.request.urlopen(f"http://127.0.0.1:{port}/health", timeout=2) as response:
                        if response.status == 200:
                            break
                except (urllib.error.URLError, TimeoutError):
                    pass
                if time.monotonic() > deadline:
                    raise TimeoutError(f"Server startup timed out; see {directory}")
                time.sleep(0.5)
            payload = json.dumps({"input_ids": list(range(1, 33)), "sampling_params": {
                "temperature": 0, "max_new_tokens": 4, "ignore_eos": True}}).encode()
            request = urllib.request.Request(f"http://127.0.0.1:{port}/generate", data=payload,
                                             headers={"Content-Type": "application/json"})
            with urllib.request.urlopen(request, timeout=180) as response:
                output = json.load(response)
            assert len(output["output_ids"]) == 4, output
            assert output["meta_info"]["finish_reason"]["type"] == "length", output
            (directory / "response.json").write_text(json.dumps(output, indent=2))
        finally:
            if process.poll() is None:
                os.killpg(process.pid, signal.SIGTERM)
            try:
                process.wait(timeout=20)
            except subprocess.TimeoutExpired:
                os.killpg(process.pid, signal.SIGKILL)
                process.wait()
                raise RuntimeError(f"Server did not shut down on SIGTERM; see {directory}")
    records = [json.loads(line) for path in directory.glob("execution.*.jsonl")
               for line in path.read_text().splitlines()]
    assert records and all(row["analysis_source"] == "libtpu_bundles" for row in records)
    assert any(row["name"] == "jit_jitted_run_model" and row["num_devices"] == devices
               for row in records)
    print(json.dumps({"http_validation_passed": True, "devices": devices,
                      "artifacts": str(directory)}))


if __name__ == "__main__":
    main()
