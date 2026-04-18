#!/usr/bin/env bash
# auto-approve.sh — env-var gated PreToolUse hook with denylist
# Activated only when CLAUDE_AUTO_APPROVE=1 and cwd is under an allowlisted path.
# Fails CLOSED: any error → exit 0 (no decision, normal prompting resumes).

set -euo pipefail

# Create log dir first (before any logic)
mkdir -p "$HOME/.claude/logs"
LOG_FILE="$HOME/.claude/logs/auto-approve.jsonl"

# Fail closed on any error
trap 'exit 0' ERR

# Read full stdin into a variable — fail closed if empty
INPUT="$(cat)"
if [[ -z "$INPUT" ]]; then
  exit 0
fi

# Gate: env var must be set to 1
if [[ "${CLAUDE_AUTO_APPROVE:-}" != "1" ]]; then
  exit 0
fi

# Extract fields — fail closed on any jq error
TOOL_NAME="$(echo "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null)" || exit 0
CWD="$(echo "$INPUT" | jq -r '.cwd // ""' 2>/dev/null)" || exit 0
COMMAND="$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null)" || exit 0

# Require non-empty cwd — fail closed
if [[ -z "$CWD" ]]; then
  exit 0
fi

# Working-dir allowlist: only /Users/bharat/projects or /Users/bharat/.dotfiles
case "$CWD" in
  /Users/bharat/projects*|/Users/bharat/.dotfiles*)
    ;;
  *)
    exit 0
    ;;
esac

# ── Denylist ────────────────────────────────────────────────────────────────

deny() {
  local REASON="$1"
  TIMESTAMP="$(date -u +%FT%TZ)"
  # Truncate command to 200 chars for log
  CMD_TRUNC="${COMMAND:0:200}"
  CMD_JSON="$(printf '%s' "$CMD_TRUNC" | jq -Rs '.')"
  printf '{"timestamp":"%s","tool":"%s","command":%s,"decision":"block","reason":"%s","cwd":"%s"}\n' \
    "$TIMESTAMP" "$TOOL_NAME" "$CMD_JSON" "$REASON" "$CWD" >> "$LOG_FILE"
  printf '{"decision":"block","reason":"%s"}' "$REASON"
  exit 0
}

# If no command (non-Bash tool), allow immediately
if [[ -z "$COMMAND" ]]; then
  TIMESTAMP="$(date -u +%FT%TZ)"
  printf '{"timestamp":"%s","tool":"%s","command":null,"decision":"allow","reason":null,"cwd":"%s"}\n' \
    "$TIMESTAMP" "$TOOL_NAME" "$CWD" >> "$LOG_FILE"
  printf '{"decision":"allow"}'
  exit 0
fi

# rm -rf targeting / ~ $HOME or /*
if echo "$COMMAND" | grep -qiE 'rm\s+-rf\s+(/|~|\$HOME|/\*)' 2>/dev/null; then
  deny "rm-rf-root"
fi

# Fork bomb: :(){
if echo "$COMMAND" | grep -qiE ':\(\)\s*\{' 2>/dev/null; then
  deny "fork-bomb"
fi

# Raw device writes: dd ... of=/dev/
if echo "$COMMAND" | grep -qiE 'dd\s+.*of=/dev/' 2>/dev/null; then
  deny "raw-device-write"
fi

# Disk erasure
if echo "$COMMAND" | grep -qiE 'mkfs|diskutil\s+erase' 2>/dev/null; then
  deny "disk-erasure"
fi

# Force push to main/master
if echo "$COMMAND" | grep -qiE 'git\s+push\s+.*--force.*\s+(main|master)' 2>/dev/null; then
  deny "force-push-main"
fi

# git reset --hard
if echo "$COMMAND" | grep -qiE 'git\s+reset\s+--hard' 2>/dev/null; then
  deny "git-reset-hard"
fi

# sudo rm, sudo dd
if echo "$COMMAND" | grep -qiE 'sudo\s+(rm|dd)\b' 2>/dev/null; then
  deny "sudo-destructive"
fi

# sudo touching /System /usr /etc
if echo "$COMMAND" | grep -qiE 'sudo\s+.*(/System|/usr|/etc)' 2>/dev/null; then
  deny "sudo-system-path"
fi

# curl/wget piped to sh/bash
if echo "$COMMAND" | grep -qiE 'curl\s+.*\|\s*(sh|bash)|wget\s+.*\|\s*(sh|bash)' 2>/dev/null; then
  deny "remote-code-execution"
fi

# chmod -R 777
if echo "$COMMAND" | grep -qiE 'chmod\s+-R\s+777' 2>/dev/null; then
  deny "chmod-777"
fi

# chown -R on system paths
if echo "$COMMAND" | grep -qiE 'chown\s+-R\s+.*(\/System|\/usr|\/etc)' 2>/dev/null; then
  deny "chown-system-path"
fi

# eval
if echo "$COMMAND" | grep -qiE 'eval\s+' 2>/dev/null; then
  deny "eval-execution"
fi

# base64 decoded execution
if echo "$COMMAND" | grep -qiE 'base64\s+.*\|\s*(sh|bash)' 2>/dev/null; then
  deny "base64-decoded-execution"
fi

# Credential exfil: piping .ssh/ .aws/ .env to curl/wget/nc
if echo "$COMMAND" | grep -qiE '(\.ssh/|\.aws/|\.env).*\|\s*(curl|wget|nc)' 2>/dev/null; then
  deny "credential-exfil"
fi

# ── Allow ────────────────────────────────────────────────────────────────────

TIMESTAMP="$(date -u +%FT%TZ)"
CMD_TRUNC="${COMMAND:0:200}"
CMD_JSON="$(printf '%s' "$CMD_TRUNC" | jq -Rs '.')"
printf '{"timestamp":"%s","tool":"%s","command":%s,"decision":"allow","reason":null,"cwd":"%s"}\n' \
  "$TIMESTAMP" "$TOOL_NAME" "$CMD_JSON" "$CWD" >> "$LOG_FILE"

printf '{"decision":"allow"}'
exit 0
