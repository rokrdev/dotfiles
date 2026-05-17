---
name: kanban-loop
description: 'Use to drain a local .workflow/kanban/ board of vertical-slice tickets. Picks eligible tickets (deps satisfied), dispatches a fresh specialist subagent per ticket running TDD, moves files between columns. Triggers: "drain the board", "run kanban", "/kanban-loop", or after to-tickets fills backlog/.'
---

# kanban-loop

Drains `.workflow/kanban/backlog/` → `doing/` → `done/` by dispatching fresh specialist subagents
running TDD per ticket. See `docs/kanban-workflow.md` for full design rationale.

## Commands

| Command | Behaviour |
|---------|-----------|
| `/kanban-loop` | Serial mode — one ticket at a time |
| `/kanban-loop --parallel` | Parallel mode — dispatch all eligible `parallel-safe` tickets with no file-overlap at once |
| `/kanban-loop --dry-run` | Resolve eligibility, print dispatch plan — no moves, no subagents |
| `/kanban-loop --branch <name>` | Pass suggested branch name to pre-flight prompt (used by feature-flow and bug-flow) |

---

## Step 0 — Branch Pre-flight

Runs once at startup. Prevents per-ticket commits landing on protected branches.

**Checks (abort on fail):**
- `git rev-parse --abbrev-ref HEAD` → if `HEAD`: `ERROR: Detached HEAD state. Checkout a branch before running kanban-loop.`
- `git status --porcelain` → if non-empty: `ERROR: Uncommitted changes detected. Stash or commit them before running kanban-loop.`

**Protected branches** (hardcoded): `main`, `master`, `develop`

- Not on protected branch → log `Using branch: <name>`, proceed to Step 1.
- On protected branch → show branch prompt:

With `--branch <name>`:
```
─────────────────────────────────────────────
  You are on <branch>. Create a branch?
  Suggested: <name>
  1. Yes — use suggested name
  2. Yes — enter custom name
  3. Stay on <branch>
─────────────────────────────────────────────
```
- **1**: use `<name>` (check collision); **2**: prompt for name then check collision; **3**: warn and proceed to Step 1.

Without `--branch`:
```
─────────────────────────────────────────────
  You are on <branch>. Enter a branch name to
  create, or type SKIP to stay on <branch>:
─────────────────────────────────────────────
```
If `SKIP` → warn and proceed. Otherwise use typed name.

**Collision check:** `git show-ref --verify --quiet refs/heads/<name>` — if exists, auto-append `-2`, `-3`, etc. Show resolved name before creating.

**Branch creation:** `git checkout -b <resolved-name>` → confirm, proceed to Step 1.

---

## Step 1 — Pre-flight

### 0. Migrate legacy .kanban/ board (if present)

If `.kanban/` exists and `.workflow/kanban/` does not, run:

```bash
mv .kanban/ .workflow/kanban/
```
Log: "Migrated .kanban/ → .workflow/kanban/"

This handles projects that ran kanban-loop before the `.workflow/` path change.

Check board structure exists:

```
.workflow/kanban/backlog/    ← tickets waiting
.workflow/kanban/doing/      ← tickets in-flight
.workflow/kanban/done/       ← completed tickets
```

If any directory is missing → abort with:

```
ERROR: .workflow/kanban/ board not initialised.
Run `to-tickets` to populate backlog/, or create the three columns manually.
```

**Validate every ticket** in `backlog/` and `doing/`:

Required fields: `id` (integer), `slug` (kebab-case, matches `NN-{slug}.md`), `language`, `acceptance` (non-empty string). Any violation → abort, list all bad tickets with field name.

**Stuck-ticket check** — for each file in `doing/` older than 3600s:

```python
import os, time
for f in os.listdir(".workflow/kanban/doing"):
    age = time.time() - os.path.getmtime(f".workflow/kanban/doing/{f}")
    if age > 3600:
        print(f"STUCK ({int(age//60)}min): {f}")
```

If stuck tickets found → pause, ask user: `retry` (→ backlog) / `skip` (ignore) / `abort`.

---

## Step 2 — Eligibility Resolver

```python
import os, re, yaml  # drop into ctx_execute for dry-run preview

done_slugs = set()
for f in os.listdir(".workflow/kanban/done"):
    m = re.match(r"\d+-(.+)\.md", f)
    if m:
        done_slugs.add(m.group(1))

eligible = []
for f in sorted(os.listdir(".workflow/kanban/backlog")):
    path = f".workflow/kanban/backlog/{f}"
    with open(path) as fh:
        body = fh.read()
    fm = yaml.safe_load(body.split("---")[1])
    deps = fm.get("depends-on") or []
    if all(d in done_slugs for d in deps):
        eligible.append((fm["id"], f, fm))

eligible.sort(key=lambda x: x[0])  # lowest id first

if not eligible and os.listdir(".workflow/kanban/backlog"):
    blocked = []
    for f in os.listdir(".workflow/kanban/backlog"):
        with open(f".workflow/kanban/backlog/{f}") as fh:
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

### 3a — HITL check (before dispatch)

Read the frontmatter `human-required` field (boolean, default `false`).

If `human-required: true` — **do NOT dispatch a subagent**. Instead:

1. Move ticket to `doing/` with a HITL marker appended to the filename:
   `mv .workflow/kanban/backlog/NN-slug.md .workflow/kanban/doing/NN-slug.md`
2. Surface the ticket to the user:

   ```
   ─────────────────────────────────────────────
     HITL REQUIRED: NN-slug
     Path: .workflow/kanban/doing/NN-slug.md
     Acceptance: <acceptance sentence>

     This ticket requires human review before an agent can proceed.
     Read the ticket, make any decisions, then type:
       proceed   — dispatch specialist subagent normally
       edit      — you will edit the ticket file; re-run kanban-loop after
       skip      — move back to backlog, continue with next eligible ticket
       abort     — halt the loop
   ─────────────────────────────────────────────
   ```

3. Wait for user input:
   - `proceed` → continue with steps 1–5 below (dispatch subagent normally)
   - `edit` → move ticket back to `backlog/`; halt loop so user can edit; tell user to re-run `/kanban-loop` when ready
   - `skip` → move ticket back to `backlog/`; continue loop with next eligible ticket
   - `abort` → halt loop, leave state as-is, print partial summary

If `human-required: false` or field absent — proceed directly to step 1 below.

1. `mv .workflow/kanban/backlog/NN-slug.md .workflow/kanban/doing/NN-slug.md`
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
You are working on ticket .workflow/kanban/doing/NN-slug.md.

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
  Report includes `## Red Output` captured BEFORE any src/ edit, showing ≥1 actual
  assertion failure ("failed", "FAILED", "AssertionError", "expected ... to ...").
  NOT valid: green-on-first-run; import errors for modules the ticket doesn't create.
  Fail if: Red Output absent; 0 failures; only import errors; test file timestamp
  later than any src/ file in files-touched.
  On fail: append `## Failure — Gate 0 (fake-green)` to ticket body, push to backlog.

Gate 1 — Tests green: all tests for files-touched exit 0. Zero failures, zero errors.

Gate 2 — Acceptance verifiable: acceptance sentence maps to ≥1 named test, or agent
  documents exact manual verification steps.

Gate 3 — Scope clean: only files-touched modified. No uncommitted unrelated changes.
```

**All gates pass** →

1. **Run full test suite** (not just ticket-scoped paths) — must exit 0. If red, fail Gate 1 and push back to backlog.
2. **Stage only files in `files-touched`** — use `git add <file1> <file2> ...` with explicit paths. Never `git add -A` or `git add .`.
3. **Commit** with conventional format:
   ```
   <type>(<scope>): <ticket title>

   <acceptance criterion>

   Co-Authored-By: Claude <noreply@anthropic.com>
   ```
   Validate: message must start with `<type>(<scope>):` — if not, reject and prompt subagent to fix.
4. `mv .workflow/kanban/doing/NN-slug.md .workflow/kanban/done/NN-slug.md`

**Any gate fails:**
- Append failure note to ticket body: `## Failure — <gate number>\n<reason>`
- `mv .workflow/kanban/doing/NN-slug.md .workflow/kanban/backlog/NN-slug.md`
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
| `eligible` empty, `.workflow/kanban/backlog/` non-empty | Deadlock — list unmet deps, halt |
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

- **Never run TDD logic inline** — dispatch a fresh specialist subagent per ticket; inline execution pollutes the orchestrator's window.
- **Never write to `done/` without all gates passing** — partial work is worse than no work.
- **Never continue after deadlock** — broken dependency graph; human fix required.
- **Never accept files modified outside `files-touched`** — fail Gate 3, push to backlog.
- **Never dispatch multiple tickets onto the same worktree** — one worktree per ticket.
- **Never stage or commit `.workflow/` files** — ephemeral board state, globally gitignored. Any `.workflow/` path in `files-touched` → fail Gate 3 immediately.
- **Never auto-drain HITL tickets** — `human-required: true` must surface to the user and pause the loop. Silently dispatching a subagent on a HITL ticket bypasses the review gate it exists to enforce.

---

## Related skills

- `to-tickets` — fills `.workflow/kanban/backlog/` from a spec; run before this skill
- `tdd` — the TDD loop run **inside** each ticket's subagent; see
  `~/.claude/skills/tdd/SKILL.md`
- Design doc: `docs/kanban-workflow.md` — full rationale, schema, parallel rules, stuck-ticket
  detection, verification gates, demo project

---

## Next Step

> **Backlog drained.** All tickets committed. Run `/ship-it` next to push the branch and open a PR.
