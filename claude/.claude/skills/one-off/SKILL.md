---
name: one-off
description: Lightweight pipeline for single, bounded implementation tasks — use this for any small change that doesn't need a full feature or bug workflow. Trigger whenever a user asks to: add a flag or option to an existing function or script, extract duplicated code into a constant or helper, rename a method or variable, make a hardcoded value configurable via an env var or parameter, add input validation to a specific function, or implement any other isolated change touching 1-3 files. Also trigger for phrases like "small change", "quick task", "single task", "one-off", or "quick fix" followed by an implementation request. Do NOT trigger for bugs with unclear root cause (use bug-flow), multi-file features (use feature-flow), architecture questions, PR reviews, or diagnostics.
---
# /one-off — Single Task Implementation

Lightweight pipeline for simple, bounded tasks that don't warrant feature-flow or bug-flow.

## When to Use

- Single concern: add a config option, refactor a function, update a script, add a small utility
- Clear scope: touches 1-3 files, no architectural decision needed
- Not a bug (use bug-flow), not a multi-file feature (use feature-flow)

## Trigger

User types `/one-off`, "one-off task", or "quick task".

## Steps

### Step 1 — Capture Task

If user included a description with the trigger, use it. Otherwise ask: "What do you want to do?"

### Step 2 — Ask 2-3 Clarifying Questions

Ask only what's genuinely ambiguous. Max 3 questions in one message. Choose from:

- **Scope**: "Does this touch just `[file X]` or also `[related file Y]`?"
- **Approach**: "Should this follow [existing pattern] or [alternative]?"
- **Constraints**: "Any edge cases to handle? Tests that must keep passing?"
- **Stack**: If language/framework isn't clear from context.

Skip questions that are obvious from context.

### Step 3 — Confirm Scope

After user answers, write a brief implementation summary (3-5 lines):
- What exactly changes
- Which files are touched
- Approach / key decision
- Test strategy (what test will prove it works)

Ask: "Does this match what you want? Say yes to proceed."

### Step 4 — Dispatch Specialist

Route by language/stack:
- Python → `snape`
- JS/TS/React/Node → `jasper`
- Swift/iOS/macOS → `swifty`
- Kotlin/JVM/Android → `conan`
- Shell/config/other → general-purpose agent (model: sonnet)

Dispatch with:
- **Exact files** to touch (from step 3)
- **Scope boundary** — what to implement AND what not to touch
- **TDD requirement** — write failing test first, then implementation, then refactor
- **Done criteria** — specific observable outcome that means "done"
- **Commit** — conventional commit format after implementation

### Step 5 — Report

After specialist completes, report back:
- Files changed
- Test added/modified
- Commit hash

## Constraints

- No kanban tickets
- No PRD
- No ship-it (user pushes manually or asks)
- If scope grows during clarification → stop, redirect to `/feature-flow`
- If it's a bug → redirect to `bug-flow`
