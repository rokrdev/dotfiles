<!--
Adapted from: github.com/mattpocock/skills/to-issues
Adapted: 2026-05-04 for local .kanban/ workflow
See docs/kanban-workflow.md for design context
-->

---
name: to-tickets
description: Break a plan, spec, or PRD into local kanban tickets written to .kanban/backlog/NN-slug.md using tracer-bullet vertical slices. No issue-tracker API required. Use when user wants to convert a PRD or spec into kanban tickets.
---

# To Tickets

Break a plan into independently-workable tickets using vertical slices (tracer bullets).
Writes each ticket to `.kanban/backlog/NN-slug.md` in the project root.
The PRD from `/to-prd` is the canonical input — run that first if you have only a spec.

See `docs/kanban-workflow.md` for the full design context, eligibility rules, and parallel-dispatch logic.

---

## Process

### 1. Gather context

Work from whatever is in the conversation context. If the user passes a path to a PRD
or spec file, read it. If a PRD was just produced by `/to-prd`, use that directly.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand current structure.
Ticket titles and slugs should use the project's domain vocabulary.

### 3. Draft vertical slices

Break the plan into **tracer bullet** tickets. Each ticket is a thin vertical slice that
cuts through ALL integration layers end-to-end, NOT a horizontal slice of one layer.

<vertical-slice-rules>
- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable via its acceptance sentence
- Prefer many thin slices over few thick ones
- Body cap: ~40 lines per ticket
</vertical-slice-rules>

**Vertical slice — hard constraints (enforced in self-check, step 7.5):**

- Every ticket must deliver **user-observable behavior end-to-end** — not an internal module in isolation
- If acceptance is a CLI/UI/HTTP invocation, the entry-point file (e.g. `src/cli.*`, `src/main.*`, `src/server.*`) **MUST** appear in `files-touched`
- Acceptance tests must exercise the entry-point (spawn binary, send HTTP request) — NOT call internal functions directly
- **Forbidden framings:** "scaffold X module", "extract Y util", "refactor Z" — those are horizontal slices and must not appear as standalone tickets

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

Present the proposed breakdown as a numbered list. For each ticket, show:

- **Slug**: `slug-name`
- **Language**: typescript / python / kotlin / swift
- **Depends on**: slugs (or "none")
- **Parallel-safe**: true / false
- **Files touched**: list of paths
- **Acceptance**: one-sentence criterion

Ask the user:
- Does the granularity feel right? (too coarse / too fine)
- Are dependency relationships correct?
- Should any tickets be merged or split further?
- Are `parallel-safe` flags correct?

Iterate until the user approves the breakdown.

### 6. Assign IDs in topological order

After approval, assign numeric IDs using the topological sort order from step 4.
Use zero-padded integers (`00`, `01`, `02`, …).
In 90% of cases, `depends-on` is empty — use ID as a rough priority/sequence signal.
Slugs in `depends-on` are the stable reference; IDs are only for filename ordering.

### 7. Write ticket files

For each ticket, write `.kanban/backlog/NN-slug.md` (create `.kanban/backlog/` if missing).

```
.kanban/
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

List each failing test by file::function name. Each must map to a sub-condition of the acceptance criterion.

- `test/<file>_test.<ext>::<test_name_snake_case>` — what it asserts (one line)
- `test/<file>_test.<ext>::<test_name_snake_case>` — what it asserts

## Files to Touch

- `src/foo/bar.<ext>` — new file
- `src/foo/mod.<ext>` — export new handler
- `test/foo/bar_test.<ext>` — new test

## Related Tickets

- depends on: `<slug>` (or "none")
- unblocks: `<slug>` (or "none")
```

### 8. Self-check before writing files

For each generated ticket, verify all four conditions before emitting:

- [ ] A user can demo the merged result by running the binary/UI — not by calling an internal function
- [ ] `files-touched` includes every layer needed for the acceptance to pass (entry-point, command handler, store, tests)
- [ ] The acceptance test invocation matches how a real user would trigger it (CLI command, HTTP request, UI interaction)
- [ ] If the acceptance criterion is a CLI/UI/HTTP call, the entry-point file is in `files-touched`
- [ ] `failing-tests` lists ≥1 test by `path::name`, and each maps to a sub-condition of the acceptance criterion

If **any** ticket fails a check → revise it before writing files. Do NOT emit horizontal tickets.

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
| `depends-on` | no | List of slugs in `done/` required before eligible; omit if none |
| `parallel-safe` | no | Default `false`; `true` only when `files-touched` has zero overlap with ALL other eligible tickets; any shared file (including the entry-point) → `false` for both tickets |
| `files-touched` | no | Paths/dirs implementation will modify — used for parallel overlap detection |
| `acceptance` | yes | One sentence a human or test can verify |
| `failing-tests` | required, list[string] | Test function names to write FIRST and run RED before any src/ edit. Format: `path/to/test.ext::test_name_in_snake_case`. Minimum 1 entry. |

---

## Eligibility Rule (for reference — enforced by kanban-loop)

A ticket is **eligible** when every slug in its `depends-on` list has a matching file in `done/`:

```
eligible(ticket) ⟺ ∀ slug ∈ ticket.depends-on: ∃ file .kanban/done/NN-{slug}.md
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

## Key Differences from mattpocock/to-issues

- No GitHub/Linear/issue-tracker API — output is local `.kanban/backlog/` files
- HITL/AFK labels replaced by `parallel-safe: true|false` frontmatter flag
- `needs-triage` label removed — not applicable to local kanban
- Cycle detection mandatory before writing any files (step 4)
- Numbering follows topological sort order; slugs are the stable dependency reference
- Body cap enforced at ~40 lines per ticket

---

## Next Step

> **Tickets created.** Run `/kanban-loop` next to drain the backlog — it will pick eligible tickets, dispatch TDD subagents, and gate on green tests.

Do NOT start implementation. Your job ends here.
