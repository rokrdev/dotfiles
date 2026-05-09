# @feature-flow

Automated feature pipeline with human review gates. Invoke by typing `@feature-flow` in the Agent Panel.

**Pipeline:**
```
@grill-me     → clarify requirements via interview
@to-prd       → write PRD to docs/prd/<slug>.md
⏸ GATE 1     → you review the PRD
@to-tickets   → decompose into .kanban/backlog/ tickets
@kanban-loop  → work through tickets serially, TDD per ticket
⏸ GATE 2     → you review implementation
@ship-it      → pre-flight checks + landing options
```

At each gate, respond with:
1. Approve → proceed to next stage
2. Reject <reason> → rework this stage based on your feedback
3. Abort → stop here; use individual prompts to continue manually

---

## Stage 1 — Requirements Interview

Conduct a requirements interview. Ask all clarifying questions before proceeding. Cover:
- What problem does this solve?
- Who is the user?
- What are the success criteria?
- What is explicitly out of scope?
- Any technical constraints or dependencies?

Do not proceed to Stage 2 until all questions are answered.

Carry forward: the full interview output (requirements, constraints, edge cases).

---

## Stage 2 — PRD

Using the interview output from Stage 1, write a Product Requirements Document to `docs/prd/<slug>.md`.

PRD structure:
```markdown
# <Feature Title>

## Goal
One sentence.

## Non-goals
- Bullet list of what this does NOT do.

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Technical Notes
Any constraints, dependencies, or implementation hints from the interview.
```

Carry forward: the PRD file path and slug.

---

## ⏸ GATE 1 — PRD Review

After writing the PRD, output this block and STOP:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⏸  GATE 1 — PRD Review
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PRD written to: docs/prd/<slug>.md

Goal: <one sentence from PRD>
Non-goals: <bullet list from PRD>
Acceptance criteria: <bullet list from PRD>

Read the full PRD at docs/prd/<slug>.md before approving.

  1. Approve             → proceed to ticketing + implementation
  2. Reject <reason>     → rewrite PRD based on your feedback
  3. Abort               → stop here; use individual prompts to continue manually
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**STOP. Do not write any file. Do not proceed to Stage 3. Wait for the user to type 1 / 2 <reason> / 3.**

### Gate 1 responses

**1** → proceed to Stage 3 (ticketing).

**2 <reason>** → rewrite the PRD incorporating the reject reason. Show Gate 1 again. Track rework count. If rework_count >= 3, output: "Max rework attempts reached. Edit `docs/prd/<slug>.md` manually, then type `1` when ready." and STOP.

**3** → output: "Pipeline aborted at Gate 1. Work preserved at `docs/prd/<slug>.md`. Resume manually with @to-tickets when ready."

---

## Stage 3 — Ticketing

Using the approved PRD, decompose the feature into vertical-slice tickets and write them to `.kanban/backlog/`.

Each ticket file: `.kanban/backlog/NN-<slug>.md`

Ticket frontmatter:
```yaml
---
id: <integer>
slug: <kebab-case>
language: <shell|typescript|python|kotlin|swift|...>
parallel-safe: <true|false>
files-touched:
  - path/to/file.ext
depends-on: []
acceptance: "Single sentence stating what done looks like"
---
```

Ticket body: context, failing tests to write, implementation notes.

Rules:
- Each ticket is one vertical slice — a thin piece of working functionality
- Tickets that touch overlapping files should be sequential (parallel-safe: false)
- Number from 00, lowest dependencies first
- acceptance must be non-empty

Proceed immediately to Stage 4 after writing tickets.

---

## Stage 4 — Implementation

Before starting, derive the branch slug from the approved PRD:
- Read `docs/prd/<slug>.md`
- Extract the H1 title
- Slugify: lowercase, replace spaces/special chars with hyphens, ASCII-only, max 50 chars

Run `@kanban-loop` with branch name `feat/<slugified-title>`. See `@kanban-loop` for the full serial execution protocol.

Wait for all tickets to move from backlog → done.

---

## ⏸ GATE 2 — Implementation Review

After all tickets are done, output this block and STOP:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⏸  GATE 2 — Implementation Review
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tickets completed: <list filenames from .kanban/done/>
Tests: <X passed, 0 failed>

Changed files:
<git diff --stat output>

Review the full diff with: git diff HEAD

  1. Approve             → proceed to ship-it (confirms before pushing)
  2. Reject <reason>     → re-run @kanban-loop to address your feedback
  3. Abort               → stop here; use @ship-it manually when ready
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**STOP. Do not commit. Do not proceed to Stage 5. Wait for the user to type 1 / 2 <reason> / 3.**

### Gate 2 responses

**1** → proceed to Stage 5 (ship-it).

**2 <reason>** → re-run @kanban-loop with the reject reason as a new constraint. Show Gate 2 again after it completes. Track rework count. If rework_count >= 3, output: "Max rework attempts reached. Use @ship-it manually when ready." and STOP.

**3** → output: "Pipeline aborted at Gate 2. Implementation preserved. Use @ship-it manually when ready."

---

## Stage 5 — Ship

Run `@ship-it`. It will show pre-flight results and ask you to choose a landing strategy before doing anything destructive.

---

## Fallback

All individual prompts (@grill-me, @to-prd, @to-tickets, @kanban-loop, @ship-it) remain fully functional. Use them for manual control at any time.
