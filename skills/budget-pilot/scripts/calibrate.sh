#!/usr/bin/env bash
# Auto-calibrate BLOCK_BUDGET_TOKENS from local history.
# Only needed where the official feed is absent (Codex, Gemini CLI, etc.).
# Method: largest observed 5-hour block total is a floor for your plan limit.
set -uo pipefail
command -v npx >/dev/null 2>&1 || { echo "needs npx"; exit 1; }
command -v jq  >/dev/null 2>&1 || { echo "needs jq"; exit 1; }

max=$(npx -y ccusage@latest blocks --json 2>/dev/null \
  | jq -r '[.. | objects | .totalTokens? // empty | numbers] | max // empty')
case "${max:-}" in (''|null|*[!0-9]*)
  echo "no block history found; keep the manual ceiling"; exit 1;;
esac

mkdir -p .budget
if [ -f .budget/config ] && grep -q '^BLOCK_BUDGET_TOKENS=' .budget/config; then
  sed -i.bak "s/^BLOCK_BUDGET_TOKENS=.*/BLOCK_BUDGET_TOKENS=$max  # auto-calibrated $(date +%F)/" .budget/config
else
  printf 'BLOCK_BUDGET_TOKENS=%s  # auto-calibrated %s\n' "$max" "$(date +%F)" >> .budget/config
fi
echo "ceiling set to $max tokens (largest observed block; a floor, not exact)"
