# ARCHITECT-BRIEF: Auto-Approve Hook System

## Goal
Replace the old toggle-file-based auto-mode.sh with a fresh env-var-gated auto-approve system for Claude Code.

## Decisions (already made by Merlin — do not revisit)
- Activation: `CLAUDE_AUTO_APPROVE=1` env var (session-scoped, dies with terminal)
- Entry point: `cc-auto` Fish function launches Claude Code with env var set
- Baseline: `defaultMode: "acceptEdits"` in settings.json (file edits free, Bash gated by hook)
- Hook fails CLOSED: any script error → no decision → normal prompting resumes
- Working-dir allowlist: only activate inside `~/projects`, `~/.dotfiles` (full path: `/Users/bharat/projects`, `/Users/bharat/.dotfiles`)
- Logging: JSONL to `~/.claude/logs/auto-approve.jsonl` — `{timestamp, tool, command, decision, reason, cwd}`
- `cc-audit` Fish function: `tail -f ~/.claude/logs/auto-approve.jsonl | jq .`

## Denylist (block even when CLAUDE_AUTO_APPROVE=1)
- rm -rf / or ~ or $HOME or /*
- fork bombs: `:(){ :|:&`
- raw device writes: `dd if=... of=/dev/`
- disk erasure: `mkfs`, `diskutil eraseDisk`, `diskutil erase`
- force push to main/master
- git reset --hard with uncommitted changes
- sudo rm, sudo dd, sudo touching /System /usr /etc
- credential exfil: commands piping ~/.ssh/, ~/.aws/, .env* to network tools
- remote code execution: `curl|sh`, `curl|bash`, `wget|sh`
- `chmod -R 777`, `chown -R` on system paths
- `eval`, base64-decoded execution

## Build Order
1. Delete `claude/.claude/hooks/auto-mode.sh`
2. Create `claude/.claude/hooks/auto-approve.sh` (executable)
3. Create `fish/.config/fish/functions/cc-auto.fish`
4. Create `fish/.config/fish/functions/cc-audit.fish`
5. Update `claude/.claude/settings.json`: register PreToolUse hook for Bash tool, set defaultMode to "acceptEdits", remove any auto-mode.sh references
6. Update `claude/.claude/rules/hooks.md`: remove auto-mode.sh docs, add auto-approve.sh docs
7. Search for any remaining references to auto-mode across the repo and remove them

## File Locations (dotfiles repo — stow package structure)
- Hook: `~/.dotfiles/claude/.claude/hooks/auto-approve.sh`
- Settings: `~/.dotfiles/claude/.claude/settings.json`
- Fish functions: `~/.dotfiles/fish/.config/fish/functions/cc-auto.fish`
- Fish functions: `~/.dotfiles/fish/.config/fish/functions/cc-audit.fish`
- Hooks docs: `~/.dotfiles/claude/.claude/rules/hooks.md`

## Constraints
- NEVER edit symlink targets (e.g. ~/.claude/, ~/.config/fish/) — always edit source in ~/.dotfiles/
- Hook script must be chmod +x
- settings.json must remain valid JSON
- Do NOT touch any other files in the repo

## Out of Scope
- Stowing (user will run stow manually)
- Testing the hook live
- Any other hooks or settings changes
