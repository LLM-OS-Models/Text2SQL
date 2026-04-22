from __future__ import annotations


from pathlib import Path
from unittest.mock import MagicMock

from llm_os_eval.schemas.sample import EvalSample
from llm_os_eval.schemas.result import EvalResult
from llm_os_eval.graders.text2sql import Text2SQLEvaluator

SAMPLES_PATH = Path(__file__).parent.parent / "eval" / "internal" / "v0.jsonl"


def _load_samples():
    samples = []
    with open(SAMPLES_PATH) as f:
        for line in f:
            line = line.strip()
            if line:
                samples.append(EvalSample.model_validate_json(line))
    return samples


def _make_runner_mock(response_text=""):
    runner = MagicMock()
    runner.generate.return_value = {
        "text": response_text,
        "tool_calls": [],
        "latency_ms": 100,
        "input_tokens": 10,
        "output_tokens": 20,
    }
    return runner


class TestSchemaValidation:
    def test_jsonl_schema_valid(self):
        samples = _load_samples()
        assert len(samples) >= 2
        for s in samples:
            assert s.task_type == "text2sql"
            assert s.difficulty in ("easy", "medium", "hard")
            assert s.user_query


class TestGraderIntegration:
    def setup_method(self):
        self.samples = _load_samples()
        self.runner = _make_runner_mock()
        self.evaluator = Text2SQLEvaluator(
            runner=self.runner, model_name="test", checkpoint_name="base"
        )

    def test_build_prompt(self):
        for sample in self.samples:
            sys_prompt, user_prompt = self.evaluator.build_prompt(sample)
            assert sample.user_query in user_prompt

    def test_grade_returns_metrics(self):
        sample = self.samples[0]
        self.runner.generate.return_value = {
            "text": "```sql\nSELECT category FROM products\n```",
            "tool_calls": [],
            "latency_ms": 100,
            "input_tokens": 10,
            "output_tokens": 20,
        }
        result = self.evaluator.run_one(sample)

        assert "parse_success" in result.metric_values
        assert "execution_success" in result.metric_values
        assert "result_accuracy" in result.metric_values
        assert "schema_link_error" in result.metric_values
        assert result.metric_values["parse_success"] == 1.0
