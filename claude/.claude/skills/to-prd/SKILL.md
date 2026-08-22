---
name: to-prd
description: Turn the current approved discovery context into a draft product contract at .workflow/docs/<slug>.md. Use when the user explicitly requests a PRD; never create tickets or implement code.
user-invocable: true
---

# To PRD

Synthesize the conversation's discovery contract and verified codebase facts into a PRD. Preserve decisions and boundaries; do not invent architecture, requirements, modules, or tests to make the document look complete.

Read `~/.dotfiles/docs/kanban-workflow.md` when pipeline context is needed.

## Preconditions

- Use the latest explicitly approved discovery summary.
- Explore the codebase when a factual claim can be verified locally. Respect ADRs and existing public interfaces.
- If one scope-affecting fact is missing, ask one focused question. If several are missing, return to `/grill-me`.
- Record every non-critical inference under `Assumptions`; never disguise it as a decision.

## Output

Derive a short kebab-case slug and write `.workflow/docs/<slug>.md`:

```markdown
# PRD: <Feature Name>

> Slug: <slug>
> Date: <YYYY-MM-DD>
> Status: draft

## Problem

The user-visible problem and who experiences it.

## Outcomes

Numbered observable outcomes. Each describes a capability, not an implementation.

## Acceptance Criteria

Numbered, unambiguous scenarios that can later become ticket acceptance tests.

## Product Decisions

Only decisions explicitly made during discovery.

## Technical Constraints

Existing interfaces, compatibility constraints, ADRs, data constraints, performance or security requirements, and repository conventions that implementation must preserve.

## Candidate Modules

Modules likely to be modified, described by responsibility. Mark unverified candidates as assumptions. Do not include exact file allowlists; `/to-tickets` establishes those from a fresh codebase inspection.

## Testing Priorities

Approved behaviors that need protection and existing test patterns verified in the repository.

## Out of Scope

Explicitly prohibited adjacent behavior, cleanup, migration, and refactoring.

## Assumptions

Non-critical inferences that remain visible to the reviewer. Use `none` when empty.

## Unresolved Decisions

Scope-affecting questions. This must be `none` before `/to-tickets` may approve the PRD.

## Approval

- Approved by: pending
- Approved at: pending
```

The document remains `draft` until a user explicitly approves its outcomes, acceptance criteria, constraints, and out-of-scope list. Do not mark it approved yourself during initial generation.

After writing, report the path, slug, observable outcomes, assumptions, unresolved decisions, and the exact sections the user must review. Do not create tickets or implementation plans. The next explicit command is `/to-tickets .workflow/docs/<slug>.md`.
