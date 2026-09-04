---
name: ship-it
description: 'Use when implementation is complete and the kanban board is drained — pushes the branch to origin and opens a PR/MR on the detected host (gh for GitHub, glab for GitLab). Each ticket was already committed by kanban-loop. Triggers: "ship it", "/ship-it", "wrap up branch", "ready to push", or after kanban-loop reports backlog empty.'
---

# ship-it Skill

Pre-flight checks, summary report, and push/PR options for a completed feature branch. Commits are created per-ticket by kanban-loop — ship-it does not commit. ship-it detects the remote host and uses the matching CLI: `gh` for GitHub, `glab` for GitLab.

## Detect the Remote Host

Run `git remote -v` once and pick the CLI before presenting the landing options:

- Remote URL contains `github.com` → **GitHub**, use **`gh`**. The landing surface is a **pull request**.
- Remote URL names GitLab (`gitlab.com`, a self-hosted host containing `gitlab`, or a `gitlab:` ssh host alias) → **GitLab**, use **`glab`**. The landing surface is a **merge request**.
- Anything ambiguous (e.g. `git@git.example.com:org/repo.git`) → **ask the user** which platform the remote is, rather than guessing. Do not assume GitHub.

Prefer reading the pushed URL line of `origin`. If `origin` is missing or not a fetch/push URL, abort with "no origin remote".

## Pre-Flight Verification

**Board state:**
- `.workflow/kanban/tickets/active/` and `review/` must be empty (abort if not)
- report remaining `ready`, `paused`, and `blocked` tickets; require the user to
  confirm shipping an incomplete feature

**Test suite:**
- Read each schema-v3 ticket in `.workflow/kanban/tickets/done/`
- Run every unique command declared in each ticket's `verification` list
- If no completed ticket declares verification, detect and run the repository's full test command from `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, or Makefile
- Require: all tests green (zero failures, zero errors)

**Git state:**
- `git status --porcelain` must be empty; abort if anything is staged, modified, or untracked
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

Derive the file list and line totals from Git against the base branch. Do not
reconstruct it from ticket hints, which are not a claim that every listed file
changed.

## Landing Options

Present to user as numbered menu:

```
Ready to ship. Choose landing strategy:

A) Push to origin/<branch>
B) Push + open a pull/merge request (via the detected CLI: gh or glab)
C) Abort — leave branch as-is

Choose [A-C]:
```

Use the CLI resolved in *Detect the Remote Host* (see above): **`gh`** for GitHub,
**`glab`** for GitLab. Use each tool's own stored auth — neither requires an env
token for a logged-in local CLI. If the detected CLI is not installed or not
authenticated, handle it in *Failure Modes* below rather than falling back to a
different host's tool.

## Execute Selected Option

**A) Push:**
- Run `git push -u origin <branch>`
- Show output

**B) Push + open a pull/merge request:**
- Execute A (push the branch).
- Use the CLI resolved in *Detect the Remote Host*:
  - **GitHub** (`gh`): run `gh pr create`.
  - **GitLab** (`glab`): run `glab mr create`.
  - Never swap hosts: a GitHub remote must use `gh`, a GitLab remote must use `glab`.
- Both tools use their own stored auth (`gh auth status` / `glab auth status`); no
  env token is required for a logged-in local CLI.
- Assemble the body from `.workflow/kanban/done/` ticket titles and acceptance criteria.
- Prompt user to confirm or edit title/body before submitting.
- Return the PR/MR URL to user.

**C) Abort:**
- Exit cleanly

## Post-Ship

After successful commit/push/merge:

```
✓ Shipped!

Next steps:
- Branch is now ahead of main by <N> commits
  (compute with: git rev-list --count origin/HEAD..HEAD)
- Create a new ticket via to-tickets skill for next feature
- Or invoke kanban-loop again if backlog has items

Ready for next feature?
```

**Optional cleanup:**
- Ask whether to archive a completed feature with
  `kanban-loop archive <feature>`. Do not move or delete ticket files manually.

## Anti-Patterns (Call Out Explicitly)

- ✗ Shipping with `active/` or `review/` non-empty → **Abort. Resolve the active session first.**
- ✗ Shipping with red tests → **Abort. Fix failing tests.**
- ✗ Committing in ship-it → **Never. kanban-loop commits per ticket. ship-it only pushes.**
- ✗ Merging to main/master → **Never. ship-it creates a PR/MR. Merging is the human's job.**
- ✗ Force-push to any branch → **Never.**
- ✗ Using `--no-verify` for hooks → **Forbidden. Let pre-commit hooks run.**

## Failure Modes

| State | Action |
|-------|--------|
| `active/` or `review/` non-empty | Abort immediately. User must resolve. |
| Tests fail | Abort. Show failing test names + summary. |
| Uncommitted changes found | Warn — kanban-loop should have committed all work. Ask user to commit or stash before pushing. |
| Not ahead of base | Abort. Nothing to ship. |
| Remote host ambiguous | Ask the user which platform the remote is before choosing `gh` or `glab`. |
| No origin remote | Abort. Nothing to push to. |
| `gh` not installed (GitHub remote) | Warn: install gh CLI (`gh auth login`). Fall back to commit+push. |
| `glab` not installed (GitLab remote) | Warn: install glab CLI (`glab auth login`). Fall back to commit+push. |
| CLI not authenticated | Warn: run `gh auth status` / `glab auth status`, then `gh auth login` / `glab auth login`. Fall back to commit+push. |

## Error Handling

- Gracefully catch `git` errors (e.g., merge conflicts). Report error + abort.
- Never proceed past first failure without user confirmation.
- Always show git output when operations fail.
