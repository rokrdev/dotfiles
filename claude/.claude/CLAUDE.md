# Global Claude Instructions

## IDE / Project Structure
- Default layout: `src/` (prod), `test/` (tests) — never under `src/`
- Check project-level CLAUDE.md for overrides
- IntelliJ IDEA is standard

## Model Selection
- Default: sonnet
- Heavy sessions: `export CLAUDE_MODEL=opus && restart`
- Subagents: claude-haiku-4-5-20251001 (set via CLAUDE_CODE_SUBAGENT_MODEL)
- Reasoning: subagent=haiku saves costs; main=sonnet balances speed/quality

## Linting
- Add PostEdit hooks in **project** settings.json (eslint, ruff, ktlint, etc.)
- Never add to global — linters vary by project

## MCP Servers & RTK Plugins
- **Things**: Task management (CLI tool — not MCP)
- **GitHub**: Use `gh` CLI (requires `export GITHUB_TOKEN=<PAT>` with repo + read:org scopes)

## RTK Plugins (loaded via settings.json `enabledPlugins`)
- **context7**: Library docs — fetch current documentation for any library/framework/API
- **context-mode**: Context protection — use `ctx_batch_execute`, `ctx_execute`, `ctx_search` to avoid flooding context window

## Active Hook Scripts
- **rtk-rewrite.sh**: Token-saving command rewrites (delegates to RTK Rust binary)
- **superpowers-redirect.sh**: Redirects superpowers docs to Obsidian vault if outside projects

## Active Skills
- **main-agent-is-orchestrator**: Loaded auto at SessionStart; enforces delegation pattern
- **capture-to-things**: Invoked explicitly when tasks/action items are identified
- **superpowers:***: Planning (writing-plans), reviews (requesting-code-review), debugging, etc.

## Documentation
- Project specs → `docs/` at repo root
- Cross-project docs → `~/projects/docs/`
- Superpowers specs → `~/projects/sacredyak/Resources/projects/superpowers/` (Obsidian vault)
- Finalized docs live in repos

## Compaction
When compacting, always preserve: file paths, test results, error messages, key decisions, and any explicit user instructions given during the session.

@RTK.md
