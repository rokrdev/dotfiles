#!/usr/bin/env bash
# orchestrator-guard.sh — PreToolUse (Bash)
# Enforces orchestrator Iron Law: only allowlisted commands may run directly.
# Non-allowlisted commands are denied — dispatch a subagent instead.

ALLOWED="git|npm|npx|node|brew|ls|mkdir|mv|cp|stow|which|rtk|jq|uvx|obsidian|things|rm"

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null)
BINARY=$(echo "$CMD" | awk '{print $1}' | xargs basename 2>/dev/null)

if [[ -z "$BINARY" ]]; then
    exit 0
fi

if echo "$BINARY" | grep -qE "^($ALLOWED)$"; then
    exit 0
fi

jq -n \
  --arg cmd "$BINARY" \
  '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:"Orchestrator Iron Law: \($cmd) is not in the allowlist. Dispatch a subagent instead."}}'
