# ARCHITECT-BRIEF: PR #11 Fix Pass

## Goal
Fix all critical and important issues found in the PR review of `memory-setup-test`. Changes split into two independent workstreams: shell scripts and documentation/config.

## Key Decisions
- **Branch naming (C3)**: `worktree-create.sh` should use `-b "worktree-$NAME"` — this matches `neo.md` docs and `cleanup-worktrees.sh` regex. Do NOT change the cleanup regex; fix the script.
- **testing.md content**: Recover deleted content with `git show main:claude/.claude/rules/testing.md` and merge key sections (TDD steps, test file location, naming conventions, arrange/act/assert) into `claude/.claude/rules/coding.md`. Do not recreate `testing.md`.
- **permission-review.sh model**: Update `rules/hooks.md` to say "Sonnet 4.6 (configurable via `CLAUDE_PERMISSION_REVIEW_MODEL`)" — do NOT change the script default.
- **cp failure in worktree-create.sh**: Treat as WARNING not fatal — `.env` copy failure should log and continue, not abort.

## Out of Scope
- Zed configs, fish configs, ghostty, hammerspoon, or any non-Claude files (except root `CLAUDE.md` for the zed stow entry)
- `install.sh` — suggestions only; skip
- `claude-notify.sh` — suggestion only; skip
- `permission-review.sh` DENY rules, ERR trap architecture, or API call logic — only add stderr output to trap
- Creating new skills or agents

## Workstream 1: Shell Script Fixes

### `claude/.claude/hooks/worktree-create.sh`

**C1 — git worktree add pipe swallows exit code (line ~63)**
Replace:
```bash
git -C "$REPO_ROOT" worktree add "$WORKTREE_DIR" -b "$NAME" "$DEFAULT_BRANCH" 2>&1 | while IFS= read -r line; do
  echo "$LOG_PREFIX git: $line" >&2
done
```
With:
```bash
GIT_OUT=$(git -C "$REPO_ROOT" worktree add "$WORKTREE_DIR" -b "worktree-$NAME" "$DEFAULT_BRANCH" 2>&1) || {
  echo "$LOG_PREFIX ERROR: git worktree add failed: $GIT_OUT" >&2
  exit 1
}
echo "$GIT_OUT" | while IFS= read -r line; do echo "$LOG_PREFIX git: $line" >&2; done
```
Note: also fixes C3 — adds `worktree-` prefix to branch name.

**C2 — jq returns literal "null" on missing field (lines ~12-13)**
Replace:
```bash
NAME=$(echo "$INPUT" | jq -r '.name')
CWD=$(echo "$INPUT" | jq -r '.cwd')
```
With:
```bash
NAME=$(echo "$INPUT" | jq -r '.name // empty')
CWD=$(echo "$INPUT"  | jq -r '.cwd  // empty')
if [[ -z "$NAME" || -z "$CWD" ]]; then
  echo "$LOG_PREFIX ERROR: missing required fields name/cwd in input" >&2
  exit 1
fi
```

**I5 — cp failure aborts with no log (line ~72)**
Replace:
```bash
cp "$ENV_FILE" "$DEST"
echo "$LOG_PREFIX copied $BASENAME → $DEST" >&2
```
With:
```bash
if cp "$ENV_FILE" "$DEST"; then
  echo "$LOG_PREFIX copied $BASENAME → $DEST" >&2
else
  echo "$LOG_PREFIX WARNING: failed to copy $BASENAME to $DEST (continuing)" >&2
fi
```

**Suggestion — default branch uses network call**
In the default branch detection section, try `git -C "$REPO_ROOT" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'` FIRST (local, no network). Fall back to `git remote show origin` only if that returns empty. Add a log entry when network fallback fires.

### `claude/.claude/hooks/cleanup-worktrees.sh`

**I2 — no set -e/pipefail/u at top**
The script intentionally continues on errors in the main loop (uses `|| true`). Instead of adding `set -e` globally, add explicit error handling for the bootstrap section: if `mkdir -p "$HOME/.claude/logs"` fails, print warning to stderr and disable logging gracefully.

**I3 — silent fallback to "main" (lines ~17-18)**
After the fallback fires, add a `_log` call:
```bash
if [ -z "$TRUNK" ]; then
  _log "cleanup-worktrees" "WARNING: origin/HEAD not set, defaulting TRUNK to main"
  TRUNK="main"
fi
```

### `claude/.claude/hooks/rtk-rewrite.sh`

**I4 — rtk stderr unconditionally suppressed (line ~47)**
Change:
```bash
REWRITTEN=$(rtk rewrite "$CMD" 2>/dev/null)
```
To:
```bash
RTK_STDERR=$(mktemp)
REWRITTEN=$(rtk rewrite "$CMD" 2>"$RTK_STDERR")
RTK_EXIT=$?
```
Then in the `*` wildcard case at the end, before `exit 0`, log the stderr:
```bash
*)
  RTK_ERR=$(cat "$RTK_STDERR" 2>/dev/null)
  [[ -n "$RTK_ERR" ]] && echo "[rtk] WARNING: unexpected exit $RTK_EXIT: $RTK_ERR" >&2
  rm -f "$RTK_STDERR"
  exit 0
  ;;
```
Add `rm -f "$RTK_STDERR"` to other case exits too.

### `claude/.claude/hooks/permission-review.sh`

**I1 — ERR trap no stderr feedback (lines ~28-37)**
In the `_permission_err_trap` function, add a stderr line before `echo '{}'`:
```bash
echo "[permission-review] WARNING: review bypassed — script error at line $lno ($cmd), falling through to user dialog" >&2
```

## Workstream 2: Documentation + Config Fixes

### `claude/.claude/agents/neo.md`

**C4 — stale defaultMode claim**
Find: `"generic agents inherit \`defaultMode: "plan"\` from settings.json"`  
Replace with: `"generic agents inherit \`defaultMode: "acceptEdits"\` from settings.json and will pause for confirmation on every edit"`

**I9 — .env claim contradicts hook**
Find the sentence about gitignored files not being copied.
Replace with: "`.env*` files are copied automatically by the configured `WorktreeCreate` hook (`worktree-create.sh`)."

**I10 — short model IDs**
Find all `model: "haiku"` references in dispatch instructions → change to `model: "claude-haiku-4-5-20251001"`
Find all `model: "sonnet"` references → change to `model: "claude-sonnet-4-6"`
(Do NOT change the routing table display text or headings — only the inline code/dispatch instructions)

**C3 — branch naming doc**
Find where branches are documented as `worktree-<name>` — verify it already says this. If it says just `<name>`, update to `worktree-<name>`.

### `claude/.claude/agents/merlin.md`

**I11 — Jasper missing from caller list**
Find: `"You are consulted by language expert agents (Swifty, Conan, Snape)"`
Replace: `"You are consulted by language expert agents (Swifty, Conan, Snape, Jasper)"`

### `claude/.claude/rules/hooks.md`

**C6 — wrong model for permission-review**
Find: `"Claude Opus 4.5 (effort: medium)"`
Replace: `"claude-sonnet-4-6 (configurable via CLAUDE_PERMISSION_REVIEW_MODEL env var; effort: medium)"`

**I6 — claude-notify.sh missing**
Add a new section under `## PermissionRequest`:
```markdown
## Notification / StopFailure

1. **claude-notify.sh** — sends macOS system notifications via `osascript`. Fires on both `Notification` (informational alerts) and `StopFailure` (session stop failures) events. Always exits 0, never writes to stdout.
```

**I7 — autoUpdate: false claim**
Remove the sentence: "The plugins (context-mode, caveman) are configured with `autoUpdate: false` in `settings.json`, so their hook paths are stable — manual updates required via `ctx upgrade` or equivalent."
Replace with: "Plugin hook paths may change on plugin update. Run `ctx upgrade` for context-mode updates."

**I13 — SessionStart incomplete**
Update the `## SessionStart` section to note that additional hooks run (RTK check, context restore, log rotation, context-mode plugin hook) alongside `cleanup-worktrees.sh`. List all of them or note they're inline/plugin-provided.
Check `settings.json` `hooks.SessionStart` array to get the actual list.

### `claude/.claude/rules/coding.md`

**C5 — testing.md content lost**
Run `git show main:claude/.claude/rules/testing.md` to get the deleted content.
Extract and append to `coding.md`:
- TDD workflow steps (the ordered process)
- Test file location convention (`test/` directory, not `src/`)
- Test naming conventions
- Arrange/Act/Assert structure
Keep the "When to Skip TDD" section that's already in `coding.md`. Don't duplicate it.

### `claude/.claude/rules/skills.md`

**I14 — compound skill missing**
Add a row to the Custom Skills table:
```
| **compound** | After code review with learnings | Extract lessons from code review and write as permanent rules into CLAUDE.md |
```

### `claude/.claude/rules/skills-plugins.md`

**I8 — 3 plugins missing**
Add entries for:
- `swift-lsp@claude-plugins-official` — LSP-backed Swift language intelligence
- `code-simplifier@claude-plugins-official` — simplifies code for clarity and maintainability
- `security-guidance@claude-plugins-official` — security review guidance and best practices

Check `settings.json` `enabledPlugins` for the exact plugin names/versions.

### `claude/.claude/rules/memory.md`

**Suggestion — AskUserQuestion doesn't exist**
Find: `"use AskUserQuestion to confirm"`
Replace: `"ask the user directly before removing or modifying any existing memory entry"`

### `claude/.claude/settings.json`

**I15 — allowlist missing mv, rm, uvx**
In `permissions.allow`, add entries for:
- `Bash(mv:*)` 
- `Bash(rm:*)`
- `Bash(uvx:*)`
Check the existing allow format and match it exactly.

### `/Users/bharat/.dotfiles/CLAUDE.md` (root)

**I12 — zed missing from stow table**
Add row to the stow packages table:
```
| `zed` | Zed editor — `~/.config/zed/` (keymap, settings, tasks) |
```
Insert alphabetically or at the end of the list.

## Done Criteria
- All 6 critical issues resolved
- All 15 important issues resolved  
- Shell scripts tested for syntax: `bash -n <script>` passes
- No new files created (except this brief)
- Commit all changes with message: `fix(claude): address PR review — error handling, doc accuracy, config consistency`
