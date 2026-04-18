#!/bin/bash
# pre-commit-reminder.sh — PreToolUse hook for git commit
# Reminds user to invoke the pre-commit skill before committing

input=$(cat)

# Extract the command from stdin JSON at .tool_input.command
command=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Check if this is a git commit command
if [[ "$command" == *"git commit"* ]]; then
    echo "⚠️  Remember to invoke the pre-commit skill before committing." >&2
    exit 2
fi

exit 0
