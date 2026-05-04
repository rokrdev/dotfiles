---
name: ship-it
description: Use when implementation is complete and the kanban board is drained — wraps up a feature branch with verification + landing options (commit, push, PR, merge, squash). Triggers: "ship it", "/ship-it", "wrap up branch", "ready to merge", or after kanban-loop reports backlog empty.
---

# ship-it Skill

Pre-flight checks, summary report, and landing options for a completed feature branch.

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

A) Commit only
B) Commit + push to origin/<branch>
C) Commit + push + create PR (requires gh CLI + GITHUB_TOKEN)
D) Squash + merge to main (requires branch != main)
E) Rebase + merge to main (requires branch != main)
F) Abort — leave branch as-is

Choose [A-F]:
```

## Execute Selected Option

**A) Commit only:**
- Stage files from `git diff --name-only <base>..HEAD`
- Prompt for commit message OR use `caveman:caveman-commit` skill if available
- Show message before committing (never silent)
- Append `Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>` if Claude touched any files
- Never use `--no-verify`

**B) Commit + push:**
- Execute A
- Run `git push -u origin <branch>`
- Show output

**C) Commit + push + PR:**
- Execute B
- Run `gh pr create` (requires `gh` CLI + `GITHUB_TOKEN` env var)
- Prompt for PR title / body
- Return PR URL to user

**D) Squash + merge to main:**
- Verify branch != main (abort if equal)
- Show: `git log --oneline <base>..HEAD` (all commits to be squashed)
- Prompt for confirmation before destructive operation
- Execute: `git checkout main && git pull origin main && git merge --squash <branch> && git commit -m "..."` (prompt for message)
- Delete branch: `git branch -d <branch>`
- Inform user to `git push origin main`

**E) Rebase + merge:**
- Verify branch != main (abort if equal)
- Show: `git rebase --interactive origin/HEAD` preview
- Prompt for confirmation
- Execute: `git rebase origin/HEAD && git checkout main && git pull origin main && git merge --ff-only <branch>`
- Delete branch: `git branch -d <branch>`
- Inform user to `git push origin main`

**F) Abort:**
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
- ✗ Squash/merge without confirmation → **Always show commits + prompt.**
- ✗ Force-push to main/master → **Never. Only fast-forward merges to main.**
- ✗ Using `--no-verify` for hooks → **Forbidden. Let pre-commit hooks run.**

## Failure Modes

| State | Action |
|-------|--------|
| `doing/` non-empty | Abort immediately. User must resolve. |
| Tests fail | Abort. Show failing test names + summary. |
| Uncommitted changes outside scope | Warn but allow (ask user to stash/commit first). |
| Not ahead of base | Abort. Nothing to ship. |
| `gh` not installed (PR option) | Warn: install gh CLI. Fall back to commit+push. |
| `GITHUB_TOKEN` not set (PR option) | Warn: set env var. Fall back to commit+push. |

## Error Handling

- Gracefully catch `git` errors (e.g., merge conflicts). Report error + abort.
- Never proceed past first failure without user confirmation.
- Always show git output when operations fail.
