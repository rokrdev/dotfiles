#!/bin/bash
# Post-push hook: remove worktrees whose branches are merged into main
mkdir -p "$HOME/.claude/logs" || true
exec 2>>"$HOME/.claude/logs/hooks.log"

REPO=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO" ]; then exit 0; fi

WORKTREE_BASE="$REPO/.claude/worktrees"
if [ ! -d "$WORKTREE_BASE" ]; then exit 0; fi

while IFS= read -r -d '' worktree_path; do
  branch=$(git -C "$REPO" worktree list --porcelain | awk -v wt="$worktree_path" '
    /^worktree / { current=$2 }
    /^branch /   { if (current == wt) print $2 }
  ' | sed 's|refs/heads/||')

  if [ -z "$branch" ]; then continue; fi

  if git -C "$REPO" branch --merged main | grep -qw "$branch"; then
    echo "[cleanup-worktrees] $(date -u +%FT%TZ) removing merged worktree: $worktree_path (branch: $branch)" >&2
    git -C "$REPO" worktree remove "$worktree_path" --force 2>/dev/null || true
    git -C "$REPO" branch -d "$branch" 2>/dev/null || true
  fi
done < <(find "$WORKTREE_BASE" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
