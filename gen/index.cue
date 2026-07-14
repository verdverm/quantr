@experiment(aliasv2)
package gen

import "strings"

config: {
	// flags
	model:   string | *"Qwen3.6-27B" @tag(model)
	gpu_mem: "0.8"                   @tag(gpu_mem)

	// grid
	algos: ["simp", "gptq"]
	schemes: ["nvfp4", "nvfp4a16"]

	tasks: {
		wikitext: ["wikitext"]
		gsm8k: ["gsm8k"]
		validate: ["wikitext", "gsm8k"]
	}
}

evals: [string]~(slug,_): {
	_algo:   string
	_scheme: string
	_tasks: [...string]

	model: "vllm"
	model_args: {
		pretrained:             string | *"./models/\(strings.ToLower(slug))"
		gpu_memory_utilization: string | *"0.8"
		max_length:             int | *4096
	}
	tasks:      _tasks
	limit:      32
	batch_size: 2

	output_path: string | *"./results/\(slug).json"
}

evals: {
	for task, tasks in config.tasks {
		"\(strings.ToLower(config.model))-test-baseline-\(task)": {
			model_args: {
				pretrained: "Qwen/\(config.model)"
			}
			_tasks:  tasks
		}
	}
	for _, algo in config.algos for _, scheme in config.schemes for task, tasks in config.tasks {
		let slug = "\(config.model)-\(algo)-\(scheme)-\(task)"
		(strings.ToLower(slug)): {
			_algo:   algo
			_scheme: scheme
			_tasks:  tasks
		}
	}
}
