---
name: pre-commit
description: Run before committing — simplify staged code, review it, fix issues, then run tests
---

> ⚠️ **MANUAL SKILL** — No automatic trigger. Invoke explicitly before every `git commit`:
> - "run pre-commit"
> - "pre-commit check"
> - "check before committing"

# Pre-Commit Quality Gate

Run this before `git commit`. Catches issues before they land in history.

**Core principle:** A commit is a promise. Make sure the code keeps it.

## When to Use

Invoke manually before any `git commit`.

**Skip only when:**
- Reverting a commit (revert commits are already-reviewed code)
- Emergency hotfix with explicit user permission

## Workflow

### Step 1 — Check staged changes

```bash
git diff --cached --stat
```

No staged changes? Stop — nothing to commit.

Note which files are staged for steps 2–4.

### Step 2 — Simplify

Dispatch `code-simplifier:code-simplifier` subagent, passing the full staged diff as context:

```bash
git diff --cached
```

After simplifier runs: re-stage any files it modified.

```bash
git add <modified files>
```

### Step 3 — Code Review

Dispatch `pr-review-toolkit:code-reviewer` subagent on the staged diff (re-run `git diff --cached` to get post-simplify version).

**Act on findings:**

| Severity | Action |
|----------|--------|
| CRITICAL | Fix immediately, re-stage, re-run review |
| IMPORTANT | Fix before proceeding, re-stage |
| MINOR | Note for later — don't block commit |

After fixing: re-stage and re-run review to confirm issues are resolved.

### Step 4 — Tests

Check if tests apply to staged changes:
1. Does a test suite exist? (`test/`, `src/test/`, `__tests__/`, `*.test.*`, `*_test.*`)
2. Do staged files touch tested logic?
3. If yes → run them

**Run tests:**
- Kotlin/Gradle: `./gradlew test`
- Python/pytest: `pytest`
- Node/npm: `npm test`

**Results:**
- All pass → proceed
- Failures → fix, re-stage, re-run
- Cannot fix → block commit and report what failed

### Step 5 — Done

All clear:
```
✅ Pre-commit checks passed. Safe to commit.
```

Unresolved issues:
```
❌ Pre-commit blocked: <reason>
```

## Checklist

- [ ] Staged changes confirmed
- [ ] Simplify ran — changes re-staged
- [ ] Code review clean — no unresolved CRITICAL/IMPORTANT
- [ ] Tests passed (if applicable)
- [ ] Safe to commit
