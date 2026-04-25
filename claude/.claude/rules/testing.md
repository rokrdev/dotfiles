# Testing Rules

## TDD Workflow

1. Write a failing test that describes the desired behaviour
2. Write the minimum implementation to make it pass
3. Refactor — clean up without breaking tests
4. Repeat per feature increment

For language-specific runners and patterns, see the specialist agents: Snape (pytest), Swifty (XCTest / Swift Testing), Conan (Kotest / JUnit5), Jasper (Vitest / Jest).

## Test Location

- Tests go in `test/` — never under `src/`
- Mirror the source path: `src/foo/bar.<ext>` → `test/foo/bar_test.<ext>` (or `BarTest`, `BarTests` — follow stack convention)
- Check project-level CLAUDE.md for overrides

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
- `calculateTotal returns zero for empty cart`
- `user with no role cannot access admin endpoint`

Avoid generic names like `test1`, `testFoo`, or `happyPath`.

## Test Runner Detection

Pick the runner already present in the project. Do not introduce a second runner.

| Stack | Preferred runner | Notes |
|-------|-----------------|-------|
| Python | pytest | See Snape for fixture and parametrize patterns |
| Swift / iOS | Swift Testing (new files); XCTest (existing suites) | Never mix in one file — see Swifty |
| Kotlin / Android | Kotest (new files); JUnit5 (existing suites) | `runTest` for coroutines — see Conan |
| JS / TS | Vitest (Vite projects); Jest (everything else) | |

## System Boundaries — What Counts

Mocks are only acceptable at system boundaries. A system boundary is any point where the code leaves the process:

- **Network** — HTTP calls, gRPC, WebSockets, message queues
- **Filesystem** — reading or writing files outside the test's own temp directory
- **Clock / time** — `Date.now()`, `datetime.now()`, `Instant.now()`, etc.
- **Random / UUID** — any non-deterministic source
- **External APIs and services** — third-party SDKs, auth providers, payment processors
- **Hardware / OS** — camera, GPS, push notifications, keychain

Everything else uses real dependencies: in-memory implementations, real parsers, real business logic.

## Coverage Expectations

Every feature must have at minimum:

- **Happy path** — the normal successful case
- **One error or edge case** — empty input, boundary value, invalid state, or failure mode

Do not aim for coverage percentage targets. Aim for confidence in the behaviours that matter.

## Generated and Binary Files

Skip test simplification on lockfiles (`package-lock.json`, `Podfile.lock`, `poetry.lock`, `Package.resolved`, etc.) and generated files. Do not write tests for generated output.

## Goal-Driven Execution

Transform vague tasks into verifiable goals before starting. For multi-step tasks, emit a plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
```

Strong success criteria enable autonomous looping and make "done" unambiguous.

## When to Skip TDD

TDD is the default. Skip it only for:

- Pure config changes (no logic path added or changed)
- Documentation-only changes
- One-liner fixes where the test suite already covers the changed line
- Scaffolding / boilerplate where zero logic is introduced

When skipping, confirm the existing test suite still passes before marking the task complete.
