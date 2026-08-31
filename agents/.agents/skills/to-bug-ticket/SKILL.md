---
name: to-bug-ticket
description: Write one intent-based schema-v3 regression ticket after diagnosis confirms a reproduction, root cause, and bounded outcome. Never implement the fix.
---

# To Bug Ticket

Compile confirmed diagnosis into one ticket accepted by `kanban-loop`. Read
`~/.dotfiles/docs/kanban-workflow.md` first.

Require an observable reproduction, evidence-backed root cause, intended fix
outcome, regression acceptance, dependencies, verification command, and explicit
user approval. Inspect the live codebase to validate those claims. If any
scope-affecting fact is unresolved, return `NEEDS_DECISION`; do not guess.

Reuse the existing schema-v3 feature and prefix when the bug belongs to one.
Otherwise propose a kebab-case feature slug and unique 1-8 character uppercase
prefix. Assign the next one-based ID and full key
`PREFIX-NN-kebab-bug-description`.

Before writing, present the complete feature/ticket proposal: reproduction,
root cause, outcome, acceptance criteria, dependencies, priority, mode,
verification, exclusions, optional strict-TDD command, and non-binding likely
files. Write only after explicit approval.

Write the ticket to `.workflow/kanban/tickets/ready/<full-key>.md` using the
canonical schema in `~/.dotfiles/docs/kanban-workflow.md`. Use `kind: ticket`,
schema version 3, full-key dependencies, and an acceptance list that proves the
regression is gone. Set `strict-tdd: true` only when the approved workflow
requires a behavior-level RED before implementation; otherwise choose suitable
verification without manufacturing a failing test.

Exact file allowlists and predetermined commit messages are forbidden. Likely
files and implementation hints may be included as context, never permissions.

Run `kanban-loop validate` and `kanban-loop plan`, repair validation errors, and
report the approved ticket and result. Do not implement it or invoke a run.
