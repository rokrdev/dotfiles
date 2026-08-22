---
name: to-bug-ticket
description: Write one immutable schema-v2 regression ticket under .workflow/kanban/backlog after diagnosis confirms a repro, root cause, and bounded fix. Never implement the fix.
user-invocable: true
---

# To Bug Ticket

Compile confirmed `/diagnose` output into one ticket accepted by the deterministic `kanban-loop` runner. Read `~/.dotfiles/docs/kanban-workflow.md` before writing it.

Require a reproducible failing behavior, confirmed root cause, minimal fix boundary, exact files, targeted test command, full verification command, and explicit user approval. If any is missing, return `NEEDS_DECISION`; do not guess.

Explore the codebase to verify every path and command. Present the complete ticket for approval before writing `.workflow/kanban/backlog/NN-slug.md`.

```markdown
---
schema-version: 2
id: <NN>
slug: <kebab-case-bug-description>
title: <short bug-fix title>
kind: bug
language: <implementation stack>
depends-on: []
parallel-safe: false
human-required: false
acceptance: "<one observable sentence proving the bug is fixed>"
allowed-changes:
  - path: <exact regression-test file>
    operation: <create|modify>
  - path: <exact production file>
    operation: modify
failing-tests:
  - <test/path>::<regression_test_name>
tdd-test-command: <exact targeted command>
verification:
  - command: <exact targeted command>
    expected-exit: 0
  - command: <full suite command>
    expected-exit: 0
commit-message: "fix(<scope>): <exact subject>"
---

## Repro

The confirmed externally observable reproduction.

## Root Cause

The evidence-backed cause, not an unverified hypothesis.

## Acceptance Test

The named regression test and assertion proving the bug is gone.

## Files to Touch

Each exact path, operation, and purpose.

## Out of Scope

Adjacent cleanup, refactors, and unaffected behavior.
```

One root cause produces one ticket. Machine-critical fields belong in frontmatter, not only in prose. Run `kanban-loop validate` after writing; repair any failure. Do not implement or invoke the loop. Tell the user the approved ticket must be reviewed and committed before `kanban-loop` can run; never create that commit without separate explicit approval.
