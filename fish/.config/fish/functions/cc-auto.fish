function cc-auto --description "Launch Claude Code with auto-approval enabled"
    set -x CLAUDE_AUTO_APPROVE 1
    echo "[AUTO MODE] Claude Code starting in $(pwd)..."
    claude $argv
end
