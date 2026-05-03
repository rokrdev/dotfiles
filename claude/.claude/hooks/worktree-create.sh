#!/usr/bin/env bash
# WorktreeCreate hook — creates a git worktree and copies .env* files from main worktree
# Receives JSON on stdin: {name, session_id, cwd}
# Must print the absolute path of the created worktree directory to stdout

set -euo pipefail

LOG_PREFIX="[worktree-create]"

# Read stdin JSON
INPUT=$(cat)
NAME=$(echo "$INPUT" | jq -r '.name // empty')
CWD=$(echo "$INPUT"  | jq -r '.cwd  // empty')
if [[ -z "$NAME" || -z "$CWD" ]]; then
  echo "$LOG_PREFIX ERROR: missing required fields name/cwd in input" >&2
  exit 1
fi

echo "$LOG_PREFIX name=$NAME cwd=$CWD" >&2

# Find git repo root from cwd
REPO_ROOT=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
  echo "$LOG_PREFIX ERROR: Could not find git repo root from $CWD" >&2
  exit 1
fi
echo "$LOG_PREFIX repo root=$REPO_ROOT" >&2

# Worktree destination
WORKTREE_DIR="$REPO_ROOT/.claude/worktrees/$NAME"
echo "$LOG_PREFIX worktree dir=$WORKTREE_DIR" >&2

# Create parent directory if needed
mkdir -p "$(dirname "$WORKTREE_DIR")"

# Detect default branch, with fallbacks if origin/HEAD is not set
DEFAULT_BRANCH=""

if command -v git &> /dev/null; then
  # First: try local symbolic-ref (no network)
  _SYMREF=$(git -C "$REPO_ROOT" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || true)
  if [ -n "$_SYMREF" ]; then
    DEFAULT_BRANCH="origin/$_SYMREF"
  else
    # Network fallback: git remote show origin
    echo "$LOG_PREFIX WARNING: origin/HEAD not set locally, falling back to network call" >&2
    _REMOTE=$(git -C "$REPO_ROOT" remote show origin 2>/dev/null | grep "HEAD branch" | awk '{print $NF}' || true)
    if [ -n "$_REMOTE" ]; then
      DEFAULT_BRANCH="origin/$_REMOTE"
    # Static fallbacks
    elif git -C "$REPO_ROOT" rev-parse --verify "origin/main" &>/dev/null; then
      DEFAULT_BRANCH="origin/main"
    elif git -C "$REPO_ROOT" rev-parse --verify "origin/master" &>/dev/null; then
      DEFAULT_BRANCH="origin/master"
    else
      # Last resort: use current HEAD (no remote base)
      DEFAULT_BRANCH="HEAD"
    fi
  fi
fi

if [ -z "$DEFAULT_BRANCH" ]; then
  echo "$LOG_PREFIX ERROR: Could not detect default branch" >&2
  exit 1
fi

echo "$LOG_PREFIX default branch=$DEFAULT_BRANCH" >&2

# Create the worktree branching from the detected default branch
GIT_OUT=$(git -C "$REPO_ROOT" worktree add "$WORKTREE_DIR" -b "worktree-$NAME" "$DEFAULT_BRANCH" 2>&1) || {
  echo "$LOG_PREFIX ERROR: git worktree add failed: $GIT_OUT" >&2
  exit 1
}
echo "$GIT_OUT" | while IFS= read -r line; do echo "$LOG_PREFIX git: $line" >&2; done

# Copy .env* files from cwd into the new worktree
ENV_COUNT=0
while IFS= read -r -d '' ENV_FILE; do
  BASENAME=$(basename "$ENV_FILE")
  DEST="$WORKTREE_DIR/$BASENAME"
  if cp "$ENV_FILE" "$DEST"; then
    echo "$LOG_PREFIX copied $BASENAME → $DEST" >&2
  else
    echo "$LOG_PREFIX WARNING: failed to copy $BASENAME to $DEST (continuing)" >&2
  fi
  ENV_COUNT=$((ENV_COUNT + 1))
done < <(find "$CWD" -maxdepth 1 -name '.env*' -type f -print0 2>/dev/null)

echo "$LOG_PREFIX copied $ENV_COUNT .env* file(s)" >&2

# Print the worktree path to stdout (required by WorktreeCreate hook contract)
echo "$WORKTREE_DIR"
