# Global Claude Instructions

## IDE / Project Structure
- Projects are typically opened in IntelliJ IDEA
- Always check for a project-level CLAUDE.md for structure details
- Default IntelliJ layout (no Maven/Gradle unless stated):
  - `src/` → production sources root
  - `test/` → test sources root
- Never place test files under `src/`

@RTK.md

## Model Selection
Default model is sonnet. To use opus for heavy sessions:
```
export CLAUDE_MODEL=opus  # then restart Claude Code
```

## Per-Project Linting
Consider adding a PostEdit hook in each project's settings.json for linting (e.g., eslint, ruff, ktlint). Avoid adding linter hooks to global settings — project linters vary too much.

## MCP Servers

- **Things** — Task management (fully configured)
- **Bear** — Note taking (fully configured)
- **GitHub** — PR/issue management. Requires: `export GITHUB_TOKEN=<your-PAT>` in shell profile. Create PAT at github.com/settings/tokens with repo + read:org scopes.
- **context7** — Library documentation lookup (via plugin)
- **context-mode** — Context window management (via plugin)
