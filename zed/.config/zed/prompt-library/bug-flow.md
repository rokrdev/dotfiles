# @bug-flow

Automated bug fix pipeline with human review gates. Invoke by typing `@bug-flow` in the Agent Panel.

**Pipeline:**
```
@diagnose     → investigate bug (root cause confirmed); emit DIAGNOSIS_COMPLETE
⏸ GATE 1     → you review the diagnosis
@to-bug-ticket → write structured ticket to .kanban/backlog/
@kanban-loop  → implement fix serially, TDD + regression guard required
⏸ GATE 2     → you review implementation
@ship-it      → pre-flight checks + landing options
```

At each gate, respond with:
1. Approve → proceed to next stage
2. Reject <reason> → rework this stage based on your feedback
3. Abort → stop here; use individual prompts to continue manually

---

## Stage 1 — Diagnose

Investigate the bug through four phases. Do NOT write any fix code. Discovery only.

**Phase 1 — Reproduce**
- Identify a minimal reproduction case from the bug description
- State the exact command, input, or user action that triggers it
- Confirm it fails consistently

**Phase 2 — Locate**
- Read the relevant code paths
- Narrow down to the file(s) and function(s) involved

**Phase 3 — Instrument**
- Add temporary logging or trace through logic mentally
- Confirm the execution path that leads to the bad state

**Phase 4 — Root Cause**
- State the exact root cause: which line, what assumption is wrong, why it fails
- One sentence: "The bug is caused by X in file Y at line Z"

**Emit the DIAGNOSIS_COMPLETE envelope** (do not proceed past this):

```
DIAGNOSIS_COMPLETE

Bug summary: <one sentence>
Root cause: <file + line + explanation>
Repro: <exact command or steps>
Suspected fix: <one sentence, no code>
Files to touch: <list>
```

Carry forward: the full DIAGNOSIS_COMPLETE envelope.

---

## ⏸ GATE 1 — Diagnosis Review

After emitting DIAGNOSIS_COMPLETE, output this block and STOP:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⏸  GATE 1 — Diagnosis Review
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DIAGNOSIS_COMPLETE

Bug summary: <from envelope>
Root cause: <from envelope — file + line>
Repro: <from envelope — runnable>
Suspected fix: <from envelope — one sentence, no code>
Files to touch: <from envelope>

  1. Approve             → write bug ticket + implement fix
  2. Reject <reason>     → re-investigate based on your feedback
  3. Abort               → stop here; use individual prompts to continue manually
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**STOP. Do not write any file. Do not proceed to Stage 2. Wait for the user to type 1 / 2 <reason> / 3.**

### Gate 1 responses

**1** → proceed to Stage 2 (write bug ticket).

**2 <reason>** → re-investigate with the original bug description AND the reject reason. Show Gate 1 again. Track rework count. If rework_count >= 3, output: "Max rework attempts reached. Use @diagnose manually with more specific context." and STOP.

**3** → output: "Pipeline aborted at Gate 1. Use @diagnose then @to-bug-ticket manually when ready."

---

## Stage 2 — Write Bug Ticket

Using the approved DIAGNOSIS_COMPLETE envelope, write one ticket to `.kanban/backlog/`.

Ticket filename: `.kanban/backlog/NN-<bug-slug>.md`

Frontmatter:
```yaml
---
id: <integer>
slug: <kebab-case-bug-slug>
language: <shell|typescript|python|kotlin|swift|...>
parallel-safe: false
files-touched:
  - <files from DIAGNOSIS_COMPLETE>
depends-on: []
acceptance: "The bug described in <summary> no longer occurs; regression test passes"
---
```

Ticket body must include these four sections:

```markdown
## Repro
<exact steps or command from DIAGNOSIS_COMPLETE>

## Root Cause
<file + line + explanation from DIAGNOSIS_COMPLETE>

## Fix
<suspected fix sentence from DIAGNOSIS_COMPLETE>

## Regression Guard
<name the specific test that must be written to prevent this bug from regressing>
This section is required and non-empty — implementation is not complete without it.
```

Proceed immediately to Stage 3 after writing the ticket.

---

## Stage 3 — Implementation

Before starting, derive the branch slug from the bug summary:
- Use the bug summary line from the DIAGNOSIS_COMPLETE envelope
- Slugify: lowercase, replace spaces/special chars with hyphens, ASCII-only, max 50 chars

Run `@kanban-loop` with branch name `fix/<slugified-summary>`.

The regression guard section in the bug ticket is required — the ticket is not done without a passing regression test. See `@kanban-loop` for the full serial execution protocol.

---

## ⏸ GATE 2 — Implementation Review

After the ticket moves to done, output this block and STOP:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⏸  GATE 2 — Implementation Review
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Ticket completed: <ticket filename from .kanban/done/>
Tests: <X passed, 0 failed — regression guard included>

Changed files:
<git diff --stat output>

Review the full diff with: git diff HEAD

  1. Approve             → proceed to ship-it (confirms before pushing)
  2. Reject <reason>     → re-run @kanban-loop to address your feedback
  3. Abort               → stop here; use @ship-it manually when ready
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**STOP. Do not commit. Do not proceed to Stage 4. Wait for the user to type 1 / 2 <reason> / 3.**

### Gate 2 responses

**1** → proceed to Stage 4 (ship-it).

**2 <reason>** → re-run @kanban-loop with the reject reason as an additional constraint. Show Gate 2 again. Track rework count. If rework_count >= 3, output: "Max rework attempts reached. Use @ship-it manually when ready." and STOP.

**3** → output: "Pipeline aborted at Gate 2. Fix preserved. Use @ship-it manually when ready."

---

## Stage 4 — Ship

Run `@ship-it`. It will show pre-flight results and ask you to choose a landing strategy before doing anything destructive.

---

## Fallback

All individual prompts (@diagnose, @to-bug-ticket, @kanban-loop, @ship-it) remain fully functional. Use them for manual control at any time.
