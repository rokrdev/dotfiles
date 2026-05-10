# @kanban-loop
> Invoke: type @kanban-loop in Zed agent panel to activate this workflow

> **Context note:** If context grows large during board drain, use @session-handoff to capture state, start a new conversation, and resume with @kanban-loop from where you left off.

Drains `.workflow/kanban/backlog/` → `doing/` → `done/` by working through tickets serially in this conversation using TDD per ticket.

## Commands

| Command | Behaviour |
|---------|-----------|
| `@kanban-loop` | Serial mode — one ticket at a time |
| `@kanban-loop --dry-run` | Resolve eligibility, print plan — no moves, no implementation |
| `@kanban-loop --branch <name>` | Suggested branch name for pre-flight prompt |

---

## Step 0 — Branch Pre-flight

Runs once at startup. Prevents work from landing on protected branches.

### 1. Detached HEAD check

Run: `git rev-parse --abbrev-ref HEAD`

If output is `HEAD` → abort:
```
ERROR: Detached HEAD state. Checkout a branch before running @kanban-loop.
```

### 2. Dirty working tree check

Run: `git status --porcelain`

If output is non-empty → abort:
```
ERROR: Uncommitted changes detected. Stash or commit them before running @kanban-loop.
```

### 3. Protected branch detection

Protected branches (hardcoded): `main`, `master`, `develop`

**If NOT on a protected branch** → skip silently, log `Using branch: <name>`, proceed to Step 1.

**If on a protected branch** → show branch prompt (Step 4).

### 4. Branch prompt

**With `--branch <name>` passed:**

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

- **1**: proceed with `<name>` (check collision first — Step 5)
- **2**: prompt user to type a name, then check collision
- **3**: warn "⚠ Staying on <branch> — commits will land on a protected branch." Proceed to Step 1.

**Without `--branch` (standalone invocation):**

```
─────────────────────────────────────────────
  You are on <branch>. Enter a branch name to
  create, or type SKIP to stay on <branch>:
─────────────────────────────────────────────
```

Wait for user input. If `SKIP` → warn and proceed. Otherwise use typed name (check collision).

### 5. Branch name collision

Check if chosen name exists locally: `git show-ref --verify --quiet refs/heads/<name>`

If exists → auto-append `-2`, `-3`, etc. until an unused name is found. Show resolved name to user before creating.

### 6. Branch creation

```bash
git checkout -b <resolved-name>
```

Confirm branch created, then proceed to Step 1.

---

## Step 1 — Pre-flight

Check board structure exists:

```
.workflow/kanban/backlog/    ← tickets waiting
.workflow/kanban/doing/      ← tickets in-flight
.workflow/kanban/done/       ← completed tickets
```

If any directory is missing → abort with:

```
ERROR: .workflow/kanban/ board not initialised.
Run @to-tickets to populate backlog/, or create the three columns manually.
```

**Validate every ticket** in `backlog/` and `doing/`:

Required fields: `id` (integer), `slug` (kebab-case, matches `NN-{slug}.md`), `language`,
`acceptance` (non-empty string). Any violation → abort, list all bad tickets with field name.

**Stuck-ticket check** — for each file in `doing/`: if mtime > 1 hour ago, flag as STUCK. Pause, show list, ask user:
- `retry` — move back to `backlog/`, continue loop
- `skip` — leave in `doing/`, continue loop ignoring it
- `abort` — stop entirely

---

## Step 2 — Eligibility Resolver

Build the eligible ticket list:

1. Collect all slugs from `.workflow/kanban/done/` (filenames `NN-slug.md` → extract slug portion)
2. For each ticket in `.workflow/kanban/backlog/` (sorted by filename):
   - Parse frontmatter (`depends-on` field)
   - If all listed deps are in done_slugs → ticket is eligible
3. Sort eligible tickets by `id` (lowest first)

**Deadlock** — if eligible is empty and `backlog/` is non-empty → surface blocked list showing each ticket's unmet deps. Halt. Human must resolve.

**Done** — if eligible is empty and `backlog/` is empty → print summary, exit.

---

## Step 3 — Work Ticket (Serial)

> **Note (Zed adaptation):** Zed runs kanban-loop in a single-agent context. TDD runs inline here, unlike the Claude CLI version which dispatches a fresh specialist subagent per ticket. The Claude CLI version is the reference implementation.

Pick the ticket with the lowest `id` from the eligible set.

1. `mv .workflow/kanban/backlog/NN-slug.md .workflow/kanban/doing/NN-slug.md`
2. Read the ticket file in full (frontmatter + body)
3. Work the ticket inline using TDD — red→green→refactor:

### TDD Workflow (inline)

**Red-first is mandatory — Gate 0.**

Before editing any production code (`src/` or equivalent):
1. Write the failing test file(s) first
2. Detect the project's test runner (see stack detection below) and run it against the new test — capture the RED output
3. The test must produce an actual assertion failure, not a green-on-first-run
   - If first run shows all tests passing or only import errors → STOP, rewrite the test to exercise the unimplemented behaviour, re-run until you see real assertion failures
4. Only after a recorded test failure may you touch any production code file

**Stack detection — choose the test runner:**
- `package.json` present → use npm/pnpm/yarn test (check scripts.test field)
- `pyproject.toml` / `setup.py` present → pytest (or `uv run pytest`)
- `Package.swift` present → `swift test`
- `build.gradle` / `build.gradle.kts` present → `./gradlew test`
- `Cargo.toml` present → `cargo test`
- `Makefile` with a `test` target → `make test`
- When ambiguous, ask the user

**Stay within the paths listed in `files-touched`.** If you need to touch a file not listed → stop, report the file and reason to the user, wait for guidance.

**Acceptance criterion** from the ticket frontmatter is your success criterion. At least one test must map to it.

---

## Step 4 — Verification Gate (before moving to done/)

All gates must pass before moving the file:

```
Gate 0 — Red-first verified
  Report includes a "Red Output" section with test runner output that:
    a. Was captured BEFORE any production code edit
    b. Shows ≥1 actual assertion failure

Gate 1 — Tests green
  All tests for files-touched paths exit 0. Zero failures, zero errors.

Gate 2 — Acceptance verifiable
  The acceptance sentence maps to at least one named test,
  OR exact manual verification steps are documented.

Gate 3 — Scope clean
  Only files listed in files-touched were modified.
  No uncommitted unrelated changes.
```

**All gates pass →**

1. Run full test suite (not just ticket-scoped paths) — must exit 0. If red, fail Gate 1 and push back to backlog.
2. Stage only files in `files-touched` — use `git add <file1> <file2> ...` with explicit paths. Never `git add -A` or `git add .`.
3. Commit with conventional format:
   ```
   <type>(<scope>): <ticket title>

   <acceptance criterion>

   Co-Authored-By: Claude <noreply@anthropic.com>
   ```
   Message must start with `<type>(<scope>):` — if not, fix before committing.
4. `mv .workflow/kanban/doing/NN-slug.md .workflow/kanban/done/NN-slug.md`

**Any gate fails:**
- Append failure note to ticket body: `## Failure — <gate number>\n<reason>`
- `mv .workflow/kanban/doing/NN-slug.md .workflow/kanban/backlog/NN-slug.md`
- Warn user with gate number, reason, ticket name
- Increment failure counter. If 3+ consecutive failures → **circuit breaker**: halt loop, surface failures, ask user to intervene
- Ask user: retry / skip / abort

---

## Step 5 — Loop

Repeat Steps 2–4 until one of the stop conditions is reached:

| Condition | Action |
|-----------|--------|
| `.workflow/kanban/backlog/` empty, `doing/` empty | Normal exit — print summary |
| eligible empty, `backlog/` non-empty | Deadlock — list unmet deps, halt |
| User types abort | Halt, leave state as-is, print partial summary |
| 3+ consecutive ticket failures | Circuit breaker — halt, surface all failed tickets |

**Summary format:**

```
@kanban-loop complete
  Done:    N tickets
  Failed:  M tickets (in backlog/ with failure notes)
  Skipped: K tickets
```

---

## Anti-patterns

- **Never write to `.workflow/kanban/done/` without all verification gates passing** — partial work is worse than no work.
- **Never continue after deadlock** — surface it. A deadlock means @to-tickets produced a broken dependency graph. Human fix required.
- **Never accept changes to files outside `files-touched`** — fail Gate 3, push back to backlog.
- **Red-first is non-negotiable** — a test that passes on first run is a fake test.

---

## Related prompts

- `@to-tickets` — fills `.workflow/kanban/backlog/` from a spec; run before this prompt
- `@ship-it` — push branch and open PR after board is drained
