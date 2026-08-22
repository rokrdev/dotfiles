#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["PyYAML>=6.0.2,<7"]
# ///
from __future__ import annotations

import importlib.machinery
import importlib.util
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace

RUNNER = Path(__file__).resolve().parents[1] / "bin/.local/bin/kanban-loop"
LOADER = importlib.machinery.SourceFileLoader("kanban_loop", str(RUNNER))
SPEC = importlib.util.spec_from_loader("kanban_loop", LOADER)
assert SPEC and SPEC.loader
kanban = importlib.util.module_from_spec(SPEC)
sys.modules["kanban_loop"] = kanban
SPEC.loader.exec_module(kanban)


VALID_TICKET = """---
schema-version: 2
id: 0
slug: hello-command
title: Add hello command
language: python
depends-on: []
human-required: false
acceptance: "Running app hello prints hello."
allowed-changes:
  - path: src/app.py
    operation: modify
  - path: tests/test_app.py
    operation: modify
failing-tests:
  - tests/test_app.py::test_hello_command
tdd-test-command: python -m unittest tests.test_app.TestApp.test_hello_command
verification:
  - command: python -m unittest
    expected-exit: 0
commit-message: "feat(cli): add hello command"
---

## Context

Add one command.
"""


class TicketTests(unittest.TestCase):
    def test_parses_v2_ticket(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "00-hello-command.md"
            path.write_text(VALID_TICKET, encoding="utf-8")
            ticket = kanban.parse_ticket(path)
            self.assertEqual(ticket.slug, "hello-command")
            self.assertEqual(ticket.test_paths, {"tests/test_app.py"})
            self.assertEqual(ticket.production_paths, {"src/app.py"})

    def test_rejects_directory_allowlist(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "00-hello-command.md"
            path.write_text(
                VALID_TICKET.replace("src/app.py", "src/"), encoding="utf-8"
            )
            with self.assertRaisesRegex(
                kanban.KanbanError, "exact repository-relative file"
            ):
                kanban.parse_ticket(path)

    def test_rejects_legacy_ticket(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "00-hello-command.md"
            path.write_text(
                VALID_TICKET.replace("schema-version: 2\n", ""), encoding="utf-8"
            )
            with self.assertRaisesRegex(kanban.KanbanError, "schema-version"):
                kanban.parse_ticket(path)


class ProviderTests(unittest.TestCase):
    def request(self, writable: bool = True) -> kanban.AgentRequest:
        return kanban.AgentRequest(
            role="validator" if not writable else "implementer-code",
            prompt="prompt",
            schema=kanban.VALIDATOR_SCHEMA
            if not writable
            else kanban.IMPLEMENTER_SCHEMA,
            cwd=Path("/tmp/repo"),
            writable=writable,
            allowed_paths=("src/app.py",) if writable else (),
        )

    def test_claude_uses_noninteractive_structured_output(self) -> None:
        command = kanban.ClaudeAdapter().build_command(
            self.request(), Path("/tmp/schema.json"), Path("/tmp/output.json")
        )
        self.assertIn("-p", command)
        self.assertIn("--json-schema", command)
        self.assertNotIn("--worktree", command)

    def test_codex_uses_exec_and_read_only_validator(self) -> None:
        command = kanban.CodexAdapter().build_command(
            self.request(writable=False),
            Path("/tmp/schema.json"),
            Path("/tmp/output.json"),
        )
        self.assertEqual(command[:2], ["codex", "exec"])
        self.assertEqual(command[command.index("--sandbox") + 1], "read-only")
        self.assertNotIn("--ask-for-approval", command)
        self.assertIn('approval_policy="never"', command)

    def test_opencode_v1_supplies_bounded_agent_config(self) -> None:
        request = self.request(writable=False)
        env = kanban.OpenCodeAdapter("opencode").environment(request)
        config = json.loads(env["OPENCODE_CONFIG_CONTENT"])
        permission = config["agent"]["kanban-validator"]["permission"]
        self.assertEqual(permission["edit"], "deny")
        self.assertEqual(permission["bash"], "deny")

    def test_opencode2_uses_v2_cli_and_exact_edit_permission(self) -> None:
        adapter = kanban.OpenCodeAdapter("opencode2")
        request = self.request(writable=True)
        command = adapter.build_command(
            request, Path("/tmp/schema.json"), Path("/tmp/output.json")
        )
        self.assertEqual(command[:3], ["opencode2", "run", "--standalone"])
        self.assertNotIn("--dir", command)
        config = json.loads(adapter.environment(request)["OPENCODE_CONFIG_CONTENT"])
        permissions = config["agents"]["kanban-implementer-code"]["permissions"]
        edit_rules = [rule for rule in permissions if rule["action"] == "edit"]
        self.assertEqual(
            edit_rules,
            [{"action": "edit", "resource": "src/app.py", "effect": "allow"}],
        )

    def test_detects_current_host_before_executable_fallback(self) -> None:
        self.assertEqual(
            kanban.detect_host_provider({"CODEX_THREAD_ID": "thread"}), "codex"
        )
        self.assertEqual(
            kanban.detect_host_provider(
                {"CODEX_THREAD_ID": "thread", "CLAUDECODE": "1"}
            ),
            "claude",
        )

    def test_extracts_nested_structured_output(self) -> None:
        raw = json.dumps(
            {"type": "result", "structured_output": {"status": "complete"}}
        )
        self.assertEqual(kanban.extract_json_object(raw), {"status": "complete"})

    def test_rejects_structured_output_with_extra_keys(self) -> None:
        result = {
            "status": "complete",
            "summary": "done",
            "files_changed": [],
            "blocker": None,
            "unexpected": True,
        }
        with self.assertRaisesRegex(kanban.KanbanError, "extra keys"):
            kanban.validate_schema(result, kanban.IMPLEMENTER_SCHEMA)


class GitTests(unittest.TestCase):
    def initialise_repo(self, root: Path) -> None:
        subprocess.run(["git", "init", "-q"], cwd=root, check=True)
        subprocess.run(
            ["git", "config", "user.name", "Kanban Test"], cwd=root, check=True
        )
        subprocess.run(
            ["git", "config", "user.email", "kanban@example.invalid"],
            cwd=root,
            check=True,
        )
        (root / "tracked.txt").write_text("before\n", encoding="utf-8")
        subprocess.run(["git", "add", "tracked.txt"], cwd=root, check=True)
        subprocess.run(["git", "commit", "-qm", "initial"], cwd=root, check=True)

    def initialise_board_repo(self, root: Path) -> kanban.Ticket:
        subprocess.run(["git", "init", "-q"], cwd=root, check=True)
        subprocess.run(
            ["git", "config", "user.name", "Kanban Test"], cwd=root, check=True
        )
        subprocess.run(
            ["git", "config", "user.email", "kanban@example.invalid"],
            cwd=root,
            check=True,
        )
        for relative in (
            "src",
            "tests",
            ".workflow/kanban/backlog",
            ".workflow/kanban/doing",
            ".workflow/kanban/done",
        ):
            (root / relative).mkdir(parents=True, exist_ok=True)
        (root / "src/app.py").write_text("before\n", encoding="utf-8")
        (root / "tests/test_app.py").write_text("before test\n", encoding="utf-8")
        ticket_text = VALID_TICKET.replace(
            "  - command: python -m unittest\n", '  - command: "true"\n'
        )
        ticket_path = root / ".workflow/kanban/backlog/00-hello-command.md"
        ticket_path.write_text(ticket_text, encoding="utf-8")
        subprocess.run(["git", "add", "-A"], cwd=root, check=True)
        subprocess.run(
            ["git", "add", "-f", ".workflow/kanban/backlog/00-hello-command.md"],
            cwd=root,
            check=True,
        )
        subprocess.run(["git", "commit", "-qm", "approved plan"], cwd=root, check=True)
        return kanban.parse_ticket(ticket_path)

    def test_diff_text_includes_tracked_and_untracked_files_without_staging(
        self,
    ) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.initialise_repo(root)
            (root / "tracked.txt").write_text("after\n", encoding="utf-8")
            (root / "created.txt").write_text("created\n", encoding="utf-8")
            ticket = SimpleNamespace(allowed_paths={"tracked.txt", "created.txt"})
            patch = kanban.diff_text(root, ticket)
            self.assertIn("tracked.txt", patch)
            self.assertIn("created.txt", patch)
            staged = subprocess.run(
                ["git", "diff", "--cached", "--name-only"],
                cwd=root,
                text=True,
                capture_output=True,
                check=True,
            ).stdout
            self.assertEqual(staged, "")

    def test_existing_worktree_detection_is_false_for_primary_checkout(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.initialise_repo(root)
            self.assertFalse(kanban.is_existing_worktree(root))

    def test_agent_cannot_modify_real_git_index(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.initialise_repo(root)
            (root / "tracked.txt").write_text("after\n", encoding="utf-8")
            subprocess.run(["git", "add", "tracked.txt"], cwd=root, check=True)
            with self.assertRaisesRegex(
                kanban.KanbanError, "only kanban-loop may stage or commit"
            ):
                kanban.assert_index_clean(root)

    def test_commit_contains_only_accepted_patch_and_ticket_transition(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            backlog_ticket = self.initialise_board_repo(root)
            doing_path = kanban.move_ticket(
                backlog_ticket, root / ".workflow/kanban/doing"
            )
            ticket = kanban.parse_ticket(doing_path)
            (root / "src/app.py").write_text("after\n", encoding="utf-8")
            (root / "tests/test_app.py").write_text("after test\n", encoding="utf-8")
            accepted_hash = kanban.sha256_text(kanban.diff_text(root, ticket))

            _, done_path = kanban.commit_ticket(root, ticket, accepted_hash)

            self.assertEqual(done_path.parent.name, "done")
            status = subprocess.run(
                ["git", "status", "--porcelain"],
                cwd=root,
                text=True,
                capture_output=True,
                check=True,
            ).stdout
            self.assertEqual(status, "")
            committed = subprocess.run(
                ["git", "show", "--pretty=format:", "--name-only", "HEAD"],
                cwd=root,
                text=True,
                capture_output=True,
                check=True,
            ).stdout
            self.assertIn("src/app.py", committed)
            self.assertIn("tests/test_app.py", committed)
            self.assertIn(".workflow/kanban/done/00-hello-command.md", committed)
            self.assertNotIn(".workflow/kanban/doing/", committed)

    def test_rejection_restore_keeps_ticket_doing_and_resets_code(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            backlog_ticket = self.initialise_board_repo(root)
            doing_path = kanban.move_ticket(
                backlog_ticket, root / ".workflow/kanban/doing"
            )
            ticket = kanban.parse_ticket(doing_path)
            (root / "src/app.py").write_text("rejected\n", encoding="utf-8")
            (root / "tests/test_app.py").write_text("rejected test\n", encoding="utf-8")

            kanban.restore_implementation(root, ticket)

            self.assertEqual((root / "src/app.py").read_text(), "before\n")
            self.assertEqual((root / "tests/test_app.py").read_text(), "before test\n")
            self.assertTrue(doing_path.exists())
            self.assertFalse(
                (root / ".workflow/kanban/backlog/00-hello-command.md").exists()
            )


if __name__ == "__main__":
    unittest.main()
