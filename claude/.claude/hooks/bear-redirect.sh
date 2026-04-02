#!/bin/bash
# PreToolUse hook: Redirect .md files to appropriate storage
# - .md files under /Users/bharat/projects/*: ALLOW (project context)
# - Superpowers docs outside projects: redirect to Obsidian vault (sacredyak/Resources/)
# - All other .md: ALLOW
# Always allows: .claude/*, CLAUDE.md, MEMORY.md

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Skip if no file path or not a .md file
if [ -z "$FILE_PATH" ] || [[ "$FILE_PATH" != *.md ]]; then
  exit 0
fi

# Allow system/config markdown files
if [[ "$FILE_PATH" == */.claude/* ]] || \
   [[ "$FILE_PATH" == */CLAUDE.md ]] || \
   [[ "$FILE_PATH" == */MEMORY.md ]]; then
  exit 0
fi

# Allow all .md writes within any project under /Users/bharat/projects/
if [[ "$FILE_PATH" == /Users/bharat/projects/* ]]; then
  exit 0
fi

# Outside projects: detect superpowers content → redirect to Obsidian vault
if [[ "$FILE_PATH" == *superpowers* ]] || \
   [[ "$FILE_PATH" == *-design.md ]] || \
   [[ "$FILE_PATH" == *-plan.md ]] || \
   [[ "$FILE_PATH" == *-spec.md ]] || \
   [[ "$FILE_PATH" == *-review.md ]] || \
   [[ "$FILE_PATH" == *-brainstorm.md ]]; then
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "No active project context. Save superpowers docs to the Obsidian vault instead: /Users/bharat/projects/sacredyak/Resources/ (use appropriate subfolder: specs/, plans/, reviews/, etc.). This is the PKM home for docs without a project."
  }
}
EOF
  exit 0
fi
