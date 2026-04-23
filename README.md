# Text2SQL

자연어 질문을 SQL 쿼리로 변환하고 실제 데이터베이스에서 실행하여 결과를 검증하는 평가 트랙.

스키마 문서와 DB 경로가 주어지면, 모델이 올바른 SQL을 생성하고 실행하여 기대 결과와 일치하는지 평가한다. SQL 파싱, 스키마 링킹, 실행 성공, 결과 정확도의 4단계로 세분화하여 측정한다.

## 평가 메트릭

| 메트릭 | 설명 |
|--------|------|
| `parse_success` | 모델 출력에서 유효한 SQL을 추출했는지 (0/1) |
| `schema_link_error` | 생성된 SQL이 gold 패턴과 매칭되지 않는지 (0=매칭, 1=에러) |
| `execution_success` | SQL이 DB에서 에러 없이 실행되었는지 (0/1) |
| `result_accuracy` | 실행 결과가 gold result hash와 일치하는지 (0/1) |
| `result_f1` | Soft-F1 score comparing predicted vs gold result rows (0~1) |

**성공 조건**: `result_accuracy > 0 AND result_f1 >= 0.8`

## 평가 파이프라인

1. 모델이 자연어 질문 + 스키마 정보를 받아 SQL 생성
2. `_extract_sql()`로 코드 펜스 또는 SQL 키워드 기반 추출
3. `schema_link_error`: gold 패턴 regex와 매칭 확인
4. SQLite DB에서 실제 실행
5. 결과 행을 MD5 해시로 비교

## 샘플 데이터 형식

```json
{
  "sample_id": "sql_0001",
  "user_query": "올해 1분기에 환불률이 5%를 넘은 상품군만 보여줘.",
  "artifacts": {
    "db_path": "/absolute/path/to/db/sales_v2.sqlite",
    "schema_docs": ["schema_docs/schema.md", "schema_docs/business_rules.md"]
  },
  "gold": {
    "acceptable_sql_patterns": ["SELECT.*category.*FROM", "refund.*rate.*>.*0\\.05"],
    "gold_sql": "SELECT category FROM products WHERE refund_rate > 0.05 AND quarter = 'Q1'",
    "gold_result": [["전자제품", 0.07], ["의류", 0.06]],
    "result_hash": "a8c19b"
  }
}
```

## 프로젝트 구조

```
Text2SQL/
├── README.md
├── pyproject.toml
├── databases/              # 기존 DB (hr_employees, ecommerce_orders)
├── eval/
│   ├── internal/
│   │   ├── v0.jsonl        # 평가 데이터셋 (2샘플)
│   │   └── db/             # 평가용 테스트 DB (sales_v2, billing_v1)
│   └── results/
├── tests/
└── data/
```

## 실행

```bash
uv sync

llm-os-eval run text2sql \
  --model Qwen/Qwen3-4B \
  --samples eval/internal/v0.jsonl \
  --output eval/results/Qwen3-4B_v0.jsonl \
  --base-url http://localhost:8001/v1
```

## 벤치마크 결과 (2026-04-23, Round 3)

| 모델 | Size | parse_success | execution_success | 성공률 |
|------|------|---------------|-------------------|--------|
| 전체 모델 | — | **100%** | 0% | 0% |

모든 모델이 SQL을 성공적으로 파싱하지만, 실제 DB 스키마와 불일치하여 실행 에러가 발생한다. 이는 모델이 테이블/컬럼 구조를 정확히 파악하지 못하기 때문이며, 스키마 문서를 프롬프트에 더 명확히 포함하면 개선 가능하다.
