---
name: tdd
description: Test-driven development. Use when the user wants to build features or fix bugs test-first, mentions "red-green-refactor", or wants integration tests.
---

# Test-Driven Development

TDD is the red → green loop. This skill is the reference that makes that loop produce tests worth keeping: what a good test is, where tests go, the anti-patterns, and the rules of the loop. Every section applies on every cycle — consult them before and during the loop, not after.

When exploring the codebase, read `CONTEXT.md` (if it exists) so test names and interface vocabulary match the project's domain language, and respect ADRs in the area you're touching.

## Kanban runner mode

When the prompt identifies a script-controlled Kanban phase, the immutable ticket is the approved plan and the runner owns every process gate:

- Do not ask the user to approve the interface or test plan again.
- In a test-authoring phase, modify only the declared test files and add one focused failing behavior test. Do not touch production code.
- In an implementation phase, modify only the declared production files and make the smallest change that passes the existing failing test. Do not touch tests.
- Do not run Git commands, move tickets, invoke other skills, start subagents, or decide that a gate passed.
- Do not refactor, rename, update dependencies, or improve adjacent code unless the ticket explicitly includes that work in its acceptance criterion and allowlist.

The runner—not this skill—executes RED, GREEN, verification, independent validation, approval, and commit transitions. When Kanban runner mode applies, follow only the phase assigned by the runner; do not mix in the standalone confirmation gates below.

## What a good test is

Tests verify behavior through public interfaces, not implementation details. Code can change entirely; tests shouldn't. A good test reads like a specification — "user can checkout with valid cart" tells you exactly what capability exists — and survives refactors because it doesn't care about internal structure.

See [tests.md](tests.md) for examples and [mocking.md](mocking.md) for mocking guidelines.

## Seams — where tests go

A **seam** is the public boundary you test at: the interface where you observe behavior without reaching inside. Tests live at seams, never against internals.

**Test only at pre-agreed seams.** Before writing any test, write down the seams under test and confirm them with the user. No test is written at an unconfirmed seam. You can't test everything — agreeing the seams up front is how testing effort lands on the critical paths and complex logic instead of every edge case.

Ask: "What's the public interface, and which seams should we test?"

When the shape of that interface is itself in question — how deep the module is, where the seam belongs, or what the interface should expose — pause and agree that design before writing tests.

## Anti-patterns

- **Implementation-coupled** — mocks internal collaborators, tests private methods, or verifies through a side channel (querying the database instead of using the interface). The tell: the test breaks when you refactor but behavior hasn't changed.
- **Tautological** — the assertion recomputes the expected value the way the code does (`expect(add(a, b)).toBe(a + b)`, a snapshot derived by hand the same way, a constant asserted equal to itself), so it passes by construction and can never disagree with the code. Expected values must come from an independent source of truth — a known-good literal, a worked example, the spec.
- **Horizontal slicing** — writing all tests first, then all implementation. Bulk tests verify _imagined_ behavior: you test the _shape_ of things rather than user-facing behavior, the tests go insensitive to real changes, and you commit to test structure before understanding the implementation. Work in **vertical slices** instead — one test → one implementation → repeat, each test a **tracer bullet** that responds to what the last cycle taught you.

## RED gate

Run each new test before editing production code and capture a failure caused by the missing behavior.

A first-run pass is not RED. An import or module-not-found error is not behavior-level RED unless the ticket is specifically about module availability. Rewrite the test until it reaches the intended public seam and fails on an assertion that the new behavior will satisfy. If the behavior already exists or no meaningful failing test can be produced, stop and report that instead of manufacturing a test.

## Rules of the loop

- **Red before green.** Write the failing test first, then only enough code to pass it. Don't anticipate future tests or add speculative features.
- **One slice at a time.** One seam, one test, one minimal implementation per cycle.
- **Refactoring is not part of the loop.** It belongs to the review stage (see the `code-review` skill), not the red → green implementation cycle.
