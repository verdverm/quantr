ALGOS := \
	simp \
	gptq \

SCHEMES := \
	nvfp4 \
	nvfp4a16 \

.PHONY: FORCE
FORCE:;

uv.sync: uv.sync.quant uv.sync.evals
uv.sync.quant: FORCE
	UV_CONCURRENT_BUILDS=1 MAX_JOBS=1 uv sync --project quant
uv.sync.evals: FORCE
	UV_CONCURRENT_BUILDS=1 MAX_JOBS=1 uv sync --project evals
uv.sync.clean:
	rm -rf quant/.venv evals/.venv

qwen.gen: FORCE
	./gen/run.sh

define QWEN_QUANT_RULE
qwen.quant.$(1).$(2): FORCE
	uv run --project quant quant/qwen36-27b.py --algo $(shell echo $(1) | tr a-z A-Z) --scheme $(shell echo $(2) | tr a-z A-Z)
endef
$(foreach algo,$(ALGOS),$(foreach scheme,$(SCHEMES),$(eval $(call QWEN_QUANT_RULE,$(algo),$(scheme)))))
QWEN_QUANT_TARGETS := $(foreach algo,$(ALGOS),$(foreach scheme,$(SCHEMES),qwen.quant.$(algo).$(scheme)))
qwen.quant: $(QWEN_QUANT_TARGETS)

define QWEN_EVALS_RULE
qwen.evals.$(1).$(2): FORCE
	uv run --project evals evals/qwen36-27b.sh $(1) $(shell echo $(2) | sed 's/a16/16/')
endef
$(foreach algo,$(ALGOS),$(foreach scheme,$(SCHEMES),$(eval $(call QWEN_EVALS_RULE,$(algo),$(scheme)))))
QWEN_EVALS_TARGETS := $(foreach algo,$(ALGOS),$(foreach scheme,$(SCHEMES),qwen.evals.$(algo).$(scheme)))
qwen.evals: $(QWEN_EVALS_TARGETS)