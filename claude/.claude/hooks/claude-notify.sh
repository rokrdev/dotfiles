#!/bin/bash
# claude-notify.sh — macOS system notifications for Claude Code hook events
# Handles: Notification (waiting/needs attention), StopFailure (task error)
# Exit 0 always — never blocks. Never writes to stdout.

INPUT=$(cat)

# Extract all fields in one jq call
read -r EVENT MESSAGE ERROR DETAILS < <(echo "$INPUT" | jq -r '[
  .hook_event_name // "",
  .message // "Claude needs your attention",
  .error // "unknown",
  .error_details // ""
] | @tsv' 2>/dev/null)

_notify() {
  local title="$1"
  local msg="$2"
  local sound="$3"
  osascript - "$title" "$msg" "$sound" <<'EOF' 2>/dev/null &
on run {t, m, s}
  display notification m with title t sound name s
end run
EOF
  disown
}

case "$EVENT" in
  Notification)
    _notify "Claude — Waiting" "$MESSAGE" "Tink"
    ;;
  StopFailure)
    if [ -n "$DETAILS" ]; then
      MSG="$ERROR: $DETAILS"
    else
      MSG="$ERROR"
    fi
    _notify "Claude — Error" "$MSG" "Basso"
    ;;
esac

exit 0
