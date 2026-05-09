---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding. Invoke with @grill-me when you want to stress-test a plan, get grilled on a design, or explore a feature idea. Hard-stops after Q&A — does not proceed to implementation.
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time.

If a question can be answered by exploring the codebase, explore the codebase instead.

---

## ⛔ Hard Stop — Interview ends here

When the Q&A is finished and we've reached shared understanding, end immediately with this exact message:

> **Interview complete.** Run @to-prd next to generate the PRD, then @to-tickets to create vertical-slice tickets.

Do NOT:
- Jump to implementation planning
- Write any files
- Start designing architecture
- Suggest next steps beyond the handoff message above

The interview is a pure discovery tool. All downstream work (PRD, tickets, implementation) is triggered by explicit user commands only.

This constraint is absolute — it applies even if the design seems clear and implementation would be straightforward. The handoff is always to @to-prd, never to code.
