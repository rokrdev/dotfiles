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

## MCP Servers & RTK Plugins

See `@rules/mcp-servers.md` for full server list and configuration details.

See `@rules/hooks.md` for active hook scripts and maintenance notes.

See `@rules/context-mode.md` for context-mode routing rules and tool selection hierarchy.

See `@RTK.md` for RTK CLI usage and hook-based command rewriting.
