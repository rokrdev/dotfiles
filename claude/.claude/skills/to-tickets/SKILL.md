---
name: to-tickets
description: Convert an approved PRD or specification into immutable schema-v2 Markdown tickets under .workflow/kanban/backlog. Use when the user explicitly wants executable Kanban tickets; never implement them.
user-invocable: true
---

# To Tickets

Compile an approved product contract into thin, observable tickets that the deterministic `kanban-loop` executable can validate and run. The ticket is an authorization boundary, not an implementation suggestion.

Read `~/.dotfiles/docs/kanban-workflow.md` before generating tickets.

## Preconditions

1. Read the explicitly supplied PRD or spec. Do not silently choose from conversation history when multiple candidates exist.
2. Require an approved PRD with no unresolved scope-affecting decisions. If its status is `draft`, show the outcomes, acceptance criteria, constraints, and out-of-scope list and ask for explicit approval. Only after approval change its status to `approved`.
3. Explore the codebase. This is mandatory: identify the real entry points, existing tests, test command, full-suite command, exact files, manifests, ADRs, and repository vocabulary.
4. Refuse ticket generation if acceptance, file scope, or verification cannot be stated unambiguously. Return `NEEDS_DECISION`; do not guess.

## Ticket Design

Create serial tracer-bullet tickets. Each ticket delivers one narrow observable delta through only the layers that delta actually requires. Do not force schema, API, UI, unit tests, or refactors into a ticket unless its acceptance criterion needs them.

Do not create standalone cleanup, scaffold, extraction, architecture, or speculative-refactor tickets. A walking skeleton is allowed only when it produces a runnable externally observable entry point and can be developed test-first.

For every ticket determine:

- Stable numeric ID and kebab-case slug.
- Short title and implementation language.
- Dependency slugs.
- One observable acceptance sentence.
- Exact repository-relative files and whether each is created, modified, or deleted.
- Exact test identifiers to write first.
- One targeted RED/GREEN test command.
- Deterministic verification commands and expected exit codes.
- Exact Conventional Commit message.
- Whether this ticket must require human review even during an AUTO run.

Directories, globs, optional files, `.workflow` paths, and “other files as needed” are forbidden in `allowed-changes`. If a necessary path cannot be identified, stop and ask.

## Review Gate

Before writing files, present the complete proposed ticket set. For every ticket show:

- ID, slug, and title.
- Dependencies.
- Acceptance criterion.
- Exact allowed changes with operations.
- Failing test identifiers and targeted command.
- All verification commands.
- Commit message.
- HITL override.

Ask whether to merge, split, reorder, change scope, or approve. Write nothing until the user explicitly approves the set. After changes, present the complete set again.

Run stable cycle detection: choose the lowest numeric ID and then slug whenever multiple nodes are ready. A dependency cycle stops generation.

## Ticket Format

Write approved tickets to `.workflow/kanban/backlog/NN-slug.md`. Create `backlog/`, `doing/`, and `done/` when missing. Runtime state is created under Git metadata by the runner; never create or track a `runs/` directory.

```markdown
---
schema-version: 2
id: 0
slug: json-output
title: Add JSON output
language: typescript
depends-on: []
parallel-safe: false
human-required: false
acceptance: "Running `app show --json` prints the requested record as valid JSON."
allowed-changes:
  - path: src/cli.ts
    operation: modify
  - path: src/commands/show.ts
    operation: modify
  - path: test/show.test.ts
    operation: modify
failing-tests:
  - test/show.test.ts::prints_requested_record_as_json
tdd-test-command: npm test -- test/show.test.ts
verification:
  - command: npm test -- test/show.test.ts
    expected-exit: 0
  - command: npm test
    expected-exit: 0
commit-message: "feat(cli): add JSON output"
---

## Context

Why this observable delta exists, its approved constraints, and relevant existing behavior. Maximum five sentences.

## Acceptance Test

Restate the acceptance sentence and list only necessary observable subconditions.

## Files to Touch

- `src/cli.ts` — modify: register the approved option
- `src/commands/show.ts` — modify: produce the approved output
- `test/show.test.ts` — modify: add the named failing test

## Out of Scope

- Explicitly prohibited adjacent behavior and refactoring.

## Related Tickets

- depends on: none
- unblocks: none
```

## Schema Rules

| Field | Rule |
|---|---|
| `schema-version` | Required integer `2` |
| `id` | Unique integer matching the zero-padded filename prefix |
| `slug` | Unique kebab-case slug matching the filename |
| `title` | Exact human-readable ticket title |
| `language` | Informational implementation stack |
| `depends-on` | List of slugs, empty when none |
| `parallel-safe` | Always `false` while the runner is serial |
| `human-required` | `true` for architecture, UX/API judgment, security, ambiguous scope, or risky cross-cutting work; otherwise `false` |
| `acceptance` | One externally observable sentence |
| `allowed-changes` | Non-empty list of exact file + `create\|modify\|delete` |
| `failing-tests` | Non-empty list in `path::test-name` form; every path must be allowed |
| `tdd-test-command` | Exact targeted command that must fail before production edits and pass afterward |
| `verification` | Non-empty command/expected-exit list; include the full suite |
| `commit-message` | Exact Conventional Commit subject |

The Markdown body may explain intent, but machine-critical information must appear in frontmatter. Never make the runner infer commands, paths, operations, or commit messages from prose.

## Final Validation

Run:

```text
kanban-loop validate
```

If validation fails, repair the tickets and rerun it. Do not invoke implementation.

Report the files written, stable topological order, approval status, and validation result. End by telling the user that `/kanban-loop` defaults to HITL and `/kanban-loop --auto` must be explicit.

Also state that `kanban-loop` requires a clean checkout: the user must review and commit the approved PRD and ticket files before starting it. Never create that planning commit without a separate explicit approval.
