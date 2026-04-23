# Pilot Run Sheet: Text2SQL

## Objective

- small student가 deterministic SQL generation에서 baseline을 유지하는지 확인한다.
- teacher 대비 성능 손실이 어디서 발생하는지 split 단위로 본다.

## Run IDs

- `SQL-P0`: 데이터 복구 완료 여부 검증
- `SQL-P1`: `Qwen3-4B` QLoRA baseline
- `SQL-P2`: `Qwen3-8B` QLoRA comparator
- `SQL-P3`: long-context ablation

## Dataset Gate

- placeholder SQL `0`
- DB missing `0`
- schema docs missing `0`
- split:
  - simple select
  - aggregation
  - join
  - window / subquery
  - business-rule hard set

## Model Matrix

| Run ID | Model | Context | Rank | Purpose |
|---|---|---:|---:|---|
| SQL-P1 | `Qwen3-4B` | 4096 | 32 | primary student |
| SQL-P2 | `Qwen3-8B` | 4096 | 32 | medium comparator |
| SQL-P3 | `Qwen3-4B` | 8192 | 32 | schema long-context ablation |

## Fixed Decisions

- chat template: official `Qwen3`
- decoding target: SQL only
- reasoning mode: off
- first stage: `QLoRA` only
- reward tuning: pilot 승리 후 검토

## Primary Metrics

- `parse_success`
- `schema_link_error`
- `execution_success`
- `result_accuracy`

## Slice Metrics

- join-heavy split
- window/subquery split
- long schema split
- ambiguous schema-link split

## Accept

- `execution_success >= 0.95`
- `result_accuracy >= 0.90`
- `Qwen3-4B`가 `v0` baseline 대비 명확한 퇴보가 없음

## Reject

- placeholder나 missing DB가 조금이라도 남음
- hard split에서 only-short-context behavior가 심함
- formatting error가 아니라 SQL logic error가 다수임

## Review Questions

1. 실패가 schema linking인지 aggregation logic인지 구분되는가
2. 4B와 8B 차이가 hard split에만 집중되는가
3. long-context 이득이 실제로 존재하는가
