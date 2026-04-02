# Global Claude Instructions

## IDE / Project Structure
- Default layout: `src/` (prod), `test/` (tests) — never under `src/`
- Check project-level CLAUDE.md for overrides
- IntelliJ IDEA is standard

## Model Selection
- Default: sonnet
- Heavy sessions: `export CLAUDE_MODEL=opus && restart`

## Linting
- Add PostEdit hooks in **project** settings.json (eslint, ruff, ktlint, etc.)
- Never add to global — linters vary by project

## MCP Servers
- **Things**: Task management
- **Bear**: Note taking
- **GitHub**: `export GITHUB_TOKEN=<PAT>` (repo + read:org scopes)
- **context7**: Library docs
- **context-mode**: Context protection

## Documentation
- Project specs → `docs/` at repo root
- Cross-project docs → `~/projects/docs/`
- Bear is capture-only; finalized docs live in repos

## Compaction
When compacting, always preserve: file paths, test results, error messages, key decisions, and any explicit user instructions given during the session.
