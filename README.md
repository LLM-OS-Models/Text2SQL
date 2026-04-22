# Text2SQL

문서 근거와 스키마 정보를 바탕으로 SQL을 생성하고 실행하는 프로젝트입니다.

## 목표
- schema linking 향상
- 실행 가능한 SQL 생성
- 결과 정확도 기반 평가

## 실행
```bash
uv sync --extra dev
```

## 평가 파이프라인

### 디렉토리 구조
```
eval/
├── eval_runner.py      # → llm-os-eval-core (symlink)
├── summarize.py        # → llm-os-eval-core (symlink)
├── run_phase1.sh       # 8-GPU 병렬 평가 (소형~중형 모델)
├── run_phase2.sh       # 추가 모델 평가 (Qwen3.6-27B, LFM 계열)
└── internal/v1.jsonl   # 평가 데이터셋
data/
├── prepare_sft.py      # → llm-os-eval-core (symlink)
├── sft_train.py        # → llm-os-eval-core (symlink)
└── sft/                # SFT 학습 데이터
    ├── train.jsonl
    └── val.jsonl
```

### 실행 방법
```bash
# Phase 1: 소형~중형 모델 8종 병렬 평가
bash eval/run_phase1.sh

# Phase 2: 추가 모델 평가 (Qwen3.6-27B, LFM2-24B-A2B, LFM2.5-1.2B-Instruct)
bash eval/run_phase2.sh

# 결과 요약
python eval/summarize.py --results-dir eval/results
```

### 평가 모델

**Phase 1** (8-GPU 병렬):
- GPU0: Qwen3.5-4B
- GPU1: gemma-4-E2B-it
- GPU2: gemma-4-E4B-it
- GPU3: Qwen3.5-9B-text-only
- GPU4: Qwen3.5-2B
- GPU5: Qwen3.6-35B-A3B
- GPU6: Qwen3.5-27B
- GPU7: LFM2-2.6B

**Phase 2** (추가):
- Qwen/Qwen3.6-27B
- LiquidAI/LFM2-24B-A2B (23.84B MoE)
- LiquidAI/LFM2.5-1.2B-Instruct
