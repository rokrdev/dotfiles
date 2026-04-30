#!/bin/bash
# claude-notify.sh — macOS system notifications for Claude Code hook events
# Handles: Notification (waiting/needs attention), Stop (task finished)
# Exit 0 always — never blocks. Never writes to stdout.

INPUT=$(cat)
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // empty' 2>/dev/null)

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
    MSG=$(echo "$INPUT" | jq -r '.message // "Claude needs your attention"' 2>/dev/null)
    MSG="${MSG:-Claude needs your attention}"
    _notify "Claude — Waiting" "$MSG" "Tink"
    ;;
  Stop)
    _notify "Claude — Finished" "Task complete" "Glass"
    ;;
esac

exit 0
