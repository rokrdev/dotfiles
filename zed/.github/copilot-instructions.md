# Coding Instructions

## Standards

**Think Before Coding** — Surface assumptions before writing. If the request is ambiguous, list interpretations — don't pick one silently. Push back when a simpler approach exists.

**Simplicity First** — Write the minimum code that solves the problem. No speculative features, no abstractions used only once, no unrequested flexibility.

**Surgical Changes** — Touch only what the request requires. Don't improve adjacent code, formatting, or comments. Match existing style. Mention unrelated dead code — don't delete it silently. Remove imports/variables your changes made unused. Test: "Every changed line should trace directly to the user's request."

## Test-Driven Development

TDD is the default. Write a failing test first, then implement.

### Workflow
1. Write a failing test describing the desired behaviour
2. Write the minimum implementation to make it pass
3. Refactor — clean up without breaking tests
4. Repeat per feature increment

### When to Skip TDD
- Pure config changes (no logic path added or changed)
- Documentation-only changes
- One-liner fixes where the test suite already covers the changed line
- Scaffolding / boilerplate where zero logic is introduced

When skipping, confirm the existing test suite still passes before marking complete.

### Mocks — System Boundaries Only
Mocks are acceptable only at system boundaries: network, filesystem (outside test temp dir), clock/time, random/UUID, external APIs, hardware/OS. Everything else uses real dependencies.

### Test Location
- Default: `test/` — never under `src/`
- Mirror the source path: `src/foo/bar.ts` → `test/foo/bar_test.ts`
- JS/TS projects using colocated tests (`*.test.ts`) — follow existing project convention

### Test Structure
Every test follows arrange / act / assert:
```
// arrange — set up state and inputs
// act     — call the code under test
// assert  — verify the outcome
```
One clear assertion per test where possible.

### Test Naming
Names must read like a sentence:
- `given_expired_token_returns_unauthorized`
- `when_cart_is_empty_checkout_throws`
- `should_parse_iso_date_string`

Avoid: `test1`, `testFoo`, `happyPath`.

## Git Conventions

All commits follow the conventional commits specification:

```
type(scope): description

body

footer
```

### Types
- `feat` — new feature
- `fix` — bug fix
- `chore` — build, tooling, dependency updates
- `refactor` — restructuring without changing functionality
- `docs` — documentation only
- `test` — test additions or fixes; no production code
- `perf` — performance improvements
- `ci` — CI/CD pipeline changes
- `style` — non-functional whitespace changes (if logic structure changes, use `refactor`)

### Description Rules
- Present tense, no period
- ✓ `add OAuth2 login flow`
- ✗ `added` (past tense), ✗ `Add login.` (period)

### Body
Explain WHY, not WHAT. The code shows WHAT.

### Examples
```
feat(auth): add OAuth2 login flow

Enables sign-in with third-party providers.
Fixes broken redirect handling on token expiry.

Closes #42
```
```
fix(parser): handle empty input gracefully

Empty strings caused a null pointer exception.
Adds early return before tokenization.
```

### PR Title
Under 70 characters, conventional commit format:
- ✓ `feat(api): add rate limiting to public endpoints`
- ✗ `fix: stuff`

### Commit Practices
- Never use `--no-verify` unless explicitly requested
- Never force-push to main/master

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

For new features, use the feature-flow pattern:
1. **Grill requirements** — clarify scope, edge cases, and constraints with targeted questions before writing any code
2. **Write a PRD** — one-page product requirements doc capturing goals, non-goals, and acceptance criteria
3. **Break into tickets** — vertical slices, each independently shippable with its own tests
4. **TDD implementation** — red → green → refactor per ticket
5. **Ship** — open a PR with a clear summary of what changed and why

Do not start implementation until requirements are clear and a PRD exists.

## Bug Workflow

For bugs, diagnose before fixing:
1. **Diagnose** — reproduce the bug, identify root cause (file + line), note what the correct behaviour should be
2. **Write a ticket** — document repro steps, root cause, proposed fix, and a regression guard (the test that will prevent recurrence)
3. **Fix** — implement the fix TDD-style; the regression guard test must be written first and must fail before the fix
