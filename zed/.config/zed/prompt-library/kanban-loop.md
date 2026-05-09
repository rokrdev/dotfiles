# @kanban-loop

Drains `.kanban/backlog/` → `doing/` → `done/` by working through tickets serially in this
conversation, one at a time. TDD (red → green → refactor) is required for every ticket.

**Single-agent serial execution.** There is no parallel mode and no subagent dispatch. You work
through tickets yourself, in order, in this conversation.

**Context overflow:** If context grows large mid-loop, invoke `@session-handoff` to produce a
structured summary. Start a new conversation, paste the handoff summary, then resume by running
`@kanban-loop` again — it will pick up from the first ticket still in `doing/` or `backlog/`.

---

## Step 0 — Branch Pre-flight

Runs once at startup, before processing any ticket.

### 1. Detached HEAD check

Run: `git rev-parse --abbrev-ref HEAD`

If output is `HEAD` → abort:
```
ERROR: Detached HEAD state. Checkout a branch before running kanban-loop.
```

### 2. Dirty working tree check

Run: `git status --porcelain`

If output is non-empty → abort:
```
ERROR: Uncommitted changes detected. Stash or commit them before running kanban-loop.
```

### 3. Protected branch detection

Protected branches (hardcoded): `main`, `master`, `develop`

**If NOT on a protected branch** → skip silently, log `Using branch: <name>`, proceed to Step 1.

**If on a protected branch** → show branch prompt.

### 4. Branch prompt

When passed `--branch <name>` (e.g. `@kanban-loop --branch feat/my-feature`):

```
─────────────────────────────────────────────
  You are on <branch>. Create a branch?

  Suggested: <name>

  1. Yes — use suggested name
  2. Yes — enter custom name
  3. Stay on <branch>
─────────────────────────────────────────────
```

Wait for user to choose [1-3].

When no `--branch` given:

```
─────────────────────────────────────────────
  You are on <branch>. Enter a branch name to
  create, or type SKIP to stay on <branch>:
─────────────────────────────────────────────
```

### 5. Branch name collision

Check: `git show-ref --verify --quiet refs/heads/<name>`

If exists → auto-append `-2`, `-3`, etc. until unused. Show resolved name before creating.

### 6. Branch creation

```bash
git checkout -b <resolved-name>
```

Confirm branch created, then proceed to Step 1.

---

## Step 1 — Pre-flight

Verify board structure:

```
.kanban/backlog/    ← tickets waiting
.kanban/doing/      ← tickets in-flight
.kanban/done/       ← completed tickets
```

If any directory is missing → abort:
```
ERROR: .kanban/ board not initialised.
Run @to-tickets to populate backlog/, or create the three columns manually.
```

**Validate every ticket** in `backlog/` and `doing/`:

Required fields: `id` (integer), `slug` (kebab-case, matches `NN-{slug}.md`), `language`,
`acceptance` (non-empty string). Any violation → abort, list all bad tickets with field name.

**Stuck-ticket check** — any file in `doing/` older than 60 minutes → pause, show list, ask:
- `retry` — move back to `backlog/`, continue
- `skip` — leave in `doing/`, continue ignoring it
- `abort` — stop entirely

---

## Step 2 — Eligibility Resolver

Collect done slugs from `done/` filenames. For each ticket in `backlog/`, parse frontmatter and
check if all `depends-on` slugs are in done slugs. Collect eligible tickets, sort by `id` ascending.

**Deadlock** — eligible is empty and `backlog/` is non-empty → list unmet dependencies, abort.
Human must resolve before resuming.

**Done** — eligible is empty and `backlog/` is empty → print summary, exit loop.

---

## Step 3 — Work the Ticket (Serial)

Pick the eligible ticket with the lowest `id`. Work through it directly in this conversation.

1. `mv .kanban/backlog/NN-slug.md .kanban/doing/NN-slug.md`
2. Read the ticket file in full (frontmatter + body).
3. Apply TDD — red → green → refactor:

**Red first (mandatory):**
- Write the failing test file(s) first
- Detect the project's test runner:
  - `package.json` present → `npm test` / `pnpm test` / `yarn test`
  - `pyproject.toml` / `setup.py` present → `pytest` (or `uv run pytest`)
  - `Package.swift` present → `swift test`
  - `build.gradle` / `build.gradle.kts` present → `./gradlew test`
  - `Cargo.toml` present → `cargo test`
  - `Makefile` with `test` target → `make test`
- Run the test suite against the new test file — capture the RED output
- Record the failure output under `## Red Output` heading in your working notes
- Only after a recorded test failure may you touch any production code file

The test must produce a real assertion failure. If the first run shows all tests passing or
only import/resolution errors (for modules not being created by this ticket), the test is fake.
Rewrite it to exercise the unimplemented behaviour, then re-run before touching src/ files.

**Green:** Write the minimum implementation to make the test pass.

**Refactor:** Clean up without breaking tests.

4. Stay within the paths listed in `files-touched`. If you need to touch an unlisted file →
   stop, explain to the user which file and why, ask whether to expand scope or redesign.
5. Success criterion: the `acceptance` sentence from frontmatter. At least one test must map to it.

---

## Step 4 — Verification Gate

Before moving the ticket to `done/`, verify all gates yourself:

```
Gate 0 — Red-first verified
  Your Red Output section contains test runner output showing ≥1 assertion failure,
  captured before any production code was edited.
  NOT valid: green-on-first-run, import errors for unrelated modules.

Gate 1 — Tests green
  Full test suite exits 0. Zero failures, zero errors.

Gate 2 — Acceptance verifiable
  The acceptance sentence maps to at least one named test,
  OR you document exact manual verification steps.

Gate 3 — Scope clean
  Only files listed in files-touched were modified.
  No uncommitted unrelated changes.
```

**All gates pass:**

1. Run full test suite (not just ticket paths) — must exit 0. If red → fix before proceeding.
2. Stage only files in `files-touched`:
   ```bash
   git add <file1> <file2> ...   # explicit paths only, never git add -A or git add .
   ```
3. Commit with conventional format:
   ```
   <type>(<scope>): <ticket title>

   Ticket: <ticket-id>
   <acceptance criterion>

   Co-Authored-By: Claude Sonnet <noreply@anthropic.com>
   ```
   Message must start with `<type>(<scope>):` — if not, fix before committing.
4. `mv .kanban/doing/NN-slug.md .kanban/done/NN-slug.md`

**Any gate fails:**
- Append `## Failure — <gate number>\n<reason>` to the ticket body
- `mv .kanban/doing/NN-slug.md .kanban/backlog/NN-slug.md`
- Report the failure to the user with gate number, reason, and ticket name
- Increment failure counter. If 3+ consecutive failures → circuit breaker: halt, surface all
  failed tickets, ask user to intervene before continuing.

---

## Step 5 — Loop

Return to Step 2. Repeat until a stop condition is reached:

| Condition | Action |
|-----------|--------|
| `backlog/` empty, `doing/` empty | Normal exit — print summary |
| `eligible` empty, `backlog/` non-empty | Deadlock — list unmet deps, halt |
| User types abort | Halt, leave state as-is, print partial summary |
| 3+ consecutive ticket failures | Circuit breaker — halt, surface all failed tickets |

**Summary format:**

```
kanban-loop complete
  Done:    N tickets
  Failed:  M tickets (in backlog/ with failure notes)
  Skipped: K tickets
```

---

## Anti-patterns

- **Never write to `done/` without all gates passing** — partial work is worse than no work.
- **Never continue after deadlock** — surface it. A deadlock means ticket dependencies are broken. Human fix required.
- **Never accept fake-green tests** — if the test passed on first run without implementation, it does not test the right thing.
- **Never touch files outside `files-touched`** — fail Gate 3 and push back to backlog. Scope drift compounds.
- **Never use `git add -A` or `git add .`** — stage only the explicit files listed in the ticket.
