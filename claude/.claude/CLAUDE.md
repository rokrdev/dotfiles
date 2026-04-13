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

## MCP Servers & RTK Plugins

See `@rules/mcp-servers.md` for full server list and configuration details.

See `@rules/hooks.md` for active hook scripts and maintenance notes.
