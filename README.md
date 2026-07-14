# Quantr

Scripts for quantizing and evaluating models.


## Setup

make sure `nvcc` is in PATH

```bash
# clone to gpu machine
git clone https://github.com/verdverm/quantr && cd quantr

# install deps (compiles flash-attn, takes a while...)
make uv.sync
```

## Using

```bash
# run full suite
make qwen.quant
make qwen.evals

# Run specific combo (qwen.<stage>.<algo>.<scheme>)
make qwen.quant.simp.nvfp4
make qwen.evals.gptq.nvfp4a16
```

### Change points

- Makefile has 2 lists
- gen/index.cue (`make qwen.gen`)

```bash
# List lm-eval tasks and related
uv run --project evals lm_eval ls tasks > tasks.txt
uv run --project evals lm_eval ls -h
```

## Notes

1. You almost certainly want to use data driven quantization.
2. You almost certainly want to use at least the Sequential pipeline.


## Compiling certain pip packages

1. `uv pip install causal-conv1d --no-build-isolation`
2. `UV_CONCURRENT_BUILDS=1 MAX_JOBS=1 uv pip install flash-attn --no-build-isolation`
3. `pip install --force-reinstall --no-binary vllm vllm --no-build-isolation`

## References

https://github.com/vllm-project/llm-compressor

llm-compressor videos

- https://www.youtube.com/watch?v=NxdtRqQaPg0

https://huggingface.co/docs/transformers/en/perplexity