# Active Hook Scripts

Hook scripts live in `~/.claude/hooks/` and are registered in `settings.json`.

## PreToolUse

Fire in this order:

1. **rtk-rewrite.sh** (Bash) — rewrites commands through the RTK proxy for token savings

## PermissionRequest

1. **permission-review.sh** — routes all permission requests to claude-sonnet-4-6 (configurable via `CLAUDE_PERMISSION_REVIEW_MODEL` env var; effort: medium); ALLOW → auto-approves; DENY/error → falls through to user dialog; logs to `~/.claude/logs/permission-review.jsonl`

## Notification / StopFailure

1. **claude-notify.sh** — sends macOS system notifications via `osascript`. Fires on both `Notification` (informational alerts) and `StopFailure` (session stop failures) events. Always exits 0, never writes to stdout.

## SessionStart

Fire in this order:

1. **RTK check** (inline) — verifies `rtk` is installed and prints version; warns if missing
2. **Context restore** (inline) — prints Iron Law reminder and recent git log for post-compaction continuity
3. **Log rotation** (inline) — rotates `hooks.log` if > 1 MB
4. **cleanup-worktrees.sh** — removes merged and stale worktrees
5. **context-mode-cache-heal.mjs** (plugin) — context-mode plugin hook for cache healing

## WorktreeCreate

1. **worktree-create.sh** — creates a worktree at `<repo-root>/.claude/worktrees/<name>` branching from `origin/HEAD`, copies `.env*` files from the main worktree, and prints the absolute worktree path to stdout

## Maintenance

- Plugin-provided hooks (e.g. context-mode) are version-pinned in `settings.json` and may change on plugin update. Run `ctx doctor` if a plugin hook stops firing.
- Plugin hook paths may change on plugin update. Run `ctx upgrade` for context-mode updates.
- Local hooks under `~/.claude/hooks/` are stable — edit the source in `~/.dotfiles/claude/.claude/hooks/` and re-stow.

## Linting

Add PostEdit hooks (eslint, ruff, ktlint, etc.) in **project** `settings.json`, never in global — linters vary by project.

## Bash Allowlist

Canonical permitted Bash commands (short-output only):
`git`, `npm`, `npx`, `node`, `brew`, `ls`, `mkdir`, `mv`, `cp`, `stow`, `which`, `rtk`, `jq`, `uvx`, `obsidian`, `things`, `rm`

Everything else routes through context-mode sandbox tools.
