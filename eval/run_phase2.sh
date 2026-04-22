#!/bin/bash
set -e
cd "$(dirname "$0")"
mkdir -p logs results

TASK_TYPE="text2sql"
EVAL_PATH="eval/internal/v1.jsonl"
EVAL_SCRIPT="eval_runner.py"

echo "=== Text2SQL Phase 2: $(date) ==="

PIDS=()
LABELS=()

run_model() {
    local gpu=$1
    local model=$2
    local logfile="logs/$(echo "$model" | tr '/' '_' | tr '[:upper:]' '[:lower:]').log"
    echo "[GPU $gpu] $model"
    CUDA_VISIBLE_DEVICES=$gpu python3 "$EVAL_SCRIPT" \
        --task-type "$TASK_TYPE" --model "$model" --gpu 0 \
        --eval-path "$EVAL_PATH" --output-dir results \
        > "$logfile" 2>&1
}

run_model 0 "Qwen/Qwen3.6-27B" &
PIDS+=($!); LABELS+=("GPU0 Qwen3.6-27B")
run_model 1 "LiquidAI/LFM2-24B-A2B" &
PIDS+=($!); LABELS+=("GPU1 LFM2-24B-A2B")
run_model 2 "LiquidAI/LFM2.5-1.2B-Instruct" &
PIDS+=($!); LABELS+=("GPU2 LFM2.5-1.2B-Instruct")

echo "PIDs: ${PIDS[*]}"
echo "Waiting..."

FAIL=0
for i in "${!PIDS[@]}"; do
    if wait "${PIDS[$i]}"; then
        echo "[OK] ${LABELS[$i]}"
    else
        echo "[FAIL] ${LABELS[$i]}"
        FAIL=$((FAIL+1))
    fi
done

echo "=== Phase 2 done at $(date) (failures: $FAIL / ${#PIDS[@]}) ==="
python3 summarize.py --results-dir results
