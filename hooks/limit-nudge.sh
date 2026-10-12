#!/usr/bin/env bash
# UserPromptSubmit hook: deterministic Step 5 trigger.
# Silent below WARN_PCT; above it, injects a context note on every prompt.
set -uo pipefail
feed="$HOME/.claude/budget-pilot/usage-live.json"
[ -f ".budget/config" ] && . ".budget/config"
warn="${WARN_PCT:-80}"
[ -f "$feed" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

get() { jq -r "($1 // empty)" "$feed" 2>/dev/null; }
h5=$(get '.rate_limits.five_hour.used_percentage // .rate_limits.five_hour.used_percent // .rateLimits.fiveHour.usedPercent')
wk=$(get '.rate_limits.seven_day.used_percentage // .rate_limits.weekly.used_percent // .rateLimits.weekly.usedPercent')

trip=""
for pair in "5-hour:$h5" "weekly:$wk"; do
  name="${pair%%:*}"; val="${pair#*:}"
  case "$val" in (''|*[!0-9.]*) continue;; esac
  if awk "BEGIN{exit !($val >= $warn)}"; then trip="$name window at ${val}%"; break; fi
done
[ -z "$trip" ] && exit 0

cat <<EOT
[budget-pilot] Official usage: ${trip} (warn threshold ${warn}%). Before doing
anything else, run Budget Pilot Step 5: update .budget/STATE.md, project
remaining work against remaining headroom, and offer HANDOFF / DOWNSHIFT /
CONTINUE. Do not pick for the user.
EOT
exit 0
