# Budget Pilot

A cross-tool agent skill that keeps long tasks from dying mid-flight when
you hit your plan's usage limit. It sizes a task before work starts, tracks
burn from local session logs, warns you before the wall with options instead
of after it with nothing, and checkpoints progress so any model or tool can
pick up where another stopped.

Works with Claude Code, OpenAI Codex, Gemini CLI, and any agent that reads
the open Agent Skills format (SKILL.md). A paste-in version covers ChatGPT,
Gemini, and Claude web apps.

## What it does

- Assigns every multi-step task a tier (S/M/L/XL) with a rough token range
  before any planning happens. Tier L and XL need your go-ahead.
- Splits tier M+ work into 3-7 phases and writes a checkpoint file,
  `.budget/STATE.md`, at every phase boundary.
- At each boundary, reads tokens used from local logs, projects the burn
  rate across remaining phases, and if the projection crosses your remaining
  headroom, stops and asks: HANDOFF (transfer summary for another model),
  DOWNSHIFT (route remaining routine phases to a cheaper model), or
  CONTINUE (with tightened checkpoints).
- Resumes in one prompt. The state file is tool-neutral, so a task
  interrupted in Claude Code can continue in Codex or Gemini CLI.
- Delegates bulk work (search, bulk reads, test runs, mechanical edits) to
  cheaper models where the host tool supports it.

## Layout

    budget-pilot/
    ├── skills/budget-pilot/
    │   ├── SKILL.md                      # the skill, open-standard format
    │   ├── scripts/
    │   │   ├── estimate.sh               # pre-task input-size estimate
    │   │   └── usage.sh                  # tokens used vs your ceiling
    │   └── references/
    │       ├── routing-claude-code.md
    │       ├── routing-codex.md
    │       ├── routing-gemini-cli.md
    │       ├── handoff-template.md       # the HANDOFF transfer summary
    │       └── chat-apps-prompt.md       # paste-in block for web apps
    ├── agents/                           # Claude Code subagents (haiku/sonnet)
    ├── .claude-plugin/                   # plugin.json + marketplace.json
    ├── .budget/config.example
    ├── gemini-extension.json
    ├── AGENTS.md                         # fallback for tools without skills
    └── README.md

## Install

Claude Code (full experience, includes the cheap-model subagents):

    claude plugin marketplace add aryand1/budget-pilot
    claude plugin install budget-pilot@budget-pilot

Any agent that supports the Agent Skills standard (Codex, Gemini CLI,
Cursor, Copilot CLI, and others):

    npx skills add aryand1/budget-pilot

Gemini CLI, as an extension instead:

    gemini extensions install https://github.com/aryand1/budget-pilot

Manual copy also works: put `skills/budget-pilot/` into your tool's skills
directory (`.claude/skills/`, `.agents/skills/` or `.codex/skills/`,
`.gemini/skills/`, `.cursor/skills/`). These conventions are young and still
moving; if a path fails, check your tool's skills documentation.

Tools with no skill support: point the agent at `AGENTS.md`.

ChatGPT, Gemini, or Claude web apps: copy the block from
`skills/budget-pilot/references/chat-apps-prompt.md` into your custom
instructions. Web apps expose no token meters to the model, so that version
budgets replies instead of tokens.

Invoke it explicitly at the start of big tasks (for example,
`/budget-pilot` in Claude Code, `$budget-pilot` in Codex). Auto-invocation
from the description usually works, but a model can skip a relevant skill,
and a budget guard that silently fails to load is worthless. Typing the name
costs you two seconds and removes that risk.

## Calibrate your ceiling

The mid-flight warning needs to know your limit, and most plans don't
expose that number to scripts. Local logs give tokens used; you supply
tokens allowed, once:

1. Copy the config: `cp .budget/config.example .budget/config`
2. Work a normal session for a while.
3. Open your tool's usage view (Claude Code `/usage`, Codex `/status`,
   Gemini CLI `/stats`) and note the percentage of your window used.
4. Run `skills/budget-pilot/scripts/usage.sh` and note tokens used.
5. Your ceiling is roughly tokens used divided by the fraction used.
   Logs show 900k and the tool says 50%? Write
   `BLOCK_BUDGET_TOKENS=1800000`.
6. Re-tune when your plan changes or warnings start feeling early or late.

Without a ceiling the skill still runs; it falls back to asking you to
check the usage view at the L/XL gates, and the mid-flight projection is
disabled.

## Model routing

Full routing exists only in Claude Code, where the bundled subagents load:
`scout` (haiku) for search and bulk reads, `runner` (haiku) for builds and
tests, `grunt-editor` (sonnet) for mechanical edits from an exact spec.
Elsewhere the skill degrades to batching discipline plus a suggestion to
switch the session model for routine phases (`/model` in Codex,
`gemini -m` in Gemini CLI). This is the real cost of being cross-platform
and the README would rather tell you than imply parity.

## Files it writes

`.budget/STATE.md` is the checkpoint, overwritten at each phase boundary,
never appended. Commit it if you want handoff across machines; gitignore it
if you don't. `.budget/config` is yours and should stay out of version
control if you consider your plan details private.

## Known limits

- Tier estimates are ranges. One failing test loop can multiply cost, and
  the skill says so rather than pretending precision.
- The ceiling is an approximation. Window resets and what exactly counts
  against a limit vary by tool and change over time.
- `usage.sh` needs `npx` (it runs ccusage against local logs). Codex logs
  are the only ones that also carry rate-limit status directly.
- In web apps nothing is measurable, so the paste-in version controls the
  one lever the model has: reply count and reply density.

## Claude Code companion setting

`autoContinueAtUsageLimit` (toggle "Continue automatically at usage limit" in
`/config`) makes a session wait out a limit reset and then
continue. Paired with the checkpoint file, a hard stop costs you nothing
but time.

## Develop

    claude plugin validate .          # catch manifest mistakes
    claude --plugin-dir . # load for one session before pushing

MIT license. Issues and tier-threshold tuning reports welcome; the 6x
multiplier in estimate.sh and the 1.3 margin in the projection are
heuristics that improve with real-world data.
