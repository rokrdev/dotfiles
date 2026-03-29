#!/bin/bash
# PreToolUse hook: Block writing .md files and redirect to Bear
# Allows: .claude/*, CLAUDE.md, MEMORY.md

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

# Detect superpowers content for specific tagging guidance
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
    "permissionDecisionReason": "Do NOT write superpowers docs to disk. Use the store-in-bear skill to save to Bear instead. Use the appropriate superpowers tag: #3resource/superpowers/spec for design specs, #3resource/superpowers/plan for implementation plans, #3resource/superpowers/brainstorm for brainstorms, #3resource/superpowers/review for code reviews. Always pair with a project tag."
  }
}
EOF
  exit 0
fi

# Block all other .md writes and redirect to Bear
cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Do NOT write markdown files to disk. Use the store-in-bear skill to save this content to Bear instead. Bear is the default storage for all notes and documents."
  }
}
EOF
