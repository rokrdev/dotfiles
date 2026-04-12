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

## Linting
- Add PostEdit hooks in **project** settings.json (eslint, ruff, ktlint, etc.)
- Never add to global — linters vary by project

## MCP Servers & RTK Plugins
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

## Maintenance Notes
- **After `ctx upgrade`**: context-mode hook paths in `settings.json` are version-pinned by the plugin. Verify hook commands still resolve after upgrades — run `ctx doctor` if hooks stop firing.

## Active Hook Scripts
- **rtk-rewrite.sh** — PreToolUse(Bash): rewrites commands through RTK proxy for token savings
- **superpowers-redirect.sh** — PreToolUse(Write|Edit): blocks spec/plan markdown writes outside ~/projects/
- **cleanup-worktrees.sh** — SessionStart: removes merged worktrees automatically (runs on every session start)
- **destructive-guard.sh** — PreToolUse(Bash): blocks DROP TABLE, rm -rf /, force-push to main, etc.

## Hook Execution Order

**PreToolUse** hooks fire in this sequence:
1. **auto-mode.sh** (all tools) — validates environment mode
2. **destructive-guard.sh** (Bash) — blocks DROP TABLE, rm -rf /, force-push main
3. **rtk-rewrite.sh** (Bash) — rewrites commands through RTK proxy
4. **superpowers-redirect.sh** (Write|Edit) — blocks spec/plan writes outside ~/projects/

**SessionStart** hooks fire in this sequence (after orchestrator mode loads):
1. cleanup-worktrees.sh — removes merged worktrees

## Context-Mode Decision Guide

**GATHER** — `ctx_batch_execute(commands, queries)`: primary entry point for research
- 2+ commands, or any command producing >20 lines output
- Results are auto-indexed; pass queries to search them in the same call

**FOLLOW-UP** — `ctx_search(queries: [...])`: query previously indexed content
- Use after `ctx_batch_execute` or `ctx_fetch_and_index`

**PROCESSING** — `ctx_execute(language, code)` / `ctx_execute_file(path, language, code)`:
- Sandbox execution; only stdout enters context
- Use `ctx_execute_file` for analyzing large files without loading them into context

**WEB** — `ctx_fetch_and_index(url, source)` then `ctx_search(queries)`:
- Fetches, chunks, and indexes web pages; raw HTML never enters context

**Bash** — single short commands only (<20 lines): `git add`, `ls`, `mkdir`, `rm`, `mv`

**Read** — only when you plan to Edit the file afterward (Edit needs content in context)

## Active Skills
- **yak** (agent): Loaded via `agent: yak` in settings.json; enforces orchestrator/delegation pattern
- **capture-to-things**: Invoked explicitly when tasks/action items are identified
- **obsidian**: Invoked when working in the Obsidian vault, or when creating/editing markdown outside a git repo — never use inside a git repo
- **superpowers:***: Planning (writing-plans), reviews (requesting-code-review), debugging, etc.

## Markdown File Creation — Hard Rule

When creating any `.md` file:
- **Inside a git repo** → create in that repo; use `docs/` for specs and plans
- **Outside a git repo** → invoke the `obsidian` skill to route to the correct vault folder

Vault root: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Sacredyak/`

Exceptions (always created in their designated locations regardless of context):
- **Claude Code system files** (under `~/.claude/`): `CLAUDE.md`, `settings.json`, hooks, skills, MCP configs
- **Memory files** (under `~/.claude/projects/*/memory/`): `MEMORY.md` and session memory records

## Documentation
- Project specs → `docs/` at repo root
- Cross-project docs → `~/projects/docs/`
- Superpowers specs → `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Sacredyak/Resources/projects/superpowers/` (Obsidian vault)
- Finalized docs live in repos

## Compaction
After compaction, restate: file paths, test results, error messages, key decisions, and any explicit user instructions from the session — so context is not lost.

@RTK.md

# context-mode — MANDATORY routing rules

You have context-mode MCP tools available. These rules are NOT optional — they protect your context window from flooding. A single unrouted command can dump 56 KB into context and waste the entire session.

## BLOCKED commands — do NOT attempt these

### curl / wget — BLOCKED
Any Bash command containing `curl` or `wget` is intercepted and replaced with an error message. Do NOT retry.
Instead use:
- `ctx_fetch_and_index(url, source)` to fetch and index web pages
- `ctx_execute(language: "javascript", code: "const r = await fetch(...)")` to run HTTP calls in sandbox

### Inline HTTP — BLOCKED
Any Bash command containing `fetch('http`, `requests.get(`, `requests.post(`, `http.get(`, or `http.request(` is intercepted and replaced with an error message. Do NOT retry with Bash.
Instead use:
- `ctx_execute(language, code)` to run HTTP calls in sandbox — only stdout enters context

### WebFetch — BLOCKED
WebFetch calls are denied entirely. The URL is extracted and you are told to use `ctx_fetch_and_index` instead.
Instead use:
- `ctx_fetch_and_index(url, source)` then `ctx_search(queries)` to query the indexed content

## REDIRECTED tools — use sandbox equivalents

### Bash (>20 lines output)
Bash is ONLY for: `git`, `mkdir`, `rm`, `mv`, `cd`, `ls`, `npm install`, `pip install`, and other short-output commands.
For everything else, use:
- `ctx_batch_execute(commands, queries)` — run multiple commands + search in ONE call
- `ctx_execute(language: "shell", code: "...")` — run in sandbox, only stdout enters context

### Read (for analysis)
If you are reading a file to **Edit** it → Read is correct (Edit needs content in context).
If you are reading to **analyze, explore, or summarize** → use `ctx_execute_file(path, language, code)` instead. Only your printed summary enters context. The raw file content stays in the sandbox.

### Grep (large results)
Grep results can flood context. Use `ctx_execute(language: "shell", code: "grep ...")` to run searches in sandbox. Only your printed summary enters context.

## Tool selection hierarchy

1. **GATHER**: `ctx_batch_execute(commands, queries)` — Primary tool. Runs all commands, auto-indexes output, returns search results. ONE call replaces 30+ individual calls.
2. **FOLLOW-UP**: `ctx_search(queries: ["q1", "q2", ...])` — Query indexed content. Pass ALL questions as array in ONE call.
3. **PROCESSING**: `ctx_execute(language, code)` | `ctx_execute_file(path, language, code)` — Sandbox execution. Only stdout enters context.
4. **WEB**: `ctx_fetch_and_index(url, source)` then `ctx_search(queries)` — Fetch, chunk, index, query. Raw HTML never enters context.
5. **INDEX**: `ctx_index(content, source)` — Store content in FTS5 knowledge base for later search.

## Subagent routing

When spawning subagents (Agent/Task tool), the routing block is automatically injected into their prompt. Bash-type subagents are upgraded to general-purpose so they have access to MCP tools. You do NOT need to manually instruct subagents about context-mode.

## Output constraints

- Keep responses under 500 words.
- Write artifacts (code, configs, PRDs) to FILES — never return them as inline text. Return only: file path + 1-line description.
- When indexing content, use descriptive source labels so others can `ctx_search(source: "label")` later.

## ctx commands

| Command | Action |
|---------|--------|
| `ctx stats` | Call the `ctx_stats` MCP tool and display the full output verbatim |
| `ctx doctor` | Call the `ctx_doctor` MCP tool, run the returned shell command, display as checklist |
| `ctx upgrade` | Call the `ctx_upgrade` MCP tool, run the returned shell command, display as checklist |
