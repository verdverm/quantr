# Quantr — Agent Guide

## Project Context

- Python 3.12 required (see `.python-version`)
- Linux only (enforced in `pyproject.toml` via `[tool.uv].environments`)
- Uses `uv` for dependency management with workspace-style separate projects
- `quant/` and `evals/` are separate uv projects with their own `pyproject.toml` and `.venv/`.
- IMPORTANT: Always use `uv run --project quant` or `uv run --project evals` (or the Makefile targets).

## Project Structure

```
quantr/
├── quant/                  # Quantization scripts (llmcompressor)
│   ├── qwen36-27b.py       # Main quantization script for Qwen3.6-27B
│   └── recipes/            # Quantization recipe configs
├── evals/                  # Evaluation scripts (lm-eval)
│   └── qwen36-27b.sh       # Eval runner script
├── utils/                  # Utility scripts
├── models/                 # Output directory for quantized models (gitignored)
├── results/                # Output directory for eval results (gitignored)
├── extern/                 # Local copy of llm-compressor source (gitignored)
└── Makefile                # The rules you should prefer to run instead of doing things by hand
```

## Primary Commands

```bash
# Install dependencies
make uv.sync

# Generate recipes
make qwen.gen

# Run quantization
make qwen.quant

# Run evals
make qwen.evals
```
