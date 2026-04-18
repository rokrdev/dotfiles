# Active Hook Scripts

Hook scripts live in `~/.claude/hooks/` and are registered in `settings.json`.

## PreToolUse

Fire in this order:

1. **rtk-rewrite.sh** (Bash) — rewrites commands through the RTK proxy for token savings
2. **auto-approve.sh** (Bash) — env-var gated auto-approval; activate via `cc-auto` Fish function; denylist blocks destructive patterns; logs to `~/.claude/logs/auto-approve.jsonl`; fails closed on error
3. **superpowers-redirect.sh** (Write, Edit) — blocks spec/plan markdown writes outside `~/projects/`
4. **pre-commit-reminder.sh** (Bash `git commit:*`) — reminds the user to invoke the `pre-commit` skill before committing

## SessionStart

1. **cleanup-worktrees.sh** — removes merged worktrees

## WorktreeCreate

1. **worktree-create.sh** — creates a worktree at `<repo-root>/.claude/worktrees/<name>` branching from `origin/HEAD`, copies `.env*` files from the main worktree, and prints the absolute worktree path to stdout

## Maintenance

- Plugin-provided hooks (e.g. context-mode) are version-pinned in `settings.json` and may change on plugin update. Run `ctx doctor` if a plugin hook stops firing.
- The three plugins (context-mode, caveman, thedotmack) are configured with `autoUpdate: false` in `settings.json`, so their hook paths are stable — manual updates required via `ctx upgrade` or equivalent.
- Local hooks under `~/.claude/hooks/` are stable — edit the source in `~/.dotfiles/claude/.claude/hooks/` and re-stow.

## Linting

Add PostEdit hooks (eslint, ruff, ktlint, etc.) in **project** `settings.json`, never in global — linters vary by project.
