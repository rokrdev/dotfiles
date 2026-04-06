---
name: obsidian
description: Use when creating a markdown file outside a git repo — routes to the correct Obsidian vault folder based on content type (PARA structure)
---

# Obsidian Vault Routing

## Overview

The Obsidian vault lives at `~/projects/sacredyak/`. When creating a markdown file outside a git repo, use this skill to determine the correct vault folder.

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

## Decision Flow

```
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
5. **Use kebab-case filenames** — e.g. `native-macos-editor-design.md`.
6. **Subfolders within PARA folders** — group by project name or topic, not by date (except Journal).

## Workflow

1. Identify content type using the decision flow above.
2. Determine the target path: `~/projects/sacredyak/<folder>/[subfolder/]<filename>.md`
3. Write the file using the Write tool — it creates parent directories automatically.
4. Confirm the path to the user.

## Examples

| Content | Target path |
|---------|-------------|
| Design spec for a new CLI tool | `~/projects/sacredyak/Projects/cli-tool/design-spec.md` |
| Notes on managing finances | `~/projects/sacredyak/Areas/finances/investment-notes.md` |
| Research on SwiftUI TextKit | `~/projects/sacredyak/Resources/swift/textkit2-notes.md` |
| Daily note for today | `~/projects/sacredyak/Journal/2026/2026-04-06.md` |
| Quick idea, no clear category | `~/projects/sacredyak/Inbox/app-idea-offline-sync.md` |
