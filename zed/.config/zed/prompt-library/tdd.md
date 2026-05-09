# @tdd
> Invoke: type @tdd in Zed agent panel to activate this workflow

# Test-Driven Development

## Philosophy

**Core principle**: Tests should verify behavior through public interfaces, not implementation details. Code can change entirely; tests shouldn't.

**Good tests** are integration-style: they exercise real code paths through public APIs. They describe _what_ the system does, not _how_ it does it. A good test reads like a specification - "user can checkout with valid cart" tells you exactly what capability exists. These tests survive refactors because they don't care about internal structure.

**Bad tests** are coupled to implementation. They mock internal collaborators, test private methods, or verify through external means (like querying a database directly instead of using the interface). The warning sign: your test breaks when you refactor, but behavior hasn't changed.

## Anti-Pattern: Horizontal Slices

**DO NOT write all tests first, then all implementation.** This is "horizontal slicing" - treating RED as "write all tests" and GREEN as "write all code."

This produces **bad tests**:

- Tests written in bulk test _imagined_ behavior, not _actual_ behavior
- You end up testing the _shape_ of things (data structures, function signatures) rather than user-facing behavior
- Tests become insensitive to real changes - they pass when behavior breaks, fail when behavior is fine
- You outrun your headlights, committing to test structure before understanding the implementation

**Correct approach**: Vertical slices via tracer bullets. One test → one implementation → repeat.

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

Before writing any code:

- [ ] Confirm what interface changes are needed
- [ ] Confirm which behaviors to test (prioritize)
- [ ] Identify opportunities for deep modules (small interface, deep implementation)
- [ ] Design interfaces for testability
- [ ] List the behaviors to test (not implementation steps)

Ask: "What should the public interface look like? Which behaviors are most important to test?"

**You can't test everything.** Focus testing effort on critical paths and complex logic, not every possible edge case.

### 2. Tracer Bullet

Write ONE test that confirms ONE thing about the system:

```
RED:   Write test for first behavior → test fails
GREEN: Write minimal code to pass → test passes
```

**Hard gate — RED required before any production code edit:**

After writing the test, run the test suite and confirm the test FAILS. Capture the failure output verbatim. You may not create or edit any production code file until you have a recorded test failure.

If the test passes immediately, the test is wrong — rewrite it to actually exercise the unimplemented behavior.

This is a hard process gate, not a guideline. Skipping RED is the most common TDD violation.

### Fake-green detection

A test that passes on the first run is fake-green — the test is wrong, not the code. Common patterns to recognize and avoid:

1. **Tautological assertion** — asserting `hash(x) == hash(x)` is always true.
2. **Test verifies pre-existing behavior** — the code already does this; you're not testing the new delta.
3. **Test exercises wrong layer** — testing a util function when acceptance is integration-level.
4. **Import/module-not-found masquerading as RED** — an import error is not behavior-red. Always pair the import with an assertion against actual behavior.

**Required action when first run is green:**

Stop. Re-examine the test:
- What new behavior does this ticket promise?
- Does my assertion fail in a world where that behavior doesn't exist yet?
- Can I write a value or scenario that the current system cannot satisfy?

Rewrite the test to fail for the right reason. Re-run. Only proceed once you have RED for the actual feature being added.

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

After all tests pass:

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
