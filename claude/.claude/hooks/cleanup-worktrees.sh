#!/bin/bash
# SessionStart hook: remove worktrees whose branches are merged into main
# Runs at session start to catch any worktrees missed by previous sessions.

REPO="$HOME/.dotfiles"
LOG="$HOME/.claude/logs/hooks.log"
mkdir -p "$HOME/.claude/logs" 2>/dev/null || true

if [ ! -d "$REPO/.git" ]; then exit 0; fi

WORKTREE_BASE="$REPO/.claude/worktrees"
if [ ! -d "$WORKTREE_BASE" ]; then exit 0; fi

TRUNK=$(git -C "$REPO" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
if [ -z "$TRUNK" ]; then TRUNK="main"; fi

while IFS= read -r -d '' worktree_path; do
  branch=$(git -C "$REPO" worktree list --porcelain | awk -v wt="$worktree_path" '
    /^worktree / { current=$2 }
    /^branch /   { if (current == wt) print $2 }
  ' | sed 's|refs/heads/||')

  if [ -z "$branch" ]; then continue; fi

  if git -C "$REPO" branch --merged "$TRUNK" | grep -qw "$branch"; then
    echo "[cleanup-worktrees] $(date -u +%FT%TZ) removing merged worktree: $worktree_path (branch: $branch)" >> "$LOG"
    if ! remove_err=$(git -C "$REPO" worktree remove "$worktree_path" --force 2>&1); then
      echo "[cleanup-worktrees] ERROR removing $worktree_path: $remove_err" >> "$LOG"
      continue
    fi
    if ! branch_err=$(git -C "$REPO" branch -d "$branch" 2>&1); then
      echo "[cleanup-worktrees] WARNING deleting branch $branch: $branch_err" >> "$LOG"
    fi
  fi
done < <(find "$WORKTREE_BASE" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
