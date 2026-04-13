#!/usr/bin/env bash
# orchestrator-guard.sh — PreToolUse (Bash)
# Enforces orchestrator Iron Law: only allowlisted commands may run directly.
# Non-allowlisted commands are denied — dispatch a subagent instead.

ALLOWED="git|npm|npx|node|brew|ls|mkdir|mv|cp|stow|which|rtk|jq|uvx|obsidian|things|rm"

_log() { mkdir -p "$HOME/.claude/logs"; echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$1] $2" >> "$HOME/.claude/logs/hooks.log"; }

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
    _log "orchestrator-guard" "denied: $DENIED_CMD"
    jq -n \
      --arg cmd "$DENIED_CMD" \
      '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:"Orchestrator Iron Law: \($cmd) is not in the allowlist. Dispatch a subagent instead."}}'
fi

# Detect dangerous git commands (destructive operations)
DANGEROUS_GIT_CMD=""
if echo "$CMD" | grep -qi "git"; then
    # git reset --hard or git reset -hard
    if echo "$CMD" | grep -qiE "git\s+reset\s+(--hard|-hard)"; then
        DANGEROUS_GIT_CMD="git reset --hard"
    # git push with --force or -f (but allow --force-with-lease)
    elif echo "$CMD" | grep -qiE "git\s+push.*(-f|--force)(?!-with-lease)"; then
        DANGEROUS_GIT_CMD="git push --force"
    # git checkout -- (discarding changes)
    elif echo "$CMD" | grep -qiE "git\s+checkout\s+--\s"; then
        DANGEROUS_GIT_CMD="git checkout --"
    # git restore (restores/discards changes)
    elif echo "$CMD" | grep -qiE "git\s+restore"; then
        DANGEROUS_GIT_CMD="git restore"
    # git clean -f or -fd or -fdx
    elif echo "$CMD" | grep -qiE "git\s+clean\s+-(f|fd|fdx)"; then
        DANGEROUS_GIT_CMD="git clean -f"
    # git branch -D (force delete)
    elif echo "$CMD" | grep -qiE "git\s+branch\s+-D"; then
        DANGEROUS_GIT_CMD="git branch -D"
    fi
fi

if [[ -n "$DANGEROUS_GIT_CMD" ]]; then
    _log "orchestrator-guard" "dangerous git blocked: $DANGEROUS_GIT_CMD"
    jq -n \
      --arg pattern "$DANGEROUS_GIT_CMD" \
      '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:"Dangerous git command blocked: \($pattern). Use explicit git flags only if the user explicitly requested this destructive operation."}}'
fi

exit 0
