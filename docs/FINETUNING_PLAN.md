# Finetuning Plan: Text2SQL

## Current State

- 현재 `v0` 베이스라인은 이미 강하다.
- 하지만 SFT 데이터 30/30이 `SELECT * FROM table WHERE condition;` placeholder다.
- `v1` 평가용 DB 자산도 일부 누락되어 있다.

## Priority

- 우선순위: 최상
- 이유: 병목이 명확하고, 데이터만 바로잡히면 teacher/student 압축까지 바로 연결할 수 있다.

## Base Models

- Teacher: `Qwen/Qwen3-14B`
- Student: `Qwen/Qwen3-4B`
- Secondary student: `Qwen/Qwen3-8B`
- Comparator: `google/gemma-4-31B-it`

## Phase 0

1. placeholder SQL 30/30을 전부 폐기한다.
2. 모든 train sample에 대해 실행 검증된 gold SQL을 다시 채운다.
3. 누락된 DB를 복구하고 local path 기준으로 정규화한다.
4. dataset을 아래 split으로 나눈다.
   - simple select
   - aggregation
   - join
   - subquery / window
   - multi-hop business rule

## Phase 1

- 목표: execution-safe SQL SFT
- 권장 시작점
  - `max_seq_length=4096`
  - `per_device_train_batch_size=2`
  - `gradient_accumulation_steps=4`
  - `learning_rate=1e-4`
  - `lora_r=32`
  - `num_train_epochs=1~2`
- 첫 실험은 QLoRA로 시작하고 full fine-tuning은 보류한다.

## Phase 2

- execution reward 기반 DPO/GRPO
- reward 구성
  - `execution_success`
  - `result_accuracy`
  - `schema_link_error` inverse reward
  - unnecessary column / table penalty

## Phase 3

- schema docs가 길어질 경우 long-context 실험
- ambiguous schema linking만 따로 hard negative set으로 만든다.

## Model Notes

- `Qwen3`는 non-thinking 모드로 두고 deterministic SQL generation에 맞추는 편이 낫다.
- Unsloth 기준으로는 LoRA/QLoRA부터 시작하고, batch보다 grad accumulation을 먼저 늘리는 편이 안전하다.

## Exit Criteria

- `execution_success >= 0.95`
- `result_accuracy >= 0.9`
- hard split에서도 `result_f1 >= 0.8`
