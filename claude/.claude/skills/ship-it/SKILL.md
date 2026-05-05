---
name: ship-it
description: Use when implementation is complete and the kanban board is drained — pushes the branch to origin and opens a PR. Each ticket was already committed by kanban-loop. Triggers: "ship it", "/ship-it", "wrap up branch", "ready to push", or after kanban-loop reports backlog empty.
---

# ship-it Skill

Pre-flight checks, summary report, and push/PR options for a completed feature branch. Commits are created per-ticket by kanban-loop — ship-it does not commit.

## Pre-Flight Verification

**Backlog state:**
- `.kanban/backlog/` must be empty (warn if not; can proceed)
- `.kanban/doing/` must be empty (abort if not — work in progress)

**Test suite:**
- Detect test command from `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, or Makefile
- Run test suite for files-touched paths only
- Require: all tests green (zero failures, zero errors)

**Git state:**
- `git status` shows no uncommitted changes outside files-touched scope
- Branch is ahead of base (`git rev-list --count origin/HEAD..HEAD > 0`)

## Summary Report

Print to user before presenting landing options:

```
✓ Backlog drained
✓ Tests pass (47 passed, 0 skipped)
✓ No uncommitted changes

Tickets completed (3):
  00-cli-scaffold
  01-store-short-url
  02-resolve-short-url

Files modified:
  src/cli.ext          (+45, -8)
  src/store.ext        (+82, -0)
  test/store_test.ext  (+64, -0)
  <project-manifest>   (+2, -0)

Total: +193, -8 lines
```

## Landing Options

Present to user as numbered menu:

```
Ready to ship. Choose landing strategy:

A) Push to origin/<branch>
B) Push + create PR (requires gh CLI + GITHUB_TOKEN)
C) Abort — leave branch as-is

Choose [A-C]:
```

## Execute Selected Option

**A) Push:**
- Run `git push -u origin <branch>`
- Show output

**B) Push + PR:**
- Execute A
- Run `gh pr create` (requires `gh` CLI + `GITHUB_TOKEN` env var)
- Assemble PR body from `.kanban/done/` ticket titles and acceptance criteria
- Prompt user to confirm or edit title/body before submitting
- Return PR URL to user

**C) Abort:**
- Exit cleanly

## Post-Ship

After successful commit/push/merge:

```
✓ Shipped!

Next steps:
- Branch is now ahead of main by 3 commits
- Create a new ticket via to-tickets skill for next feature
- Or invoke kanban-loop again if backlog has items

Ready for next feature?
```

**Optional cleanup:**
- Ask user: "Archive completed tickets? (A) move to `.kanban/archive/<date>/` or (D) delete?"
- If A: `mkdir -p .kanban/archive/$(date +%Y-%m-%d) && mv .kanban/done/* .kanban/archive/$(date +%Y-%m-%d)/`
- If D: `rm .kanban/done/*`

## Anti-Patterns (Call Out Explicitly)

- ✗ Shipping with `doing/` non-empty → **Abort. Finish in-progress work first.**
- ✗ Shipping with red tests → **Abort. Fix failing tests.**
- ✗ Committing in ship-it → **Never. kanban-loop commits per ticket. ship-it only pushes.**
- ✗ Merging to main/master → **Never. ship-it creates a PR. Merging is the human's job.**
- ✗ Force-push to any branch → **Never.**
- ✗ Using `--no-verify` for hooks → **Forbidden. Let pre-commit hooks run.**

## Failure Modes

| State | Action |
|-------|--------|
| `doing/` non-empty | Abort immediately. User must resolve. |
| Tests fail | Abort. Show failing test names + summary. |
| Uncommitted changes found | Warn — kanban-loop should have committed all work. Ask user to commit or stash before pushing. |
| Not ahead of base | Abort. Nothing to ship. |
| `gh` not installed (PR option) | Warn: install gh CLI. Fall back to commit+push. |
| `GITHUB_TOKEN` not set (PR option) | Warn: set env var. Fall back to commit+push. |

## Error Handling

- Gracefully catch `git` errors (e.g., merge conflicts). Report error + abort.
- Never proceed past first failure without user confirmation.
- Always show git output when operations fail.
