# Labeling Guide: Text2SQL

## Goal

- 질문을 실행 가능한 SQL과 연결한다.
- gold label은 결과가 맞는 SQL이지, 그럴듯한 SQL이 아니다.

## Required Fields

- `db_path`
- `schema_doc_paths`
- `gold_sql`
- `execution_result_hash`
- `task_family`

## Labeling Rules

- SQL은 한 개만 gold로 저장한다.
- 동일 결과를 내는 변형 SQL이 여러 개여도 canonical SQL 하나를 정한다.
- `SELECT * FROM table WHERE condition;` 같은 placeholder는 즉시 폐기한다.
- alias 남용보다 읽기 가능한 canonical form을 우선한다.

## Task Family Tags

- `select`
- `aggregation`
- `join`
- `window`
- `business_rule`

복합 샘플은 주된 병목 기준으로 하나를 main tag로 둔다.

## Verification

1. DB open
2. SQL parse
3. SQL execute
4. result hash 기록
5. schema link 오류 여부 확인

## Common Mistakes

- schema docs와 실제 DB 컬럼이 다른데 그대로 라벨링
- 결과는 맞지만 evaluator parsing이 깨지는 다중 SQL 저장
- hard query를 easy로 분류
