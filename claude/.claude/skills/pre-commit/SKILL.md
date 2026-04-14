---
name: pre-commit
description: Run before committing — simplify staged code, review it, fix issues, then run tests
---

> ⚠️ **MANUAL SKILL** — Invoke explicitly before every `git commit`:
> - "run pre-commit"
> - "pre-commit check"
> - "check before committing"

# Pre-Commit Workflow

When this skill is invoked, execute the following steps automatically — do not ask the user to do them manually.

## Step 1: Check staged files

Run `git diff --cached --stat` and list what's staged. If nothing is staged, report "Nothing staged — nothing to check" and stop.

## Step 2: Dispatch code-simplifier

Dispatch `code-simplifier:code-simplifier` subagent on the staged files. Pass the list of staged file paths and instruct it to simplify and refine for quality.

After it completes, re-stage any files it modified: `git add -u`

## Step 3: Dispatch code reviewer

Dispatch `pr-review-toolkit:code-reviewer` on the staged diff (`git diff --cached`). Instruct it to check for correctness, style, and maintainability.

If the reviewer returns **CRITICAL** or **IMPORTANT** issues → stop. Report the issues to the user and do NOT proceed to commit. Wait for fixes.

## Step 4: Run project tests

Detect and run the project test suite:
- JavaScript/Node.js: `npm test`
- Python: `pytest` or `python -m unittest`
- Kotlin/Java: `./gradlew test`
- Swift: `swift test`
- If no test command detected: skip this step and note it

If tests fail → stop. Report failures. Do NOT commit.

## Step 5: Commit

All checks passed. Report:
- What was simplified (Step 2)
- Reviewer verdict (Step 3)
- Test results (Step 4)

Generate a commit message from the staged diff following conventional commits format (type(scope): description). Show the message to the user, then commit immediately — do not ask the user for the commit message. On success, proceed to Step 6.

## Step 6: Update memory

Commit succeeded — invoke the `update-memory` skill to consolidate what was just shipped into project memory.

Focus the memory update on:
- What this commit added/changed (update `current-work.md` "Recent Work Completed")
- Whether any architectural decision was made (update `architecture-decisions.md` if relevant)
- Any new lessons or feedback surfaced during review (add topic file if warranted)

Skip this step only if the commit was trivial (e.g. typo fix, comment update, version bump) — use judgment.

## Error handling

Any step can fail. On failure:
- Stop immediately
- Report what failed and why
- Return control to the user for fixes
- Do NOT commit on partial success
