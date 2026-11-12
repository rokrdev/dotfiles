#!/usr/bin/env python3
import argparse
import json
import re
import sys
from datetime import datetime
from pathlib import Path

# Skip .pyc files, since a stray __pycache__ in the stow tree breaks stow.
sys.dont_write_bytecode = True
# Reuse the note template and writers so both scripts stay in lockstep.
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "things-daily-log" / "scripts"))
from log_things import TASKS_HEADING, TS_FORMAT, Fail, new_note, set_modified, write_atomic  # noqa: E402

MEETINGS_HEADING = "## 📅 Meetings"
NOTES_HEADING = "## 📝 Notes / Log"
TIME = re.compile(r"\d{2}:\d{2}", re.ASCII)
MEETING_LINE = re.compile(r"^- \d{2}:\d{2}-\d{2}:\d{2} ", re.ASCII)
BULLET = re.compile(r"^- ")


def clean(value, label):
    if not isinstance(value, str):
        raise Fail("%s must be a string" % label)
    value = " ".join(value.split())
    if not value:
        raise Fail("%s must not be empty" % label)
    return value


def parse_input(raw):
    """Return (meeting entries sorted by start, notes). Raises Fail on bad input."""
    try:
        data = json.loads(raw)
    except json.JSONDecodeError as e:
        raise Fail("stdin is not valid JSON: %s" % e)
    if not isinstance(data, dict):
        raise Fail("stdin JSON must be an object")
    meetings = data.get("meetings", [])
    notes = data.get("notes", [])
    if not isinstance(meetings, list) or not isinstance(notes, list):
        raise Fail("'meetings' and 'notes' must be lists")

    entries = []
    for i, meeting in enumerate(meetings):
        label = "meetings[%d]" % i
        if not isinstance(meeting, dict):
            raise Fail("%s must be an object" % label)
        times = []
        for key in ("start", "end"):
            value = meeting.get(key)
            if not isinstance(value, str) or not TIME.fullmatch(value):
                raise Fail("%s.%s must look like HH:MM" % (label, key))
            times.append(value)
        title = clean(meeting.get("title"), label + ".title")
        entries.append("%s-%s %s" % (times[0], times[1], title))

    return sorted(entries), [clean(n, "notes[%d]" % i) for i, n in enumerate(notes)]


def find_heading(lines, heading):
    return next((i for i, l in enumerate(lines) if l.rstrip() == heading), None)


def section_end(lines, heading):
    return next((i for i in range(heading + 1, len(lines)) if lines[i].startswith("## ")), len(lines))


def append_to_section(lines, heading, new_lines):
    end = section_end(lines, heading)
    last = max((i for i in range(heading + 1, end) if lines[i].strip()), default=None)
    if last is not None:
        lines[last + 1:last + 1] = new_lines
        return
    block = [""] + new_lines
    # Keep a blank line before the next heading when the section had none.
    if end == heading + 1 and end < len(lines):
        block.append("")
    lines[heading + 1:heading + 1] = block


def insert_meeting(lines, heading, line):
    end = section_end(lines, heading)
    # Only top-level timed lines count, so sub-bullets stay under their parent.
    later = next(
        (i for i in range(heading + 1, end) if MEETING_LINE.match(lines[i]) and lines[i] > line),
        None,
    )
    if later is None:
        append_to_section(lines, heading, [line])
    else:
        lines.insert(later, line)


def add_meetings(lines, entries):
    """Edit lines in place and return (added, skipped). Raises Fail when there is nowhere to insert."""
    if not entries:
        return 0, 0
    heading = find_heading(lines, MEETINGS_HEADING)
    seen = set()
    if heading is not None:
        seen = {l.strip() for l in lines[heading + 1:section_end(lines, heading)] if l.strip()}

    added = []
    for entry in entries:
        line = "- " + entry
        if line not in seen:
            seen.add(line)
            added.append(line)
    skipped = len(entries) - len(added)
    if not added:
        return 0, skipped

    if heading is not None:
        for line in added:
            insert_meeting(lines, heading, line)
        return len(added), skipped

    tasks = find_heading(lines, TASKS_HEADING)
    if tasks is None:
        raise Fail("no '%s' heading in note" % TASKS_HEADING)
    at = section_end(lines, tasks)
    block = [MEETINGS_HEADING, ""] + added + [""]
    if at > 0 and lines[at - 1].strip():
        block.insert(0, "")
    lines[at:at] = block
    return len(added), skipped


def add_notes(lines, notes):
    """Edit lines in place and return (added, skipped). Raises Fail when the Notes heading is missing."""
    if not notes:
        return 0, 0
    heading = find_heading(lines, NOTES_HEADING)
    if heading is None:
        raise Fail("no '%s' heading in note" % NOTES_HEADING)
    end = section_end(lines, heading)

    section = [l.strip() for l in lines[heading + 1:end]]
    seen = {BULLET.sub("", s) for s in section if s not in ("", "-")}
    added = []
    for note in notes:
        if note not in seen:
            seen.add(note)
            added.append(note)
    skipped = len(notes) - len(added)
    if not added:
        return 0, skipped

    new_lines = ["- " + n for n in added]
    placeholders = [i for i in range(heading + 1, end) if lines[i].strip() == "-"]
    for i, line in zip(placeholders, new_lines):
        lines[i] = line
    rest = new_lines[len(placeholders):]
    if rest:
        append_to_section(lines, heading, rest)
    return len(added), skipped


def run(vault, raw, now=None):
    now = now or datetime.now().astimezone()
    entries, notes = parse_input(raw)
    if not entries and not notes:
        return "Nothing to log."

    path = vault.expanduser() / "Daily" / ("%s.md" % now.date().isoformat())
    if path.exists():
        with open(str(path), encoding="utf-8", newline="") as f:
            text = f.read()
    else:
        text = new_note(now)

    # Keep the note's own line endings so a CRLF note never ends up mixed.
    eol = "\r\n" if text.count("\r\n") * 2 > text.count("\n") else "\n"
    # log_things leaves bare LF lines in CRLF notes, so split on LF and rejoin with eol.
    lines = text.replace("\r\n", "\n").split("\n")
    m_added, m_skipped = add_meetings(lines, entries)
    n_added, n_skipped = add_notes(lines, notes)
    if m_added or n_added:
        set_modified(lines, now.strftime(TS_FORMAT))
        write_atomic(path, eol.join(lines))
    return "Meetings: added %d, skipped %d. Notes: added %d, skipped %d: %s" % (
        m_added, m_skipped, n_added, n_skipped, path)


def main():
    parser = argparse.ArgumentParser(description="Log meetings and notes (JSON on stdin) into today's daily note.")
    parser.add_argument("--vault", default="~/Documents/rokr_vault", help="vault root (default: %(default)s)")
    args = parser.parse_args()
    try:
        print(run(Path(args.vault), sys.stdin.read()))
    except Fail as e:
        print("error: %s" % e, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
