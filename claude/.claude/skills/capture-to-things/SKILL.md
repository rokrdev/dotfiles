---
name: capture-to-things
description: Use when tasks, action items, or next steps are identified in any context — planning sessions, code discussions, or implementation plans. Also use when the user says to add tasks to Things.
---

# Capture to Things

## Overview

Things app is the **source of truth for all actionable tasks**. Use the **Things CLI** to capture tasks directly from conversations. Whenever tasks surface — from planning sessions, notes, or discussions — they go into the right Things project.

## When to Use

- Tasks or next steps are identified during any session
- User says "add to Things", "track this in Things", or similar
- A plan is written and produces a list of next actions

**Do NOT use when:**
- The item is reference material, not an action
- A task already exists in Things (check first)

## Things CLI Reference

The Things CLI is located at `/opt/homebrew/bin/things`. All commands below use this binary.

### Add to Inbox (no project)

```bash
things add "Clear, actionable task title"
```

### Add to Inbox with Notes

```bash
things add "Task title" --notes="Context or reference information"
```

### Add to Specific Project

```bash
things add "Task title" --list="Project Name"
```

### Add to Project with Notes

```bash
things add "Task title" --list="Project Name" --notes="Context here"
```

### Add with Tags

```bash
things add "Task title" --list="Project Name" --tags="tag1,tag2"
```

### Add with Deadline

```bash
things add "Task title" --list="Project Name" --deadline="2026-04-15"
```

### Add with Schedule (when)

```bash
# Possible values: today, tomorrow, evening, anytime, someday
# Or a date: 2026-04-15
# Or datetime with reminder: 2026-04-15T14:30:00
things add "Task title" --list="Project Name" --when="today"
```

### Add to Project with Heading

```bash
things add "Task title" --list="Project Name" --heading="Phase 1"
```

### Add with Multiple Checklist Items

```bash
things add "Task title" --list="Project Name" \
  --checklist-item="Subtask 1" \
  --checklist-item="Subtask 2"
```

### Create New Project

```bash
things add-project "Project Name" --notes="Stack/Tool: ...\nRepo: ~/projects/..."
```

### Full Example

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
# List all projects to find a match
things projects

# If no match, create a new project
things add-project "New Project" --notes="Stack/Tool: ...\nRepo: ..."
```

- Match loosely by project name when one exists
- Use `add-project` if no suitable project exists
- Never duplicate a project

### 2. Add Todos

```bash
things add "Clear, actionable task title" --list="Project Name"
```

- One CLI call per task
- Title must be a concrete action, not a vague label
- Add `--notes` when the task needs context (e.g. "Deferred — needs live TWS running")
- Use `--when="today"` only if the user explicitly asks to schedule it
- Use `--heading` to organize tasks within a project
- Use `--tags` to label tasks (comma-separated)

## Quick Reference

| Task | CLI Command |
|------|-------------|
| List all projects | `things projects` |
| List today's tasks | `things today` |
| Create a new project | `things add-project "Name" --notes="..."` |
| Add task to inbox | `things add "Title"` |
| Add task to project | `things add "Title" --list="Project"` |
| Add with notes | `things add "Title" --list="Project" --notes="..."` |
| Add with tags | `things add "Title" --list="Project" --tags="tag1,tag2"` |
| Add with deadline | `things add "Title" --list="Project" --deadline="2026-04-15"` |
| Add with checklist | `things add "Title" --checklist-item="Item 1" --checklist-item="Item 2"` |
| Search tasks | `things search "query"` |

## Common Mistakes

- Creating a duplicate project instead of checking `things projects` first
- Omitting `--list` and accidentally creating inbox tasks instead of project tasks
- Using vague task titles like "Phase 2" — always use a concrete action
- Scheduling tasks as `--when="today"` without the user asking for it
- Forgetting to add `--notes` for context when needed
