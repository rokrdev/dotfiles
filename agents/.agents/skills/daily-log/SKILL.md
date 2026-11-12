---
name: daily-log
description: Log today's completed Things tasks and attended Google Calendar meetings into today's daily note in the rokr_vault. Asks which meetings to drop and what else to log before writing. Use when the user says "log my day", "daily log", "what did I do today", "log tasks and meetings", or "/daily-log".
---

Log today's tasks and meetings into `~/Documents/rokr_vault/Daily/<YYYY-MM-DD>.md`. Tasks come from Things. Meetings come from Google Calendar. Two scripts write the note. You never do.

Python cannot call the Google Calendar MCP. So you fetch and filter the meetings, then pipe them to the script as JSON.

## Steps

1. Run the Things script and relay its one-line output as is.

   ```bash
   python3 ~/.agents/skills/things-daily-log/scripts/log_things.py
   ```

   If it exits non-zero, show its stderr, then continue with meetings.

2. Get the local time and UTC offset with `date +%Y-%m-%dT%H:%M:%S%z`. Then call the claude.ai Google Calendar MCP `list_events` with:

   - `calendarId: "primary"`
   - `startTime`: today at `T00:00:00`, `endTime`: tomorrow at `T00:00:00`. Use local time with no offset and no `Z`. The tool resolves the user's time zone itself.
   - `eventType: ["DEFAULT"]`
   - `orderBy: "startTime"`

   If the result has a `nextPageToken`, fetch the next page. The tool has no param to expand recurring events, so treat each returned item as one occurrence.

3. Keep an event only if all of these hold:

   - It is timed, not all-day.
   - Its type is default. Drop `workingLocation`, `focusTime` and `outOfOffice`.
   - In `attendees`, the entry with `self: true` has `responseStatus: "accepted"`. If there is no self entry, drop the event.
   - Its end time is before now.
   - It is on the primary calendar.

   Convert start and end to local `HH:MM`. Use the offset from step 2 as the target. Below, the local offset is `+0530`. Look at the shape of each `dateTime`:

   - Ends in `Z`: it is UTC. Convert it to the local offset. `2026-11-12T04:15:00Z` becomes `09:45`.
   - Ends in `+HH:MM` or `-HH:MM`: it is an instant with its own offset. Convert it to the local offset. `2026-11-12T09:45:00+05:30` becomes `09:45`. `2026-11-12T00:15:00-04:00` becomes `09:45`. Never add the local offset on top of an offset that is already there.
   - No offset: it is wall time in the event's `timeZone`. If that zone has the local offset on that date, take `HH:MM` as is. `2026-11-12T09:45:00` in `Asia/Kolkata` becomes `09:45`. If the zone has another offset, convert it to the local offset.

   Always write local `HH:MM`. A rerun must give the same text, or the dedup misses and you get duplicate lines.

4. Show the kept meetings as a short list. Ask one question: "Drop any of these, or anything specific to log?" Wait for the answer. If no meetings are kept, say so and ask: "Anything specific to log?" Do not skip this question, even when you run the skill on your own.

   Remove the meetings the user drops. Turn each extra item the user gives into one string in `notes`.

5. Pipe the JSON to the meetings script and relay its one-line output as is.

   ```bash
   python3 ~/.agents/skills/daily-log/scripts/log_meetings.py <<'EOF'
   {"meetings":[{"start":"09:45","end":"10:45","title":"Standup"}],"notes":["called the vendor"]}
   EOF
   ```

   `start` and `end` must be `HH:MM`. `title` must not be empty. Send empty lists if there is nothing to log. The script then prints "Nothing to log." and creates no note.

   On a non-zero exit, show the stderr and stop.

## Rules

- Never edit the daily note by hand. The two scripts are the only writers.
- The calendar is read-only. Never call `create_event`, `update_event`, `delete_event`, `respond_to_event` or `suggest_time`.
- The skill only handles today. There is no date argument. If the user wants another day, say so.
- `--vault PATH` is the only flag on either script. Use it only if the user points at a different vault.
- Tasks are not pruned in this flow. Never call Things write commands.
- Re-runs are safe. Both scripts skip lines already in the note and do not rewrite the file if nothing is new.
