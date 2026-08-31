#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["PyYAML>=6.0.2,<7"]
# ///
from __future__ import annotations

import contextlib
import importlib.machinery
import importlib.util
import io
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest import mock

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

PREFIXED_TICKET = VALID_TICKET.replace(
    "schema-version: 2\nid: 0\n",
    "schema-version: 2\n"
    "feature: ticket-naming-conventions\n"
    "ticket-prefix: TNC\n"
    "id: 1\n",
).replace("slug: hello-command", "slug: add-ticket-prefix")


class TicketTests(unittest.TestCase):
    def test_parses_v2_ticket(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "00-hello-command.md"
            path.write_text(VALID_TICKET, encoding="utf-8")
            ticket = kanban.parse_ticket(path)
            self.assertEqual(ticket.slug, "hello-command")
            self.assertEqual(ticket.test_paths, {"tests/test_app.py"})
            self.assertEqual(ticket.production_paths, {"src/app.py"})

    def test_parses_one_based_prefixed_ticket(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "TNC-01-add-ticket-prefix.md"
            path.write_text(PREFIXED_TICKET, encoding="utf-8")

            ticket = kanban.parse_ticket(path)

            self.assertEqual(ticket.feature, "ticket-naming-conventions")
            self.assertEqual(ticket.ticket_prefix, "TNC")
            self.assertEqual(ticket.id, 1)
            self.assertEqual(ticket.slug, "add-ticket-prefix")
            self.assertEqual(ticket.key, "TNC-01-add-ticket-prefix")

    def test_rejects_zero_based_prefixed_ticket(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "TNC-00-add-ticket-prefix.md"
            path.write_text(
                PREFIXED_TICKET.replace("id: 1", "id: 0"), encoding="utf-8"
            )

            with self.assertRaisesRegex(kanban.KanbanError, "IDs start at 1"):
                kanban.parse_ticket(path)

    def test_rejects_prefixed_filename_that_disagrees_with_frontmatter(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "ABC-01-add-ticket-prefix.md"
            path.write_text(PREFIXED_TICKET, encoding="utf-8")

            with self.assertRaisesRegex(
                kanban.KanbanError, "filename must be TNC-01-add-ticket-prefix.md"
            ):
                kanban.parse_ticket(path)

    def test_rejects_incomplete_prefixed_identity(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "TNC-01-add-ticket-prefix.md"
            path.write_text(
                PREFIXED_TICKET.replace(
                    "feature: ticket-naming-conventions\n", ""
                ),
                encoding="utf-8",
            )

            with self.assertRaisesRegex(kanban.KanbanError, "feature must"):
                kanban.parse_ticket(path)

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

    def test_read_result_uses_stdout_when_output_file_is_empty(self) -> None:
        final = {
            "status": "complete",
            "summary": "done",
            "files_changed": [],
            "blocker": None,
        }
        with tempfile.TemporaryDirectory() as directory:
            output_path = Path(directory) / "output.json"
            output_path.touch()
            result = kanban.ProviderAdapter().read_result(
                subprocess.CompletedProcess([], 0, stdout=json.dumps(final)),
                output_path,
                kanban.IMPLEMENTER_SCHEMA,
            )
        self.assertEqual(result.data, final)
        self.assertEqual(result.raw_output, json.dumps(final))

    def test_read_result_preserves_noisy_stdout_and_prefers_output_file(self) -> None:
        final = {"verdict": "accept", "summary": "approved", "findings": []}
        stdout = json.dumps({"type": "error", "error": "transient stream error"})
        with tempfile.TemporaryDirectory() as directory:
            output_path = Path(directory) / "output.json"
            output_path.write_text(json.dumps(final), encoding="utf-8")
            result = kanban.ProviderAdapter().read_result(
                subprocess.CompletedProcess([], 0, stdout=stdout),
                output_path,
                kanban.VALIDATOR_SCHEMA,
            )
        self.assertEqual(result.data, final)
        self.assertEqual(result.raw_output, stdout + "\n" + json.dumps(final))

    def test_selects_last_schema_valid_result_from_provider_formats(self) -> None:
        cases = [
            (
                kanban.IMPLEMENTER_SCHEMA,
                {
                    "status": "complete",
                    "summary": "done",
                    "files_changed": ["src/app.py"],
                    "blocker": None,
                },
                {"status": "complete"},
            ),
            (
                kanban.VALIDATOR_SCHEMA,
                {"verdict": "accept", "summary": "approved", "findings": []},
                {"verdict": "accept"},
            ),
        ]
        for schema, final, expected in cases:
            with self.subTest(schema=schema["required"][0]):
                raw = "\n".join(
                    [
                        json.dumps({"type": "event", "structured_output": {"summary": "partial"}}),
                        json.dumps({"type": "result", "result": json.dumps(final)}),
                        "```json\n" + json.dumps({"payload": json.dumps(final)}) + "\n```",
                    ]
                )
                result = kanban.parse_agent_result(raw, schema)
                self.assertEqual(
                    {key: result[key] for key in expected}, expected
                )

    def test_provider_errors_do_not_fall_back_to_prose_decisions(self) -> None:
        for raw in (
            json.dumps({"type": "error", "error": {"message": "rate limited"}}),
            "## Error\nProvider failed before validation.\nVerdict: accept",
        ):
            with self.subTest(raw=raw), self.assertRaisesRegex(
                kanban.AgentResultError, "Provider reported an error"
            ) as raised:
                kanban.parse_agent_result(raw, kanban.VALIDATOR_SCHEMA)
            self.assertEqual(raised.exception.raw_output, raw)

    def test_final_valid_result_wins_over_earlier_provider_error_event(self) -> None:
        cases = [
            (
                kanban.IMPLEMENTER_SCHEMA,
                {
                    "status": "complete",
                    "summary": "done",
                    "files_changed": [],
                    "blocker": None,
                },
                "status",
            ),
            (
                kanban.VALIDATOR_SCHEMA,
                {"verdict": "accept", "summary": "approved", "findings": []},
                "verdict",
            ),
        ]
        for schema, final, decision_key in cases:
            with self.subTest(schema=decision_key):
                raw = "\n".join(
                    [
                        json.dumps({"type": "error", "error": "transient stream error"}),
                        json.dumps({"type": "result", "structured_output": final}),
                    ]
                )
                self.assertEqual(
                    kanban.parse_agent_result(raw, schema)[decision_key],
                    final[decision_key],
                )

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

    def test_accepts_explicit_prose_implementer_status(self) -> None:
        result = kanban.parse_agent_result(
            "Work complete.\nstatus: complete", kanban.IMPLEMENTER_SCHEMA
        )
        self.assertEqual(result["status"], "complete")

    def test_claude_success_envelope_requires_explicit_inner_status(self) -> None:
        raw = json.dumps(
            {
                "type": "result",
                "subtype": "success",
                "terminal_reason": "completed",
                "result": "Added three focused tests. No production code was touched.",
            }
        )
        with self.assertRaisesRegex(kanban.KanbanError, "unambiguous status"):
            kanban.parse_agent_result(raw, kanban.IMPLEMENTER_SCHEMA)

    def test_accepts_explicit_status_in_claude_success_envelope(self) -> None:
        raw = json.dumps(
            {
                "type": "result",
                "subtype": "success",
                "terminal_reason": "completed",
                "result": (
                    "Added three focused tests. No production code was touched.\n"
                    "Status: complete"
                ),
            }
        )
        result = kanban.parse_agent_result(raw, kanban.IMPLEMENTER_SCHEMA)
        self.assertEqual(result["status"], "complete")
        self.assertEqual(
            result["summary"],
            "Added three focused tests. No production code was touched.\n"
            "Status: complete",
        )

    def test_accepts_explicit_prose_validator_verdict(self) -> None:
        result = kanban.parse_agent_result(
            "Reviewed the patch. Verdict: accept", kanban.VALIDATOR_SCHEMA
        )
        self.assertEqual(result["verdict"], "accept")

    def test_prompts_require_explicit_claude_code_prose_fallbacks(self) -> None:
        ticket = SimpleNamespace(
            path=Path(".workflow/tickets/in-progress/ABC-01-test.md"),
            raw="ticket body",
            test_paths=("tests/test_app.py",),
            production_paths=("src/app.py",),
        )
        implementer = kanban.implementer_prompt(ticket, "tests", [])
        validator = kanban.validator_prompt(ticket, "", [], "abc123")
        self.assertIn("`Status: complete`", implementer)
        self.assertIn("`Status: blocked`", implementer)
        self.assertIn("`Verdict: accept`", validator)
        self.assertIn("`Verdict: reject`", validator)
        self.assertIn("`Verdict: blocked`", validator)

    def test_accepts_markdown_heading_and_table_decisions(self) -> None:
        cases = [
            ("### Status\ncomplete", kanban.IMPLEMENTER_SCHEMA, "status", "complete"),
            ("### Verdict\naccept", kanban.VALIDATOR_SCHEMA, "verdict", "accept"),
            ("| Status | complete |", kanban.IMPLEMENTER_SCHEMA, "status", "complete"),
            ("| Verdict | reject |", kanban.VALIDATOR_SCHEMA, "verdict", "reject"),
        ]
        for raw, schema, key, expected in cases:
            with self.subTest(raw=raw):
                self.assertEqual(kanban.parse_agent_result(raw, schema)[key], expected)

    def test_accepts_markdown_and_unambiguous_bare_prose_decisions(self) -> None:
        implementation = kanban.parse_agent_result(
            "Implementation complete", kanban.IMPLEMENTER_SCHEMA
        )
        validation = kanban.parse_agent_result(
            "**Verdict:** accept\nI accept this patch.", kanban.VALIDATOR_SCHEMA
        )
        self.assertEqual(implementation["status"], "complete")
        self.assertEqual(validation["verdict"], "accept")

    def test_rejects_prose_without_explicit_decision(self) -> None:
        with self.assertRaisesRegex(kanban.KanbanError, "unambiguous verdict"):
            kanban.parse_agent_result("Looks good to me.", kanban.VALIDATOR_SCHEMA)

    def test_rejects_negated_validator_acceptance_prose(self) -> None:
        for raw in (
            "I cannot accept this patch.",
            "I don't accept this patch.",
            "I do not accept this patch.",
            "This patch is not accepted.",
            "I am unable to accept this patch.",
            "This patch is not approved.",
            "I cannot approve this patch.",
        ):
            with self.subTest(raw=raw), self.assertRaisesRegex(
                kanban.KanbanError, "unambiguous verdict"
            ):
                kanban.parse_agent_result(raw, kanban.VALIDATOR_SCHEMA)

    def test_explicit_validator_reject_allows_negated_acceptance(self) -> None:
        result = kanban.parse_agent_result(
            "Verdict: reject. I cannot accept this patch.",
            kanban.VALIDATOR_SCHEMA,
        )
        self.assertEqual(result["verdict"], "reject")

    def test_explicit_validator_accept_conflicts_with_negated_authorization(self) -> None:
        for raw in (
            "Verdict: accept. I cannot accept this patch.",
            "Verdict: accept. This patch is not approved.",
        ):
            with self.subTest(raw=raw), self.assertRaisesRegex(
                kanban.KanbanError, "unambiguous verdict"
            ):
                kanban.parse_agent_result(raw, kanban.VALIDATOR_SCHEMA)

    def test_implementer_blocked_prose_requires_explicit_positive_phrase(self) -> None:
        for raw in (
            "blocked",
            "not currently blocked",
            "no longer blocked",
        ):
            with self.subTest(raw=raw), self.assertRaisesRegex(
                kanban.KanbanError, "unambiguous status"
            ):
                kanban.parse_agent_result(raw, kanban.IMPLEMENTER_SCHEMA)
        for raw in (
            "Implementation complete; not currently blocked.",
            "Implementation complete; no longer blocked.",
        ):
            with self.subTest(raw=raw):
                result = kanban.parse_agent_result(raw, kanban.IMPLEMENTER_SCHEMA)
                self.assertEqual(result["status"], "complete")

    def test_rejects_conflicting_prose_decisions(self) -> None:
        with self.assertRaisesRegex(kanban.KanbanError, "unambiguous verdict"):
            kanban.parse_agent_result(
                "Verdict: accept, but reject the patch.", kanban.VALIDATOR_SCHEMA
            )
        with self.assertRaisesRegex(kanban.KanbanError, "unambiguous status"):
            kanban.parse_agent_result(
                "Implementation complete, but I am blocked.",
                kanban.IMPLEMENTER_SCHEMA,
            )

    def test_validates_embedded_json_strictly(self) -> None:
        with self.assertRaisesRegex(kanban.KanbanError, "extra keys"):
            kanban.parse_agent_result(
                'Result follows:\n{"status":"complete","summary":"ok","files_changed":[],"blocker":null,"extra":true}',
                kanban.IMPLEMENTER_SCHEMA,
            )


class GitTests(unittest.TestCase):
    def initialise_repo(self, root: Path) -> None:
        subprocess.run(["git", "init", "-q"], cwd=root, check=True)
        subprocess.run(
            ["git", "config", "core.excludesFile", "/dev/null"],
            cwd=root,
            check=True,
        )
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
            ["git", "config", "core.excludesFile", "/dev/null"],
            cwd=root,
            check=True,
        )
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
            ".workflow/kanban/paused",
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
        subprocess.run(["git", "add", "src", "tests"], cwd=root, check=True)
        subprocess.run(["git", "commit", "-qm", "approved plan"], cwd=root, check=True)
        return kanban.parse_ticket(ticket_path)

    def write_prefixed_ticket(
        self,
        root: Path,
        *,
        prefix: str = "TNC",
        feature: str = "ticket-naming-conventions",
        ticket_id: int = 1,
        slug: str = "add-ticket-prefix",
    ) -> kanban.Ticket:
        text = (
            PREFIXED_TICKET.replace(
                "feature: ticket-naming-conventions", f"feature: {feature}"
            )
            .replace("ticket-prefix: TNC", f"ticket-prefix: {prefix}")
            .replace("id: 1", f"id: {ticket_id}")
            .replace("slug: add-ticket-prefix", f"slug: {slug}")
        )
        path = (
            root
            / ".workflow/kanban/backlog"
            / f"{prefix}-{ticket_id:02d}-{slug}.md"
        )
        path.write_text(text, encoding="utf-8")
        return kanban.parse_ticket(path)

    def test_board_allows_same_one_based_id_under_different_feature_prefixes(
        self,
    ) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.initialise_board_repo(root)
            self.write_prefixed_ticket(root)
            self.write_prefixed_ticket(
                root,
                prefix="ABC",
                feature="another-big-change",
                slug="add-another-change",
            )

            tickets = kanban.validate_board(root)

            self.assertEqual(
                {ticket.key for ticket in tickets},
                {
                    "00-hello-command",
                    "TNC-01-add-ticket-prefix",
                    "ABC-01-add-another-change",
                },
            )

    def test_board_rejects_prefix_reused_for_another_feature(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.initialise_board_repo(root)
            self.write_prefixed_ticket(root)
            self.write_prefixed_ticket(
                root,
                feature="totally-new-capability",
                ticket_id=2,
                slug="add-new-capability",
            )

            with self.assertRaisesRegex(
                kanban.KanbanError,
                "ticket-prefix TNC already belongs to feature ticket-naming-conventions",
            ):
                kanban.validate_board(root)

    def test_board_rejects_duplicate_id_within_feature_prefix(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.initialise_board_repo(root)
            self.write_prefixed_ticket(root)
            self.write_prefixed_ticket(root, slug="add-another-prefix-change")

            with self.assertRaisesRegex(
                kanban.KanbanError, "duplicate ticket ID 01 for TNC"
            ):
                kanban.validate_board(root)

    def test_board_rejects_duplicate_slug_across_feature_prefixes(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.initialise_board_repo(root)
            self.write_prefixed_ticket(root)
            self.write_prefixed_ticket(
                root,
                prefix="ABC",
                feature="another-big-change",
                slug="add-ticket-prefix",
            )

            with self.assertRaisesRegex(
                kanban.KanbanError, "duplicate ticket slug add-ticket-prefix"
            ):
                kanban.validate_board(root)

    def test_validate_command_accepts_mixed_legacy_and_prefixed_board(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.initialise_board_repo(root)
            self.write_prefixed_ticket(root)
            original_cwd = Path.cwd()
            stdout = io.StringIO()
            try:
                os.chdir(root)
                with contextlib.redirect_stdout(stdout):
                    self.assertEqual(kanban.main(["validate"]), 0)
            finally:
                os.chdir(original_cwd)

            self.assertEqual(
                stdout.getvalue(),
                "Valid board: 2 tickets, schema-version 2, 0 paused\n",
            )

    def test_paused_ticket_is_valid_but_not_eligible(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            ticket = self.initialise_board_repo(root)
            paused_path = kanban.move_ticket(
                ticket, root / ".workflow/kanban/paused"
            )

            tickets = kanban.validate_board(root)

            self.assertEqual([item.slug for item in tickets], ["hello-command"])
            self.assertEqual(kanban.eligible_tickets(root), [])
            self.assertIn(
                ".workflow/kanban/paused/00-hello-command.md",
                kanban.ticket_board_paths(kanban.parse_ticket(paused_path)),
            )

    def test_existing_three_column_board_remains_valid(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.initialise_board_repo(root)
            (root / ".workflow/kanban/paused").rmdir()

            tickets = kanban.validate_board(root)

            self.assertEqual([ticket.slug for ticket in tickets], ["hello-command"])

    def test_bulk_pause_and_resume_preserve_ticket_contents(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            first = self.initialise_board_repo(root)
            second_text = (
                VALID_TICKET.replace("id: 0", "id: 1")
                .replace("slug: hello-command", "slug: goodbye-command")
                .replace("title: Add hello command", "title: Add goodbye command")
            )
            second_path = root / ".workflow/kanban/backlog/01-goodbye-command.md"
            second_path.write_text(second_text, encoding="utf-8")
            second = kanban.parse_ticket(second_path)
            original = {first.slug: first.raw, second.slug: second.raw}

            paused = kanban.transition_tickets(
                root,
                ["hello-command", "goodbye-command"],
                "backlog",
                "paused",
            )
            self.assertEqual(
                [ticket.slug for ticket in paused],
                ["hello-command", "goodbye-command"],
            )
            self.assertEqual(kanban.eligible_tickets(root), [])
            for slug, raw in original.items():
                path = next(
                    (root / ".workflow/kanban/paused").glob(f"*-{slug}.md")
                )
                self.assertEqual(path.read_text(encoding="utf-8"), raw)

            kanban.transition_tickets(
                root,
                ["hello-command", "goodbye-command"],
                "paused",
                "backlog",
            )
            self.assertEqual(
                [ticket.slug for ticket in kanban.eligible_tickets(root)],
                ["hello-command", "goodbye-command"],
            )

    def test_pause_rejects_duplicate_slug_arguments_without_moving_ticket(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            ticket = self.initialise_board_repo(root)

            with self.assertRaisesRegex(kanban.KanbanError, "must not be repeated"):
                kanban.transition_tickets(
                    root,
                    ["hello-command", "hello-command"],
                    "backlog",
                    "paused",
                )

            self.assertTrue(ticket.path.exists())

    def test_pause_and_resume_commands_move_ticket_under_board_lock(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.initialise_board_repo(root)
            original_cwd = Path.cwd()
            stdout = io.StringIO()
            try:
                os.chdir(root)
                with contextlib.redirect_stdout(stdout):
                    self.assertEqual(
                        kanban.main(["pause", "hello-command"]), 0
                    )
                    self.assertEqual(
                        kanban.main(["resume", "hello-command"]), 0
                    )
            finally:
                os.chdir(original_cwd)

            self.assertIn("PAUSED 00-hello-command", stdout.getvalue())
            self.assertIn("RESUMED 00-hello-command", stdout.getvalue())
            self.assertTrue(
                (root / ".workflow/kanban/backlog/00-hello-command.md").exists()
            )
            self.assertTrue((root / ".git/kanban-loop/.lock").exists())

    def test_plan_reports_paused_tickets_separately_from_eligible(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            first = self.initialise_board_repo(root)
            kanban.move_ticket(first, root / ".workflow/kanban/paused")
            self.write_prefixed_ticket(root)
            original_cwd = Path.cwd()
            stdout = io.StringIO()
            try:
                os.chdir(root)
                with mock.patch.object(
                    kanban,
                    "select_provider",
                    return_value=SimpleNamespace(name="test-provider"),
                ), contextlib.redirect_stdout(stdout):
                    self.assertEqual(kanban.main(["plan"]), 0)
            finally:
                os.chdir(original_cwd)

            payload = json.loads(stdout.getvalue())
            self.assertEqual(
                payload["eligible"],
                [
                    {
                        "key": "TNC-01-add-ticket-prefix",
                        "feature": "ticket-naming-conventions",
                        "ticket_prefix": "TNC",
                        "id": 1,
                        "slug": "add-ticket-prefix",
                        "human_required": False,
                        "allowed_paths": ["src/app.py", "tests/test_app.py"],
                        "acceptance": "Running app hello prints hello.",
                    }
                ],
            )
            self.assertEqual(
                payload["paused"],
                [
                    {
                        "key": "00-hello-command",
                        "feature": None,
                        "ticket_prefix": None,
                        "id": 0,
                        "slug": "hello-command",
                        "title": "Add hello command",
                    }
                ],
            )

    def test_pause_accepts_full_prefixed_ticket_key(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.initialise_board_repo(root)
            ticket = self.write_prefixed_ticket(root)

            moved = kanban.transition_tickets(
                root,
                ["TNC-01-add-ticket-prefix"],
                "backlog",
                "paused",
            )

            self.assertEqual([item.key for item in moved], [ticket.key])
            self.assertTrue(
                (
                    root
                    / ".workflow/kanban/paused/TNC-01-add-ticket-prefix.md"
                ).exists()
            )

    def test_move_ticket_refuses_to_overwrite_existing_ticket(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            ticket = self.initialise_board_repo(root)
            target = root / ".workflow/kanban/paused/00-hello-command.md"
            target.write_text("existing\n", encoding="utf-8")

            with self.assertRaisesRegex(kanban.KanbanError, "Refusing to overwrite"):
                kanban.move_ticket(ticket, target.parent)

            self.assertTrue(ticket.path.exists())
            self.assertEqual(target.read_text(encoding="utf-8"), "existing\n")

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

    def test_clean_check_ignores_local_workflow_but_not_staged_index(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.initialise_repo(root)
            (root / ".workflow").mkdir()
            (root / ".workflow/local-state.md").write_text("local\n")
            kanban.ensure_clean(root)
            (root / "tracked.txt").write_text("staged\n")
            subprocess.run(["git", "add", "tracked.txt"], cwd=root, check=True)
            with self.assertRaisesRegex(kanban.KanbanError, "only kanban-loop"):
                kanban.ensure_clean(root)

    def test_changed_paths_ignores_legacy_tracked_workflow_files(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.initialise_repo(root)
            (root / ".workflow").mkdir()
            workflow = root / ".workflow/legacy.md"
            workflow.write_text("before\n")
            subprocess.run(["git", "add", ".workflow/legacy.md"], cwd=root, check=True)
            subprocess.run(["git", "commit", "-qm", "legacy board"], cwd=root, check=True)
            workflow.write_text("after\n")
            self.assertNotIn(".workflow/legacy.md", kanban.changed_paths(root))

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
            visible_status = subprocess.run(
                ["git", "status", "--porcelain", "--", ".", ":(exclude).workflow"],
                cwd=root,
                text=True,
                capture_output=True,
                check=True,
            ).stdout
            self.assertEqual(visible_status, "")
            committed = subprocess.run(
                ["git", "show", "--pretty=format:", "--name-only", "HEAD"],
                cwd=root,
                text=True,
                capture_output=True,
                check=True,
            ).stdout
            self.assertIn("src/app.py", committed)
            self.assertIn("tests/test_app.py", committed)
            self.assertNotIn(".workflow/", committed)

    def test_failed_attempt_writes_durable_failure_record(self) -> None:
        class FailingProvider(kanban.ProviderAdapter):
            name = "failing"
            executable = "false"

            def build_command(self, request, schema_path, output_path):
                raise NotImplementedError

            def run(self, request):
                raise kanban.AgentResultError("bad worker output", "not json")

        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            ticket = self.initialise_board_repo(root)
            with self.assertRaisesRegex(kanban.AgentResultError, "bad worker output"):
                kanban.process_ticket(
                    root, ticket, FailingProvider(), "auto", 1, run_id="failure-test"
                )
            run_path = kanban.state_dir(root, "failure-test")
            record = json.loads((run_path / "attempt-01.failure.json").read_text())
            self.assertEqual(record["error_type"], "AgentResultError")
            self.assertEqual((run_path / "attempt-01.raw.txt").read_text(), "not json")

    def test_provider_failure_records_stdout_and_stderr(self) -> None:
        class FailingProcessProvider(kanban.ProviderAdapter):
            executable = "/bin/sh"

            def build_command(self, request, schema_path, output_path):
                return ["/bin/sh", "-c", "printf stdout; printf stderr >&2; exit 7"]

        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.initialise_repo(root)
            request = kanban.AgentRequest(
                role="validator",
                prompt="prompt",
                schema=kanban.VALIDATOR_SCHEMA,
                cwd=root,
                writable=False,
            )
            with self.assertRaises(kanban.ProcessError) as raised:
                FailingProcessProvider().run(request)
            failure = kanban.record_failure(root, "provider", raised.exception)
            record = json.loads(failure.read_text())
            self.assertEqual((root / record["stdout"]).read_text(), "stdout")
            self.assertEqual((root / record["stderr"]).read_text(), "stderr")

    def test_main_prints_global_failure_log_path(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.initialise_repo(root)
            original_cwd = Path.cwd()
            stderr = io.StringIO()
            try:
                os.chdir(root)
                with contextlib.redirect_stderr(stderr):
                    self.assertEqual(kanban.main(["validate"]), kanban.EXIT_BLOCKED)
            finally:
                os.chdir(original_cwd)
            self.assertIn("Failure log:", stderr.getvalue())

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
