#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import tempfile
import unittest
from datetime import datetime, timedelta, timezone
from pathlib import Path
from unittest import mock

SCRIPTS = Path(__file__).resolve().parents[1] / "agents/.agents/skills/daily-log/scripts"
sys.path.insert(0, str(SCRIPTS))

import log_meetings
import log_things  # importable once log_meetings has put its scripts dir on sys.path
from log_meetings import Fail, run

NOW = datetime(2026, 11, 12, 18, 30, 0, tzinfo=timezone(timedelta(hours=5, minutes=30)))
LATER = NOW + timedelta(hours=1)
DAY = "2026-11-12"

OLD_NOTE = """---
id: 1
title: 2026-11-12
created: 2026-11-12T08:00:00+0530
modified: 2026-11-12T08:00:00+0530
---

# 2026-11-12

## 📋 Tasks

- [x] write report
## 📝 Notes / Log

- existing note

## 🚧 Blockers

-
"""


def payload(meetings: list[dict[str, str]] | None = None, notes: list[str] | None = None) -> str:
    return json.dumps({"meetings": meetings or [], "notes": notes or []})


def meeting(start: str, end: str, title: str) -> dict[str, str]:
    return {"start": start, "end": end, "title": title}


def section(text: str, heading: str) -> list[str]:
    lines = text.split("\n")
    start = lines.index(heading) + 1
    end = next((i for i in range(start, len(lines)) if lines[i].startswith("## ")), len(lines))
    return lines[start:end]


class VaultCase(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.vault = Path(self.temporary.name)
        self.note = self.vault / "Daily" / (DAY + ".md")

    def write_note(self, text: str) -> None:
        self.note.parent.mkdir(parents=True)
        self.note.write_text(text, encoding="utf-8")

    def read(self) -> str:
        return self.note.read_text(encoding="utf-8")


class CreateTests(VaultCase):
    def test_creates_note_with_meetings_and_notes(self) -> None:
        message = run(
            self.vault,
            payload([meeting("09:45", "10:45", "Standup")], ["called the vendor"]),
            NOW,
        )
        text = self.read()
        self.assertEqual(
            message,
            "Meetings: added 1, skipped 0. Notes: added 1, skipped 0: %s" % self.note,
        )
        self.assertIn("title: %s\n" % DAY, text)
        self.assertEqual(section(text, "## 📅 Meetings"), ["", "- 09:45-10:45 Standup", ""])
        self.assertEqual(section(text, "## 📝 Notes / Log"), ["", "- called the vendor", ""])

    def test_sections_are_ordered_tasks_meetings_notes(self) -> None:
        run(self.vault, payload([meeting("09:00", "10:00", "A")]), NOW)
        headings = [l for l in self.read().split("\n") if l.startswith("## ")]
        self.assertEqual(
            headings,
            ["## 📋 Tasks", "## 📅 Meetings", "## 📝 Notes / Log", "## 🚧 Blockers", "## 🔜 Tomorrow"],
        )

    def test_empty_lists_create_nothing(self) -> None:
        self.assertEqual(run(self.vault, payload(), NOW), "Nothing to log.")
        self.assertEqual(run(self.vault, "{}", NOW), "Nothing to log.")
        self.assertFalse((self.vault / "Daily").exists())

    def test_notes_only_leaves_meetings_section_out(self) -> None:
        run(self.vault, payload(notes=["just a note"]), NOW)
        self.assertNotIn("## 📅 Meetings", self.read())

    def test_title_whitespace_is_collapsed(self) -> None:
        run(self.vault, payload([meeting("09:00", "10:00", "  Design \n review ")]), NOW)
        self.assertIn("- 09:00-10:00 Design review\n", self.read())


class MeetingsTests(VaultCase):
    def test_meetings_are_sorted_by_start(self) -> None:
        run(
            self.vault,
            payload([meeting("14:00", "15:00", "Late"), meeting("09:00", "09:30", "Early")]),
            NOW,
        )
        self.assertEqual(
            section(self.read(), "## 📅 Meetings"),
            ["", "- 09:00-09:30 Early", "- 14:00-15:00 Late", ""],
        )

    def test_inserts_section_into_old_note_after_tasks(self) -> None:
        self.write_note(OLD_NOTE)
        run(self.vault, payload([meeting("09:45", "10:45", "Standup")]), NOW)
        text = self.read()
        self.assertEqual(section(text, "## 📋 Tasks"), ["", "- [x] write report", ""])
        self.assertEqual(section(text, "## 📅 Meetings"), ["", "- 09:45-10:45 Standup", ""])
        headings = [l for l in text.split("\n") if l.startswith("## ")]
        self.assertEqual(headings[:3], ["## 📋 Tasks", "## 📅 Meetings", "## 📝 Notes / Log"])

    def test_inserts_section_when_tasks_is_last(self) -> None:
        self.write_note("---\nmodified: x\n---\n\n## 📋 Tasks\n\n- [x] a\n")
        run(self.vault, payload([meeting("09:00", "10:00", "A")]), NOW)
        self.assertEqual(
            self.read(),
            "---\nmodified: %s\n---\n\n## 📋 Tasks\n\n- [x] a\n\n## 📅 Meetings\n\n- 09:00-10:00 A\n"
            % NOW.strftime(log_meetings.TS_FORMAT),
        )

    def test_later_run_merges_new_meeting_in_order(self) -> None:
        run(self.vault, payload([meeting("09:00", "10:00", "A"), meeting("14:00", "15:00", "C")]), NOW)
        message = run(
            self.vault,
            payload([meeting("09:00", "10:00", "A"), meeting("11:00", "12:00", "B")]),
            LATER,
        )
        self.assertTrue(message.startswith("Meetings: added 1, skipped 1."))
        self.assertEqual(
            section(self.read(), "## 📅 Meetings"),
            ["", "- 09:00-10:00 A", "- 11:00-12:00 B", "- 14:00-15:00 C", ""],
        )

    def test_new_meeting_goes_between_existing_ones_without_touching_hand_typed_lines(self) -> None:
        self.write_note(
            "## 📋 Tasks\n\n- [x] a\n\n## 📅 Meetings\n\n"
            "- 09:00-10:00 A\n  - discussed X\n\n- 14:00-15:00 C\n\n## 📝 Notes / Log\n\n-\n"
        )
        run(self.vault, payload([meeting("11:00", "12:00", "B")]), NOW)
        self.assertEqual(
            self.read(),
            "## 📋 Tasks\n\n- [x] a\n\n## 📅 Meetings\n\n"
            "- 09:00-10:00 A\n  - discussed X\n\n- 11:00-12:00 B\n- 14:00-15:00 C\n\n## 📝 Notes / Log\n\n-\n",
        )

    def test_meeting_after_all_others_goes_below_last_line_of_last_section(self) -> None:
        self.write_note("## 📋 Tasks\n\n## 📅 Meetings\n\n- 09:00-10:00 A\n  - discussed X\n")
        run(self.vault, payload([meeting("11:00", "12:00", "B")]), NOW)
        self.assertEqual(
            self.read(),
            "## 📋 Tasks\n\n## 📅 Meetings\n\n- 09:00-10:00 A\n  - discussed X\n- 11:00-12:00 B\n",
        )

    def test_meeting_goes_into_empty_section_with_blank_line_before_next_heading(self) -> None:
        self.write_note("## 📋 Tasks\n\n## 📅 Meetings\n## 📝 Notes / Log\n\n-\n")
        run(self.vault, payload([meeting("09:00", "10:00", "A")]), NOW)
        self.assertEqual(
            self.read(),
            "## 📋 Tasks\n\n## 📅 Meetings\n\n- 09:00-10:00 A\n\n## 📝 Notes / Log\n\n-\n",
        )

    def test_duplicate_inside_one_payload_counts_as_skipped(self) -> None:
        message = run(
            self.vault,
            payload([meeting("09:00", "10:00", "A"), meeting("09:00", "10:00", "A")]),
            NOW,
        )
        self.assertTrue(message.startswith("Meetings: added 1, skipped 1."))

    def test_same_title_at_another_time_is_a_new_meeting(self) -> None:
        run(self.vault, payload([meeting("09:00", "10:00", "Sync")]), NOW)
        message = run(self.vault, payload([meeting("15:00", "16:00", "Sync")]), NOW)
        self.assertTrue(message.startswith("Meetings: added 1, skipped 0."))


class NotesTests(VaultCase):
    def test_first_note_replaces_placeholder_and_rest_append(self) -> None:
        run(self.vault, payload(notes=["one", "two"]), NOW)
        text = self.read()
        self.assertEqual(section(text, "## 📝 Notes / Log"), ["", "- one", "- two", ""])
        self.assertEqual(section(text, "## 🚧 Blockers"), ["", "-", ""])

    def test_notes_append_after_existing_notes(self) -> None:
        self.write_note(OLD_NOTE)
        run(self.vault, payload(notes=["fresh"]), NOW)
        self.assertEqual(
            section(self.read(), "## 📝 Notes / Log"),
            ["", "- existing note", "- fresh", ""],
        )

    def test_note_goes_into_empty_section_with_blank_line_before_next_heading(self) -> None:
        self.write_note("## 📝 Notes / Log\n## 🚧 Blockers\n\n-\n")
        run(self.vault, payload(notes=["fresh"]), NOW)
        self.assertEqual(self.read(), "## 📝 Notes / Log\n\n- fresh\n\n## 🚧 Blockers\n\n-\n")

    def test_note_goes_into_empty_last_section(self) -> None:
        self.write_note("## 📝 Notes / Log\n")
        run(self.vault, payload(notes=["fresh"]), NOW)
        self.assertEqual(self.read(), "## 📝 Notes / Log\n\n- fresh\n")

    def test_existing_note_is_skipped(self) -> None:
        self.write_note(OLD_NOTE)
        message = run(self.vault, payload(notes=["existing note"]), NOW)
        self.assertTrue(message.endswith("Notes: added 0, skipped 1: %s" % self.note))
        self.assertEqual(self.read(), OLD_NOTE)


class IdempotenceTests(VaultCase):
    def test_rerun_with_same_input_writes_nothing(self) -> None:
        body = payload([meeting("09:00", "10:00", "A")], ["a note"])
        run(self.vault, body, NOW)
        before = self.read()
        with mock.patch.object(log_meetings, "write_atomic") as write:
            message = run(self.vault, body, LATER)
        write.assert_not_called()
        self.assertEqual(self.read(), before)
        self.assertTrue(message.startswith("Meetings: added 0, skipped 1. Notes: added 0, skipped 1:"))

    def test_write_updates_modified_but_not_created(self) -> None:
        run(self.vault, payload([meeting("09:00", "10:00", "A")]), NOW)
        run(self.vault, payload([meeting("11:00", "12:00", "B")]), LATER)
        text = self.read()
        stamp = log_meetings.TS_FORMAT
        self.assertIn("created: %s\n" % NOW.strftime(stamp), text)
        self.assertIn("modified: %s\n" % LATER.strftime(stamp), text)


class LineEndingTests(VaultCase):
    def logged(self, note: str) -> str:
        self.note.parent.mkdir(parents=True, exist_ok=True)
        self.note.write_bytes(note.encode("utf-8"))
        run(self.vault, payload([meeting("11:00", "12:00", "B")], ["fresh"]), NOW)
        return self.note.read_bytes().decode("utf-8")

    def assert_crlf_matches_lf(self, lf_note: str) -> None:
        crlf = self.logged(lf_note.replace("\n", "\r\n"))
        self.assertIsNone(re.search(r"(?<!\r)\n", crlf))
        self.assertEqual(crlf, self.logged(lf_note).replace("\n", "\r\n"))

    def test_crlf_note_gets_new_meetings_section(self) -> None:
        self.assert_crlf_matches_lf(OLD_NOTE)

    def test_crlf_note_merges_into_existing_meetings_section(self) -> None:
        self.assert_crlf_matches_lf(OLD_NOTE.replace("## 📝", "## 📅 Meetings\n\n- 09:00-10:00 A\n\n## 📝", 1))

    def test_note_stays_intact_after_things_script_leaves_bare_lf_lines(self) -> None:
        for name, lf_note in (("template", log_things.new_note(NOW)), ("tasks run into notes", OLD_NOTE)):
            with self.subTest(name):
                # log_things splits on LF, so on a CRLF note it writes bare LF lines.
                mixed, _, _ = log_things.add_tasks(lf_note.replace("\n", "\r\n"), ["new task"], NOW)
                self.assertIsNotNone(re.search(r"(?<!\r)\n", mixed))
                text = self.logged(mixed)
                self.assertIsNone(re.search(r"(?<!\r)\n", text))
                lines = text.split("\r\n")
                self.assertEqual(lines.count("---"), 2)
                self.assertEqual(
                    [l for l in lines if l.startswith("## ")][:3],
                    ["## 📋 Tasks", "## 📅 Meetings", "## 📝 Notes / Log"],
                )
                self.assertIn("- fresh", section(text.replace("\r\n", "\n"), "## 📝 Notes / Log"))

    def test_mostly_lf_note_with_one_crlf_line_still_works(self) -> None:
        text = self.logged(OLD_NOTE.replace("- existing note\n", "- existing note\r\n"))
        self.assertIn("- 11:00-12:00 B\n", text)


class ValidationTests(VaultCase):
    def assert_rejected(self, raw: str, pattern: str) -> None:
        with self.assertRaisesRegex(Fail, pattern):
            run(self.vault, raw, NOW)
        self.assertFalse(self.note.exists())

    def test_rejects_bad_json(self) -> None:
        self.assert_rejected("not json", "not valid JSON")

    def test_rejects_blank_stdin(self) -> None:
        self.assert_rejected("", "not valid JSON")

    def test_rejects_non_object(self) -> None:
        self.assert_rejected("[]", "must be an object")

    def test_rejects_non_list_fields(self) -> None:
        self.assert_rejected('{"meetings": "x"}', "must be lists")

    def test_rejects_bad_times(self) -> None:
        for bad in ("9:45", "09:45\n", "0945", "ab:cd", "09:45:00", ""):
            with self.subTest(start=bad):
                self.assert_rejected(payload([meeting(bad, "10:45", "A")]), r"meetings\[0\]\.start")
        self.assert_rejected(payload([meeting("09:45", "10-45", "A")]), r"meetings\[0\]\.end")

    def test_rejects_missing_time(self) -> None:
        self.assert_rejected('{"meetings": [{"end": "10:00", "title": "A"}]}', r"meetings\[0\]\.start")

    def test_rejects_empty_title(self) -> None:
        self.assert_rejected(payload([meeting("09:00", "10:00", "   ")]), "title must not be empty")

    def test_rejects_non_string_title(self) -> None:
        self.assert_rejected('{"meetings": [{"start": "09:00", "end": "10:00", "title": 5}]}', "must be a string")

    def test_rejects_empty_note(self) -> None:
        self.assert_rejected(payload(notes=[" "]), r"notes\[0\] must not be empty")

    def test_missing_tasks_heading_fails_and_leaves_note_alone(self) -> None:
        text = "---\nmodified: x\n---\n\n## 📝 Notes / Log\n\n-\n"
        self.write_note(text)
        with self.assertRaisesRegex(Fail, "Tasks"):
            run(self.vault, payload([meeting("09:00", "10:00", "A")]), NOW)
        self.assertEqual(self.read(), text)

    def test_missing_notes_heading_fails_without_partial_write(self) -> None:
        text = "---\nmodified: x\n---\n\n## 📋 Tasks\n"
        self.write_note(text)
        with self.assertRaisesRegex(Fail, "Notes / Log"):
            run(self.vault, payload([meeting("09:00", "10:00", "A")], ["n"]), NOW)
        self.assertEqual(self.read(), text)


class CliTests(VaultCase):
    def invoke(self, stdin: str, env: dict[str, str] | None = None) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [sys.executable, str(SCRIPTS / "log_meetings.py"), "--vault", str(self.vault)],
            input=stdin,
            text=True,
            capture_output=True,
            env=env,
        )

    def test_writes_todays_note(self) -> None:
        result = self.invoke(payload([meeting("09:45", "10:45", "Standup")], ["hi"]))
        today = self.vault / "Daily" / (datetime.now().date().isoformat() + ".md")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(result.stdout.startswith("Meetings: added 1, skipped 0. Notes: added 1, skipped 0:"))
        self.assertIn("- 09:45-10:45 Standup", today.read_text(encoding="utf-8"))

    def test_run_writes_no_bytecode(self) -> None:
        # Stow does not honour .gitignore, so a stray __pycache__ would break it.
        with tempfile.TemporaryDirectory() as cache:
            env = {k: v for k, v in os.environ.items() if k != "PYTHONDONTWRITEBYTECODE"}
            env["PYTHONPYCACHEPREFIX"] = cache
            result = self.invoke(payload([meeting("09:45", "10:45", "Standup")]), env)
            self.assertEqual(result.returncode, 0, result.stderr)
            # Stdlib imports before the script runs may still land in the cache prefix.
            self.assertEqual(list(Path(cache).rglob("log_things*.pyc")), [])

    def test_bad_input_exits_one_with_error_on_stderr(self) -> None:
        result = self.invoke("nope")
        self.assertEqual(result.returncode, 1)
        self.assertTrue(result.stderr.startswith("error: "))
        self.assertEqual(result.stdout, "")


if __name__ == "__main__":
    unittest.main()
