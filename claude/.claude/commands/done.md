---
description: Save session learnings to memory.
---

Review the entire conversation for durable learnings worth persisting: tooling facts, hook behaviors, project conventions, patterns, gotchas, model preferences, CLI tricks.

For each learning, write it to the correct file under `~/.claude/memory/`:

- `~/.claude/memory/general.md` — cross-project facts: environment, OS, model defaults, shell setup, user preferences
- `~/.claude/memory/tools/{tool}.md` — tool-specific configs, CLI patterns, workarounds (one file per tool)
- `~/.claude/memory/domain/{topic}.md` — domain knowledge (one file per topic)
- `~/.claude/projects/{project}/memory/MEMORY.md` — project-specific notes (use the mapped path, e.g. `-Users-bharat--dotfiles` for this repo)

Entry format: `- [YYYY-MM-DD] What. Why.`

After writing entries:

1. If any new files were created, add them to `~/.claude/memory/memory.md` index with a one-line description
2. If nothing durable was learned this session, say so explicitly — do not write empty entries
