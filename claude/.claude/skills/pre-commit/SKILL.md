---
name: pre-commit
description: Run before committing — simplify staged code, review it, fix issues, then run tests
---

> **MANUAL SKILL** — Invoke explicitly before every `git commit`:
> - "run pre-commit"
> - "pre-commit check"
> - "check before committing"

# Pre-Commit Workflow

When invoked, execute these steps automatically — never ask the user to run them manually.

## Step 1: Check staged files

Run `git diff --cached --stat`.

- If files are staged → list them and proceed to Step 2.
- If nothing is staged → run `git status --short`:
  - Tracked files modified → `git add -u`, report what was staged, proceed.
  - Working tree clean → report "Nothing to commit — working tree clean" and stop.

## Step 2: Simplify staged code

Dispatch the `code-simplifier:code-simplifier` subagent with the staged file paths. Instruct it to simplify and refine for quality.

After it completes, re-stage any modified files with `git add -u`.

## Step 3: Review staged diff

Dispatch `pr-review-toolkit:code-reviewer` on the staged diff (`git diff --cached`). Instruct it to check correctness, style, and maintainability.

If the reviewer returns **CRITICAL** or **IMPORTANT** issues → stop, report them, and wait for fixes. Do NOT commit.

## Step 4: Run project tests

Detect and run the project test suite:

| Stack | Command |
|-------|---------|
| JavaScript / Node.js | `npm test` |
| Python | `pytest` (fallback: `python -m unittest`) |
| Kotlin / Java | `./gradlew test` |
| Swift | `swift test` |

If no test command is detected, skip this step and note it in the final report.

If tests fail → stop, report failures. Do NOT commit.

## Step 5: Commit

All checks passed. Report:
- What was simplified (Step 2)
- Reviewer verdict (Step 3)
- Test results (Step 4)

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
