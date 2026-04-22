"""Run evaluation using llm-os-eval-core framework.

Usage:
    python eval/run_eval.py --model MODEL_NAME --base-url http://localhost:8000/v1
"""
from __future__ import annotations

import argparse
from pathlib import Path

from llm_os_eval.runners.vllm_runner import VLLMRunner
from llm_os_eval.graders.text2sql import Text2SQLEvaluator


def main():
    parser = argparse.ArgumentParser(description="Run Text2SQL evaluation")
    parser.add_argument("--model", required=True)
    parser.add_argument("--base-url", default="http://localhost:8000/v1")
    parser.add_argument("--samples", default="eval/internal/v0.jsonl")
    parser.add_argument("--output", default=None)
    parser.add_argument("--checkpoint", default="base", help="Checkpoint name")
    args = parser.parse_args()

    runner = VLLMRunner(base_url=args.base_url, model_name=args.model)
    evaluator = Text2SQLEvaluator(
        runner=runner, model_name=args.model, checkpoint_name=args.checkpoint
    )
    samples = evaluator.load_jsonl(args.samples)

    output = args.output or f"eval/results/{args.model.replace('/', '_')}_v0.jsonl"
    Path(output).parent.mkdir(parents=True, exist_ok=True)

    results = []
    for sample in samples:
        result = evaluator.run_one(sample)
        results.append(result)
        print(f"  {sample.sample_id}: success={result.final_success}")

    evaluator.save_results(results, output)
    print(f"Saved {len(results)} results to {output}")

    success = sum(1 for r in results if r.final_success)
    rate = success / len(results) * 100 if results else 0
    print(f"Success rate: {success}/{len(results)} ({rate:.1f}%)")


if __name__ == "__main__":
    main()
