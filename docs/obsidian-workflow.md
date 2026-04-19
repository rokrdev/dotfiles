# Claude ↔ Obsidian Vault Workflow — Implementation Plan

**Vault root**: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Sacredyak/`
**Vault structure**: PARA-ish — Inbox, Areas, Projects, Resources, Archive, Journal, Templates

---

## Core Principles

- **Two capture surfaces, never merged**: `Inbox.md` (frictionless mid-day) vs `Journal/YYYY-MM-DD.md` (end-of-day human narrative)
- **Claude's hard boundary in journals**: Claude only writes inside a fenced `<!-- Claude context -->` block. Human-written sections are never touched.
- **Dry-run before any destructive action**: All rename/move operations show a diff and require approval.

---

## Skill Trigger Table

| Skill | Trigger phrase | What it does |
|---|---|---|
| `obsidian` | Creating/routing any `.md` file | Routes file to correct vault folder; enforces PARA structure |
| `obsidian-capture` | `cld "capture: <text>"` | Appends item to Inbox.md with date prefix |
| `obsidian-capture` | `cld "journal"` or `cld "open journal"` | Scaffolds today's journal from template if missing |
| `obsidian-search` | `cld "find notes about <topic>"` | Searches vault by keyword, tag, or frontmatter field |
| (triage workflow) | `cld "triage my inbox"` | Reads Inbox, classifies, proposes routing, executes on approval |
| `obsidian-refactor` | `cld "rename note X to Y"` | Link-safe rename/move with dry-run diff |
| (weekly review) | `cld "weekly review"` | Synthesises 7 journals into theme/heatmap brief |
| (monthly distill) | `cld "monthly distill"` | Clusters 30-journal themes, proposes vault refactor |

---

## Inbox.md Format

Simple append-only log. One item per line, date-prefixed. Claude always appends; never rewrites existing lines.

```
2026-04-18 :: link to that article on distributed tracing
2026-04-18 :: follow up with design team re: onboarding flow
2026-04-18 :: half-thought: maybe consolidate Areas/Health into Journal habit tracking
```

Claude appends via a single `echo "$(date +%Y-%m-%d) :: <item>" >> Inbox.md` equivalent. No reformatting of existing content.

---

## Journal Template Structure

File: `Templates/daily-journal.md` (Claude reads this when scaffolding)

```markdown
---
created: YYYY-MM-DD
tags: [journal]
---

## Intentions
<!-- human writes here -->

## Notes
<!-- human writes here -->

## Reflections
<!-- human writes here -->

<!-- Claude context -->
<!-- END Claude context -->
```

Claude only ever writes between `<!-- Claude context -->` and `<!-- END Claude context -->`. If the markers are absent (e.g. user deleted them), Claude adds them at the bottom — it does not infer where to write.

---

## Claude Section Fencing Rule

**Markers** (exact strings, no variation):
```
<!-- Claude context -->
<!-- END Claude context -->
```

**Rules**:
- Claude reads the entire journal for triage context.
- Claude writes **only** between the two markers.
- Claude never edits, reorders, or appends to `## Intentions`, `## Notes`, or `## Reflections`.
- If markers are missing: add them at end of file, then write inside.
- Claude context block content is structured as a brief bulleted summary of what was routed/captured that day.

---

## Phase 1 — MVP

### 1. Narrow `obsidian` skill (routing + conventions only)

**File**: `~/.dotfiles/claude/.claude/skills/obsidian.md`

**What changes**: Strip anything beyond vault routing and PARA folder mapping. The skill should answer only "where does this file go?" No capture, no search logic here.

**Done criteria**: Skill has a clear `when_to_use` frontmatter, a PARA folder map, and nothing else. No capture or search logic.

---

### 2. `obsidian-capture` skill — two commands

**File to create**: `~/.dotfiles/claude/.claude/skills/obsidian-capture.md`

**Trigger**: `cld "capture: <text>"` or `cld "journal"`

**What Claude does**:

*Capture to Inbox*:
1. Reads current `Inbox.md` (or creates it at vault root if missing).
2. Appends `YYYY-MM-DD :: <text>` as a new line.
3. Confirms append with line count.

*Scaffold today's journal*:
1. Checks if `Journal/YYYY-MM-DD.md` exists.
2. If missing: reads `Templates/daily-journal.md`, substitutes today's date, writes the file.
3. If exists: reports path only (no overwrite).

**Done criteria**: Both commands work end-to-end. Existing journal is never overwritten. Inbox append is idempotent (no duplicate lines from repeated invocations with identical text).

---

### 3. `obsidian-search` skill

**File to create**: `~/.dotfiles/claude/.claude/skills/obsidian-search.md`

**Trigger**: `cld "find notes about <topic>"`, `cld "notes tagged <tag>"`, `cld "notes with <frontmatter-field>: <value>"`

**What Claude does**:
1. Runs ripgrep against vault root for keyword, or greps frontmatter for tag/field.
2. Returns a ranked list: filename, path, matching excerpt (first 80 chars of match context).
3. Offers to open any result or capture a follow-up note.

**Done criteria**: Returns results for keyword, `#tag`, and frontmatter queries. Respects `.obsidianignore` if present.

---

### 4. Evening triage workflow

**Trigger**: `cld "triage my inbox"`

**What Claude does**:
1. Reads `Inbox.md` in full.
2. For each line, classifies into one of: `task`, `note-fragment`, `reference`, `learning`, `noise`.
3. Proposes routing per classification:
   - `task` → Things 3 (via Things CLI capture)
   - `note-fragment` → append to relevant Area or Project note (Claude proposes which)
   - `reference` → `Resources/References.md` or specific Resource note
   - `learning` → append to `Resources/Learnings.md` + queue for claude-mem observation
   - `noise` → discard (list shown for user confirmation)
4. Prints the full routing plan as a table. Waits for user approval (`y` / edit / skip per item).
5. Executes approved actions.
6. Clears routed lines from `Inbox.md` (leaves unrouted lines intact).
7. Appends a "Captured today" summary to `Journal/YYYY-MM-DD.md` inside the Claude context fenced block.

**Files involved**:
- Read: `Inbox.md`
- Write: various Area/Project/Resource notes (append only)
- Write: `Journal/YYYY-MM-DD.md` (Claude context block only)
- External: Things CLI for task capture

**Done criteria**: Full triage run clears inbox, routes all items, writes journal summary. Partial approval (user skips some items) leaves skipped lines in Inbox. Journal fencing rule never violated.

---

## Phase 2

### 5. `obsidian-refactor` skill — link-safe rename/move

**File to create**: `~/.dotfiles/claude/.claude/skills/obsidian-refactor.md`

**Trigger**: `cld "rename note <old> to <new>"`, `cld "move <note> to <folder>"`

**What Claude does**:
1. Finds the note by name (fuzzy match if needed, confirms with user if ambiguous).
2. Scans vault for all `[[wikilinks]]` pointing to the old name.
3. Shows a dry-run diff: new file path + all link updates.
4. Waits for explicit user approval.
5. Executes rename + link rewrites atomically.

**Done criteria**: No broken wikilinks after rename. Dry-run always shown before execution. Move to non-existent folder prompts user to confirm folder creation.

---

### 6. `obsidian-lint.sh` PostWrite hook

**File to create**: `~/.dotfiles/claude/.claude/hooks/obsidian-lint.sh`
**Settings change**: `~/.dotfiles/claude/.claude/settings.json` — add PostToolUse hook for Write/Edit targeting vault path

**What it does**:
- Fires after any Write or Edit to a `.md` file inside the vault.
- Checks for: missing `created` frontmatter field, missing `tags` frontmatter field, broken `[[wikilinks]]` (target file does not exist).
- Logs each warning as a JSON line to `~/.claude/logs/obsidian-lint.jsonl`: `{"ts": "...", "file": "...", "warning": "..."}`.
- **Never blocks writes.** Exit 0 always. Warnings are informational only.
- Prints warnings to stderr so they appear as Claude output.

**Done criteria**: Hook fires on vault writes. Non-vault writes are ignored. Log file grows correctly. A write to a note missing frontmatter produces a warning log entry.

---

## Phase 3

### 7. `obsidian-distill` agent

**File to create**: `~/.dotfiles/claude/.claude/skills/obsidian-distill.md`

**Trigger**: `cld "distill observations"` or invoked at end of monthly distill

**What Claude does**:
1. Reads recent claude-mem observations (via `claude-mem:mem-search` skill).
2. Identifies clusters of related observations.
3. Drafts a permanent note for each cluster in `Resources/` (e.g. `Resources/Learnings/distributed-systems.md`).
4. Shows drafted notes to user for approval before writing.
5. Writes only approved notes.

**Done criteria**: No file is written without explicit user approval. Draft is shown as full markdown before commit. Existing notes are appended to (not overwritten) if a matching resource note already exists.

---

### 8. Weekly review command

**Trigger**: `cld "weekly review"`

**What Claude does**:
1. Reads the last 7 `Journal/YYYY-MM-DD.md` files (Claude context blocks + any non-private sections user has chosen to share — Claude reads all sections but synthesises only from the Claude context blocks unless user says otherwise).
2. Reads the triage routing log (from inbox triage runs).
3. Synthesises:
   - **Themes**: recurring topics across the week
   - **Area heatmap**: which Areas got attention vs went quiet
   - **Stalled projects**: Projects not mentioned in any journal
   - **Streaks**: consecutive days with journal entries
4. Outputs the synthesis as a structured brief (not written to vault — user writes their own weekly note).

**Done criteria**: Output is a readable brief, not a raw dump. Claude does not write to vault during this command. Brief is under 400 words.

---

### 9. Monthly distill command

**Trigger**: `cld "monthly distill"`

**What Claude does**:
1. Reads last 30 journal files.
2. Clusters themes across the month.
3. Identifies:
   - Neglected Areas (no journal mentions in 2+ weeks)
   - Completed projects eligible for Archive
   - Resources that have grown large enough to split
4. Proposes vault refactor as a numbered action list: archive X, rename Y, split Z.
5. Waits for user approval per action.
6. Executes approved actions via `obsidian-refactor` skill patterns.
7. Triggers `obsidian-distill` agent for any new permanent notes.

**Done criteria**: Each proposed action is discrete and reversible. No bulk execution — user approves individually. Monthly summary brief is produced even if user declines all refactor proposals.

---

## Implementation Order

1. Narrow `obsidian` skill (no new files, just trim)
2. `obsidian-capture` skill (highest daily value)
3. Triage workflow (core daily loop)
4. `obsidian-search` skill
5. `obsidian-lint.sh` hook + settings registration
6. `obsidian-refactor` skill
7. `obsidian-distill` agent
8. Weekly review command (add to `obsidian-capture` or standalone skill)
9. Monthly distill command (add to `obsidian-distill` or standalone)

Phases 1–2 are the daily driver. Phase 3 is high-value but lower urgency — build after the daily rhythm is stable.
