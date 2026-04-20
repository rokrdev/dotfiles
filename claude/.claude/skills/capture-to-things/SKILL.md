---
name: capture-to-things
description: Use when tasks, action items, or next steps are identified in any context — planning sessions, code discussions, or implementation plans. Also use when the user says to add tasks to Things.
when_to_use: |
  - Tasks or next steps are identified during any session
  - User says "add to Things", "track this in Things", or similar
  - A plan is written and produces a list of next actions
---

# Capture to Things

## Overview

Things app is the **source of truth for all actionable tasks**. Use the **Things CLI** (`/opt/homebrew/bin/things`) to capture tasks directly from conversations — whenever tasks surface from planning sessions, notes, or discussions, they go into the right Things project.

**Do NOT use when:**
- The item is reference material, not an action
- A task already exists in Things (check first)

## Things CLI Reference

`things add` accepts any combination of these flags:

| Flag | Purpose | Example |
|------|---------|---------|
| `--list` | Target project (omit for Inbox) | `--list="Project Name"` |
| `--notes` | Context / reference info | `--notes="Context here"` |
| `--tags` | Comma-separated tags | `--tags="tag1,tag2"` |
| `--heading` | Group under a heading in the project | `--heading="Phase 1"` |
| `--deadline` | Hard due date | `--deadline="2026-04-15"` |
| `--when` | Schedule; `today`, `tomorrow`, `evening`, `anytime`, `someday`, a date `2026-04-15`, or datetime with reminder `2026-04-15T14:30:00` | `--when="today"` |
| `--checklist-item` | Subtask (repeatable) | `--checklist-item="Subtask 1" --checklist-item="Subtask 2"` |

Create a new project:

```bash
things add-project "Project Name" --notes="Stack/Tool: ...\nRepo: ~/projects/..."
```

Full example combining everything:

```bash
things add "Implement auth flow" \
  --list="Backend Refactor" \
  --heading="Phase 2" \
  --notes="Uses JWT with refresh tokens, see auth spec in docs/" \
  --tags="backend,auth" \
  --when="2026-04-10" \
  --deadline="2026-04-20"
```

## Workflow

### 1. Search for or Create the Project

```bash
things search "project name"   # faster — try first
things projects                # fall back if search misses
things add-project "New Project" --notes="Stack/Tool: ...\nRepo: ..."
```

Match loosely by project name when one exists. Never duplicate a project — only `add-project` if no suitable match.

### 2. Add Todos

```bash
things add "Clear, actionable task title" --list="Project Name"
```

- One CLI call per task
- Title must be a concrete action, not a vague label
- Add `--notes` when the task needs context (e.g. "Deferred — needs live TWS running")
- Use `--when="today"` only if the user explicitly asks to schedule it

## Quick Reference

| Task | CLI Command |
|------|-------------|
| List all projects | `things projects` |
| List today's tasks | `things today` |
| Search tasks | `things search "query"` |
| Add task to inbox | `things add "Title"` |
| Add task to project | `things add "Title" --list="Project"` |
| Create a new project | `things add-project "Name" --notes="..."` |

See the flag table above for `--notes`, `--tags`, `--deadline`, `--checklist-item`, etc.

## Common Mistakes

- Creating a duplicate project instead of checking `things projects` first
- Omitting `--list` and accidentally creating inbox tasks instead of project tasks
- Using vague task titles like "Phase 2" — always use a concrete action
- Scheduling tasks as `--when="today"` without the user asking for it
- Forgetting to add `--notes` for context when needed
