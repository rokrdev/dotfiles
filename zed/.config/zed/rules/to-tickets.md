# @to-tickets

> Invoke: type @to-tickets in the Zed agent panel.

Convert an explicitly approved PRD into one schema-v3 feature definition and a
serial set of intent-based tickets. Do not implement them.

Read `~/.dotfiles/docs/kanban-workflow.md` for the canonical schema and board
layout.

## Preconditions

1. Use the supplied approved PRD or specification.
2. Inspect the live codebase for actual entry points, tests, commands,
   constraints, and repository vocabulary.
3. Stop with `NEEDS_DECISION` when an outcome, dependency, safety boundary, or
   verification expectation is unresolved.

## Proposal

Choose a stable kebab-case feature slug and unique 1-8 character uppercase
prefix. Reuse an existing feature's prefix. Create small serial tracer bullets
with:

- full key `PREFIX-NN-kebab-slug` and full-key dependencies;
- priority and outcome;
- observable acceptance criteria;
- constraints and explicit exclusions;
- `mode: inherit` for ordinary work, `hitl` only for a mandatory human gate, or
  `auto` to document settled low-risk AUTO eligibility;
- verification commands and expected exits;
- optional strict-TDD command when RED -> GREEN is genuinely required;
- optional implementation hints and likely files as non-binding context.

Do not generate exact file allowlists, predetermined commit messages, mandatory
failing-test names, or parallel-safety claims.

Present the complete feature and ticket set before writing. Ask the user to
approve, merge, split, reorder, or revise it. After changes, present the complete
set again. Validate the dependency graph and stable serial ordering.

## Write and Validate

Run `kanban-loop init` when the schema-v3 board does not exist so the local Git
exclusion and columns are created. Write the feature to
`.workflow/kanban/features/<feature>.md` and tickets to
`.workflow/kanban/tickets/ready/<full-key>.md`. Ensure the schema-v3 ticket
columns exist: `ready`, `active`, `review`, `paused`, `blocked`, `done`, and
`cancelled`.

Run:

```text
kanban-loop validate
kanban-loop plan
```

Repair validation errors, then report the feature, prefix, files written,
serial order, approval status, and validation result. Do not start
implementation. Remind the user that HITL is the default and AUTO is explicit.
