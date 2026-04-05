# Claude Code Setup Fixes — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix 5 identified gaps in the Claude Code dotfiles setup: hardcoded paths in hooks, missing hook error logging, empty mcp.json, sparse memory system, and missing dotfiles-specific skill.

**Architecture:** All changes are in `/Users/bharat/.dotfiles/claude/.claude/` (the stow package). After edits, `stow -R claude` from `/Users/bharat/.dotfiles` updates live symlinks. MCP config requires discovering registered servers first via `claude mcp list`, then writing them to mcp.json.

**Tech Stack:** Bash (hooks), JSON (mcp.json), Markdown (skill files, memory entries)

---

### Task 1: Replace hardcoded paths in superpowers-redirect.sh

**Files:**
- Modify: `claude/.claude/hooks/superpowers-redirect.sh`

- [ ] **Step 1: Replace all hardcoded `/Users/bharat/` with `$HOME/`**

Two locations in the file need changing:

```bash
# BEFORE (line ~24):
if [[ "$FILE_PATH" == /Users/bharat/projects/* ]]; then

# AFTER:
if [[ "$FILE_PATH" == $HOME/projects/* ]]; then
```

```bash
# BEFORE (deny message, line ~33):
"permissionDecisionReason": "No active project context. Save superpowers docs to the Obsidian vault instead: /Users/bharat/projects/sacredyak/superpowers/ ..."

# AFTER:
"permissionDecisionReason": "No active project context. Save superpowers docs to the Obsidian vault instead: $HOME/projects/sacredyak/superpowers/ ..."
```

- [ ] **Step 2: Verify no hardcoded paths remain**

```bash
grep -n "bharat" /Users/bharat/.dotfiles/claude/.claude/hooks/superpowers-redirect.sh
```

Expected: no output.

- [ ] **Step 3: Commit**

```bash
cd /Users/bharat/.dotfiles
git add claude/.claude/hooks/superpowers-redirect.sh
git commit -m "fix(hooks): replace hardcoded home path with \$HOME for portability"
```

---

### Task 2: Add stderr logging to both hooks

**Files:**
- Modify: `claude/.claude/hooks/rtk-rewrite.sh`
- Modify: `claude/.claude/hooks/superpowers-redirect.sh`

- [ ] **Step 1: Add logging preamble to rtk-rewrite.sh**

Insert these 3 lines immediately after the comment block (before `RTK_VERSION=`):

```bash
# Logging: stderr goes to ~/.claude/logs/hooks.log
mkdir -p "$HOME/.claude/logs"
exec 2>>"$HOME/.claude/logs/hooks.log"
```

- [ ] **Step 2: Add a log line when rtk-rewrite rewrites a command**

Find the `# Command was rewritten.` comment and add a log line before the jq output:

```bash
# Command was rewritten. Return the new command.
echo "[rtk-rewrite] $(date -u +%FT%TZ) rewrote command" >&2
echo "$INPUT" | jq --arg cmd "$REWRITTEN" '.tool_input.command = $cmd'
```

- [ ] **Step 3: Add logging preamble to superpowers-redirect.sh**

Insert these 3 lines immediately after the shebang:

```bash
# Logging: stderr goes to ~/.claude/logs/hooks.log
mkdir -p "$HOME/.claude/logs"
exec 2>>"$HOME/.claude/logs/hooks.log"
```

- [ ] **Step 4: Add a log line when superpowers-redirect denies a write**

In the deny block, add before the `cat <<'EOF'` line:

```bash
echo "[superpowers-redirect] $(date -u +%FT%TZ) denied write to: $FILE_PATH" >&2
```

- [ ] **Step 5: Verify syntax of both scripts**

```bash
bash -n /Users/bharat/.dotfiles/claude/.claude/hooks/rtk-rewrite.sh && echo "rtk-rewrite: OK"
bash -n /Users/bharat/.dotfiles/claude/.claude/hooks/superpowers-redirect.sh && echo "superpowers-redirect: OK"
```

Expected: both print `OK`.

- [ ] **Step 6: Commit**

```bash
cd /Users/bharat/.dotfiles
git add claude/.claude/hooks/rtk-rewrite.sh claude/.claude/hooks/superpowers-redirect.sh
git commit -m "fix(hooks): add stderr logging to hooks.log for visibility"
```

---

### Task 3: Discover and codify MCP server registrations into mcp.json

**Files:**
- Modify: `claude/.claude/mcp.json`

- [ ] **Step 1: Discover currently registered MCP servers**

```bash
claude mcp list
```

Note down all server names and types. Also check for alternate config locations:

```bash
ls /Users/bharat/.mcp.json 2>/dev/null || echo "no home .mcp.json"
ls /Users/bharat/.dotfiles/.mcp.json 2>/dev/null || echo "no dotfiles .mcp.json"
```

- [ ] **Step 2: Get full config for each server**

For each server listed in Step 1, run:

```bash
claude mcp get <server-name>
```

Collect command, args, and env for each.

- [ ] **Step 3: Write all servers into mcp.json**

Populate `/Users/bharat/.dotfiles/claude/.claude/mcp.json`. Use env var references for secrets:

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    },
    "things": {
      "command": "/path/to/things-mcp",
      "args": []
    }
  }
}
```

(Fill in actual values from Step 2 — do not guess.)

- [ ] **Step 4: Restow the claude package**

```bash
cd /Users/bharat/.dotfiles
stow -n -R claude && stow -R claude
```

- [ ] **Step 5: Verify servers still work**

```bash
claude mcp list
```

Expected: same servers as Step 1.

- [ ] **Step 6: Commit**

```bash
cd /Users/bharat/.dotfiles
git add claude/.claude/mcp.json
git commit -m "feat(mcp): codify MCP server registrations into dotfiles mcp.json"
```

---

### Task 4: Populate memory system with meaningful entries

**Files:**
- Modify: `/Users/bharat/.claude/projects/-Users-bharat--dotfiles/memory/MEMORY.md`
- Create: 4 new memory files in the same directory

- [ ] **Step 1: Write feedback memory — orchestrator pattern**

Create `/Users/bharat/.claude/projects/-Users-bharat--dotfiles/memory/feedback_orchestrator.md`:

```markdown
---
name: orchestrator-pattern
description: Main agent must always delegate work to subagents, never do work directly
type: feedback
---

All work must be delegated to subagents via the Agent tool. The main agent is an orchestrator only.

**Why:** Prevents context flooding; enforces clean separation between planning and execution; makes work reviewable.

**How to apply:** Before doing ANY file read (for analysis), bash command, or code write — dispatch a subagent. Only exception: reading a file immediately before editing it.
```

- [ ] **Step 2: Write feedback memory — context-mode routing**

Create `/Users/bharat/.claude/projects/-Users-bharat--dotfiles/memory/feedback_context_mode.md`:

```markdown
---
name: context-mode-routing
description: All large-output commands must go through ctx_ MCP tools, never raw Bash
type: feedback
---

Use ctx_batch_execute, ctx_execute, ctx_search instead of Bash for anything producing >20 lines.

**Why:** A single unrouted command can dump 56 KB into context, wasting the entire session.

**How to apply:** curl/wget → ctx_fetch_and_index. Analysis → ctx_execute_file. Multi-command research → ctx_batch_execute. Follow-up questions → ctx_search.
```

- [ ] **Step 3: Write user memory — dotfiles setup**

Create `/Users/bharat/.claude/projects/-Users-bharat--dotfiles/memory/user_dotfiles.md`:

```markdown
---
name: user-dotfiles-setup
description: User manages macOS dotfiles with GNU Stow; all edits must go in .dotfiles/, not symlink targets
type: user
---

Uses GNU Stow to manage macOS dotfiles at /Users/bharat/.dotfiles. Each top-level dir is a stow package mirroring the target path relative to $HOME.

Key rule: NEVER edit files under ~/.config/, ~/.hammerspoon/, ~/.claude/ directly — those are symlinks. Always edit source in ~/.dotfiles/<package>/.

After adding files to a package: `stow -R <package>` from repo root.
```

- [ ] **Step 4: Write feedback memory — haiku for subagents**

Create `/Users/bharat/.claude/projects/-Users-bharat--dotfiles/memory/feedback_subagent_model.md`:

```markdown
---
name: subagent-model-haiku
description: Subagents use Haiku model to save costs; main agent uses Sonnet
type: feedback
---

CLAUDE_CODE_SUBAGENT_MODEL=claude-haiku-4-5-20251001 is set in settings.json env vars.

**Why:** Subagents do focused, bounded tasks — Haiku is sufficient and much cheaper.

**How to apply:** Don't override to Sonnet/Opus for subagents unless the task genuinely requires it (complex reasoning, long synthesis).
```

- [ ] **Step 5: Update MEMORY.md index**

Add these sections to `/Users/bharat/.claude/projects/-Users-bharat--dotfiles/memory/MEMORY.md`:

```markdown
## Workflow
- [Orchestrator Pattern](feedback_orchestrator.md) — main agent delegates all work; never does work directly
- [Context-Mode Routing](feedback_context_mode.md) — large-output commands must use ctx_ MCP tools
- [Subagent Model](feedback_subagent_model.md) — use Haiku for subagents to save costs

## User Context
- [Dotfiles Setup](user_dotfiles.md) — GNU Stow managed; always edit source in .dotfiles/, not symlinks
```

- [ ] **Step 6: Verify index is under 200 lines**

```bash
wc -l /Users/bharat/.claude/projects/-Users-bharat--dotfiles/memory/MEMORY.md
```

Expected: under 200.

---

### Task 5: Create dotfiles-specific skill

**Files:**
- Create: `claude/.claude/skills/dotfiles/SKILL.md`

- [ ] **Step 1: Create the skill file**

Create `/Users/bharat/.dotfiles/claude/.claude/skills/dotfiles/SKILL.md` with this exact content:

```markdown
---
name: dotfiles
description: Use when working in the dotfiles repo — enforces stow conventions, prevents editing symlink targets, guides adding new packages
when_to_use: When the user asks to add, edit, or restructure any dotfile or stow package
---

# Dotfiles Skill

## Core Rule

NEVER edit files under `~/.config/`, `~/.hammerspoon/`, `~/.claude/`, or any stow target directly.
Those paths are symlinks. Always edit the source in `~/.dotfiles/<package>/`.

## Before Stowing — Always Dry-Run First

```bash
stow -n <package>
```

If conflicts are shown (existing non-symlink files): back up, remove, then stow.

## Adding a New Package

1. Create the directory mirroring the target path relative to $HOME:
   - File at `~/.config/foo/bar.toml` → package structure: `~/.dotfiles/foo/.config/foo/bar.toml`
2. Dry-run: `stow -n foo`
3. Stow: `stow foo`
4. Verify: `ls -la ~/.config/foo/bar.toml`

## Adding Files to an Existing Package

```bash
stow -R <package>
```

## Removing a Package

```bash
stow -D <package>
```

Removes symlinks only — source files are preserved.

## Common Mistakes to Avoid

- Editing `~/.config/fish/config.fish` instead of `~/.dotfiles/fish/.config/fish/config.fish`
- Running `stow` without `-n` dry-run first
- Forgetting `stow -R` after adding new files
- Committing secrets or tokens in any config file
```

- [ ] **Step 2: Restow to deploy the new skill**

```bash
cd /Users/bharat/.dotfiles
stow -R claude
```

- [ ] **Step 3: Verify skill is live**

```bash
ls -la /Users/bharat/.claude/skills/dotfiles/SKILL.md
```

Expected: symlink pointing into `.dotfiles`.

- [ ] **Step 4: Commit**

```bash
cd /Users/bharat/.dotfiles
git add claude/.claude/skills/dotfiles/SKILL.md
git commit -m "feat(skills): add dotfiles skill with stow conventions and guardrails"
```

---

## Final Verification Checklist

- [ ] `grep -r "bharat" ~/.dotfiles/claude/.claude/hooks/` → no output
- [ ] `bash -n ~/.claude/hooks/rtk-rewrite.sh && bash -n ~/.claude/hooks/superpowers-redirect.sh` → both OK
- [ ] `claude mcp list` shows all expected servers and matches mcp.json
- [ ] `wc -l ~/.claude/projects/-Users-bharat--dotfiles/memory/MEMORY.md` → under 200 lines
- [ ] `ls ~/.claude/skills/dotfiles/SKILL.md` → exists as symlink
- [ ] `ls ~/.claude/logs/hooks.log` → exists after next hook trigger
