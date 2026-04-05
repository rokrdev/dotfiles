---
name: capture-to-things
description: Use when tasks, action items, or next steps are identified in any context — planning sessions, code discussions, or implementation plans. Also use when the user says to add tasks to Things.
---

# Capture to Things

## Overview

Things app is the **source of truth for all actionable tasks**. Whenever tasks surface — from planning sessions, notes, or conversations — they go into the right Things project.

## When to Use

- Tasks or next steps are identified during any session
- User says "add to Things", "track this in Things", or similar
- A plan is written and produces a list of next actions

**Do NOT use when:**
- The item is reference material, not an action
- A task already exists in Things (check first)

## Workflow

### 1. Find or Create the Project

```
get_projects() → scan titles for a match
```

- Match loosely by project name (e.g. "Smart BAS" matches "Smart BAS Prep")
- If no match → `add_project` with title, notes (stack/repo/context), and tags
- Never create a duplicate project

### 2. Add Todos

```
add_todo(
  title: "Clear, actionable task title",
  list_title: "Project Name",   ← or list_id if you have it
  heading: "Phase / Section",   ← optional, use if project has headings
  notes: "Context or reference"  ← for complex tasks
)
```

- One `add_todo` call per task
- Title must be a concrete action, not a vague label
- Add `notes` when the task needs context (e.g. "Deferred — needs live TWS running")
- Use `when: "today"` only if the user explicitly asks to schedule it

## Quick Reference

| Task | Tool |
|------|------|
| Find existing projects | `get_projects()` |
| Create a new project | `add_project(title, notes, tags, todos)` |
| Add a single todo | `add_todo(title, list_title, notes, when)` |
| Add todo under heading | `add_todo(title, list_title, heading)` |
| Get today's tasks | `get_today()` |
| Search for a todo | `search_todos(query)` |

## Project Notes Format

When creating a new project, use this format for `notes`:

```
Stack/Tool: ...
Repo: ~/projects/...
```

## Common Mistakes

- Creating a duplicate project instead of searching first
- Adding tasks as notes text instead of as `add_todo` calls
- Using vague task titles like "Phase 2" — always use a concrete action
- Scheduling tasks as `today` without the user asking for it
