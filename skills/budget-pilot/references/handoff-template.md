# Handoff summary (for transferring to another model or tool)

Produce one self-contained block the user can paste anywhere. Under 60
lines. Contents, in order:

1. TASK: the goal in two sentences, including constraints the user stated.
2. STATE: the current STATE.md, verbatim.
3. CONTEXT THE FILES WON'T SHOW: decisions made in conversation, rejected
   approaches and why, gotchas discovered (flaky test, odd API behavior).
4. WORKING SET: the 3-8 files or sources that matter, each with one line
   on its role. Quote only irreplaceable snippets, max 10 lines each.
5. FIRST INSTRUCTION: the exact prompt the next model should act on.

Then update STATE.md one last time and confirm the stop.
