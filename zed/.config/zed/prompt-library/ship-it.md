# @ship-it

Pre-flight checks, summary report, and push/PR options for a completed feature branch. Invoke
by typing `@ship-it` in the Agent Panel after the kanban board is fully drained.

Commits are created per-ticket by @kanban-loop — ship-it does NOT commit.

---

## Pre-Flight Verification

**Backlog state:**
- `.kanban/backlog/` must be empty (warn if not; can proceed)
- `.kanban/doing/` must be empty (abort if not — work is still in progress)

**Test suite:**
- Detect test command from `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, or Makefile
- Run the full test suite
- Require: all tests green (zero failures, zero errors)

**Git state:**
- `git status` shows no uncommitted changes
- Branch is ahead of base: `git rev-list --count origin/HEAD..HEAD > 0`

---

## Summary Report

Print before presenting landing options:

```
✓ Backlog drained
✓ Tests pass (X passed, 0 skipped)
✓ No uncommitted changes

Tickets completed (N):
  00-<slug>
  01-<slug>
  ...

Files modified:
  <git diff --stat output>

Total: +X, -Y lines
```

---

## Landing Options

```
Ready to ship. Choose landing strategy:

A) Push to origin/<branch>
B) Push + create PR (requires gh CLI + GITHUB_TOKEN)
C) Abort — leave branch as-is

Choose [A-C]:
```

---

## Execute Selected Option

**A) Push:**
```bash
git push -u origin <branch>
```
Show command output.

**B) Push + PR:**
1. Run `git push -u origin <branch>`
2. Assemble PR body from `.kanban/done/` ticket titles and acceptance criteria
3. Show draft title and body; ask user to confirm or edit
4. Run: `gh pr create --title "<title>" --body "<body>"`
5. Return the PR URL

Requirements: `gh` CLI installed and `GITHUB_TOKEN` env var set.

**C) Abort:**
Exit cleanly. Branch and commits are preserved.

---

## Post-Ship

After successful push:

```
✓ Shipped!

Branch is now ahead of main by N commits.
```

**Optional cleanup — ask the user:**
"Archive completed tickets? (A) move to `.kanban/archive/<date>/` or (D) delete?"
- A: `mkdir -p .kanban/archive/$(date +%Y-%m-%d) && mv .kanban/done/* .kanban/archive/$(date +%Y-%m-%d)/`
- D: `rm .kanban/done/*`

---

## Anti-Patterns

- **Shipping with `doing/` non-empty** → Abort. Finish in-progress work first.
- **Shipping with red tests** → Abort. Fix failing tests before pushing.
- **Committing in ship-it** → Never. @kanban-loop commits per ticket. ship-it only pushes.
- **Merging to main/master** → Never. ship-it creates a PR. Merging is the human's job.
- **Force-push to any branch** → Never.
- **Using `--no-verify` to skip hooks** → Forbidden. Let pre-commit hooks run.

---

## Failure Modes

| State | Action |
|-------|--------|
| `doing/` non-empty | Abort immediately. User must resolve. |
| Tests fail | Abort. Show failing test names + summary. |
| Uncommitted changes found | Warn — @kanban-loop should have committed all work. Ask user to commit or stash before pushing. |
| Not ahead of base | Abort. Nothing to ship. |
| `gh` not installed (option B) | Warn: install gh CLI. Fall back to push-only (option A). |
| `GITHUB_TOKEN` not set (option B) | Warn: `export GITHUB_TOKEN=<PAT>`. Fall back to push-only. |

On any `git` error: report the error and abort. Show full git output. Never proceed past first failure without user confirmation.
