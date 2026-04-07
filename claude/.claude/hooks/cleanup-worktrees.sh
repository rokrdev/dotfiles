#!/bin/bash
# Post-push hook: remove worktrees whose branches are merged into main
mkdir -p "$HOME/.claude/logs" || true
exec 2>>"$HOME/.claude/logs/hooks.log"

REPO=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO" ]; then exit 0; fi

TRUNK=$(git -C "$REPO" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
if [ -z "$TRUNK" ]; then
  echo "[cleanup-worktrees] WARNING: could not detect trunk via origin/HEAD — falling back to 'main'. Run: git remote set-head origin --auto" >&2
  TRUNK="main"
fi

WORKTREE_BASE="$REPO/.claude/worktrees"
if [ ! -d "$WORKTREE_BASE" ]; then exit 0; fi

while IFS= read -r -d '' worktree_path; do
  branch=$(git -C "$REPO" worktree list --porcelain | awk -v wt="$worktree_path" '
    /^worktree / { current=$2 }
    /^branch /   { if (current == wt) print $2 }
  ' | sed 's|refs/heads/||')

  if [ -z "$branch" ]; then continue; fi

  if git -C "$REPO" branch --merged "$TRUNK" | grep -qw "$branch"; then
    echo "[cleanup-worktrees] $(date -u +%FT%TZ) removing merged worktree: $worktree_path (branch: $branch)" >&2
    if ! remove_err=$(git -C "$REPO" worktree remove "$worktree_path" --force 2>&1); then
      echo "[cleanup-worktrees] ERROR: failed to remove worktree $worktree_path: $remove_err" >&2
      continue
    fi
    if ! branch_err=$(git -C "$REPO" branch -d "$branch" 2>&1); then
      echo "[cleanup-worktrees] WARNING: could not delete branch $branch: $branch_err" >&2
    fi
  fi
done < <(find "$WORKTREE_BASE" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
