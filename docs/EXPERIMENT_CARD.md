# Experiment Card: Text2SQL

## task_type
`text2sql`

## 목적
문서 근거와 스키마 정보를 함께 활용해 실행 가능한 SQL을 생성하고, 최종 결과 정확도로 성능을 평가한다.

## 핵심 지표
- parse_success — SQL 추출 성공 여부 (0/1)
- schema_link_error — 스키마 링킹 오류 여부 (0=정상, 1=오류)
- execution_success — SQL 실행 성공 여부 (0/1)
- result_accuracy — 실행 결과 해시 일치 여부 (0/1)

## 평가 실행
```bash
bash eval/run_phase1.sh
bash eval/run_phase2.sh
```

## 평가 모델
- Phase 1: 8개 모델
- Phase 2: Qwen3.6-27B + LFM 모델
