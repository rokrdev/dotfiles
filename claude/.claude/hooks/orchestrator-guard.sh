#!/usr/bin/env bash
# orchestrator-guard.sh — PreToolUse (Bash)
# Enforces orchestrator Iron Law: only allowlisted commands may run directly.
# Non-allowlisted commands are denied — dispatch a subagent instead.

ALLOWED="git|npm|npx|node|brew|ls|mkdir|mv|cp|stow|which|rtk|jq|uvx|obsidian|things|rm"

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null)

if [[ -z "$CMD" ]]; then
    exit 0
fi

# Split on shell chain operators and pipes; check each segment
# Use tr to normalize delimiters, then check each segment's first binary
DENIED_CMD=""
while IFS= read -r segment; do
    # Skip empty segments
    [[ -z "${segment// }" ]] && continue
    # Extract first word of this segment
    bin=$(echo "$segment" | awk '{print $1}' | xargs basename 2>/dev/null)
    [[ -z "$bin" ]] && continue
    if ! echo "$bin" | grep -qE "^($ALLOWED)$"; then
        DENIED_CMD="$bin"
        break
    fi
done < <(echo "$CMD" | tr ';|&' '\n')

if [[ -n "$DENIED_CMD" ]]; then
    jq -n \
      --arg cmd "$DENIED_CMD" \
      '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:"Orchestrator Iron Law: \($cmd) is not in the allowlist. Dispatch a subagent instead."}}'
fi

exit 0
