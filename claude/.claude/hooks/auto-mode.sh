#!/usr/bin/env bash
# auto-mode.sh — Hook-based auto-approve mode
# Toggle: touch ~/.claude/.auto-mode to enable, rm ~/.claude/.auto-mode to disable

TOGGLE="$HOME/.claude/.auto-mode"

# Read stdin FIRST — can only be read once
INPUT=$(cat)

# Always protect the toggle file — user-controlled only
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
if echo "$COMMAND $FILE_PATH" | grep -qF '.auto-mode'; then
    jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:"~/.claude/.auto-mode is user-controlled — Claude cannot create or delete it"}}'
    exit 0
fi

# Exit early if auto mode is disabled
if [ ! -f "$TOGGLE" ]; then
    exit 0
fi

# Deny list — dangerous commands fall through to normal permission flow
if echo "$COMMAND" | grep -qE '(rm\s+-rf\s+/|DROP\s+TABLE|curl.*\|\s*bash|shutdown|reboot)'; then
    exit 0
fi

jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"allow",permissionDecisionReason:"Hook-based auto mode",bypassPermissions:true}}'
exit 0
