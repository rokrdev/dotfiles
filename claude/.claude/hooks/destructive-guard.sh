#!/bin/bash
# PreToolUse hook: Block or confirm destructive Bash operations
# Guards:
# - Obsidian deletions: require explicit confirmation via timestamp flag file (30s window)
# - SQL destructive statements: DROP TABLE, TRUNCATE TABLE, DELETE FROM <table>
# - Destructive filesystem/git ops: rm -rf /, rm -rf ~, git push --force to main/master

mkdir -p "$HOME/.claude/logs" || true
exec 2>>"$HOME/.claude/logs/hooks.log"

block() {
  echo "$1"
  echo "[destructive-guard] $1" >&2
  exit 2
}

if ! command -v jq &>/dev/null; then
  echo "WARNING: destructive-guard hook dependency missing (jq not found) — guard inactive, all operations allowed" >&2
  echo "WARNING: Install jq to enable destructive operation protection."
  echo "{}"
  exit 0
fi

raw=$(cat 2>/dev/null)
cmd=$(echo "$raw" | jq -r '.tool_input.command // ""' 2>/dev/null)

if [ -z "$cmd" ]; then
  echo "[destructive-guard] WARNING: could not extract command from hook input" >&2
  echo "{}"
  exit 0
fi

# --- Obsidian delete guard ---
if echo "$cmd" | grep -qE "^obsidian\b" && echo "$cmd" | grep -qiE "delete|trash|remove|destroy|purge|wipe"; then
  flag="$HOME/.claude/obsidian-delete-confirmed"
  if [ -f "$flag" ]; then
    confirmed_at=$(cat "$flag" 2>/dev/null)
    now=$(date +%s)
    rm -f "$flag"
    if [[ "$confirmed_at" =~ ^[0-9]+$ ]] && [ "$((now - confirmed_at))" -le 30 ]; then
      echo "{}"
      exit 0
    fi
    block "BLOCKED: Obsidian deletion confirmation expired (>30s). Run: echo \$(date +%s) > ~/.claude/obsidian-delete-confirmed — then retry immediately."
  fi
  block "BLOCKED: Obsidian deletion requires explicit user permission. Run: echo \$(date +%s) > ~/.claude/obsidian-delete-confirmed — then retry within 30 seconds."
fi

# --- Destructive operation guard ---
patterns="DROP TABLE|TRUNCATE TABLE|DELETE FROM [a-zA-Z]+|git push.*--force.*main|git push.*--force.*master|rm -rf /|rm -rf ~|rm -fr /|rm -fr ~|rm -rf \$HOME|rm -fr \$HOME"
if echo "$cmd" | grep -qiE "$patterns"; then
  matched=$(echo "$cmd" | grep -oiE "$patterns" | head -1)
  block "BLOCKED: Destructive operation detected: '$matched'. Confirm this is intentional."
fi

# --- git push --force-with-lease to main/master guard ---
if echo "$cmd" | grep -qE "git push" && echo "$cmd" | grep -qiE "\-\-force-with-lease" && echo "$cmd" | grep -qE "(main|master)"; then
  block "BLOCKED: 'git push --force-with-lease' to main/master detected. Force-with-lease still rewrites remote history. Confirm this is intentional and you are not discarding others' work."
fi

echo "{}"
exit 0
