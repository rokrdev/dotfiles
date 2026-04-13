#!/bin/bash
# PreToolUse hook: Hook-based auto mode (no-matcher = runs for all tools)
# Explicitly grants permission for all non-Bash tool calls when toggle is enabled.
# Bash is excluded — destructive-guard.sh handles Bash safety.
# Requires 30-second confirmation window for security.
#
# Toggle:
#   First invocation: touch ~/.claude/.auto-mode
#     (creates pending file, user must confirm within 30s)
#   Second invocation within 30s: touch ~/.claude/.auto-mode
#     (confirms and enables auto-mode)
#   To disable: rm ~/.claude/.auto-mode

TOGGLE="$HOME/.claude/.auto-mode"
PENDING="$HOME/.claude/.auto-mode-pending"
LOG_DIR="$HOME/.claude/logs"
LOG_FILE="$LOG_DIR/auto-mode.log"

# Ensure log directory exists
mkdir -p "$LOG_DIR" 2>/dev/null

log_event() {
  local event="$1"
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] [auto-mode] $event" >> "$LOG_FILE"
}

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

# Check if toggle already exists — user is disabling auto-mode
if [ -f "$TOGGLE" ]; then
  rm "$TOGGLE"
  log_event "DISABLED by $TOOL"
  exit 0
fi

# Check if auto-mode is currently enabled
if [ -f "$TOGGLE" ]; then
  # Auto mode is already enabled — grant permission
  jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"allow",permissionDecisionReason:"auto-mode hook: permission granted"}}'
  exit 0
fi

# Auto mode is not enabled. Check if pending confirmation exists.
if [ -f "$PENDING" ]; then
  # Pending file exists — check if it's still within 30-second window
  PENDING_TIME=$(cat "$PENDING" 2>/dev/null)
  CURRENT_TIME=$(date +%s)
  ELAPSED=$((CURRENT_TIME - PENDING_TIME))

  if [ "$ELAPSED" -lt 30 ]; then
    # Confirmation window is still open — enable auto-mode
    echo "$CURRENT_TIME" > "$TOGGLE"
    rm -f "$PENDING"
    log_event "ENABLED by $TOOL"
    echo "auto-mode.sh: auto-mode enabled" >&2
    exit 0
  else
    # Confirmation window expired — treat as first invocation
    log_event "confirmation window expired, resetting"
    echo "$CURRENT_TIME" > "$PENDING"
    log_event "confirmation pending - invoke again within 30s to enable"
    echo "auto-mode.sh: pending confirmation expired. New confirmation window opened." >&2
    echo "auto-mode.sh: Please invoke again within 30 seconds to confirm auto-mode enable." >&2
    exit 0
  fi
else
  # No pending file — this is the first invocation
  CURRENT_TIME=$(date +%s)
  echo "$CURRENT_TIME" > "$PENDING"
  log_event "confirmation pending - invoke again within 30s to enable"
  echo "auto-mode.sh: auto-mode pending confirmation — please invoke again within 30 seconds to confirm" >&2
  exit 0
fi
