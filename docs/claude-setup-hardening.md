# Claude Code Setup Hardening Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Harden the Claude Code dotfiles setup against security bypasses, enforcement gaps, and documentation drift.

**Architecture:** Shell script patches for hooks, settings.json reordering, CLAUDE.md refactor into focused rule files.

**Tech Stack:** Bash, JSON (settings.json), Markdown

---

## Task 1: Harden auto-mode toggle with 30-second confirmation window

**Priority:** P0 — Security  
**Files:**
- Modify: `$HOME/.dotfiles/claude/.claude/hooks/auto-mode.sh`

**Problem:** `touch ~/.claude/.auto-mode` grants full tool permissions without confirmation. Any process with `~/.claude/` write access can enable it.

**Solution:** Add a 30-second confirmation window. First invocation creates a pending file with timestamp. Second invocation within 30s confirms and enables auto-mode. All toggles logged to `~/.claude/logs/auto-mode.log`.

### Implementation

- [ ] **Step 1:** Replace `$HOME/.dotfiles/claude/.claude/hooks/auto-mode.sh` — add `PENDING`, `LOGFILE` tracking, timestamp validation, confirmation logic
- [ ] **Step 2:** Test: `echo "$(($(date +%s)))" > ~/.claude/.auto-mode-pending && bash ~/.dotfiles/claude/.claude/hooks/auto-mode.sh && [ -f ~/.claude/.auto-mode ] && echo OK`
- [ ] **Step 3:** Commit: `git -C $HOME/.dotfiles add claude/.claude/hooks/auto-mode.sh && git -C $HOME/.dotfiles commit -m "security(auto-mode): add 30s confirmation window and logging"`

---

## Task 2: Fix destructive-guard regex bypasses for rm -rf

**Priority:** P0 — Security  
**Files:**
- Modify: `$HOME/.dotfiles/claude/.claude/hooks/destructive-guard.sh`

**Problem:** Current pattern catches `rm -rf ~` but not `rm -rf ${HOME}`, `rm -rf $(echo ~)`, `rm -rf ~+`, `rm -rf .` from root.

**Solution:** Replace lines 48–53 with broader check: `grep -qE "rm\s+-[a-z]*f.*\s+(/|\.|\~|~\+|\$HOME|\$\{HOME\}|\$\(|~)"`

### Implementation

- [ ] **Step 1:** Update destructive operation guard to split SQL/git patterns from rm patterns
- [ ] **Step 2:** Test: `echo "rm -rf ${HOME}" | grep -qE "rm\s+-[a-z]*f.*\s+(/|\.|\~|~\+|\$HOME|\$\{HOME\}|\$\(|~)" && echo "✓ BLOCKS"`
- [ ] **Step 3:** Commit: `git -C $HOME/.dotfiles add claude/.claude/hooks/destructive-guard.sh && git -C $HOME/.dotfiles commit -m "security(destructive-guard): block rm -rf variable bypasses"`

---

## Task 3: Create orchestrator-guard.sh hook and update settings.json

**Priority:** P1 — Enforcement  
**Files:**
- Create: `$HOME/.dotfiles/claude/.claude/hooks/orchestrator-guard.sh`
- Modify: `$HOME/.dotfiles/claude/.claude/settings.json`

**Problem:** Orchestrator guard in settings.json only warns (exit 0). Neo ignores advisory messages.

**Solution:** Extract to standalone script that denies (permissionDecision: deny) when non-allowlisted commands detected.

### Implementation

- [ ] **Step 1:** Create orchestrator-guard.sh — extract first word, check allowlist (git|npm|npx|node|brew|ls|mkdir|mv|cp|stow|which|rtk|jq|uvx|obsidian|things|rm), return deny JSON if not in list
- [ ] **Step 2:** Update settings.json PreToolUse: replace inline echo with `bash "$HOME/.claude/hooks/orchestrator-guard.sh"`
- [ ] **Step 3:** Verify hook order: auto-mode → destructive-guard → orchestrator-guard → rtk-rewrite → superpowers-redirect
- [ ] **Step 4:** Commit: `git -C $HOME/.dotfiles add claude/.claude/hooks/orchestrator-guard.sh claude/.claude/settings.json && git -C $HOME/.dotfiles commit -m "refactor(orchestrator-guard): extract to blocking script"`

---

## Task 4: Sync CLAUDE.md Bash allowlist with settings.json

**Priority:** P1 — Documentation  
**Files:**
- Modify: `$HOME/.dotfiles/claude/.claude/CLAUDE.md`

**Problem:** CLAUDE.md docs "git/mkdir/rm/mv/ls/npm/pip" but settings.json allows all 16 commands.

**Solution:** Replace old list with: git, npm, npx, node, brew, ls, mkdir, mv, cp, stow, which, rtk, jq, uvx, obsidian, things, rm

### Implementation

- [ ] **Step 1:** Find section "Bash is ONLY for" and update with complete allowlist
- [ ] **Step 2:** Verify: `grep "allowlisted commands:" $HOME/.dotfiles/claude/.claude/CLAUDE.md`
- [ ] **Step 3:** Commit: `git -C $HOME/.dotfiles add claude/.claude/CLAUDE.md && git -C $HOME/.dotfiles commit -m "docs(CLAUDE.md): sync Bash allowlist with settings.json"`

---

## Task 5: Extract context-mode rules to separate file

**Priority:** P1 — Documentation  
**Files:**
- Create: `$HOME/.dotfiles/claude/.claude/rules/context-mode.md`
- Modify: `$HOME/.dotfiles/claude/.claude/CLAUDE.md`

**Problem:** CLAUDE.md too long (~2.5 KB context-mode section). Critical guidance diluted.

**Solution:** Move entire "context-mode — MANDATORY routing rules" section to separate file, replace with brief reference.

### Implementation

- [ ] **Step 1:** Create `$HOME/.dotfiles/claude/.claude/rules/` dir: `mkdir -p $HOME/.dotfiles/claude/.claude/rules`
- [ ] **Step 2:** Copy context-mode section from CLAUDE.md to new rules/context-mode.md (full BLOCKED commands, REDIRECTED tools, tool hierarchy, subagent routing, output constraints, ctx commands)
- [ ] **Step 3:** Replace that section in CLAUDE.md with brief pointer and TL;DR
- [ ] **Step 4:** Commit: `git -C $HOME/.dotfiles add claude/.claude/rules/context-mode.md claude/.claude/CLAUDE.md && git -C $HOME/.dotfiles commit -m "refactor(rules): extract context-mode routing to separate file"`

---

## Task 6: Fix hook execution order in settings.json

**Priority:** P2 — Correctness  
**Files:**
- Modify: `$HOME/.dotfiles/claude/.claude/settings.json`

**Problem:** rtk-rewrite runs before superpowers-redirect. RTK could rewrite paths before redirect check.

**Solution:** Reorder PreToolUse hooks: superpowers-redirect (Write matcher) should come before rtk-rewrite (Bash matcher).

### Implementation

- [ ] **Step 1:** Locate PreToolUse hooks, find superpowers-redirect block (matcher: Write) and rtk-rewrite block (matcher: Bash)
- [ ] **Step 2:** Move superpowers-redirect earlier in array
- [ ] **Step 3:** Verify: `jq '.hooks.PreToolUse[] | select(.hooks[0].command | contains("superpowers") or contains("rtk")) | .hooks[0].command' $HOME/.dotfiles/claude/.claude/settings.json`
- [ ] **Step 4:** Commit: `git -C $HOME/.dotfiles add claude/.claude/settings.json && git -C $HOME/.dotfiles commit -m "fix(settings): reorder PreToolUse hooks for correct precedence"`

---

## Task 7: Make RTK failure noisy

**Priority:** P2 — Observability  
**Files:**
- Modify: `$HOME/.dotfiles/claude/.claude/hooks/rtk-rewrite.sh`

**Problem:** RTK missing/version fail → silent exit 0. Users don't know token savings disabled.

**Solution:** Add logging to hooks.log for all RTK failures (jq missing, rtk missing, version too old).

### Implementation

- [ ] **Step 1:** Add `LOGDIR="$HOME/.claude/logs" LOGFILE="$LOGDIR/hooks.log" mkdir` at top
- [ ] **Step 2:** Before each `exit 0`, add: `echo "[$(date '+%Y-%m-%d %H:%M:%S')] [rtk-rewrite] MESSAGE" >> "$LOGFILE"`
- [ ] **Step 3:** Verify logging code present: `grep -q "LOGDIR\|LOGFILE" $HOME/.dotfiles/claude/.claude/hooks/rtk-rewrite.sh && echo OK`
- [ ] **Step 4:** Commit: `git -C $HOME/.dotfiles add claude/.claude/hooks/rtk-rewrite.sh && git -C $HOME/.dotfiles commit -m "observability(rtk-rewrite): log RTK failures to hooks.log"`

---

## Task 8: Mark pre-commit skill as manual

**Priority:** P2 — Documentation  
**Files:**
- Modify: `$HOME/.dotfiles/claude/.claude/skills/pre-commit/SKILL.md`

**Problem:** No trigger. Users forget to invoke before committing.

**Solution:** Add "⚠️ MANUAL SKILL" header, example invocation phrases ("run pre-commit", "pre-commit check", etc.).

### Implementation

- [ ] **Step 1:** Replace opening section with MANUAL warning and invocation examples
- [ ] **Step 2:** Verify: `head -15 $HOME/.dotfiles/claude/.claude/skills/pre-commit/SKILL.md | grep -i manual && echo OK`
- [ ] **Step 3:** Commit: `git -C $HOME/.dotfiles add claude/.claude/skills/pre-commit/SKILL.md && git -C $HOME/.dotfiles commit -m "docs(pre-commit): mark as manual skill with invocation reminders"`

---

## Task 9: Update memory: Janus → Neo

**Priority:** P3 — Documentation  
**Files:**
- Modify: `$HOME/.claude/projects/<project-slug>/memory/MEMORY.md`

**Problem:** Memory references "Janus" (old name). Orchestrator now called "Neo".

**Solution:** Replace all "Janus" → "Neo" in memory file.

### Implementation

- [ ] **Step 1:** `sed -i '' 's/Janus/Neo/g' $HOME/.claude/projects/<project-slug>/memory/MEMORY.md`
- [ ] **Step 2:** Verify: `grep "Janus" $HOME/.claude/projects/<project-slug>/memory/MEMORY.md || echo "✓ All replaced"`
- [ ] **Step 3:** Note: NOT git-tracked (not part of stow package). Edit only.

---

## Task 10: Standardize hook logging format

**Priority:** P3 — Observability  
**Files:**
- Modify: auto-mode.sh, destructive-guard.sh, rtk-rewrite.sh (Task 7), superpowers-redirect.sh

**Problem:** Each hook logs differently. No standard format.

**Solution:** All hooks log to `~/.claude/logs/hooks.log` with format: `[YYYY-MM-DD HH:MM:SS] [hook-name] message`

### Implementation

- [ ] **Step 1:** auto-mode.sh: already correct (uses hooks.log from Task 1)
- [ ] **Step 2:** destructive-guard.sh: already correct (line 15)
- [ ] **Step 3:** rtk-rewrite.sh: done in Task 7
- [ ] **Step 4:** superpowers-redirect.sh (line 49): add LOGDIR/LOGFILE setup, then: `echo "[$(date '+%Y-%m-%d %H:%M:%S')] [superpowers-redirect] denied write to: $FILE_PATH" >> "$LOGFILE"`
- [ ] **Step 5:** Verify all hooks: `for hook in $HOME/.dotfiles/claude/.claude/hooks/*.sh; do grep -E ">> .*\.log" "$hook" | head -1 || echo "$(basename $hook): NO LOGGING"; done`
- [ ] **Step 6:** Commit: `git -C $HOME/.dotfiles add claude/.claude/hooks/superpowers-redirect.sh && git -C $HOME/.dotfiles commit -m "observability(hooks): standardize logging format across all hooks"`

---

## Post-Implementation Verification

```bash
# All hooks syntax-check
for hook in $HOME/.dotfiles/claude/.claude/hooks/*.sh; do
  bash -n "$hook" && echo "✓ $(basename $hook)" || echo "✗ $(basename $hook)"
done

# JSON valid
jq empty $HOME/.dotfiles/claude/.claude/settings.json && echo "✓ settings.json" || echo "✗ settings.json"

# Files exist
[ -f $HOME/.dotfiles/docs/claude-setup-hardening.md ] && echo "✓ Plan"
[ -f $HOME/.dotfiles/claude/.claude/rules/context-mode.md ] && echo "✓ Rules"
```

---

## Implementation Notes

- **Source editing:** All `claude/.claude/*` files edited in `$HOME/.dotfiles/claude/.claude/`, NOT `~/.claude/` (those are stow symlinks)
- **Memory:** `$HOME/.claude/projects/<project-slug>/memory/MEMORY.md` is NOT stow-managed—edit directly, no git commit
- **Git:** Use conventional format: `type(scope): description`
- **Logging:** All failures → `~/.claude/logs/hooks.log` with `[YYYY-MM-DD HH:MM:SS] [hook-name]` prefix
- **Testing:** Syntax: `bash -n FILE`. Logic: manual invocation + check logs.

