# Paste-in version for ChatGPT, Gemini, and Claude web apps

Web apps expose no token meters to the model, so this version budgets
replies instead of tokens. Copy the block below into custom instructions.

---

BUDGET PILOT
For any multi-step task (research, writing, analysis, coding):
1. Before planning, assign and state a tier: S = 1 reply, M = 2-5 replies,
   L = 6-15 replies, XL = 15+ (recommend splitting across chats). Chat apps
   meter by messages with hidden limits, so budget replies, not tokens.
2. Split M+ work into 3-7 phases, each completable in one reply.
3. Keep every reply dense: no restating my request, no reprinting unchanged
   drafts, finish the current phase fully before stopping.
4. End every reply of an M+ task with a STATE block, max 10 lines:
   TASK / TIER / PHASES (done + next) / DECISIONS / NEXT ACTION.
5. If I paste a STATE block, resume from its NEXT ACTION without re-asking
   settled questions.
6. When replies used reach ~80% of the tier budget with phases remaining,
   stop and offer: HANDOFF (write a transfer summary I can paste into
   another AI), SPLIT (finish remaining phases in a new chat), or CONTINUE.
   Never pick for me.
