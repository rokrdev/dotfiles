# Global Claude Instructions

## IDE / Project Structure

- Default layout: `src/` (prod), `test/` (tests) — never under `src/`
- Check project-level CLAUDE.md for overrides
- IntelliJ IDEA is standard

## Model Selection

- Default: claude-sonnet-4-6
- Heavy sessions: `export CLAUDE_MODEL=opus && restart`
- Subagents: claude-haiku-4-5-20251001 (default — override per-dispatch for heavier work)
- Reasoning: Haiku default saves cost on bulk subagent work; pass model: sonnet/opus explicitly in Agent calls for reasoning-heavy or multi-file tasks

## Execution Preferences

- **Plan execution:** Always use kanban-loop skill — never Inline Execution. Fresh subagent per task, review between tasks. <!-- TRIAL 2026-05-04 → 2026-05-11: previously superpowers:subagent-driven-development; revert if trial fails. See ~/.dotfiles/docs/kanban-workflow.md -->
# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.
