#!/bin/bash
# PreToolUse hook: Hook-based auto mode (no-matcher = runs for all tools)
# Explicitly grants permission for all non-Bash tool calls when toggle is enabled.
# Bash is excluded — destructive-guard.sh handles Bash safety.
# Toggle: touch ~/.claude/.auto-mode to enable, rm ~/.claude/.auto-mode to disable.

TOGGLE="$HOME/.claude/.auto-mode"
if [ ! -f "$TOGGLE" ]; then
  exit 0  # Auto mode disabled — fall through to normal permission flow
fi

if ! command -v jq &>/dev/null; then
  echo "auto-mode.sh: jq not found — cannot grant permission" >&2
  exit 0  # Defer to normal flow
fi

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)

# Exclude Bash — let destructive-guard.sh handle safety checks
if [ "$TOOL" = "Bash" ]; then
  exit 0
fi

jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"allow",permissionDecisionReason:"auto-mode hook: permission granted"}}'
exit 0
