---
name: things-daily-log
description: Append today's completed Things 3 tasks to today's daily note in the rokr_vault. Use when the user says "log my done tasks", "sync Things to my daily note", "what did I finish today", "update my daily note from Things", or "/things-daily-log".
---

Run the script and tell the user what it printed.

```bash
python3 ~/.agents/skills/things-daily-log/scripts/log_things.py
```

The script reads the Things logbook, keeps tasks completed today (local time), and appends them as `- [x] <title>` lines under `## 📋 Tasks` in `~/Documents/rokr_vault/Daily/<YYYY-MM-DD>.md`. It creates the note if it does not exist. Re-runs are safe. Tasks already in the section are skipped, and the file is not rewritten if nothing is new.

On success, relay the one-line output as is. On a non-zero exit, show the stderr to the user and stop.

Rules:

- Never edit the daily note by hand. The script is the only writer.
- Never call Things write commands (`things log`, `complete`, `edit`, `add`, `cancel`). This skill only reads.
- The script only handles today. It has no date argument. If the user wants another day, say so.
- The script writes to the vault directly. The vault has no Obsidian app config, so the Obsidian CLI is not an option here.
- `--vault PATH` is the only flag. Use it only if the user points at a different vault.
