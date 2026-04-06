---
name: obsidian
description: Use when working in the Obsidian vault (~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Sacredyak/), or when creating/editing markdown outside a git repo — never use inside a git repo
---

# Obsidian Vault Routing

## Overview

The Obsidian vault lives at `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Sacredyak/`. Use this skill when creating or editing any file in the vault.

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

## Workflow

### Creating a new file
1. Identify content type using the decision flow above.
2. Determine the target path: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Sacredyak/<folder>/[subfolder/]<filename>.md`
3. Write the file using the Write tool — it creates parent directories automatically.
4. Confirm the path to the user.

### Editing an existing file
1. Read the file (Read tool — needed for Edit).
2. Copy it to `<filename>.bak` in the same directory (Bash: `cp <path> <path>.bak`).
3. Apply the edit using the Edit tool.
4. Read the file again to verify the edit is correct and surrounding content is intact.
5. Delete the backup (Bash: `rm <path>.bak`).
6. Confirm the edit to the user.

## Examples

| Content | Target path |
|---------|-------------|
| Design spec for a new CLI tool | `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Sacredyak/Projects/cli-tool/design-spec.md` |
| Notes on managing finances | `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Sacredyak/Areas/finances/investment-notes.md` |
| Research on SwiftUI TextKit | `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Sacredyak/Resources/swift/textkit2-notes.md` |
| Daily note for today | `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Sacredyak/Journal/2026/2026-04-06.md` |
| Quick idea, no clear category | `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Sacredyak/Inbox/app-idea-offline-sync.md` |
