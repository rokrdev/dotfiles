---
name: to-bug-ticket
description: Write a single structured bug ticket to .kanban/backlog/ after running /diagnose. Use when diagnose has completed and you have a root cause, repro, and fix approach. Triggers: "to-bug-ticket", "/to-bug-ticket", "write bug ticket", "create bug ticket".
---

# to-bug-ticket

Writes one ticket to `.kanban/backlog/` using the bug ticket template. Takes input from `/diagnose` output.

## Input Required

Before writing the ticket, confirm you have:
- [ ] A reproducible feedback loop (from diagnose Phase 1)
- [ ] A confirmed root cause (from diagnose Phase 3–4)
- [ ] A fix approach (from diagnose Phase 5)
- [ ] A regression test plan (from diagnose Phase 5)

If any are missing, tell the user to complete `/diagnose` first.

## Ticket Filename

Format: `.kanban/backlog/NN-<slug>.md`

- `NN`: next available number in backlog (check existing files)
- `slug`: kebab-case description of the bug (e.g. `null-pointer-on-empty-cart`)

## Frontmatter

```yaml
---
id: <NN>
slug: <kebab-case-bug-description>
kind: bug
language: <typescript|python|kotlin|swift>
depends-on: []
parallel-safe: false
files-touched: [<list from diagnose>]
acceptance: "<one sentence: what correct behaviour looks like after the fix>"
---
```

`kind: bug` distinguishes from feature tickets. `parallel-safe` is always `false` for bugs — bugs share causal chains, never parallelize.

## Ticket Body Template

```markdown
## Repro

<!-- The failing test or script from diagnose Phase 1. Must be runnable. -->
<!-- This IS the TDD failing-test step — paste it here exactly. -->

<paste repro from diagnose>

## Root Cause

<!-- One paragraph from diagnose Phase 3–4. State the hypothesis that was confirmed. -->

<root cause from diagnose>

## Fix

<!-- Minimal change needed. Reference specific files and lines from diagnose Phase 5. -->

<fix approach from diagnose>

## Regression Guard

<!-- The repro test above, now expected to pass after the fix. -->
<!-- Required section — kanban-loop will NOT mark this ticket done without it. -->
<!-- State: which test file, which test name, what assertion proves the bug is gone. -->

<regression test plan from diagnose>
```

## Rules

- One ticket per bug. Multi-ticket only if diagnose explicitly surfaced **independent** defects with separate root causes. Requires a one-line justification in each ticket body.
- Regression Guard is **required** and non-empty. The kanban-loop subagent will refuse to mark the ticket done if this section is empty.
- Do not write the fix — write the ticket. Implementation happens in `/kanban-loop`.
- Do not create a PRD. Bugs have no PRD.

---

## Next Step

> **Bug ticket written.** Run `/kanban-loop` next to drain the backlog — it will implement the fix using TDD and gate on the regression guard passing.
