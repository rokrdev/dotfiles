Audit and tune the agent instruction files in this repo. Do not apply edits — output proposed changes for review.

## Files to review

- CLAUDE.md (root and any nested)
- All files in .claude/agents/
- All files in .claude/commands/
- Any AGENTS.md, .cursorrules, or adjacent instruction files

## Phase 1 — Inventory

For each file: path, line count, rough token estimate, last-modified date, one-sentence scope summary.

## Phase 2 — Diagnose

For each file, flag instances of:

1. Vague principles ("write clean code", "be careful", "follow best practices"). Quote the line and propose a concrete replacement spelling out the actual behavior (e.g., "max nesting 3, early returns, no else-after-return").

2. Misplaced rules — instructions far from the decision point they govern. A "run tests before commit" rule buried in general guidelines is the canonical example. Propose where it should live instead.

3. Missing examples — any non-trivial rule without 1-2 worked examples. Draft the examples.

4. Negative framing where positive would work — rewrite "don't do X" as "do Y" unless it's a genuine never-rule (security, destructive ops, secrets).

5. Stale/fossil rules — anything that reads like a one-off frustration patch rather than a recurring pattern. Mark for likely deletion with reasoning.

6. Orchestrator/subagent duplication — rules repeated across CLAUDE.md and individual subagents. Identify canonical home (orchestration → main; execution detail → subagent) and propose where to cut.

7. Contradictions — direct or implicit conflicts. List as pairs with file:line refs.

8. Token bloat — sections cuttable by 50%+ without losing instruction content. Show the trim.

## Phase 3 — Output three artifacts

1. audit-report.md — findings grouped by file, with severity (critical / nice-to-have) and expected behavioral impact.

2. Concrete diffs — before/after blocks for the top 10 highest-impact changes, ranked by behavioral improvement per token saved.

3. regression-scenarios.md — 5-10 prompt scenarios to manually re-test after changes land. Format each as: scenario, expected behavior, governing rule(s). Derive these from what the current instructions appear designed to handle.

## Constraints

- Default to deletion and consolidation over addition.
- If a rule's purpose is unclear, ask before proposing a change — don't guess.
- Don't add philosophy preambles, mission statements, or anything I didn't ask for.
- Treat the instruction file as code: every line should justify its tokens.
- Cite file:line for every finding so I can verify quickly.
