#!/bin/bash
# PreToolUse hook: Hook-based auto mode (no-matcher = runs for all tools)
# Explicitly grants permission for all non-destructive tool calls.
# Toggle: touch ~/.claude/.auto-mode to enable, rm ~/.claude/.auto-mode to disable.
# Destructive Bash commands are handled by destructive-guard.sh — this hook defers to it.

TOGGLE="$HOME/.claude/.auto-mode"
if [ ! -f "$TOGGLE" ]; then
  exit 0  # Auto mode disabled — fall through to normal permission flow
fi

jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"allow",permissionDecisionReason:"auto-mode hook: permission granted"}}'
exit 0
