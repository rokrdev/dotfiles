---
name: kanban-loop
description: 'Run the deterministic Kanban executable against schema-v2 tickets in .workflow/kanban. Use for "drain the board", "run kanban", or "/kanban-loop". The executable—not Claude—owns implementation dispatch, independent validation, Git commits, and board transitions.'
user-invocable: true
---

# Kanban Loop

This skill is a thin Claude adapter for the provider-neutral `kanban-loop` executable. Read `~/.dotfiles/docs/kanban-workflow.md` only when explaining or diagnosing the workflow.

## Commands

Map the user's invocation to exactly one command:

```text
/kanban-loop --dry-run
  → kanban-loop plan --provider claude

/kanban-loop --auto [--branch NAME]
  → kanban-loop run --provider claude --mode auto [--branch NAME]

/kanban-loop [--hitl] [--branch NAME]
  → kanban-loop run --provider claude --mode hitl [--branch NAME]

/kanban-loop pause <ticket> [<ticket> ...]
  → kanban-loop pause <ticket> [<ticket> ...]

/kanban-loop resume <ticket> [<ticket> ...]
  → kanban-loop resume <ticket> [<ticket> ...]
```

HITL is the default. AUTO must be explicitly requested.

Pause and resume are local board transitions. Return the executable's output
faithfully; do not edit ticket frontmatter or move the files manually.

Run the executable and return its output faithfully. Do not select tickets, dispatch Agent-tool workers, invoke TDD inline, create worktrees, edit implementation files, validate a patch, stage files, commit, or move board files yourself.

## HITL Results

When the executable returns `KANBAN_AWAITING_COMMIT run_id=<id>`, present its exact diff, verification results, and validator report. Ask the user for one decision:

- Approve → `kanban-loop decide <id> approve`
- Approve with human-authored supplemental changed files → collect each exact
  repository-relative path and a concise reason, then run
  `kanban-loop decide <id> approve --include <path> [--include <path> ...] --reason <reason>`
  using safe argument passing. This triggers fresh verification and independent
  validation; do not use it for unchanged, ticket-allowed, board, Git metadata,
  directory, glob, absolute, or traversal paths.
- Revise → collect a concise reason, then `kanban-loop decide <id> revise --feedback <reason>` using safe argument passing. This preserves the accepted patch and makes a focused correction on top.
- Restart → collect a concise reason, then `kanban-loop decide <id> restart --feedback <reason>` using safe argument passing only when the current approach should be discarded. The runner snapshots the patch, restores ticket-owned files, and starts a fresh strict attempt.
- Abort → `kanban-loop decide <id> abort`

When it returns `KANBAN_AWAITING_NEXT run_id=<id>`, ask whether to continue:

- Continue → `kanban-loop decide <id> continue`
- Abort → `kanban-loop decide <id> abort`

Do not interpret an approval as permission for any action other than the matching `decide` command. If the executable reports an error, surface it unchanged and stop.
