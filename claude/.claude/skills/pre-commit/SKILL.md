---
name: pre-commit
description: Run before committing — review staged code, fix issues, then run tests
when_to_use: Invoke explicitly before every `git commit` — when user says "run pre-commit", "pre-commit check", or "check before committing"
---

# Pre-Commit Workflow

**Manual skill** — invoke explicitly before every `git commit` (triggers: "run pre-commit", "pre-commit check", "check before committing").

When invoked, execute these steps automatically — never ask the user to run them manually.

## Step 1: Check staged files

Run `git diff --cached --stat`.

- If files are staged → list them and proceed to Step 2.
- If nothing is staged → run `git status --short`:
  - Tracked files modified → list all modified files and warn: "These tracked files will be staged. If you have unrelated WIP changes, stage manually with `git add <file>` instead of proceeding." Then wait for confirmation before running `git add -u`.
  - Working tree clean → report "Nothing to commit — working tree clean" and stop.

## Step 2: Review staged diff

Dispatch `pr-review-toolkit:review-pr` on the staged diff (`git diff --cached`). Instruct it to check correctness, style, and maintainability.

If the reviewer returns **CRITICAL** or **IMPORTANT** issues → stop, report them, and wait for fixes. Do NOT commit.

## Step 3: Run project tests

Detect and run the project test suite:

| Stack | Command |
|-------|---------|
| JavaScript / Node.js | `npm test` |
| Python | `pytest` (fallback: `python -m unittest`) |
| Kotlin / Java | `./gradlew test` |
| Swift | `swift test` |

If no test command is detected, skip this step and note it in the final report.

If tests fail → stop, report failures. Do NOT commit.

## Step 4: Commit

All checks passed. Report:
- Reviewer verdict (Step 2)
- Test results (Step 3)

Generate a commit message from the staged diff using conventional commits format (`type(scope): description`). Present it and ask: "Commit with this message? (yes/edit/cancel)". Then:
- **yes** → commit.
- **edit** → accept the user's revised message and commit.
- **cancel** → stop without committing.

After your PR is reviewed and merged, use the `compound` skill to capture pattern-level learnings as permanent rules in the project CLAUDE.md.

## Error handling

Any step may fail. On failure:
- Stop immediately.
- Report what failed and why.
- Return control to the user for fixes.
- Never commit on partial success.
