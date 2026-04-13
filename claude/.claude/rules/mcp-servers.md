# MCP Servers & RTK Plugins

- **Things**: Task management (CLI tool — not MCP)
- **GitHub**: Use `gh` CLI (requires `export GITHUB_TOKEN=<PAT>` with repo + read:org scopes)
- **Serena**: LSP-backed code intelligence — use for symbol lookup, find references, go-to-definition; prefer over text-based code search tools when navigating code structure
  - Always use Serena tools in coding projects instead of Read/Grep for exploration
  - Call `check_onboarding_performed` once per new project (the check is idempotent); if not done, run `onboarding` before working
  - Tool priority: `get_symbols_overview` → `find_symbol` → `find_referencing_symbols` → `search_for_pattern` (regex-based, for when symbol names are unknown); only use `Read` when you need to `Edit` a file
  - For file discovery, use `find_file` instead of Bash `find`

## RTK Plugins (loaded via settings.json `enabledPlugins`)

- **context7**: Library docs — fetch current documentation for any library/framework/API
- **context-mode**: Context protection — use `ctx_batch_execute`, `ctx_execute`, `ctx_search` to avoid flooding context window
- **Note**: No separate `mcp.json` — all MCP integration is plugin-based via `enabledPlugins` in `settings.json`
