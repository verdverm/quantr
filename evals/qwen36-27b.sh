#!/usr/bin/env bash
set -euo pipefail

export MAX_JOBS=1

# RECIPE=qwen36-27b-baseline
RECIPE=qwen36-27b-wikitext

lm_eval run --config evals/recipes/${RECIPE}.yaml


# MODEL=Qwen3.6-27B-NVFP4-32-4096
# MODEL=Qwen/Qwen3.5-9B
# TASK=wikitext
# OUTDIR="./results/${MODEL}/${TASK}"

# MAX_JOBS=1 \
# lm_eval run --model vllm \
#   --model_args pretrained="./models/${MODEL}",add_bos_token=true \
#   --tasks ${TASK} \
#   --output_path ${OUTDIR} \
#   --limit 32 \
#   --batch_size 1
