# Data Recovery Plan: Text2SQL

## Objective

- 누락 DB를 복구하고 placeholder SQL을 실행 검증된 gold SQL로 교체한다.

## Current Blockers

- placeholder SFT 다수
- train/eval DB 누락
- split metadata 불완전

## Recovery Sequence

1. 누락 DB 인벤토리 확정
2. DB 파일 복구
3. 각 샘플의 schema doc / DB 연결 확인
4. gold SQL 재작성
5. execution result hash 저장
6. split / difficulty 재태깅

## Required Outputs

- restored `databases/*.db`
- updated `train.jsonl`, `val.jsonl`
- execution hash ledger
- QA completion sheet

## Acceptance

- missing DB `0`
- placeholder SQL `0`
- execution verified sample ratio `100%`
- task family tags completion `100%`
