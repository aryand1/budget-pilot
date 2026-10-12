#!/usr/bin/env bash
# Budget Pilot statusline: captures Claude Code's official usage payload.
# Claude Code pipes a JSON status object here every turn; the raw dump is
# the contract, the parsed display is best-effort (field names shift across
# versions). Limits are account-level, so the feed lives in $HOME.
set -uo pipefail
dir="$HOME/.claude/budget-pilot"
mkdir -p "$dir"
payload="$(cat)"
printf '%s' "$payload" > "$dir/usage-live.json"
date +%s > "$dir/usage-live.ts"

# Chain a pre-existing statusline so the user loses nothing
if [ -n "${BUDGET_PILOT_CHAIN:-}" ]; then
  printf '%s' "$payload" | eval "$BUDGET_PILOT_CHAIN"
  exit 0
fi

if command -v jq >/dev/null 2>&1; then
  printf '%s' "$payload" | jq -r '
    def pct(x): if x == null then "?" else (x|floor|tostring)+"%" end;
    (.model.display_name // "claude")
    + "  5h " + pct(.rate_limits.five_hour.used_percentage // .rate_limits.five_hour.used_percent // .rateLimits.fiveHour.usedPercent)
    + "  wk " + pct(.rate_limits.seven_day.used_percentage // .rate_limits.weekly.used_percent // .rateLimits.weekly.usedPercent)
  ' 2>/dev/null || echo "budget-pilot: feed captured"
else
  echo "budget-pilot: feed captured"
fi
