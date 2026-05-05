# MCP Servers & RTK Plugins

- **Things**: Task management (CLI tool — not MCP)
- **GitHub**: Use `gh` CLI (requires `export GITHUB_TOKEN=<PAT>` with repo + read:org scopes)
- **Serena**: LSP-backed code intelligence — mandatory for code navigation when onboarded
  - Call `check_onboarding_performed` once per new project (idempotent); if not done, run `onboarding` before working
  - **Grep is PROHIBITED for code navigation when Serena is onboarded.** Fall back to Grep only if Serena is NOT onboarded, or for non-code files (YAML, JSON, markdown, plain text).
  - Tool priority: `get_symbols_overview` → `find_symbol` → `find_referencing_symbols` → `search_for_pattern` (regex within Serena)
  - Use `Read` only when about to `Edit` a file immediately — never for exploration
  - Use `find_file` instead of Bash `find` for file discovery

## RTK Plugins (loaded via settings.json `enabledPlugins`)

- **context7**: Library docs — fetch current documentation for any library/framework/API
- **context-mode**: Context protection — use `ctx_batch_execute`, `ctx_execute`, `ctx_search` to avoid flooding context window
