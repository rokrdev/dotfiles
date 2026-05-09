# Coding Instructions

## Standards

**Think Before Coding** — Surface assumptions before writing. List interpretations if the request is ambiguous. Push back when a simpler approach exists.

**Simplicity First** — Write the minimum code that solves the problem. No speculative features, no abstractions for single-use code, no unrequested flexibility. Remove abstractions used only once.

**Surgical Changes** — Touch only what the request requires. Don't improve adjacent code, formatting, or comments. Match existing style. Mention unrelated dead code — don't silently delete it. Remove imports/variables your changes made unused. Every changed line must trace directly to the request.

## Test-Driven Development

TDD is the default workflow. Skip only for: pure config changes, documentation-only changes, one-liner fixes covered by existing tests, or zero-logic scaffolding. When skipping, confirm the existing test suite still passes.

**Workflow:**
1. Write a failing test describing the desired behaviour
2. Write the minimum implementation to make it pass
3. Refactor — clean up without breaking tests
4. Repeat per feature increment

**Test location:** `test/` by default, never under `src/`. Mirror source path: `src/foo/bar.ts` → `test/foo/bar_test.ts`. For JS/TS projects with colocated tests (`*.test.ts`), follow existing project convention.

**Structure** — every test follows arrange / act / assert:
```
// arrange — set up state and inputs
// act     — call the code under test
// assert  — verify the outcome
```

**Naming** — names must read like a sentence describing what the test proves:
- `given_expired_token_returns_unauthorized`
- `when_cart_is_empty_checkout_throws`
- `should_parse_iso_date_string`

**Mocks** — only at system boundaries (network, filesystem outside temp dir, clock/time, random/UUID, external APIs, hardware/OS). Everything else uses real dependencies.

## Git Conventions

All commits follow the conventional commits specification:

```
type(scope): description

body (explain WHY, not WHAT)

footer
```

**Types:** `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `perf`, `ci`, `style`

**Description:** present tense, no period. Example: `add OAuth2 login flow`

**Body:** explain motivation, context, or implications — not what the code does.

**Footer:** breaking changes (`BREAKING CHANGE: ...`), issue refs (`Closes #123`), collaborators.

**PR titles:** under 70 characters, conventional commit format.

**Never:** `--no-verify`, `--no-gpg-sign`, or force push to main/master.

Examples:
```
feat(auth): add OAuth2 login flow

Enables users to sign in with third-party providers.
Fixes broken redirect handling on token expiry.

Closes #42
```
```
fix(parser): handle empty input gracefully

Empty strings were causing a null pointer exception.
Adds early return before tokenization.
```

## Security

- Never commit secrets, tokens, or credentials
- Always validate at system boundaries (user input, external APIs)
- No SQL string concatenation — use parameterized queries:
  ```js
  // Safe
  db.query("SELECT * FROM users WHERE id = ?", [userId])
  // Unsafe
  db.query("SELECT * FROM users WHERE id = " + userId)
  ```
- No command injection — never interpolate user input into shell commands:
  ```python
  # Safe
  subprocess.run(["ls", user_path])
  # Unsafe
  subprocess.run(f"ls {user_path}", shell=True)
  ```
- XSS: always escape output in templates

## Feature Workflow

For new features: clarify requirements → write PRD → create tickets → TDD implementation → ship.

1. **Clarify** — ask questions until requirements are unambiguous; don't start coding with open assumptions
2. **PRD** — write a short product requirements doc covering the problem, scope, and acceptance criteria
3. **Tickets** — break the PRD into vertical slices (each slice: UI + logic + test, independently shippable)
4. **TDD implementation** — per ticket: failing test → passing implementation → refactor
5. **Ship** — confirm all tests pass, open a PR with a conventional commit title

## Bug Workflow

For bugs: diagnose root cause first, write a bug ticket, then fix with a regression test.

1. **Diagnose** — reproduce the bug, trace to the exact file and line, identify the root cause
2. **Bug ticket** — document: reproduction steps, root cause (file + line), proposed fix, regression guard
3. **Fix** — write a failing regression test first, then implement the fix to make it pass
4. **Verify** — confirm the regression test passes and no existing tests broke
