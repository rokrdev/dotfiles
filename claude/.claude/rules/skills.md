# Active Skills

- **neo** (agent): Loaded via `agent: neo` in settings.json; enforces orchestrator/delegation pattern
- **capture-to-things**: Invoked explicitly when tasks/action items are identified
- **obsidian**: Invoked when working in the Obsidian vault, or when creating/editing markdown outside a git repo — never use inside a git repo
- **pre-commit**: Invoke before commits — runs simplify → review → test in sequence

## Superpowers Skills (invoke via Skill tool)

| Skill | Trigger | Purpose |
|-------|---------|---------|
| `superpowers:writing-plans` | Before entering plan mode on complex tasks | Structured planning with brainstorming step |
| `superpowers:test-driven-development` | When writing new features with tests | TDD workflow enforcement |
| `superpowers:requesting-code-review` | After completing a logical chunk of work | Structured code review checklist |
| `superpowers:systematic-debugging` | When debugging with unknown root cause | Step-by-step debugging protocol |
| `update-memory` | After completing a session or merging a PR | Memory consolidation checklist |
