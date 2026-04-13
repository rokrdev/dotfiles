# Active Hook Scripts

- **rtk-rewrite.sh** — PreToolUse (Bash): rewrites commands through RTK proxy for token savings
- **superpowers-redirect.sh** — PreToolUse (Write|Edit): blocks spec/plan markdown writes outside ~/projects/
- **cleanup-worktrees.sh** — SessionStart: removes merged worktrees automatically (runs on every session start)

## Hook Execution Order

**PreToolUse** hooks fire in this sequence:
1. **rtk-rewrite.sh** (Bash) — rewrites commands through RTK proxy for token savings
2. **superpowers-redirect.sh** (Write|Edit) — blocks spec/plan writes outside ~/projects/

**SessionStart** hooks fire in this sequence:
1. cleanup-worktrees.sh — removes merged worktrees
