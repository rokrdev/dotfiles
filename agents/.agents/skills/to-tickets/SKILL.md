---
name: to-tickets
description: Convert an approved PRD or specification into an intent-based schema-v3 feature and serial Kanban tickets. Use when the user wants executable local tickets; never implement them.
---

# To Tickets

Turn an approved product contract into a feature definition and small,
observable tickets for the `kanban-loop` executable. Tickets communicate intent;
they are not file permissions or frozen implementation plans.

Read `~/.dotfiles/docs/kanban-workflow.md` before writing a board.

## Preconditions

1. Use the explicitly supplied PRD or specification. If more than one candidate
   exists, ask which is authoritative.
2. Require explicit approval and no unresolved scope-affecting decisions. Do not
   silently approve a draft.
3. Inspect the live codebase for relevant entry points, tests, commands,
   constraints, and repository vocabulary.
4. If an outcome, dependency, safety boundary, or verification expectation
   cannot be stated honestly, return `NEEDS_DECISION` rather than guessing.

## Design the Feature

Choose one canonical kebab-case feature slug and a stable 1-8 character uppercase
prefix. Prefer initials (`ticket-naming-conventions` -> `TNC`), but preserve an
existing prefix for the feature. A prefix may belong to only one active or
archived feature.

Create `.workflow/kanban/features/<feature>.md` with schema version 3, feature
identity, and the approved goal, acceptance criteria,
constraints, and exclusions. Feature pause, resume, and archive are runner
operations; do not simulate them by editing ticket files.

## Design the Tickets

Prefer serial tracer bullets: each ticket delivers one narrow observable delta
through only the layers that delta requires. Do not manufacture horizontal
scaffold, cleanup, extraction, or architecture tickets unless that work is itself
an approved observable outcome.

For each ticket define:

- a one-based ID and globally unique full key `PREFIX-NN-kebab-slug`;
- the feature slug and stable prefix;
- explicit full-key dependencies and a priority;
- an outcome and observable acceptance criteria;
- relevant constraints and explicit exclusions;
- `mode: inherit` for ordinary work, `hitl` only when the ticket must always
  stop for a person, or `auto` to document settled low-risk AUTO eligibility;
- deterministic verification commands and expected exit codes;
- optional strict TDD configuration only when RED -> GREEN is genuinely required;
- optional implementation hints and likely files, clearly non-binding.

Do not add an exact file allowlist, a predetermined commit message, mandatory
failing-test names, or a parallel-safety claim. The runner is serial, and human
feedback in HITL may legitimately change files, tests, or approach.

## Approval Gate

Before writing anything, present the feature and complete ticket set. Show each
ticket's full key, outcome, acceptance criteria, dependencies, priority, mode,
verification, optional TDD requirement, and important exclusions. Ask the user
to approve, merge, split, reorder, or revise the set.

After any change, present the complete set again. Write only after explicit
approval. Validate that the dependency graph is acyclic and that stable ordering
uses priority, then numeric ID, then ticket key.

## Schema-v3 Shape

Run `kanban-loop init` when the schema-v3 board does not exist; this creates the
columns and the checkout-local Git exclusion. Write new tickets to
`.workflow/kanban/tickets/ready/PREFIX-NN-slug.md`. Ensure all schema-v3 columns
exist: `ready`, `active`, `review`, `paused`, `blocked`, `done`, and `cancelled`.
Runtime sessions belong under Git metadata and must not be created by this skill.

Use the canonical examples and complete field rules in
`~/.dotfiles/docs/kanban-workflow.md`. Keep machine-critical values in YAML
frontmatter and useful context in the body.

## Final Validation

Run:

```text
kanban-loop validate
kanban-loop plan
```

Repair validation errors but do not implement tickets or start the loop. Report
the feature slug, prefix, files written, serial plan, approval status, and
validation result. Remind the user that `/kanban-loop` defaults to HITL and AUTO
must be explicit.
