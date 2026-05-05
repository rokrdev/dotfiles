<!--
Adapted from: github.com/mattpocock/skills/to-prd
Adapted: 2026-05-04 for local docs/prd/ workflow
See docs/kanban-workflow.md for design context
-->

---
name: to-prd
description: Turn the current conversation context into a PRD and write it to docs/prd/<slug>.md in the project root. No issue-tracker API required. The PRD is the direct input to /to-tickets. Use when user wants to create a PRD from the current context.
---

# To PRD

Synthesize the current conversation context and codebase understanding into a PRD.
Writes output to `docs/prd/<slug>.md` in the project root (creates dir if missing).

**This PRD is the input to `/to-tickets`** — run this skill first, then run `/to-tickets`
to break the PRD into `.kanban/backlog/` tickets.

See `docs/kanban-workflow.md` for the full pipeline context.

Do NOT interview the user — synthesize what you already know. If critical information
is missing, ask one focused question before proceeding.

---

## Process

### 1. Explore the codebase

If you have not already explored the codebase, do so to understand the current state.
Use the project's domain vocabulary throughout the PRD.
Respect any ADRs (`docs/adr/`) or existing design decisions in the area you're touching.

### 2. Sketch major modules

Identify the major modules you will need to build or modify to complete the implementation.
Actively look for opportunities to extract **deep modules** — ones that encapsulate a lot
of functionality behind a simple, testable interface that rarely changes.

Check with the user:
- Do these modules match their expectations?
- Which modules should have tests written for them?

### 3. Derive a slug

Derive a short kebab-case slug from the feature name (e.g. `url-shortener-cli`,
`cart-checkout-flow`). This becomes the filename: `docs/prd/<slug>.md`.

### 4. Write the PRD file

Create `docs/prd/` if it does not exist, then write `docs/prd/<slug>.md` using the
template below.

### 5. Report

After writing the file, output:
- File path written
- Slug used
- Module list (one line each)
- Reminder: run `/to-tickets docs/prd/<slug>.md` to generate backlog tickets

---

## PRD Template

```markdown
# PRD: <Feature Name>

> Slug: <slug>
> Date: <YYYY-MM-DD>
> Status: draft

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A numbered list of user stories. Cover all aspects of the feature.

1. As a <actor>, I want <feature>, so that <benefit>
2. ...

## Implementation Decisions

- Modules that will be built or modified
- Interfaces of those modules
- Technical clarifications
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets — they go stale quickly.

## Testing Decisions

- What makes a good test for this feature (test external behavior, not implementation details)
- Which modules will be tested
- Prior art in the codebase (similar test patterns to follow)

## Out of Scope

Explicit list of things that are out of scope for this PRD.

## Further Notes

Any additional context, constraints, or open questions.
```

---

## Key Differences from mattpocock/to-prd

- No GitHub/Linear/issue-tracker publish step — output is a local `docs/prd/<slug>.md` file
- `needs-triage` label removed — not applicable to local kanban
- Slug derived from feature name and used as filename
- Explicit handoff note: PRD is the direct input to `/to-tickets`
- `docs/prd/` directory created if missing

---

## Next Step

> **PRD written.** Run `/to-tickets` next to decompose the PRD into vertical-slice tickets in `.kanban/backlog/`.

Do NOT start implementation or planning. Your job ends here.
