# Claude Code

Delegation: this plugin ships three subagents. Delegate by name with a
self-contained brief and require a compact report:
- `scout` (haiku): search, locate, read many files, summarize docs/logs.
- `runner` (haiku): run builds/tests/linters, report only failing lines.
- `grunt-editor` (sonnet): mechanical multi-file edits from an exact spec.
Keep planning and review in the main session on the strongest model.

Usage view: `/usage`; `scripts/usage.sh` reads local transcript logs.
Downshift: route remaining routine phases to the subagents above, or ask
the user to switch the session model with `/model`.
