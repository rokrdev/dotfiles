#!/bin/bash
# done-exit.sh — Stop hook for /done command
# Reads transcript, checks for __DONE_EXIT__, SIGTERMs the Claude CLI process.
# Always exits 0 — never blocks the session.

# Read stdin JSON
input="$(cat)"

# Extract transcript path
transcript_path="$(echo "$input" | jq -r '.transcript_path // empty' 2>/dev/null)"

# Bail if no transcript path or file doesn't exist
[ -z "$transcript_path" ] && exit 0
[ -f "$transcript_path" ] || exit 0

# Fast path: bail immediately if sentinel not in last 5000 bytes (skips jq on every normal turn)
# 500 bytes was too small when last message contains tool_use with large payloads
tail -c 5000 "$transcript_path" | grep -qF '__DONE_EXIT__' || exit 0

# Extract text from the last assistant message (last 50 lines of JSONL for efficiency)
last_assistant_text="$(tail -n 50 "$transcript_path" \
  | jq -r 'select(.type == "assistant") | .message.content[]? | select(.type == "text") | .text' 2>/dev/null \
  | tail -c 4096 || true)"

# Bail gracefully if jq failed or produced nothing
[ -z "$last_assistant_text" ] && exit 0

# Check for sentinel
if echo "$last_assistant_text" | grep -qF '__DONE_EXIT__'; then
  echo "[/done] memory saved — exiting" >&2

  # Walk PPID chain (up to 8 levels) looking for the claude process
  pid=$PPID
  for _ in $(seq 1 8); do
    [ -z "$pid" ] || [ "$pid" = "1" ] && break
    cmd="$(ps -o command= -p "$pid" 2>/dev/null || echo '')"
    if echo "$cmd" | grep -qE '(^|[/ ])claude( |$)'; then
      kill -TERM "$pid" 2>/dev/null || true
      break
    fi
    pid="$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ' || echo '')"
  done
fi

exit 0
