#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

python3 "$ROOT/scripts/train_unsloth_chat_sft.py" \
  --config "$ROOT/Text2SQL/train/sft/qwen3_4b_qlora.json" \
  "$@"
