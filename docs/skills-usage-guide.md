# Skills Usage Guide

Daily reference for the kanban workflow skills. For design rationale see `docs/kanban-workflow.md`.

## Decision Tree

```
I have a vague idea
  └─ no existing codebase   → /grill-me      → /to-prd → /to-tickets → /kanban-loop → /ship-it
  └─ existing codebase      → /grill-with-docs → /to-prd → /to-tickets → /kanban-loop → /ship-it

Single-file fix or trivial change → skip kanban, dispatch specialist directly

Something is broken, root cause unknown → /diagnose

Codebase feels tangled (periodic) → /improve-codebase-architecture

Branch drained, ready to land → /ship-it
```

## Skills Reference

| Skill | When | Output |
|-------|------|--------|
| `grill-me` | Non-code project — gather requirements from scratch | Structured spec (stdout) |
| `grill-with-docs` | Existing codebase — interview against CONTEXT.md + ADRs | Structured spec (stdout) |
| `to-prd` | After interview output is ready | `docs/prd/<slug>.md` |
| `to-tickets` | After PRD exists | `.kanban/backlog/NN-<slug>.md` per slice |
| `kanban-loop` | After tickets written | Drains backlog via specialist subagents |
| `tdd` | Inside each ticket subagent (auto — rarely manual) | Red→green→refactor cycle |
| `diagnose` | Bug with unknown root cause | Hypothesis list → fix plan |
| `improve-codebase-architecture` | Periodic refactor reflection | Refactored modules |
| `ship-it` | After backlog is drained | Commit/push/PR/merge |

## grill-me vs grill-with-docs

| | `grill-me` | `grill-with-docs` |
|-|------------|-------------------|
| Use when | No codebase yet, or purely product-level idea | Existing code with domain model and ADRs |
| Reads | Nothing — pure interview | `CONTEXT.md`, `docs/adr/` |
| Validates against | Your answers only | Domain model constraints + architecture decisions |

## kanban-loop behaviour

- Picks tickets from `.kanban/backlog/` with satisfied deps
- Dispatches fresh specialist subagent per ticket (Jasper for TS, Snape for Python, etc.)
- TDD enforced inside each subagent — red first, no exceptions
- Moves ticket to `.kanban/done/` on completion
- Pauses for review between tickets if configured

## tdd (when to invoke manually)

Rarely needed. kanban-loop injects tdd behaviour into each subagent automatically.
Invoke manually only when working outside the kanban pipeline on a feature that needs TDD scaffolding.

## ship-it checklist (what it does)

1. Verifies backlog is empty
2. Runs test suite
3. Commits any uncommitted changes
4. Pushes branch
5. Opens PR (or merges if merge-ready flag set)

## Trial notes (2026-05-04 → 2026-05-11)

Superpowers plugin is **disabled** during the trial. These skills replace:

| Removed | Replaced by |
|---------|-------------|
| `superpowers:subagent-driven-development` | `kanban-loop` |
| `superpowers:systematic-debugging` | `diagnose` |
| `superpowers:finishing-a-development-branch` | `ship-it` |
| `superpowers:test-driven-development` | `tdd` (mattpocock) |
| `pre-commit` skill | per-ticket TDD gates in kanban-loop |

Revert: set `superpowers@claude-plugins-official: true` in `claude/.claude/settings.json`.
