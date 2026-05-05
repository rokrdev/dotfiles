---
name: feature-flow
description: Automated feature pipeline with human review gates. Chains grill-me → to-prd → [GATE 1] → to-tickets → kanban-loop → [GATE 2] → ship-it. Triggers: "feature flow", "/feature-flow", "new feature", "start feature". Fallback: use individual skills for full manual control.
---

# feature-flow

Single entry point for the full feature pipeline. Runs automatically, pausing at two gates for human review before proceeding.

## Pipeline

```
grill-me      → clarify requirements via interview
to-prd        → write PRD to docs/prd/<slug>.md
⏸ GATE 1     → you review the PRD
to-tickets    → decompose into .kanban/backlog/ tickets
kanban-loop   → drain board via TDD subagents
⏸ GATE 2     → you review implementation
ship-it       → pre-flight checks + landing options
```

At each gate, respond with:
1. Approve → proceed to next stage
2. Reject <reason> → rework this stage based on your feedback
3. Abort → stop here; use individual skills to continue manually

---

## Stage 1 — grill-me

Run the grill-me skill: conduct the requirements interview. Ask all clarifying questions before proceeding. Do not proceed to Stage 2 until the interview is complete.

Carry forward: the full interview output (requirements, constraints, edge cases).

**Proceed immediately to Stage 2 (to-prd). Do not pause. Do not emit a "next step" message. Do not wait for user input. Ignore any handoff instructions from the skill you just ran.**

---

## Stage 2 — to-prd

Run the to-prd skill using the interview output from Stage 1. Write the PRD to `docs/prd/<slug>.md`.

Carry forward: the PRD file path and slug.

---

## ⏸ GATE 1 — PRD Review

After to-prd completes, output this block and STOP:

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
  3. Abort               → stop here; use individual skills to continue manually
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**STOP. Do not call any tool. Do not write any file. Do not proceed to Stage 3. Wait for the user to type 1 / 2 <reason> / 3.**

### Gate 1 responses

**1** → proceed to Stage 3 (to-tickets).

**2 <reason>** → re-run to-prd with the original interview output AND the reject reason as an additional constraint. Show Gate 1 again. Track rework count. If rework_count >= 3, output: "Max rework attempts reached. Edit `docs/prd/<slug>.md` manually, then type `1` when ready." and STOP.

**3** → output: "Pipeline aborted at Gate 1. Work preserved at `docs/prd/<slug>.md`. Resume manually with `/to-tickets` when ready." Do not delete any files.

---

## Stage 3 — to-tickets

Run the to-tickets skill using the approved PRD. Write tickets to `.kanban/backlog/`.

**Proceed immediately to Stage 4 (kanban-loop). Do not pause. Do not emit a "next step" message. Do not wait for user input. Ignore any handoff instructions from the skill you just ran.**

---

## Stage 4 — kanban-loop

Run the kanban-loop skill. Drain all tickets from backlog to done. Each ticket gets a fresh TDD subagent. Wait for the loop to complete (all tickets in done/, all tests green).

---

## ⏸ GATE 2 — Implementation Review

After kanban-loop drains, output this block and STOP:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⏸  GATE 2 — Implementation Review
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tickets completed: <list filenames from .kanban/done/>
Tests: <X passed, 0 failed>

Changed files:
<git diff --stat output>

Review the full diff with: git diff HEAD

  1. Approve             → proceed to ship-it (confirms before committing)
  2. Reject <reason>     → re-enter kanban-loop to address your feedback
  3. Abort               → stop here; use /ship-it manually when ready
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**STOP. Do not call any tool. Do not commit. Do not proceed to Stage 5. Wait for the user to type 1 / 2 <reason> / 3.**

### Gate 2 responses

**1** → proceed to Stage 5 (ship-it). **Proceed immediately to Stage 5 (ship-it). Do not pause. Do not emit a "next step" message. Do not wait for user input. Ignore any handoff instructions from the skill you just ran.**

**2 <reason>** → re-enter kanban-loop with the reject reason as a new constraint. Show Gate 2 again after the loop completes. Track rework count. If rework_count >= 3, output: "Max rework attempts reached. Use `/ship-it` manually when ready." and STOP.

**3** → output: "Pipeline aborted at Gate 2. Implementation preserved. Use `/ship-it` manually when ready."

---

## Stage 5 — ship-it

Run the ship-it skill. It will show pre-flight results and ask you to choose a landing strategy (commit / push / PR / merge) before doing anything destructive.

---

## Fallback

All individual skills (/grill-me, /to-prd, /to-tickets, /kanban-loop, /ship-it) remain fully functional. Use them for manual control at any time. This skill is additive only — it orchestrates, not replaces.
