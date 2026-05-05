# Vertical-Slice Kanban Workflow

> Design document for a local, file-based kanban workflow built around vertical slices,
> mattpocock skills, and the Neo orchestrator.
>
> **Branch at time of writing:** `vertical-slices`
> **Uncommitted changes:** `claude/.claude/.buddy-reroll.json` (deleted)
> **Trial start date:** 2026-05-04

---

## Table of Contents

0. [Workflow Lanes](#workflow-lanes)
1. [Philosophy](#1-philosophy)
2. [Storage Layout](#2-storage-layout)
3. [Ticket Schema](#3-ticket-schema)
4. [Dependency Resolution](#4-dependency-resolution)
5. [Pipeline Overview](#5-pipeline-overview)
6. [kanban-loop Logic](#6-kanban-loop-logic)
7. [Parallel Dispatch](#7-parallel-dispatch)
8. [Stuck Ticket Detection](#8-stuck-ticket-detection)
9. [Verification Before Completion](#9-verification-before-completion)
10. [Ralph Reflection (v2 — Deferred)](#10-ralph-reflection-v2--deferred)
11. [Skill Stack](#11-skill-stack)
12. [Trial Plan (7 Days)](#12-trial-plan-7-days)
13. [Coverage Gaps to Monitor](#13-coverage-gaps-to-monitor)
14. [Demo Project — URL Shortener CLI](#14-demo-project--url-shortener-cli)
15. [MVP Build Order](#15-mvp-build-order)

---

## Workflow Lanes

### Feature Lane

For new features and enhancements.

```
/grill-me          Clarify requirements via interview (or /grill-with-docs for domain-heavy features)
    ↓
/to-prd            Write structured PRD to docs/prd/<slug>.md
    ↓
/to-tickets        Decompose PRD into vertical-slice tickets in .kanban/backlog/
    ↓
/kanban-loop       Drain the board — picks eligible tickets, dispatches TDD subagents, gates on green tests
    ↓
/ship-it           Pre-flight checks (tests, git state, board empty) + landing options (commit/push/PR/merge)
```

### Bug Fix Lane

For reproducing and fixing existing bugs.

```
/diagnose          Build a feedback loop → reproduce → hypothesise → instrument → fix → regression test
    ↓
/to-bug-ticket     Write a single bug ticket to .kanban/backlog/ (Repro → Root cause → Fix → Regression guard)
    ↓
/kanban-loop       Drain the board — same as feature lane; regression guard section required to mark done
    ↓
/ship-it           Same as feature lane
```

### Skill Descriptions

| Skill | What it does |
|-------|-------------|
| `/grill-me` | Interviews you with targeted questions to surface requirements, constraints, and edge cases before any spec is written. Pure discovery — no files written. |
| `/grill-with-docs` | Same as grill-me but pulls in domain model, ADRs, and CONTEXT.md to ground questions in existing architecture. |
| `/to-prd` | Takes the interview output and writes a structured PRD to `docs/prd/<slug>.md`. Defines goals, non-goals, user stories, and success criteria. |
| `/to-tickets` | Reads the PRD and decomposes it into vertical-slice tickets in `.kanban/backlog/`. Each ticket delivers one user-observable outcome. Runs topological sort to sequence by dependency. |
| `/diagnose` | Disciplined 6-phase debugging: build feedback loop → reproduce → hypothesise → instrument → fix → cleanup. Entry point for the bug fix lane. |
| `/to-bug-ticket` | Writes a single structured bug ticket to `.kanban/backlog/` with four required sections: Repro, Root cause, Fix, Regression guard. |
| `/kanban-loop` | Drains the backlog by picking eligible tickets (deps satisfied), dispatching a fresh TDD subagent per ticket, and gating completion on passing tests + acceptance verifiable. |
| `/ship-it` | Pre-merge checklist: verifies board drained, tests green, no uncommitted changes. Then presents landing options: commit / push / PR / squash-merge / rebase-merge. |

---

## 1. Philosophy

**Vertical slices, not horizontal layers.**

Each ticket delivers one user-observable outcome end-to-end — storage, logic, and interface
all change together in a single ticket. No ticket delivers "just the model layer" or
"just the API routes". A user can verify the acceptance sentence manually or via a test.

**Iterative over exhaustive.** The backlog is a rolling queue, not a frozen spec. New tickets
enter `backlog/` between drains. The board is never committed to git — it is working memory,
not history.

**Plain files beat dashboards.** One markdown file per ticket. `mv` to move columns.
No database, no server, no sync conflicts.

---

## 2. Storage Layout

```
<project-root>/
└── .kanban/
    ├── backlog/
    │   ├── 01-create-short-url.md
    │   └── 03-list-urls.md
    ├── doing/
    │   └── 02-redirect-url.md
    └── done/
        └── 00-cli-scaffold.md
```

### Rules

- **Column directories:** `backlog/`, `doing/`, `done/` — no others.
- **Filename format:** `NN-slug.md` where `NN` is a zero-padded integer (topo sort order).
- **Move with `mv`**, never `git mv`. The board is never committed.
- **Global gitignore:** Add `.kanban/` to `~/.config/git/ignore` so it is invisible to git
  across every project without touching per-project `.gitignore`.

```bash
# Add once — global gitignore
echo '.kanban/' >> ~/.config/git/ignore
```

### Why per-file over BOARD.md

- Atomic moves — `mv` is a single syscall, no partial writes.
- Race-free — parallel agents each own a distinct file; no merge conflicts.
- Grep-able — `ls .kanban/done/` is the dependency oracle.

---

## 3. Ticket Schema

Every ticket is a markdown file with YAML frontmatter followed by a structured body.
Body cap: ~40 lines.

```yaml
---
id: 5
slug: cart-checkout-flow
language: typescript
depends-on: [auth-middleware]   # slugs preferred — survives renumber
parallel-safe: true
files-touched: [src/cart/, test/cart/]
acceptance: "User can add item to cart and complete checkout with stored card"
---
```

### Frontmatter Fields

| Field | Required | Notes |
|-------|----------|-------|
| `id` | yes | Integer, unique, used for sort order |
| `slug` | yes | Kebab-case, matches filename after `NN-` |
| `language` | yes | Routes to specialist: `typescript`, `python`, `kotlin`, `swift` |
| `depends-on` | no | List of slugs that must be in `done/` before this ticket is eligible |
| `parallel-safe` | no | Default `false`. `true` only when `files-touched` has no overlap with other eligible tickets |
| `files-touched` | no | List of paths/dirs the implementation will modify — used for parallel overlap detection |
| `acceptance` | yes | One sentence a human (or test) can verify |

### Body Sections

```markdown
## Context

Why this ticket exists. What problem it solves. Max 5 sentences.

## Acceptance Test

Restate the acceptance sentence from frontmatter, then add any sub-conditions:
- Sub-condition 1
- Sub-condition 2

## Files to Touch

- `src/cart/checkout.ts` — new file
- `src/cart/index.ts` — export new handler
- `test/cart/checkout.test.ts` — new test

## Related Tickets

- depends on: `auth-middleware`
- unblocks: `order-confirmation`
```

---

## 4. Dependency Resolution

### Eligibility Rule

A ticket in `backlog/` is **eligible** if and only if every slug in its `depends-on` list
has a matching file in `done/`:

```
eligible(ticket) ⟺ ∀ slug ∈ ticket.depends-on: ∃ file done/NN-{slug}.md
```

### Topo Numbering

`NN` prefix encodes the topological sort order computed at planning time. In 90% of tickets
`depends-on` is empty and order is arbitrary — use `NN` as a rough priority signal.

### Slugs Over IDs

`depends-on` lists slugs, not IDs. If a ticket is renumbered (e.g. after replanning), slug
references remain valid. ID references would silently break.

### Cycle Detection

The planning step (to-tickets skill) runs a topological sort before writing any files.
If a cycle is detected, planning **fails** and the user must replan. No cycle survives
into the backlog.

```
planning → topo-sort → FAIL if cycle → replan
                     → PASS → write backlog/NN-slug.md files
```

---

## 5. Pipeline Overview

> **Note:** This diagram shows the **feature lane** only. For the bug fix lane, see [Workflow Lanes](#workflow-lanes).

```
vague request
    │
    ▼
grill-me / grill-with-docs      ← mattpocock skill (clarifies requirements)
    │
    ▼
spec (markdown)
    │
    ▼
to-prd (local adapted)          ← writes docs/prd/<slug>.md
    │
    ▼
to-tickets (adapted)            ← writes .kanban/backlog/NN-slug.md
    │
    ▼
kanban-loop                     ← drains backlog → done
    │
    ▼ (v2 — deferred)
ralph reflection                ← reads done/ + tests + coverage → new backlog tickets
```

### Skill Handoffs

| Stage | Skill | Input | Output |
|-------|-------|-------|--------|
| Clarify | `grill-me` or `grill-with-docs` | user request | structured spec |
| PRD | `to-prd` (local) | spec | `docs/prd/<slug>.md` |
| Tickets | `to-tickets` (adapted) | PRD | `.kanban/backlog/NN-slug.md` files |
| Implement | `kanban-loop` | backlog/ | done/ tickets + passing tests |
| Reflect | ralph (v2) | done/ + coverage | new backlog/ tickets |

---

## 6. kanban-loop Logic

### Pseudocode

```
loop:
  check_stuck()                        # warn if anything in doing/ > 1hr old

  eligible = [t for t in backlog/ if all deps in done/]

  if eligible is empty and backlog/ is non-empty:
    DEADLOCK → warn user, list blocking deps, halt

  if eligible is empty and backlog/ is empty:
    DONE → report summary, exit

  ticket = min(eligible, key=id)       # lowest ID first

  mv backlog/NN-slug.md → doing/NN-slug.md

  agent = route_specialist(ticket.language)
  # typescript → jasper, python → snape, kotlin → conan, swift → swifty

  dispatch fresh agent(agent, ticket):
    invoke mattpocock tdd skill:
      write failing test (acceptance drives test name)
      write minimum implementation to pass
      refactor

    verify():
      assert tests green
      assert acceptance sentence verifiable
      assert frontmatter valid (id, slug, language, acceptance present)

    mv doing/NN-slug.md → done/NN-slug.md

  loop
```

### Specialist Routing

| `language` value | Agent dispatched |
|-----------------|-----------------|
| `typescript` | jasper |
| `python` | snape |
| `kotlin` | conan |
| `swift` | swifty |
| anything else | Neo decides |

### Exit Conditions

| State | Action |
|-------|--------|
| `backlog/` empty, `doing/` empty | Normal exit — report summary |
| `backlog/` non-empty, `eligible` empty | Deadlock — list unresolved deps, halt |
| Verification fails after 1 retry | Move ticket back to `backlog/`, append failure note to body, warn user |

---

## 7. Parallel Dispatch

Default mode is **serial** — one ticket at a time. Parallel mode is opt-in.

### Parallel Eligibility

A set of tickets can be dispatched in parallel iff:
1. Each ticket has `parallel-safe: true`
2. No two tickets share a path in `files-touched` (no prefix overlap)

```python
def parallel_eligible(tickets):
    safe = [t for t in tickets if t.parallel_safe]
    touched = []
    result = []
    for t in safe:
        if not any(overlap(p, q) for p in t.files_touched for q in touched):
            result.append(t)
            touched.extend(t.files_touched)
    return result

def overlap(a, b):
    return a.startswith(b) or b.startswith(a)
```

### Parallel Mode Activation

Parallel mode is invoked explicitly by Neo when `dispatching-parallel-agents` applies.
The kanban-loop does not auto-parallelize — Neo reads the eligible set and decides.

---

## 8. Stuck Ticket Detection

At the start of every loop iteration, kanban-loop runs a 10-line check:

```bash
# Pseudocode — run inside kanban-loop skill
for ticket in doing/:
  age = now() - mtime(ticket)
  if age > 3600:
    warn("STUCK: {ticket} has been in doing/ for {age}s — investigate")
```

If a stuck ticket is found, the loop **warns the user and pauses** before picking the next
ticket. The user can:
- Investigate and manually move the ticket back to `backlog/`
- Force-continue (loop picks next eligible ticket, leaving stuck one in `doing/`)

The check does not auto-recover — human judgment required.

---

## 9. Verification Before Completion

Baked directly into kanban-loop — no separate skill needed.

Before `mv doing/ → done/`, the dispatched agent must pass all three gates:

```
Gate 1: Tests green
  → run test suite for files-touched paths
  → all tests pass (zero failures, zero errors)

Gate 2: Acceptance verifiable
  → acceptance sentence from frontmatter maps to at least one test
  → OR acceptance can be manually verified (agent documents how)

Gate 3: Frontmatter valid
  → id, slug, language, acceptance fields all present and non-empty
  → slug matches filename
```

Failure at any gate:
- Append failure note to ticket body
- Move back to `backlog/`
- Warn user with gate number and reason

---

## 10. Ralph Reflection (v2 — Deferred)

Not built in v1. Manual re-planning between drains.

### v2 Design (for reference)

An outer loop wraps kanban-loop. After each drain (backlog empty), a reflector subagent:

1. Reads all `done/` tickets
2. Reads test coverage report
3. Reads TODO/FIXME comments in touched files
4. Produces new tickets with **cited evidence** (e.g. "coverage gap at src/auth/refresh.ts:42")
5. Writes new tickets to `backlog/`
6. kanban-loop restarts

### v1 (Manual)

User re-plans by hand between drains:
- Review `done/` tickets
- Run coverage tool manually
- Write new tickets via to-tickets skill
- Re-invoke kanban-loop

---

## 11. Skill Stack

### mattpocock Skills (pull verbatim)

| Skill | Role in workflow |
|-------|-----------------|
| `grill-me` | Clarify vague requests before spec |
| `grill-with-docs` | Clarify with library docs context |
| `tdd` | TDD cycle inside each specialist dispatch |
| `improve-codebase-architecture` | Architecture review between drains |
| `ship-it` | Pre-merge checklist — **not in mattpocock repo; built locally as minimal stub. See `~/.dotfiles/claude/.claude/skills/ship-it/SKILL.md`** |
| `diagnose` | Debugging when stuck |

### Adapted Skills (local modifications)

| Skill | Source | Adaptation |
|-------|--------|-----------|
| `to-tickets` | mattpocock `to-issues` | Writes `.kanban/backlog/NN-slug.md` instead of GitHub issues. Adds YAML frontmatter. Runs topo sort. |
| `to-prd` | mattpocock `to-prd` | Writes `docs/prd/<slug>.md` locally instead of remote. No GitHub dependency. |

### New Skills (built for this workflow)

| Skill | Purpose |
|-------|---------|
| `kanban-loop` | Core drain loop — eligible → dispatch → verify → done |

### Fish Function

```fish
# fish/.config/fish/functions/kb.fish
function kb
    # kb status  — show board state
    # kb next    — show next eligible ticket
    # kb loop    — invoke kanban-loop skill
    # kb add     — invoke to-tickets on a spec file
    switch $argv[1]
        case status
            echo "=== DOING ===";  ls .kanban/doing/  2>/dev/null || echo "(empty)"
            echo "=== BACKLOG ==="; ls .kanban/backlog/ 2>/dev/null || echo "(empty)"
            echo "=== DONE ===";   ls .kanban/done/   2>/dev/null | wc -l; echo "tickets"
        case next
            ls .kanban/backlog/ 2>/dev/null | head -1
        case loop
            claude --skill kanban-loop
        case add
            claude --skill to-tickets $argv[2]
        case '*'
            echo "usage: kb [status|next|loop|add <spec>]"
    end
end
```

---

## 12. Trial Plan (7 Days)

### Day 0 — Setup (2026-05-04)

- [ ] Pull 6 mattpocock skills verbatim into `claude/.claude/skills/` + build custom `ship-it` skill
- [ ] Adapt `to-tickets` (local) and `to-prd` (local)
- [ ] Build `kanban-loop` skill
- [ ] Add `.kanban/` to `~/.config/git/ignore`
- [ ] Create `kb` fish function in `fish/.config/fish/functions/kb.fish`
- [ ] Comment out `superpowers` from `enabledPlugins` in `claude/.claude/settings.json`
- [ ] Update Neo agent prompt to reference kanban-loop and new skill stack
- [ ] Run demo project (URL shortener CLI) as smoke test
- [ ] Record trial start in `MEMORY.md`

### Days 1–6 — Use and Observe

Track these signals in `MEMORY.md` as they occur:

| Signal | What to note |
|--------|-------------|
| Missing superpowers skill | Which one, what was the gap |
| kanban-loop stuck ticket | Cause, resolution |
| Deadlock encountered | Which deps were unresolved |
| Verification gate failure | Which gate, how often |
| Parallel dispatch used | How many tickets, any overlap collision |

### Day 7 — Decide

Three options:

**Keep:** mattpocock + kanban-loop covers all needs → leave superpowers commented out.

**Revert:** Too many gaps → uncomment superpowers in `settings.json`, restow, delete kanban skills.

**Hybrid:** Re-enable specific superpowers skills alongside new stack (e.g. keep `requesting-code-review`).

### Revert Procedure

```bash
# 1. Re-enable superpowers in settings.json
#    Uncomment the "superpowers@claude-plugins-official" entry in enabledPlugins

# 2. Restow claude package
cd ~/.dotfiles && stow -R claude

# 3. Optionally remove kanban skills
rm ~/.claude/skills/kanban-loop.md
rm ~/.claude/skills/to-tickets.md
rm ~/.claude/skills/to-prd.md
```

---

## 13. Coverage Gaps to Monitor

Skills dropped when superpowers is disabled, and mitigations:

| Dropped Skill | Risk | Mitigation |
|--------------|------|-----------|
| `verification-before-completion` | Ship broken code | Baked into kanban-loop as 3-gate check |
| `requesting-code-review` | No structured review step | Use `ship-it` (7 mattpocock skills + 1 custom); note if insufficient |
| `receiving-code-review` | Feedback not processed well | Manual discipline; watch for rushed merges |
| `dispatching-parallel-agents` | Parallel work not used | Neo handles natively; kanban-loop has parallel mode |
| `systematic-debugging` | Longer debug cycles | Use `diagnose` from mattpocock verbatim |
| `writing-plans` | Unstructured planning | `to-prd` + `to-tickets` replaces this path |

**Verdict signal:** If `requesting-code-review` / `receiving-code-review` gap causes a real
problem (missed bug, rushed merge) within 7 days → note it and consider hybrid.

---

## 14. Demo Project — URL Shortener CLI

**Why this project:** Small, self-contained, TypeScript (jasper handles it), 5–8 vertical
slices with clear user-observable outcomes, no external service dependencies beyond a local
JSON store.

**Stack:** Node.js + TypeScript, JSON file storage, Vitest for tests.

### Acceptance

A CLI tool where the user can shorten a URL, retrieve the original, list all stored URLs,
and delete one. Data persists between runs in a local JSON file.

### Ticket List

```
00-cli-scaffold
01-store-short-url
02-resolve-short-url
03-list-urls
04-delete-url
05-collision-handling
06-persistent-storage
```

### Ticket Details

| # | Slug | Depends-on | Files-touched | Parallel-safe | Acceptance |
|---|------|-----------|--------------|--------------|-----------|
| 00 | `cli-scaffold` | — | `src/cli.ts`, `package.json`, `tsconfig.json` | false | `npx ts-node src/cli.ts --help` exits 0 and prints usage |
| 01 | `store-short-url` | `cli-scaffold` | `src/store.ts`, `test/store.test.ts` | false | `shorten https://example.com` prints a short code like `abc123` |
| 02 | `resolve-short-url` | `store-short-url` | `src/resolve.ts`, `test/resolve.test.ts` | false | `resolve abc123` prints `https://example.com` |
| 03 | `list-urls` | `store-short-url` | `src/list.ts`, `test/list.test.ts` | true | `list` prints all stored code→URL pairs, one per line |
| 04 | `delete-url` | `store-short-url` | `src/delete.ts`, `test/delete.test.ts` | true | `delete abc123` removes the entry; subsequent `resolve abc123` errors |
| 05 | `collision-handling` | `store-short-url` | `src/store.ts`, `test/store.test.ts` | false | Shortening the same URL twice returns the same code |
| 06 | `persistent-storage` | `store-short-url` | `src/db.ts`, `test/db.test.ts` | false | URLs survive process restart — data written to `~/.url-shortener.json` |

### Dependency Graph (ASCII)

```
00-cli-scaffold
       │
       ▼
01-store-short-url
       ├──────────────────┐──────────────┐────────────────────┐
       ▼                  ▼              ▼                    ▼
02-resolve-short-url  03-list-urls  04-delete-url  05-collision-handling
                                                              │
                                                             (also 06)
06-persistent-storage (depends on 01 only)
```

Tickets 03 and 04 are both `parallel-safe: true` with non-overlapping `files-touched` →
can be dispatched in parallel after 02 completes.

---

## 15. MVP Build Order

Sequenced tasks for the `vertical-slices` branch:

| Step | Task | Owner |
|------|------|-------|
| 1 | This doc (done) | Claude |
| 2 | Pull 6 mattpocock skills verbatim into `claude/.claude/skills/` + build custom `ship-it` skill | Claude |
| 3 | Adapt `to-tickets` skill (local .kanban/ output, YAML frontmatter, topo sort) | Claude |
| 4 | Adapt `to-prd` skill (local `docs/prd/` output, no GitHub) | Claude |
| 5 | Build `kanban-loop` skill (eligible check, dispatch, 3-gate verify, mv) | Claude |
| 6 | Add `.kanban/` to `~/.config/git/ignore` | Claude |
| 7 | Create `kb` fish function in `fish/.config/fish/functions/kb.fish` | Claude |
| 8 | Disable superpowers: comment out from `enabledPlugins` in `claude/.claude/settings.json` | Claude |
| 9 | Update Neo agent prompt to reference new skill stack + kanban-loop | Claude |
| 10 | Run URL shortener demo: grill-me → to-prd → to-tickets → kanban-loop | Claude + user |

---

*Generated on 2026-05-04. Branch: `vertical-slices`. Trial period: 2026-05-04 through 2026-05-11.*
