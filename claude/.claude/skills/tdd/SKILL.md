<!--
Source: github.com/mattpocock/skills
Skill: tdd
Commit: b843cb5e
Pulled: 2026-05-04
Trial: 7-day vertical-slice kanban experiment (see docs/kanban-workflow.md)
-->

---
name: tdd
description: Test-driven development with red-green-refactor loop. Use when user wants to build features or fix bugs using TDD, mentions "red-green-refactor", wants integration tests, or asks for test-first development.
---

# Test-Driven Development

## Philosophy

**Core principle**: Tests should verify behavior through public interfaces, not implementation details. Code can change entirely; tests shouldn't.

**Good tests** are integration-style: they exercise real code paths through public APIs. They describe _what_ the system does, not _how_ it does it. A good test reads like a specification - "user can checkout with valid cart" tells you exactly what capability exists. These tests survive refactors because they don't care about internal structure.

**Bad tests** are coupled to implementation. They mock internal collaborators, test private methods, or verify through external means (like querying a database directly instead of using the interface). The warning sign: your test breaks when you refactor, but behavior hasn't changed. If you rename an internal function and tests fail, those tests were testing implementation, not behavior.

See [tests.md](tests.md) for examples and [mocking.md](mocking.md) for mocking guidelines.

## Anti-Pattern: Horizontal Slices

**DO NOT write all tests first, then all implementation.** This is "horizontal slicing" - treating RED as "write all tests" and GREEN as "write all code."

This produces **crap tests**:

- Tests written in bulk test _imagined_ behavior, not _actual_ behavior
- You end up testing the _shape_ of things (data structures, function signatures) rather than user-facing behavior
- Tests become insensitive to real changes - they pass when behavior breaks, fail when behavior is fine
- You outrun your headlights, committing to test structure before understanding the implementation

**Correct approach**: Vertical slices via tracer bullets. One test → one implementation → repeat. Each test responds to what you learned from the previous cycle. Because you just wrote the code, you know exactly what behavior matters and how to verify it.

```
WRONG (horizontal):
  RED:   test1, test2, test3, test4, test5
  GREEN: impl1, impl2, impl3, impl4, impl5

RIGHT (vertical):
  RED→GREEN: test1→impl1
  RED→GREEN: test2→impl2
  RED→GREEN: test3→impl3
  ...
```

## Workflow

### 1. Planning

When exploring the codebase, use the project's domain glossary so that test names and interface vocabulary match the project's language, and respect ADRs in the area you're touching.

Before writing any code:

- [ ] Confirm with user what interface changes are needed
- [ ] Confirm with user which behaviors to test (prioritize)
- [ ] Identify opportunities for [deep modules](deep-modules.md) (small interface, deep implementation)
- [ ] Design interfaces for [testability](interface-design.md)
- [ ] List the behaviors to test (not implementation steps)
- [ ] Get user approval on the plan

Ask: "What should the public interface look like? Which behaviors are most important to test?"

**You can't test everything.** Confirm with the user exactly which behaviors matter most. Focus testing effort on critical paths and complex logic, not every possible edge case.

### 2. Tracer Bullet

Write ONE test that confirms ONE thing about the system:

```
RED:   Write test for first behavior → test fails
GREEN: Write minimal code to pass → test passes
```

This is your tracer bullet - proves the path works end-to-end.

**Hard gate — RED required before any src/ edit:**

After writing the test, run the test suite and confirm the test FAILS. Capture the failure output verbatim. You may not create or edit any file under `src/` (or your project's production code directory) until you have a recorded test failure.

If the test passes immediately, the test is wrong — rewrite it to actually exercise the unimplemented behavior. A passing test before implementation means the test is not testing what you think it is.

This is a hard process gate, not a guideline. Skipping RED is the most common TDD violation; the rest of the workflow assumes it.

### Fake-green detection

A test that passes on the first run is fake-green — the test is wrong, not the code.
Common fake-green patterns to recognize and avoid:

1. **Tautological assertion** — asserting `hash(x) == hash(x)` is always true.
   Fix: assert against the *behavior* being added (e.g., assert that `store.get(code1) == store.get(code2)` after two `store.put(url)` calls — that requires dedup logic to pass).

2. **Test verifies pre-existing behavior** — if the ticket adds `--help`, but
   the CLI already prints `--help` from a prior ticket, the test is verifying
   the old code, not the new requirement. Read the ticket's *delta* carefully
   and test only that delta.

3. **Test exercises wrong layer** — testing a util function passes when the
   integration is broken. If acceptance is CLI-level, the failing test must
   spawn the CLI binary, not call the util.

4. **Import/module-not-found masquerading as RED** — an import error (e.g.
   `ModuleNotFoundError`, `Cannot find module`, `unresolved reference`) is
   not behavior-red. It "passes" once the file exists, even if empty. Always
   pair the import with an assertion against actual behavior, so the test stays
   red until the behavior is implemented.

**Required action when first run is green:**

Stop. Do not edit src/. Re-examine the test:
- What new behavior does this ticket promise?
- Does my assertion fail in a world where that behavior doesn't exist yet?
- Can I write a value or scenario that the current system cannot satisfy?

Rewrite the test to fail for the right reason. Re-run. Only proceed once you
have RED for the actual feature being added.

If after rewriting you still cannot make the test fail, the ticket is wrong
or the behavior already exists — report `NEEDS_CONTEXT` to the orchestrator.

### 3. Incremental Loop

For each remaining behavior:

```
RED:   Write next test → fails
GREEN: Minimal code to pass → passes
```

Rules:

- One test at a time
- Only enough code to pass current test
- Don't anticipate future tests
- Keep tests focused on observable behavior

### 4. Refactor

After all tests pass, look for [refactor candidates](refactoring.md):

- [ ] Extract duplication
- [ ] Deepen modules (move complexity behind simple interfaces)
- [ ] Apply SOLID principles where natural
- [ ] Consider what new code reveals about existing code
- [ ] Run tests after each refactor step

**Never refactor while RED.** Get to GREEN first.

## Checklist Per Cycle

```
[ ] Test describes behavior, not implementation
[ ] Test uses public interface only
[ ] Test would survive internal refactor
[ ] Code is minimal for this test
[ ] No speculative features added
```
