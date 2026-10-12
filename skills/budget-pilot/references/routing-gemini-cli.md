# Gemini CLI

Delegation: no bundled subagents here. Emulate by batching exploration into
single passes and keeping intermediate output terse.
Usage view: `/stats` shows live token spend; headless runs with JSON output
emit a full stats object.
Downshift: ask the user to restart the session with `gemini -m <model>` (or
the in-session model switcher if available) for the remaining routine
phases.
