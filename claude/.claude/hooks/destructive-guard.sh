#!/bin/bash
# PreToolUse hook: Block or confirm destructive Bash operations
# Guards:
# - Obsidian deletions: require explicit confirmation via timestamp flag file (30s window)
# - SQL destructive statements: DROP TABLE, TRUNCATE TABLE, DELETE FROM <table>
# - Destructive filesystem/git ops: rm -rf /, rm -rf ~, git push --force to main/master

mkdir -p "$HOME/.claude/logs" 2>/dev/null || true
LOG="$HOME/.claude/logs/hooks.log"

block() {
  echo "$1" >&2
  echo "[destructive-guard] BLOCKED: $1" >> "$LOG"
  exit 2
}

if ! command -v jq &>/dev/null; then
  block "BLOCKED: destructive-guard dependency missing (jq not found). Install jq to restore Bash access."
fi

raw=$(cat 2>/dev/null)
cmd=$(echo "$raw" | jq -r '.tool_input.command // ""' 2>/dev/null)
if [ $? -ne 0 ] || [ -z "$cmd" ]; then
  block "BLOCKED: destructive-guard could not parse hook input — failing safe."
fi

# --- Obsidian delete guard ---
if echo "$cmd" | grep -qE "^obsidian\b" && echo "$cmd" | grep -qiE "delete|trash|remove|destroy|purge|wipe"; then
  flag="$HOME/.claude/obsidian-delete-confirmed"
  if [ -f "$flag" ]; then
    confirmed_at=$(cat "$flag" 2>/dev/null)
    now=$(date +%s)
    rm -f "$flag"
    if [[ "$confirmed_at" =~ ^[0-9]+$ ]] && [ "$((now - confirmed_at))" -le 30 ]; then
      jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"allow",permissionDecisionReason:"destructive-guard: Obsidian deletion confirmed"}}'
      exit 0
    fi
    block "BLOCKED: Obsidian deletion confirmation expired (>30s). Run: echo \$(date +%s) > ~/.claude/obsidian-delete-confirmed — then retry immediately."
  fi
  block "BLOCKED: Obsidian deletion requires explicit user permission. Run: echo \$(date +%s) > ~/.claude/obsidian-delete-confirmed — then retry within 30 seconds."
fi

# --- Destructive operation guard ---
patterns="DROP TABLE|TRUNCATE TABLE|DELETE FROM [a-zA-Z]+|git push.*--force.*main|git push.*--force.*master|git push.*-f\s+.*main|git push.*-f\s+.*master|rm -rf|rm -fr"
if echo "$cmd" | timeout 1 grep -qiE "$patterns"; then
  matched=$(echo "$cmd" | timeout 1 grep -oiE "$patterns" | head -1)
  block "BLOCKED: Destructive operation detected: '$matched'. Confirm this is intentional."
fi

# --- git push --force-with-lease to main/master guard ---
if echo "$cmd" | grep -qE "git push" && echo "$cmd" | grep -qiE "\-\-force-with-lease" && echo "$cmd" | grep -qE "(main|master)"; then
  block "BLOCKED: 'git push --force-with-lease' to main/master detected. Force-with-lease still rewrites remote history. Confirm this is intentional and you are not discarding others' work."
fi

jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"allow",permissionDecisionReason:"destructive-guard: no destructive patterns detected"}}'
exit 0
