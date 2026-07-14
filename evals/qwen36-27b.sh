#!/usr/bin/env bash
set -euo pipefail

export MAX_JOBS=1

# RECIPE=qwen36-27b-baseline
RECIPE=${1:-missing recipe slug}

lm_eval run --config evals/recipes/${RECIPE}.yaml
