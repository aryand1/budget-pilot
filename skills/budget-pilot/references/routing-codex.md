# OpenAI Codex

Delegation: no bundled subagents here. Emulate by batching exploration into
single passes and keeping intermediate output terse.
Usage view: `/status`; session logs under `~/.codex/sessions/` include
token counts and rate-limit status, so `scripts/usage.sh` reads real
headroom on this tool.
Downshift: ask the user to switch the session model with `/model` for the
remaining routine phases.
