#!/usr/bin/env python3
import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
import uuid
from datetime import datetime, timezone
from pathlib import Path

TASKS_HEADING = "## 📋 Tasks"
TS_FORMAT = "%Y-%m-%dT%H:%M:%S%z"
CHECKBOX = re.compile(r"^- \[[ x]\] ?")

NEW_NOTE = """---
id: {id}
title: {date}
tags: []
pinned: false
created: {ts}
modified: {ts}
---

# {date}

## 📋 Tasks

## 📝 Notes / Log

-

## 🚧 Blockers

-

## 🔜 Tomorrow

- [ ]
"""


class Fail(Exception):
    pass


def fetch_logbook():
    try:
        result = subprocess.run(
            ["things", "list", "logbook", "-j", "--no-hints"],
            capture_output=True,
            text=True,
        )
    except FileNotFoundError:
        raise Fail("things CLI not found on PATH")
    if result.returncode != 0:
        raise Fail(result.stderr.strip() or result.stdout.strip() or "things exited non-zero")
    try:
        return json.loads(result.stdout) or []
    except json.JSONDecodeError as e:
        raise Fail("could not parse things output: %s" % e)


def parse_stop_date(value):
    # things-cli emits nanosecond fractions, which fromisoformat rejects before 3.11.
    return datetime.strptime(value[:19], "%Y-%m-%dT%H:%M:%S").replace(tzinfo=timezone.utc)


def completed_on(items, day):
    done = []
    for item in items:
        if item.get("status") != "completed" or item.get("type") != "task":
            continue
        title = (item.get("title") or "").strip()
        stop = item.get("stopDate")
        if not title or not stop:
            continue
        local = parse_stop_date(stop).astimezone()
        if local.date() == day:
            done.append((local, title))
    done.sort(key=lambda pair: pair[0])
    return [title for _, title in done]


def new_note(now):
    return NEW_NOTE.format(
        id=str(uuid.uuid4()).upper(),
        date=now.date().isoformat(),
        ts=now.strftime(TS_FORMAT),
    )


def add_tasks(text, titles, now):
    """Return (new_text, added, skipped). Raises Fail when the Tasks heading is missing."""
    lines = text.split("\n")
    heading = next((i for i, l in enumerate(lines) if l.rstrip() == TASKS_HEADING), None)
    if heading is None:
        raise Fail("no '%s' heading in note" % TASKS_HEADING)
    end = next((i for i in range(heading + 1, len(lines)) if lines[i].startswith("## ")), len(lines))

    section = lines[heading + 1:end]
    existing = [CHECKBOX.sub("", l.strip()) for l in section]
    added = [t for t in titles if not any(e.startswith(t) for e in existing)]
    skipped = len(titles) - len(added)
    if not added:
        return text, added, skipped

    new_lines = ["- [x] " + t for t in added]
    last = max((i for i in range(heading + 1, end) if lines[i].strip()), default=None)
    if last is None:
        block = [""] + new_lines
        # Keep a blank line before the next heading when the section had none.
        if end == heading + 1 and end < len(lines):
            block.append("")
        lines[heading + 1:heading + 1] = block
    else:
        lines[last + 1:last + 1] = new_lines

    set_modified(lines, now.strftime(TS_FORMAT))
    return "\n".join(lines), added, skipped


def set_modified(lines, stamp):
    if not lines or lines[0].rstrip() != "---":
        return
    for i in range(1, len(lines)):
        if lines[i].rstrip() == "---":
            return
        if lines[i].startswith("modified:"):
            lines[i] = "modified: " + stamp
            return


def write_atomic(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    # mkstemp creates 0600 files, so copy the old mode or use a normal one.
    mode = path.stat().st_mode & 0o777 if path.exists() else 0o644
    fd, tmp = tempfile.mkstemp(dir=str(path.parent), prefix=".things-log-")
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="") as f:
            f.write(text)
        os.chmod(tmp, mode)
        os.replace(tmp, str(path))
    except BaseException:
        if os.path.exists(tmp):
            os.unlink(tmp)
        raise


def run(vault):
    now = datetime.now().astimezone()
    titles = completed_on(fetch_logbook(), now.date())
    path = vault.expanduser() / "Daily" / ("%s.md" % now.date().isoformat())

    created = not path.exists()
    if created:
        text = new_note(now)
    else:
        with open(str(path), encoding="utf-8", newline="") as f:
            text = f.read()

    new_text, added, skipped = add_tasks(text, titles, now)
    if not added and not created:
        if not titles:
            return "No completed tasks today."
        return "Added 0, skipped %d (already present): %s" % (skipped, path)

    write_atomic(path, new_text)
    if not titles:
        return "No completed tasks today. Created note: %s" % path
    return "Added %d, skipped %d (already present): %s" % (len(added), skipped, path)


def main():
    parser = argparse.ArgumentParser(description="Append today's completed Things tasks to today's daily note.")
    parser.add_argument("--vault", default="~/Documents/rokr_vault", help="vault root (default: %(default)s)")
    args = parser.parse_args()
    try:
        print(run(Path(args.vault)))
    except Fail as e:
        print("error: %s" % e, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
