---
description: Wire Budget Pilot's official-usage feed into Claude Code and calibrate the fallback ceiling. Run once after installing the plugin.
---

Do the following, asking the user before each file edit:

1. Back up `~/.claude/settings.json` to `~/.claude/backups/budget-pilot-<timestamp>.json`.
2. Resolve this plugin's installed path, then set `statusLine.command` in
   `~/.claude/settings.json` to its `hooks/statusline.sh`. If a statusLine
   already exists, preserve it by putting its old command in a
   `BUDGET_PILOT_CHAIN` env entry on the new one, so it still runs.
3. Confirm via `/hooks` that this plugin's UserPromptSubmit hook is active.
4. Run `skills/budget-pilot/scripts/calibrate.sh` and show the result,
   noting it only matters for non-Claude-Code tools.
5. Tell the user: the feed file is `~/.claude/budget-pilot/usage-live.json`,
   it populates after the first API response of a session, and the nudge
   threshold is `WARN_PCT` in `.budget/config` (default 80).
