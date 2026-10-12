#!/usr/bin/env bash
# Tokens used (from local agent logs) vs your configured budget.
# Consumption is read automatically; remaining plan quota is not exposed by
# most tools, so set your own ceiling once in .budget/config.
set -uo pipefail
[ -f ".budget/config" ] && . ".budget/config"

echo "== tokens used (local logs) =="
if command -v npx >/dev/null 2>&1; then
  npx -y ccusage@latest blocks 2>/dev/null | tail -20 \
    || npx -y ccusage@latest session 2>/dev/null | tail -20 \
    || echo "no local usage logs found"
else
  echo "npx not found; check inside your tool: Claude Code /usage, Codex /status, Gemini CLI /stats"
fi

echo "== budget =="
if [ -n "${BLOCK_BUDGET_TOKENS:-}" ]; then
  echo "configured block ceiling: ${BLOCK_BUDGET_TOKENS} tokens"
else
  echo "no ceiling set; add BLOCK_BUDGET_TOKENS=<n> to .budget/config"
fi
