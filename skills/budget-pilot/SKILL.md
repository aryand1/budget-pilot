---
name: budget-pilot
description: Use at the start of any multi-step task, whether coding, research, data analysis, writing, or document production, before planning large or long-running work, when the user mentions token budgets, usage limits, or running out of tokens mid-task, or when resuming an interrupted task. Sizes the task into a tier, warns before expensive work, checkpoints at every phase boundary, and routes bulk work to cheaper models where the host tool allows it.
---

# Budget Pilot

Estimate before you act. Checkpoint at every phase boundary. Spend the
expensive model only where it earns its cost.

## Step 0: Resume check

If `.budget/STATE.md` exists and describes the current task, resume from the
first unchecked phase. Do not replan completed phases.

## Step 1: Assign a tier

GATE: produce no plan and no output until the tier is reported.

When the scope is known, run `scripts/estimate.sh <paths>`. Then assign:

| Tier | Signals | Rough working budget |
|------|---------|----------------------|
| S  | 1-2 files or sources, no new structure | under 50k tokens |
| M  | 3-10 files or sources, known pattern, a few revision or test cycles | 50k-200k |
| L  | 10-40 files, long documents, or a new subsystem; repeated cycles | 200k-1M |
| XL | Repo-wide or project-wide work, many unknowns | over 1M |

Report the tier as a range, not a promise: one failed cycle can multiply
cost. For tier L or XL, run `scripts/usage.sh` and compare tokens used
against the configured ceiling. If the script reports nothing, ask the user
to check the usage view named in the tool reference. Never start an XL task
without explicit go-ahead.

## Step 2: Plan in phases

Plan with the strongest available model. Break tier M+ work into 3-7 phases,
each independently completable, and state where each checkpoint lands.

## Step 3: Delegate labor, not decisions

Structure, design, tricky debugging or synthesis, and final review stay with
the strongest model. Bulk work (searching, reading many files or sources,
running tests, mechanical edits or reformatting from an exact spec) goes to
the cheapest capable model. Read the matching reference once:

- Claude Code: `references/routing-claude-code.md`
- OpenAI Codex: `references/routing-codex.md`
- Gemini CLI: `references/routing-gemini-cli.md`
- Any other tool: no delegation mechanism; emulate by reading sources in one
  batched pass and keeping intermediate output terse.

## Step 4: Checkpoint at every phase boundary

At each phase boundary, and immediately upon any usage-limit warning from
the host tool, overwrite `.budget/STATE.md`:

    # Task: <one line>
    Tier: <S/M/L/XL> | Started: <date> | Tool: <host tool>
    ## Phases
    - [x] 1. <phase> (done: <one-line result>)
    - [ ] 2. <phase>  <- NEXT
    ## Decisions
    - <decision>: <reason>
    ## Files touched
    - <path> (<what changed>)
    ## Next action
    <exact first step of the next phase>

Keep it under 40 lines. This file is tool-neutral: a task interrupted in one
agent resumes in any other via Step 0.

## Step 5: Project forward; warn before the wall

At every phase boundary, after updating STATE.md, establish headroom:

1. OFFICIAL: if `~/.claude/budget-pilot/usage-live.json` exists, read the
   5-hour and weekly used-percent and reset fields from it. Remaining
   headroom comes straight from those numbers; no ceiling involved.
2. FALLBACK: otherwise run `scripts/usage.sh` (tokens used from local logs
   vs the ceiling in `.budget/config`; run `scripts/calibrate.sh` once to
   set that ceiling from history).

Then project:

    burn rate = usage this task / phases completed
    projected = burn rate x phases left x 1.3  (margin for failed cycles)

If projected demand exceeds remaining headroom, or a `[budget-pilot]`
nudge appears in context (treat it as this step's trigger, even
mid-phase), STOP and say:

    Heads up: this task may not finish within your remaining limit
    (~<remaining> tokens left, ~<projected> still needed). Pick one:
    1. HANDOFF: I write a transfer summary you can paste into another
       model or tool, and we stop cleanly here.
    2. DOWNSHIFT: I route the remaining routine phases to a cheaper model
       and keep the strong model only for review.
    3. CONTINUE: keep going as-is; I will checkpoint after every phase so
       a hard stop loses nothing.

Do not pick for the user. If they choose HANDOFF, follow
`references/handoff-template.md`. If DOWNSHIFT, use the delegation
mechanics in the tool reference. If CONTINUE, tighten checkpoints to every
phase and repeat this projection at each one. If no ceiling is configured,
skip the projection and rely on the host tool's own usage warnings.
