#!/bin/bash
# SessionStart hook: remove worktrees whose branches are merged into main
# Runs at session start to catch any worktrees missed by previous sessions.

REPO=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO" ]; then
  exit 0  # not in a git repo, nothing to do
fi
LOG="$HOME/.claude/logs/hooks.log"
mkdir -p "$HOME/.claude/logs" 2>/dev/null || true

_log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$1] $2" >> "$LOG"; }

WORKTREE_BASE="$REPO/.claude/worktrees"
if [ ! -d "$WORKTREE_BASE" ]; then exit 0; fi

TRUNK=$(git -C "$REPO" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
if [ -z "$TRUNK" ]; then TRUNK="main"; fi

STALE_SECONDS=$((15 * 24 * 3600))
STALE_CUTOFF=$(( $(date +%s) - STALE_SECONDS ))

while IFS= read -r -d '' worktree_path; do
  branch=$(git -C "$REPO" worktree list --porcelain | awk -v wt="$worktree_path" '
    /^worktree / { current=$2 }
    /^branch /   { if (current == wt) print $2 }
  ' | sed 's|refs/heads/||')

  if [ -z "$branch" ]; then continue; fi

  if git -C "$REPO" branch --merged "$TRUNK" | grep -qw "$branch"; then
    _log "cleanup-worktrees" "removed worktree: $(basename "$worktree_path")"
    if ! remove_err=$(git -C "$REPO" worktree remove "$worktree_path" --force 2>&1); then
      _log "cleanup-worktrees" "ERROR removing $worktree_path: $remove_err"
      continue
    fi
    if ! branch_err=$(git -C "$REPO" branch -d "$branch" 2>&1); then
      _log "cleanup-worktrees" "WARNING deleting branch $branch: $branch_err"
    fi
  else
    last_commit_ts=$(git -C "$REPO" log -1 --format=%ct "$branch" 2>/dev/null)
    if [ -n "$last_commit_ts" ] && [ "$last_commit_ts" -lt "$STALE_CUTOFF" ]; then
      _log "cleanup-worktrees" "stale worktree (15d+): $(basename "$worktree_path")"
      if ! remove_err=$(git -C "$REPO" worktree remove "$worktree_path" --force 2>&1); then
        _log "cleanup-worktrees" "ERROR removing $worktree_path: $remove_err"
        continue
      fi
      if ! branch_err=$(git -C "$REPO" branch -D "$branch" 2>&1); then
        _log "cleanup-worktrees" "WARNING deleting branch $branch: $branch_err"
      fi
    fi
  fi
done < <(find "$WORKTREE_BASE" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)

# Second pass: clean up orphaned worktree branches (directory already gone, branch remains)
while IFS= read -r branch; do
  # Skip if branch still has a live worktree registered with git
  if git -C "$REPO" worktree list --porcelain | grep -q "branch refs/heads/$branch"; then
    continue
  fi

  if git -C "$REPO" branch --merged "$TRUNK" | grep -qw "$branch"; then
    if branch_err=$(git -C "$REPO" branch -d "$branch" 2>&1); then
      _log "cleanup-worktrees" "deleted orphaned branch (merged): $branch"
    else
      _log "cleanup-worktrees" "WARNING deleting orphaned branch $branch: $branch_err"
    fi
  else
    last_commit_ts=$(git -C "$REPO" log -1 --format=%ct "$branch" 2>/dev/null)
    if [ -n "$last_commit_ts" ] && [ "$last_commit_ts" -lt "$STALE_CUTOFF" ]; then
      if branch_err=$(git -C "$REPO" branch -D "$branch" 2>&1); then
        _log "cleanup-worktrees" "force-deleted orphaned stale branch (15d+): $branch"
      else
        _log "cleanup-worktrees" "WARNING force-deleting orphaned branch $branch: $branch_err"
      fi
    fi
  fi
done < <(git -C "$REPO" branch --format='%(refname:short)' | grep -E '^(worktree-agent-|agent-[a-f0-9]{8,})')
