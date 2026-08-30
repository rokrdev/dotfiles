---
name: grill-me
description: Interview the user one decision at a time to turn an ambiguous plan into an explicit discovery contract. Use when the user asks to stress-test a design or says "grill me"; never write files or implement.
user-invocable: true
---

# Grill Me

Resolve the decisions that materially affect user-visible behavior, scope, constraints, interfaces, verification, or implementation authority. Ask one question at a time and include a recommended answer with its tradeoff.

If a factual question can be answered from the codebase, inspect it instead of asking. Report the evidence and ask only when a product or judgment decision remains. Do not silently convert a codebase observation into user intent.

Avoid exhaustive hypothetical branches. Follow a branch only when its answer can change the resulting product contract. Do not begin architecture or implementation planning.

## Completion Test

The interview is complete only when all of these are explicit:

- Problem and affected user.
- Observable outcomes.
- Acceptance examples.
- Constraints and compatibility requirements.
- Product decisions already made.
- Out-of-scope behavior.
- Verification priorities.
- Remaining assumptions.
- Unresolved scope-affecting decisions: none.

Before ending, present a `Discovery Contract` containing those headings and ask the user to approve or correct it. Iterate until explicitly approved.

After approval, end with exactly:

> **Interview complete.** Run `/to-prd` next to generate the draft PRD. Review that PRD before running `/to-tickets`.

Do not write files, create a PRD, create tickets, dispatch workers, modify code, or suggest implementation commands. Every downstream mutation requires a separate explicit invocation.
