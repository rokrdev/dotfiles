# Active Hook Scripts

Hook scripts live in `~/.claude/hooks/` and are registered in `settings.json`.

## PreToolUse

Fire in this order:

1. **rtk-rewrite.sh** (Bash) — rewrites commands through the RTK proxy for token savings
2. **superpowers-redirect.sh** (Write, Edit) — blocks spec/plan markdown writes outside `~/projects/`
3. **pre-commit-reminder.sh** (Bash `git commit:*`) — reminds the user to invoke the `pre-commit` skill before committing

## PermissionRequest

1. **permission-review.sh** — routes all permission requests to Claude Opus 4.5 (effort: medium); ALLOW → auto-approves; DENY/error → falls through to user dialog; logs to `~/.claude/logs/permission-review.jsonl`

## SessionStart

1. **cleanup-worktrees.sh** — removes merged worktrees

## WorktreeCreate

1. **worktree-create.sh** — creates a worktree at `<repo-root>/.claude/worktrees/<name>` branching from `origin/HEAD`, copies `.env*` files from the main worktree, and prints the absolute worktree path to stdout

## Maintenance

- Plugin-provided hooks (e.g. context-mode) are version-pinned in `settings.json` and may change on plugin update. Run `ctx doctor` if a plugin hook stops firing.
- The plugins (context-mode, caveman) are configured with `autoUpdate: false` in `settings.json`, so their hook paths are stable — manual updates required via `ctx upgrade` or equivalent.
- Local hooks under `~/.claude/hooks/` are stable — edit the source in `~/.dotfiles/claude/.claude/hooks/` and re-stow.

## Linting

Add PostEdit hooks (eslint, ruff, ktlint, etc.) in **project** `settings.json`, never in global — linters vary by project.

## Bash Allowlist

Canonical permitted Bash commands (short-output only):
`git`, `npm`, `npx`, `node`, `brew`, `ls`, `mkdir`, `mv`, `cp`, `stow`, `which`, `rtk`, `jq`, `uvx`, `obsidian`, `things`, `rm`

Everything else routes through context-mode sandbox tools.
