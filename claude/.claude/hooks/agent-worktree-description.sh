#!/usr/bin/env bash
# PreToolUse hook for Agent: spool the description so WorktreeCreate can read it.

set -u

payload="$(command cat 2>/dev/null)"
spool="${TMPDIR:-/tmp}/claude-worktree-desc"

command -v jq >/dev/null 2>&1 || exit 0
mkdir -p "$spool" 2>/dev/null || exit 0

# Drop leftovers from calls that never reached worktree creation.
find "$spool" -type f -mmin +10 -delete 2>/dev/null

session_id="$(printf '%s' "$payload" | jq -r '.session_id // empty' 2>/dev/null)"
description="$(printf '%s' "$payload" | jq -r 'select(.tool_input.isolation? == "worktree") | .tool_input.description // empty' 2>/dev/null)"

if [ -n "$session_id" ] && [ -n "$description" ]; then
  printf '%s' "$description" > "$spool/$session_id.$(date +%s).$$"
fi
exit 0
