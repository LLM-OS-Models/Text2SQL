#!/bin/bash
set -e
cd "$(dirname "$0")"
mkdir -p logs results

TASK_TYPE="text2sql"
EVAL_PATH="eval/internal/v1.jsonl"
EVAL_SCRIPT="eval_runner.py"

echo "=== Text2SQL Phase 1: $(date) ==="

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

run_model 0 "Qwen/Qwen3.5-4B" &
PIDS+=($!); LABELS+=("GPU0 Qwen3.5-4B")
run_model 1 "google/gemma-4-E2B-it" &
PIDS+=($!); LABELS+=("GPU1 gemma-E2B")
run_model 2 "google/gemma-4-E4B-it" &
PIDS+=($!); LABELS+=("GPU2 gemma-E4B")
run_model 3 "Qwen/Qwen3.5-9B-text-only" &
PIDS+=($!); LABELS+=("GPU3 Qwen3.5-9B")
run_model 4 "principled-intelligence/Qwen3.5-2B-text-only" &
PIDS+=($!); LABELS+=("GPU4 Qwen3.5-2B")
run_model 5 "Qwen/Qwen3.6-35B-A3B" &
PIDS+=($!); LABELS+=("GPU5 Qwen3.6-35B")
run_model 6 "Qwen/Qwen3.5-27B" &
PIDS+=($!); LABELS+=("GPU6 Qwen3.5-27B")
run_model 7 "LiquidAI/LFM2-2.6B" &
PIDS+=($!); LABELS+=("GPU7 LFM2-2.6B")

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

echo "=== Phase 1 done at $(date) (failures: $FAIL / ${#PIDS[@]}) ==="
python3 summarize.py --results-dir results
