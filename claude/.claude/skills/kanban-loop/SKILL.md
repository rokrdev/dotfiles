---
name: kanban-loop
description: Use to drain a local .kanban/ board of vertical-slice tickets. Picks eligible tickets (deps satisfied), dispatches a fresh specialist subagent per ticket running TDD, moves files between columns. Triggers: "drain the board", "run kanban", "/kanban-loop", or after to-tickets fills backlog/.
---

# kanban-loop

Drains `.kanban/backlog/` → `doing/` → `done/` by dispatching fresh specialist subagents
running TDD per ticket. See `docs/kanban-workflow.md` for full design rationale.

## Commands

| Command | Behaviour |
|---------|-----------|
| `/kanban-loop` | Serial mode — one ticket at a time |
| `/kanban-loop --parallel` | Parallel mode — dispatch all eligible `parallel-safe` tickets with no file-overlap at once |
| `/kanban-loop --dry-run` | Resolve eligibility, print dispatch plan — no moves, no subagents |

---

## Step 1 — Pre-flight

Check board structure exists:

```
.kanban/backlog/    ← tickets waiting
.kanban/doing/      ← tickets in-flight
.kanban/done/       ← completed tickets
```

If any directory is missing → abort with:

```
ERROR: .kanban/ board not initialised.
Run `to-tickets` to populate backlog/, or create the three columns manually.
```

**Validate every ticket** in `backlog/` and `doing/`:

Required fields: `id` (integer), `slug` (kebab-case, matches `NN-{slug}.md`), `language`,
`acceptance` (non-empty string). Any violation → abort, list all bad tickets with field name.

**Stuck-ticket check** — for each file in `doing/`:

```python
import os, time
for f in os.listdir(".kanban/doing"):
    age = time.time() - os.path.getmtime(f".kanban/doing/{f}")
    if age > 3600:
        print(f"STUCK ({int(age//60)}min): {f}")
```

If any stuck tickets found → pause, show list, ask user:
- `retry` — move back to `backlog/`, continue loop
- `skip` — leave in `doing/`, continue loop ignoring it
- `abort` — stop entirely

---

## Step 2 — Eligibility Resolver

```python
import os, re, yaml  # drop into ctx_execute for dry-run preview

done_slugs = set()
for f in os.listdir(".kanban/done"):
    m = re.match(r"\d+-(.+)\.md", f)
    if m:
        done_slugs.add(m.group(1))

eligible = []
for f in sorted(os.listdir(".kanban/backlog")):
    path = f".kanban/backlog/{f}"
    with open(path) as fh:
        body = fh.read()
    fm = yaml.safe_load(body.split("---")[1])
    deps = fm.get("depends-on") or []
    if all(d in done_slugs for d in deps):
        eligible.append((fm["id"], f, fm))

eligible.sort(key=lambda x: x[0])  # lowest id first

if not eligible and os.listdir(".kanban/backlog"):
    blocked = []
    for f in os.listdir(".kanban/backlog"):
        with open(f".kanban/backlog/{f}") as fh:
            fm = yaml.safe_load(fh.read().split("---")[1])
        unmet = [d for d in (fm.get("depends-on") or []) if d not in done_slugs]
        blocked.append((f, unmet))
    print("DEADLOCK — unmet dependencies:")
    for fname, unmet in blocked:
        print(f"  {fname}: needs {unmet}")
```

**Deadlock** — if `eligible` is empty and `backlog/` is non-empty → surface the blocked list,
abort. Do not continue. Human must resolve.

**Done** — if `eligible` is empty and `backlog/` is empty → print summary, exit.

---

## Step 3 — Dispatch (Serial, default)

For the ticket with the lowest `id`:

1. `mv .kanban/backlog/NN-slug.md .kanban/doing/NN-slug.md`
2. Map `language` → specialist:

| `language` | `subagent_type` |
|------------|----------------|
| `typescript` / `javascript` | `jasper` |
| `python` | `snape` |
| `kotlin` | `conan` |
| `swift` | `swifty` |
| anything else | ask user before dispatching |

3. Dispatch a **fresh subagent** — never run TDD logic inline:

```
subagent_type: <specialist>
mode: "auto"
isolation: "worktree"   ← only when files-touched has > 3 distinct paths
```

### Subagent prompt template

```
You are working on ticket .kanban/doing/NN-slug.md.

1. Read the ticket file in full (frontmatter + body).
2. Invoke the `tdd` skill via the Skill tool — do NOT read the skill file and
   implement inline. The skill drives the full red→green→refactor loop.
2a. **Red-first is mandatory — Gate 0 of the verification gates.**
    Before editing any file under src/ or any production code path, you MUST:
    a. Write the failing test file(s) first
    b. Detect the project's test runner (see stack detection below) and run it against
       the new test file — capture the RED output
    c. Paste the RED failure output into your final report under a `## Red Output` heading
    Only after a recorded test failure may you touch any src/ file.
    If you cannot produce RED output before src/ edits, stop and report NEEDS_CONTEXT.
    The first file you create or edit on this ticket MUST be a test file.
  d. The test must produce an actual assertion failure, not a green-on-first-run.
     If your first test run shows all tests passing or only import errors,
     STOP — your test is fake. Rewrite it to exercise the unimplemented behavior:
       - Add an assertion that requires the new code path
       - Use a value the existing system cannot produce
       - Test the exact behavior the ticket adds, not adjacent existing behavior
     Re-run the test suite. Only proceed to src/ edits once you see real assertion failures.
3. Stay within the paths listed in `files-touched`. If you need to touch a file not listed →
   stop immediately, report NEEDS_CONTEXT to kanban-loop with the file and reason.
4. Acceptance criterion: "<acceptance sentence from frontmatter>"
   This sentence is your success criterion. At least one test must map to it.
5. Use Serena for all code navigation. Fall back to Grep only for non-code files.
6. When tests are green AND acceptance is verifiable, report:
   DONE: <slug>
   Tests: <runner command + exit 0 confirmation>
   Acceptance: <how it was verified — test name or manual check>
   Files changed: <list — must be subset of files-touched>

**Stack detection — choose the test runner:**
- `package.json` present → use npm/pnpm/yarn test (check scripts.test field)
- `pyproject.toml` / `setup.py` present → pytest (or `uv run pytest`)
- `Package.swift` present → `swift test`
- `build.gradle` / `build.gradle.kts` present → `./gradlew test`
- `Cargo.toml` present → `cargo test`
- `Makefile` with a `test` target → `make test`
- When ambiguous, check for a `Makefile` test target or ask the user.
```

---

## Step 4 — Verification Gate (before moving to done/)

The dispatched subagent MUST attest to all gates before kanban-loop moves the file:

```
Gate 0 — Red-first verified (with assertion failure)
  Subagent's report includes a `## Red Output` section with test runner output that:
    a. Was captured BEFORE any src/ file edit (cross-check files-touched ordering)
    b. Shows ≥1 actual assertion failure (look for "failed", "FAILED",
       "AssertionError", "expected ... to ...", or framework-equivalent failure markers)
  
  A green-on-first-run is NOT a valid RED. Module-not-found / import errors only count as
  RED if the missing module is one the ticket creates — otherwise it's an environment bug.
  
  Fail Gate 0 if:
    - Red Output section absent
    - Output shows 0 failures or all-pass
    - Output shows only import/resolution errors with no assertion attempts
    - Test file timestamp is later than any src/ file timestamp listed in files-touched
  
  When Gate 0 fails: append `## Failure — Gate 0 (fake-green)` note to ticket body
  with the actual Red Output for review, push back to backlog.

Gate 1 — Tests green
  All tests for files-touched paths exit 0. Zero failures, zero errors.

Gate 2 — Acceptance verifiable
  The acceptance sentence maps to at least one named test,
  OR the agent documents exact manual verification steps.

Gate 3 — Scope clean
  Only files listed in files-touched were modified.
  No uncommitted unrelated changes.
```

**All gates pass** → `mv .kanban/doing/NN-slug.md .kanban/done/NN-slug.md`

**Any gate fails:**
- Append failure note to ticket body: `## Failure — <gate number>\n<reason>`
- `mv .kanban/doing/NN-slug.md .kanban/backlog/NN-slug.md`
- Warn user with gate number, reason, ticket name
- Increment failure counter. If 3+ consecutive failures → **circuit breaker**: halt loop,
  surface failures, ask user to intervene before continuing.
- Ask user: retry / skip / abort

---

## Step 5 — Parallel Mode (`--parallel`)

Activate when user passes `--parallel` OR backlog has > 5 tickets and any are `parallel-safe: true`.

**Parallel eligibility** — from the eligible set, select tickets where:
- `parallel-safe: true`
- `files-touched` has zero path overlap with any other in-flight ticket

```python
in_flight_paths = set()
parallel_batch = []
for _, fname, fm in eligible:
    touched = set(fm.get("files-touched") or [])
    if fm.get("parallel-safe") and not touched.intersection(in_flight_paths):
        parallel_batch.append((fname, fm))
        in_flight_paths |= touched
```

Dispatch all tickets in `parallel_batch` **in a single message** (multiple Agent tool calls).
Wait for ALL to complete before running the next eligibility pass.

Serial tickets (not parallel-safe, or overlapping) are queued for the next iteration.

---

## Step 6 — Loop

Repeat steps 2–5 until one of the stop conditions is reached:

| Condition | Action |
|-----------|--------|
| `backlog/` empty, `doing/` empty | Normal exit — print summary |
| `eligible` empty, `backlog/` non-empty | Deadlock — list unmet deps, halt |
| User types abort / ctrl-c | Halt, leave state as-is, print partial summary |
| 3+ consecutive ticket failures | Circuit breaker — halt, surface all failed tickets |

**Summary format:**

```
kanban-loop complete
  Done:    N tickets
  Failed:  M tickets (in backlog/ with failure notes)
  Skipped: K tickets
  Time:    ~X min
```

---

## Anti-patterns

- **Never run TDD logic inline** — always dispatch a fresh specialist subagent. Each ticket
  needs clean context; inline execution pollutes the orchestrator's window.
- **Never write to `done/` without all three verification gates passing** — partial work is
  worse than no work.
- **Never continue after deadlock** — surface it. A deadlock means `to-tickets` produced a
  broken dependency graph. Human fix required.
- **Never accept a subagent report that modified files outside `files-touched`** — fail Gate 3,
  push back to backlog. Scope drift compounds across tickets.
- **Never dispatch multiple tickets onto the same worktree** — isolation: worktree means one
  worktree per ticket per dispatch.

---

## Related skills

- `to-tickets` — fills `.kanban/backlog/` from a spec; run before this skill
- `tdd` — the TDD loop run **inside** each ticket's subagent; see
  `~/.claude/skills/tdd/SKILL.md`
- Design doc: `docs/kanban-workflow.md` — full rationale, schema, parallel rules, stuck-ticket
  detection, verification gates, demo project
