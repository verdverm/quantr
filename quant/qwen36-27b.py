#!/usr/bin/env python

import argparse

import torch
from compressed_tensors.quantization import preset_name_to_scheme
from compressed_tensors.utils import save_mtp_tensors_to_checkpoint
from datasets import load_dataset
from transformers import AutoProcessor, Qwen3_5ForConditionalGeneration

from llmcompressor import oneshot
from llmcompressor.modifiers.quantization import QuantizationModifier
from llmcompressor.modifiers.gptq import GPTQModifier
from llmcompressor.modifiers.autoround import AutoRoundModifier
from llmcompressor.modifiers.transform.imatrix import IMatrixGatherer
from llmcompressor.utils import load_context


# NOTE: This example requires transformers >= v5

parser = argparse.ArgumentParser()
parser.add_argument("--model-id", default="Qwen/Qwen3.6-27B")
parser.add_argument("--scheme", default="NVFP4")
parser.add_argument("--algo", default="SIMP")
parser.add_argument("--dataset", default="HuggingFaceH4/ultrachat_200k")
parser.add_argument("--num-samples", type=int, default=512)
parser.add_argument("--max-length", type=int, default=8192)
args = parser.parse_args()
 
MODEL_ID = args.model_id
SCHEME = args.scheme
ALGO = args.algo

DATASET_ID = args.dataset
NUM_CALIBRATION_SAMPLES = args.num_samples
MAX_SEQUENCE_LENGTH = args.max_length

# SUFFIX = f"-{ALGO}-{SCHEME}-{NUM_CALIBRATION_SAMPLES}-{MAX_SEQUENCE_LENGTH}"
SUFFIX = f"-{ALGO}-{SCHEME}"
SAVE_DIR = "./models/" + MODEL_ID.rstrip("/").split("/")[-1] + SUFFIX
SAVE_DIR = SAVE_DIR.lower()

# Load model.
with load_context(Qwen3_5ForConditionalGeneration):
    model = Qwen3_5ForConditionalGeneration.from_pretrained(MODEL_ID)
processor = AutoProcessor.from_pretrained(MODEL_ID)

ds = load_dataset(
    DATASET_ID,
    split=f"train_sft[:{NUM_CALIBRATION_SAMPLES}]",
)
ds = ds.select_columns(["messages"])
ds = ds.shuffle(seed=42)

IGNORE = [
    "re:.*lm_head.*",
    "re:.*embed_tokens.*",
    "re:model.visual.*",
    "re:.*linear_attn.*",
    # "re:.*mlp.*",
]

# Setup recipe.
if ALGO == "SIMP":
    recipe = [
        QuantizationModifier(
            targets="Linear",
            scheme=SCHEME,
            ignore=IGNORE,
        ),
    ]

if ALGO == "GPTQ":
    recipe = [
        GPTQModifier(
            targets="Linear",
            scheme=SCHEME,
            ignore=IGNORE,
        ),
    ]

if ALGO == "IMAX-GPTQ":
    scheme = preset_name_to_scheme(SCHEME, ["Linear"])
    scheme.weights.observer = "imatrix_mse"

    recipe = [
        IMatrixGatherer(
            ignore=IGNORE,
        ),
        GPTQModifier(
            config_groups={"group_0": scheme},
            ignore=IGNORE,
        ),
    ]

if ALGO == "AutoRound":
    recipe = [
        AutoRoundModifier(
            targets="Linear",
            scheme=SCHEME,
            ignore=IGNORE,
            iters=200,
        ),
    ]

if recipe is None:
    print(f"unknown algo: {ALGO}")
    exit(1)

#
# Handle Data
#


def preprocess_function(example):
    messages = [
        {"role": m["role"], "content": [{"type": "text", "text": m["content"]}]}
        for m in example["messages"]
    ]
    return processor.apply_chat_template(
        messages,
        tokenize=True,
        return_dict=True,
        add_generation_prompt=False,
        processor_kwargs={
            "return_tensors": "pt",
            "padding": False,
            "truncation": True,
            "max_length": MAX_SEQUENCE_LENGTH,
            "add_special_tokens": False,
        },
    )


ds = ds.map(preprocess_function, batched=False, remove_columns=ds.column_names)


def data_collator(batch):
    assert len(batch) == 1
    return {key: torch.tensor(value) for key, value in batch[0].items()}


# Apply quantization.
oneshot(
    model=model,
    recipe=recipe,
    pipeline="sequential",
    dataset=ds,
    max_seq_length=MAX_SEQUENCE_LENGTH,
    num_calibration_samples=NUM_CALIBRATION_SAMPLES,
    # moe_calibrate_all_experts=True,
    data_collator=data_collator,
    # disable shuffling to get slightly better mmlu score
    shuffle_calibration_samples=False,
)

# Save to disk in compressed-tensors format.
model.save_pretrained(SAVE_DIR, max_shard_size="8GB")
processor.save_pretrained(SAVE_DIR)

# MTP layers are excluded from the model through Qwen3_5ForConditionalGeneration
# Save them as-is from the original checkpoint into the quantized output.
save_mtp_tensors_to_checkpoint(source_model=MODEL_ID, dest_dir=SAVE_DIR)
