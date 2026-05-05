# Coding Behavior

**Think Before Coding** — Surface assumptions explicitly before writing. List all interpretations if the request is ambiguous — don't pick one silently. Push back when a simpler approach exists.

**Simplicity First** — Write the minimum code that solves the problem. No speculative features, no abstractions for single-use code, no unrequested flexibility. If you added an abstraction used only once, remove it.

**Surgical Changes** — Touch only what the request requires. Don't improve adjacent code, formatting, or comments. Match existing style. Mention unrelated dead code — don't silently delete it. DO remove imports/variables your changes made unused. Test: "Every changed line should trace directly to the user's request."

## When to Skip TDD

TDD is the default. Skip it only for:

- Pure config changes (no logic path added or changed)
- Documentation-only changes
- One-liner fixes where the test suite already covers the changed line
- Scaffolding / boilerplate where zero logic is introduced

When skipping, confirm the existing test suite still passes before marking the task complete.

## System Boundaries — What Counts

Mocks are only acceptable at system boundaries. A system boundary is any point where the code leaves the process:

- **Network** — HTTP calls, gRPC, WebSockets, message queues
- **Filesystem** — reading or writing files outside the test's own temp directory
- **Clock / time** — `Date.now()`, `datetime.now()`, `Instant.now()`, etc.
- **Random / UUID** — any non-deterministic source
- **External APIs and services** — third-party SDKs, auth providers, payment processors
- **Hardware / OS** — camera, GPS, push notifications, keychain

Everything else uses real dependencies: in-memory implementations, real parsers, real business logic.

## TDD Workflow

1. Write a failing test that describes the desired behaviour
2. Write the minimum implementation to make it pass
3. Refactor — clean up without breaking tests
4. Repeat per feature increment

For language-specific runners and patterns, see the specialist agents: Snape (pytest), Swifty (XCTest / Swift Testing), Conan (Kotest / JUnit5), Jasper (Vitest / Jest).

## Test Location

- Tests go in `test/` by default — never under `src/`
- Mirror the source path: `src/foo/bar.<ext>` → `test/foo/bar_test.<ext>` (or `BarTest`, `BarTests` — follow stack convention)
- **Override:** JS/TS projects using colocated tests (`*.test.ts` next to source) should follow existing project convention. Check for existing test files before creating `test/` directories.
- Check project-level CLAUDE.md for additional overrides

## Test Structure

Every test follows arrange / act / assert:

```
// arrange — set up state and inputs
// act     — call the code under test
// assert  — verify the outcome
```

One clear assertion per test where possible. Multiple assertions are acceptable when they verify a single logical outcome.

## Test Naming

Names must read like a sentence describing what the test proves:

- `given_expired_token_returns_unauthorized`
- `when_cart_is_empty_checkout_throws`
- `should_parse_iso_date_string`

Avoid names like `test1`, `testFoo`, or `happyPath`.
