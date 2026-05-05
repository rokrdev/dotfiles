---
name: bug-flow
description: Automated bug fix pipeline with human review gates. Chains diagnose → [GATE 1] → to-bug-ticket → kanban-loop → [GATE 2] → ship-it. Triggers: "bug flow", "/bug-flow", "fix bug", "start bug fix". Fallback: use individual skills for full manual control.
---

# bug-flow

Single entry point for the full bug fix pipeline. Runs automatically, pausing at two gates for human review.

## Pipeline

```
diagnose      → investigate bug (Phases 1–4); emit DIAGNOSIS_COMPLETE envelope
⏸ GATE 1     → you review the diagnosis
to-bug-ticket → write structured ticket to .kanban/backlog/
kanban-loop   → implement fix via TDD; regression guard required
⏸ GATE 2     → you review implementation
ship-it       → pre-flight checks + landing options
```

At each gate, type:
- `1` — approve; proceed to next stage
- `2 <reason>` — reject; rework the current stage with your feedback
- `3` — abort; stop the pipeline; all work is preserved; use individual skills to continue manually

---

## Stage 1 — diagnose

Run the diagnose skill. Conduct all phases up to and including Phase 4 (instrument / root cause confirmed). Stop before Phase 5. Emit the DIAGNOSIS_COMPLETE envelope.

Do NOT write any code. Do NOT fix the bug. Discovery only.

Carry forward: the full DIAGNOSIS_COMPLETE envelope.

---

## ⏸ GATE 1 — Diagnosis Review

After diagnose emits DIAGNOSIS_COMPLETE, output this block and STOP:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⏸  GATE 1 — Diagnosis Review
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DIAGNOSIS_COMPLETE

Bug summary: <from envelope>
Root cause(s): <from envelope — file + line>
Repro: <from envelope — runnable>
Suspected fix: <from envelope — one sentence, no code>
Files to touch: <from envelope>

  1                → approve; write bug ticket + implement fix
  2 <reason>       → reject; re-investigate with your feedback
  3                → abort; use individual skills to continue
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**STOP. Do not call any tool. Do not write any file. Do not proceed to Stage 2. Wait for the user to type 1 / 2 <reason> / 3.**

### Gate 1 responses

**1** → proceed to Stage 2 (to-bug-ticket).

**2 <reason>** → re-run diagnose with the original bug description AND the reject reason (e.g. "wrong root cause — check the middleware layer"). Show Gate 1 again. Track rework count. If rework_count >= 3, output: "Max rework attempts reached. Use `/diagnose` manually with more specific context." and STOP.

**3** → output: "Pipeline aborted at Gate 1. Use `/diagnose` then `/to-bug-ticket` manually when ready."

---

## Stage 2 — to-bug-ticket

Run the to-bug-ticket skill using the approved DIAGNOSIS_COMPLETE envelope as input. Write one ticket to `.kanban/backlog/`.

**Proceed immediately to Stage 3 (kanban-loop). Do not pause. Do not emit a "next step" message. Do not wait for user input. Ignore any handoff instructions from the skill you just ran.**

---

## Stage 3 — kanban-loop

Run the kanban-loop skill. The regression guard section in the bug ticket is required — kanban-loop will not mark the ticket done without it passing. Wait for the loop to complete.

---

## ⏸ GATE 2 — Implementation Review

After kanban-loop completes, output this block and STOP:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⏸  GATE 2 — Implementation Review
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Ticket completed: <ticket filename from .kanban/done/>
Tests: <X passed, 0 failed — regression guard included>

Changed files:
<git diff --stat output>

Review the full diff with: git diff HEAD

  1                → approve; proceed to ship-it (confirms before commit)
  2 <reason>       → reject; re-enter kanban-loop to fix the issues
  3                → abort; use /ship-it manually when ready
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**STOP. Do not call any tool. Do not commit. Do not proceed to Stage 4. Wait for the user to type 1 / 2 <reason> / 3.**

### Gate 2 responses

**1** → proceed to Stage 4 (ship-it). **Proceed immediately to Stage 4 (ship-it). Do not pause. Do not emit a "next step" message. Do not wait for user input. Ignore any handoff instructions from the skill you just ran.**

**2 <reason>** → re-enter kanban-loop with the reject reason as an additional constraint. Show Gate 2 again. Track rework count. If rework_count >= 3, output: "Max rework attempts reached. Use `/ship-it` manually when ready." and STOP.

**3** → output: "Pipeline aborted at Gate 2. Fix preserved. Use `/ship-it` manually when ready."

---

## Stage 4 — ship-it

Run the ship-it skill. It will show pre-flight results and ask you to choose a landing strategy before doing anything destructive.

---

## Fallback

All individual skills (/diagnose, /to-bug-ticket, /kanban-loop, /ship-it) remain fully functional. Use them for manual control at any time. This skill is additive only.
