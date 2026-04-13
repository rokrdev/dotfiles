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
- **rtk-rewrite.sh** — PreToolUse (Bash): rewrites commands through RTK proxy for token savings
- **superpowers-redirect.sh** — PreToolUse (Write|Edit): blocks spec/plan markdown writes outside ~/projects/
- **cleanup-worktrees.sh** — SessionStart: removes merged worktrees automatically (runs on every session start)

## Hook Execution Order

**PreToolUse** hooks fire in this sequence:
1. **rtk-rewrite.sh** (Bash) — rewrites commands through RTK proxy
2. **superpowers-redirect.sh** (Write|Edit) — blocks spec/plan writes outside ~/projects/

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

**Bash** — single short commands only (<20 lines): `git`, `npm`, `npx`, `node`, `brew`, `ls`, `mkdir`, `mv`, `cp`, `stow`, `which`, `rtk`, `jq`, `uvx`, `obsidian`, `things`, `rm`

**Read** — only when you plan to Edit the file afterward (Edit needs content in context)

## Active Skills
- **neo** (agent): Loaded via `agent: neo` in settings.json; enforces orchestrator/delegation pattern
- **capture-to-things**: Invoked explicitly when tasks/action items are identified
- **obsidian**: Invoked when working in the Obsidian vault, or when creating/editing markdown outside a git repo — never use inside a git repo
- **simplify**: Invoke before commits — simplify and refine changed code for quality

## Superpowers Skills (invoke via Skill tool)
| Skill | Trigger | Purpose |
|-------|---------|---------|
| `superpowers:writing-plans` | Before entering plan mode on complex tasks | Structured planning with brainstorming step |
| `superpowers:test-driven-development` | When writing new features with tests | TDD workflow enforcement |
| `superpowers:requesting-code-review` | After completing a logical chunk of work | Structured code review checklist |
| `superpowers:systematic-debugging` | When debugging with unknown root cause | Step-by-step debugging protocol |

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

# context-mode — MANDATORY routing rules

See `rules/context-mode.md` for the full routing guide.

**TL;DR:** Use `ctx_batch_execute` for 2+ commands or >20 lines output. Use `ctx_search` for follow-up queries. Never use Bash for commands producing large output, WebFetch, or inline curl/wget — these are blocked.

@RTK.md
