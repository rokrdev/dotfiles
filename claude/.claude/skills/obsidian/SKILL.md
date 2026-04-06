---
name: obsidian
description: Use when working in the Obsidian vault (~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Sacredyak/), or when creating/editing markdown outside a git repo — never use inside a git repo
---

# Obsidian Vault Routing

## Overview

The Obsidian vault lives at `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Sacredyak/`. Use this skill when creating or editing any file in the vault.

**Always use the Obsidian CLI (`obsidian` at `/usr/local/bin/obsidian`) — never write directly to the vault path.** The CLI auto-detects the vault, uses vault-relative paths, and keeps backlinks and vault metadata consistent. Direct file writes bypass vault indexing and risk writing to the wrong path.
Verify it's available with `which obsidian` before use; it was installed at `/usr/local/bin/obsidian`.

## Vault Structure (PARA)

| Folder | Use for |
|--------|---------|
| `Projects/` | Active, named deliverables — specs, plans, project notes, brainstorms tied to a specific outcome |
| `Areas/` | Recurring, indefinite responsibilities — health, finances, career, personal development (no end date) |
| `Resources/` | Reference material — research, documentation, how-tos, notes on tools/concepts |
| `Journal/` | Date-based entries — daily notes, reflections, meeting notes tied to a date |
| `Excalidraw/` | Diagrams and visual notes only |
| `Inbox/` | When unsure — quick capture, unprocessed notes, anything that doesn't clearly fit elsewhere |
| `Archive/` | Completed or inactive items — do NOT create new notes here; only move existing ones |
| `Templates/` | Obsidian template definitions only — do NOT create new notes here; managed manually |
| `Attachments/` | Non-markdown assets only — never store notes here. Subfolders: `Images/` (png, jpg, gif, svg), `Audios/` (mp3, m4a, wav), `Pdfs/` (pdf), `Files/` (everything else: json, csv, zip, binaries, etc.) |

## Decision Flow

```
Is this a non-markdown asset (image, audio, pdf, or other file)?
  → YES → Attachments/<subfolder>/<filename> (see rule #5 for subfolder mapping)
  → NO

Is this tied to an active, named deliverable or project?
  → YES → Projects/<project-name>/<filename>.md
  → NO

Is this a recurring, indefinite responsibility (no specific end goal — e.g. Health, Career, Finances)?
  → YES → Areas/<area-name>/<filename>.md
  (Note: long-running projects with a defined outcome still belong in Projects/)
  → NO

Is this reference material you'll look up later?
  → YES → Resources/<topic>/<filename>.md
  → NO

Is this date-based (daily note, meeting note, reflection)?
  → YES → Journal/<YYYY>/<YYYY-MM-DD>-<title>.md
  → NO

Not sure?
  → Inbox/<filename>.md
```

## Rules

1. **Never create files directly in the vault root** — always use a subfolder.
2. **Never create files in `Archive/`** — that folder is for moved/retired content.
3. **Never create files in `Templates/`** — that folder is managed manually for Obsidian template use.
4. **Only create files in `Excalidraw/`** if the user explicitly requests a diagram note.
5. **Store attachments in `Attachments/`** using the appropriate subfolder: `Images/` (png, jpg, gif, svg), `Audios/` (mp3, m4a, wav), `Pdfs/` (pdf), `Files/` (everything else: json, csv, zip, binaries, etc.). Never store attachments in PARA folders, and never store notes or markdown files in `Attachments/` or any of its subfolders.
6. **Use kebab-case filenames** — e.g. `native-macos-editor-design.md`.
7. **Subfolders within PARA folders** — group by project name or topic, not by date (except Journal).
8. **Safe edit protocol** — when editing an existing vault file:
   - Make a backup first: copy the file to `<filename>.bak` in the same directory
   - Apply the edit using the Edit tool
   - Verify the edit was applied correctly and no surrounding content was disrupted
   - Delete the backup only after verification passes

## CLI Reference

```bash
# Create a new file with content
obsidian create path="<vault-relative-path>" content="<text>"

# Create using a template
obsidian create path="<vault-relative-path>" template="<template-name>"

# Read a file
obsidian read path="<vault-relative-path>"

# Overwrite an existing file
obsidian create path="<vault-relative-path>" content="<text>" overwrite

# Move/rename a file
obsidian move path="<from-path>" to="<to-path>"
```

**Path format:** Always vault-relative — e.g. `Projects/local-ai-server/setup-plan.md`. Never use the absolute iCloud path.

**Multiline content:** Pass content via shell variable or heredoc to handle newlines:
```bash
CONTENT=$(cat <<'EOF'
# My Note

Content here.
EOF
)
obsidian create path="Projects/foo/bar.md" content="$CONTENT"
```

### Common failures
- **`obsidian: command not found`** — CLI not in PATH; verify with `which obsidian`
- **`Error: vault not found`** — Obsidian app must be running for the CLI to detect the active vault
- **`Error: file already exists`** — add `overwrite` flag to `obsidian create`
- **`Error: path not found`** — parent folder doesn't exist; the CLI does not create intermediate folders automatically

## Workflow

### Creating a new file
1. Identify content type using the decision flow above.
2. Determine the vault-relative path: `<PARA-folder>/[subfolder/]<filename>.md`
3. Create via Bash: `obsidian create path="<relative-path>" content="<text>"`
4. Confirm the vault-relative path to the user.

### Editing an existing file
1. Read current content: `obsidian read path="<relative-path>"` via Bash
2. Compute the updated content.
3. Overwrite: `obsidian create path="<relative-path>" content="<updated>" overwrite`
4. Verify with another `obsidian read` call.

### Moving a file
```bash
obsidian move path="<from>" to="<to>"
```

## Examples

| Content | Vault-relative path |
|---------|-------------|
| Design spec for a new CLI tool | `Projects/cli-tool/design-spec.md` |
| Notes on managing finances | `Areas/finances/investment-notes.md` |
| Research on SwiftUI TextKit | `Resources/swift/textkit2-notes.md` |
| Daily note for today | `Journal/2026/2026-04-07.md` |
| Quick idea, no clear category | `Inbox/app-idea-offline-sync.md` |
