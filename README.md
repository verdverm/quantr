# Quantr

Utilities for quantizing and evaluating open weight models.

- llm-compressor & lm-evaluation-harness
- config driven, grid generation, simple commands


## Setup

Tools:

- `uv` for python
- make sure `nvcc` is in PATH
- `cue` for recipe and grid generation (some pregen'd)

```bash
# clone to gpu machine
git clone https://github.com/verdverm/quantr && cd quantr

# install deps
make uv.sync
```


## Using

```bash
# run full suite
make qwen.quant
make qwen.evals

# Run specific combo (qwen.<stage>.<algo>.<scheme>.<task>)
make qwen.quant.simp.nvfp4.wikitext
make qwen.evals.gptq.nvfp4a16.gsm8k
```


### Change points

- Makefile has 2 lists
- gen/index.cue (`make qwen.gen`)
- quant/*.py

```bash
# List lm-eval tasks and related
uv run --project evals lm_eval ls tasks > tasks.txt
uv run --project evals lm_eval ls -h
```


## Notes

1. You almost certainly want to use data driven quantization.
2. You almost certainly want to use at least the Sequential pipeline.


## References

### llm-compressor

- https://github.com/vllm-project/llm-compressor
- https://www.youtube.com/watch?v=NxdtRqQaPg0

### lm-evaluation-harness

- https://github.com/EleutherAI/lm-evaluation-harness

### Other

CUE:

- https://cuelang.org
- https://cuetorials.org

Evals:

- https://huggingface.co/docs/transformers/en/perplexity

NVFP4:

- https://research.nvidia.com/labs/nemotron/files/NVFP4-QAD-Report.pdf
- https://research.colfax-intl.com/cutlass-tutorial-nvfp4-blockscaled-gemm-on-nvidia-rtx-pro-blackwell-gpus-sm12x/
- https://humansand.ai/blog/nvfp4-rl
- https://hanlab.mit.edu/blog/svdquant-nvfp4 | https://news.ycombinator.com/item?id=43134907