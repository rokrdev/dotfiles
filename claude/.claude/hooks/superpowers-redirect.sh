#!/bin/bash
# Logging: stderr goes to ~/.claude/logs/hooks.log
mkdir -p "$HOME/.claude/logs" || true
exec 2>>"$HOME/.claude/logs/hooks.log"

# PreToolUse hook: Redirect .md files to appropriate storage
# Handles both Write and Edit tool events — both pass file_path in .tool_input.file_path
# - .md files under $HOME/projects/*: ALLOW (project context)
# - Superpowers docs outside projects: redirect to Obsidian vault (use obsidian skill to route correctly)
# - All other .md: ALLOW
# Always allows: .claude/*, CLAUDE.md, MEMORY.md

if ! command -v jq &>/dev/null; then
  echo "WARNING: superpowers-redirect hook dependency missing (jq not found) — redirect inactive" >&2
  echo "{}"
  exit 0
fi

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Skip if no file path or not a .md file
if [ -z "$FILE_PATH" ] || [[ "$FILE_PATH" != *.md ]]; then
  echo "{}"
  exit 0
fi

# Allow system/config markdown files
if [[ "$FILE_PATH" == */.claude/* ]] || \
   [[ "$FILE_PATH" == */CLAUDE.md ]] || \
   [[ "$FILE_PATH" == */MEMORY.md ]]; then
  echo "{}"
  exit 0
fi

# Allow all .md writes within any project under $HOME/projects/
if [[ "$FILE_PATH" == "$HOME/projects/"* ]]; then
  echo "{}"
  exit 0
fi

# Outside projects: detect superpowers content → redirect to Obsidian vault
if [[ "$FILE_PATH" == *superpowers* ]] || \
   [[ "$FILE_PATH" == *-design.md ]] || \
   [[ "$FILE_PATH" == *-plan.md ]] || \
   [[ "$FILE_PATH" == *-spec.md ]] || \
   [[ "$FILE_PATH" == *-review.md ]] || \
   [[ "$FILE_PATH" == *-brainstorm.md ]]; then
  echo "[superpowers-redirect] $(date -u +%FT%TZ) denied write to: $FILE_PATH" >&2
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "No active project context. Save superpowers docs to the Obsidian vault instead: ${HOME}/Library/Mobile Documents/iCloud~md~obsidian/Documents/Sacredyak/ (use the obsidian skill to pick the right subfolder). When working inside a project, save to the project's docs/ folder instead."
  }
}
EOF
  exit 0
fi

echo "{}"
exit 0
