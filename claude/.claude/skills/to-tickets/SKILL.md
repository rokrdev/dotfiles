---
name: to-tickets
description: Break a plan, spec, or PRD into local kanban tickets written to .workflow/kanban/backlog/NN-slug.md using tracer-bullet vertical slices. No issue-tracker API required. Use when user wants to convert a PRD or spec into kanban tickets.
---

# To Tickets

Break a plan into independently-workable tickets using vertical slices (tracer bullets).
Writes each ticket to `.workflow/kanban/backlog/NN-slug.md` in the project root.
The PRD from `/to-prd` is the canonical input — run that first if you have only a spec.

See `docs/kanban-workflow.md` for the full design context, eligibility rules, and parallel-dispatch logic.

---

## Process

### 1. Gather context

Work from whatever is in the conversation context. If the user passes a path to a PRD
or spec file, read it. If a PRD was just produced by `/to-prd` (in `.workflow/docs/<slug>.md`), use that directly.

### 2. Explore the codebase (optional)

If not already explored, do so to understand current structure. Slugs/titles should use the project's domain vocabulary.

### 3. Draft vertical slices

Break the plan into **tracer bullet** tickets — each a thin vertical slice cutting through ALL integration layers, NOT a horizontal slice of one layer.

<vertical-slice-rules>
- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable via its acceptance sentence
- Prefer many thin slices over few thick ones
- Body cap: ~40 lines per ticket
- Acceptance tests are thin probes of one observable delta, not full integration sweeps. Re-asserting behavior verified by a dependency ticket's acceptance test is forbidden.
- "Observable" means verifiable at any external surface: CLI invocation, HTTP call, or a public test harness entry-point — internal module calls are not observable surfaces
- Prefer AFK (`human-required: false`) over HITL (`human-required: true`) where possible. HITL blocks kanban-loop until a human reviews and approves.
</vertical-slice-rules>

### When to mark `human-required: true` (HITL)

Mark a ticket HITL when completing it requires a judgment call no autonomous agent should make alone:

- **Architecture decisions** — choosing between two valid designs with non-obvious trade-offs (e.g., event sourcing vs. CQRS, sync vs. async queue)
- **Design or UX review** — visual, interaction, or API surface choices that need a human eye before merging
- **Security-sensitive changes** — auth flows, permission models, data exposure decisions, cryptographic choices
- **Ambiguous scope** — acceptance criterion cannot be written unambiguously without a product decision
- **Cross-cutting refactors** — changes touching ≥4 modules with unclear blast radius

Everything else is AFK. Default is AFK; omit `human-required` or set `false`.

**Hard constraints (enforced in self-check, step 7.5):**

- Every ticket delivers **user-observable behavior end-to-end** — not an internal module in isolation
- If acceptance is a CLI/UI/HTTP invocation, the entry-point file (e.g. `src/cli.*`, `src/main.*`, `src/server.*`) **MUST** appear in `files-touched`; acceptance tests must exercise the entry-point (spawn binary, send HTTP request) — NOT call internal functions directly
- **Forbidden framings:** "scaffold X module", "extract Y util", "refactor Z" — horizontal slices; must not appear as standalone tickets
- **Walking skeleton exception (max 1 per board):** `skeleton: true` in frontmatter — scaffolds build toolchain + hello-world entry-point. Acceptance must be a runnable binary command (e.g. `java -jar app.jar --help` exits 0). All other tickets must depend on this skeleton.
- **Support tickets (max 2 per board):** `support: true` — delivers a pure internal module (e.g. domain value types, fare table) only when blocked-by zero tickets and ≥1 vertical ticket lists it in `depends-on`. Acceptance must be a passing unit-test suite for the module's public API. Once 2 used, remaining internal work absorbed into vertical slices.

For each slice, determine:
- **slug**: kebab-case, concise (becomes the filename suffix)
- **language**: routes to the correct specialist (`typescript`, `python`, `kotlin`, `swift`)
- **depends-on**: list of slugs (not IDs) that must be in `done/` first; use slugs so refs survive renumber
- **parallel-safe**: `true` only when `files-touched` has zero overlap with ALL other eligible tickets; if two sibling tickets both touch the entry-point file, both must be `false`
- **files-touched**: list of paths/dirs the implementation will modify — must include every layer the acceptance requires (entry-point, command handler, store, etc.)
- **acceptance**: one sentence a human (or test) can verify

**Parallel-safe overlap check:** After drafting all tickets, list every file in each ticket's `files-touched` and intersect with siblings. Any shared file → set `parallel-safe: false` for **both** tickets.

### 4. Run cycle detection before quizzing

Before presenting the breakdown, build the dependency graph and verify it is acyclic.

```python
# Cycle detection — run mentally or as a shell snippet
import graphlib

graph = {
    "slug-a": {"slug-b"},   # slug-a depends on slug-b
    "slug-b": set(),
    # ... one entry per ticket
}

ts = graphlib.TopologicalSorter(graph)
try:
    order = list(ts.static_order())   # raises CycleError if cyclic
    print("Acyclic. Topo order:", order)
except graphlib.CycleError as e:
    print("CYCLE DETECTED:", e)
    # Planning must stop. Ask user to replan.
```

Shell alternative (if Python unavailable):
```sh
# Build edges file: "dependency dependent" one per line, then:
tsort edges.txt 2>&1 | grep -q "has a loop" && echo "CYCLE" || echo "OK"
```

If a cycle is detected: **stop, report the cycle to the user, do not write any files.**

### 5. Quiz the user

Present numbered list. For each ticket: slug, language, depends-on, parallel-safe, human-required (HITL/AFK), files-touched, acceptance. Ask: granularity right? deps correct? merge/split? parallel-safe flags correct? HITL/AFK classification correct? Iterate until approved.

### 6. Assign IDs in topological order

After approval, assign zero-padded integers (`00`, `01`, `02`, …) in topo sort order. Slugs in `depends-on` are the stable reference; IDs only for filename ordering.

### 7. Write ticket files

For each ticket, write `.workflow/kanban/backlog/NN-slug.md` (create `.workflow/kanban/backlog/` if missing).

```
.workflow/
└── kanban/
    └── backlog/
        ├── 00-cli-scaffold.md
        ├── 01-store-short-url.md
        └── ...
```

Use this template for each file:

```markdown
---
id: <NN as integer>
slug: <slug>
language: <typescript|python|kotlin|swift>
depends-on: [<slug-a>, <slug-b>]   # omit field if empty
parallel-safe: false
human-required: false               # true = HITL (kanban-loop pauses for human review); omit or false = AFK
files-touched: [src/foo/, test/foo/]
acceptance: "<One sentence a human or test can verify>"
---

## Context

Why this ticket exists. What problem it solves. Max 5 sentences.

## Acceptance Test

Restate the acceptance sentence from frontmatter, then add any sub-conditions:
- Sub-condition 1
- Sub-condition 2

## Failing Tests (write these FIRST, run RED before any src/ edit)

### Unit Tests

Test individual functions, handlers, and data-layer logic in isolation — do NOT call the entry-point binary or spin up a server.

- `test/<file>_test.<ext>::<test_name_snake_case>` — what it asserts (one line)

### Acceptance Tests

Exercise the full vertical slice via the entry point (CLI binary, HTTP request, UI interaction). Must match how a real user triggers the feature.

- `test/<file>_test.<ext>::<test_name_snake_case>` — what it asserts (one line)

## Files to Touch

- `src/foo/bar.<ext>` — new file
- `src/foo/mod.<ext>` — export new handler
- `test/foo/bar_test.<ext>` — new test

## Related Tickets

- depends on: `<slug>` (or "none")
- unblocks: `<slug>` (or "none")
```

### 8. Self-check before writing files

**Cap enforcement (board-wide):**
- [ ] At most **1** ticket has `skeleton: true`; excess → convert to vertical slices
- [ ] At most **2** tickets have `support: true`; excess → absorb into vertical slices

**Per-ticket checks** (revise before writing; do NOT emit horizontal tickets):

- [ ] User can demo by running the binary/UI — not by calling an internal function
  - `skeleton: true` exception: acceptance is a runnable binary command (e.g. `./app --help` exits 0)
  - `support: true` exception: acceptance is a passing unit-test suite for the module's public API; zero `depends-on`; ≥1 vertical ticket lists its slug in `depends-on`
- [ ] `files-touched` includes every layer for acceptance to pass (entry-point, handler, store, tests)
  - `support: true` exception: only module source + unit tests (no entry-point required)
- [ ] Acceptance test invocation matches real user trigger (CLI command, HTTP request, UI interaction)
  - `support: true` exception: acceptance test is a unit-test suite for the module's public API
- [ ] If acceptance is CLI/UI/HTTP call, entry-point file is in `files-touched`
  - `skeleton: true` and `support: true` excepted as above
- [ ] `failing-tests` lists ≥1 **unit test** AND ≥1 **acceptance test** asserting ONLY the new observable behavior this slice introduces. If extending a dependency ticket's acceptance test, add an assertion to that test file rather than a new function — name the exact file and assertion in `## Failing Tests`.
  - `support: true` exception: only unit tests required; `skeleton: true` exception: only acceptance test for runnable binary (unit tests optional)
- [ ] `human-required` has been explicitly considered: set `true` (HITL) only for arch decisions, design review, security choices, ambiguous scope, or cross-cutting refactors; all other tickets omit or set `false` (AFK)

### 9. Report

After writing all files, output:
- Number of tickets written
- Topological order (slug sequence)
- Any tickets marked `parallel-safe: true` (candidates for parallel dispatch)
- Reminder: run `kanban-loop` to begin draining the backlog

---

## Frontmatter Schema

| Field | Required | Notes |
|-------|----------|-------|
| `id` | yes | Integer matching NN prefix; unique |
| `slug` | yes | Kebab-case; matches filename after `NN-` |
| `language` | yes | Routes specialist: `typescript`, `python`, `kotlin`, `swift` |
| `depends-on` | no | List of slugs in `.workflow/kanban/done/` required before eligible; omit if none |
| `parallel-safe` | no | Default `false`; `true` only when `files-touched` has zero overlap with ALL other eligible tickets; any shared file (including the entry-point) → `false` for both tickets |
| `human-required` | no (boolean) | Default `false` (AFK — agent can complete and merge unattended). Set `true` (HITL) for arch decisions, design/UX review, security-sensitive changes, ambiguous scope, or cross-cutting refactors spanning ≥4 modules. HITL tickets pause kanban-loop for human decision before dispatch. |
| `files-touched` | no | Paths/dirs implementation will modify — used for parallel overlap detection |
| `acceptance` | yes | One sentence a human or test can verify |
| `failing-tests` | required, list[string] | Test function names to write FIRST and run RED before any src/ edit. Format: `path/to/test.ext::test_name_in_snake_case`. Must include ≥1 unit test (logic in isolation) AND ≥1 acceptance test that asserts only the observable delta this slice introduces. Extend an existing acceptance test from a dependency ticket rather than duplicating entry-point coverage. |
| `skeleton` | no (boolean) | `true` marks the single walking-skeleton ticket. Max 1 per board. Acceptance must be a runnable binary command (e.g. `./app --help` exits 0). All other tickets must depend on this ticket's slug. Omit for all other tickets. |
| `support` | no (boolean) | `true` marks a pure internal-module ticket (e.g. domain value types, fare table). Max 2 per board. Must have empty `depends-on`; at least one vertical ticket must list this slug in its `depends-on`. Acceptance must be a passing unit-test suite for the module's public API — not an entry-point invocation. Omit for all other tickets. |

---

## Eligibility Rule (for reference — enforced by kanban-loop)

A ticket is **eligible** when every slug in its `depends-on` list has a matching file in `done/`:

```
eligible(ticket) ⟺ ∀ slug ∈ ticket.depends-on: ∃ file .workflow/kanban/done/NN-{slug}.md
```

---

## Vertical Slice Examples

### ❌ Bad — horizontal slice

```yaml
slug: store-short-url
acceptance: "shorten(url, db) returns a 6-char code"
files-touched: [src/store.<ext>, test/store_test.<ext>]
parallel-safe: true
```

Fails self-check: acceptance calls an internal function; the entry-point is absent; a specialist ships the store but no CLI subcommand is registered — acceptance cannot be verified by a user.

### ✅ Good — vertical slice

```yaml
slug: shorten-command
acceptance: "running the CLI `shorten https://example.com` prints a 6-char code"
files-touched: [src/cli.<ext>, src/store.<ext>, test/cli_test.<ext>]
parallel-safe: false   # entry-point also touched by other tickets
```

Entry-point present, acceptance exercises the binary, all layers covered.

---

## Next Step

> **Tickets created.** Run `/kanban-loop` next to drain the backlog — it will pick eligible tickets, dispatch TDD subagents, and gate on green tests.

Do NOT start implementation. Your job ends here.
