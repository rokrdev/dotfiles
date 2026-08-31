#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["PyYAML>=6.0.2,<7"]
# ///
from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from collections.abc import Callable
from pathlib import Path
from typing import Any

LIBRARY = Path(__file__).resolve().parents[1] / "bin/.local/lib"
sys.path.insert(0, str(LIBRARY))

from kanban_loop import gitops
from kanban_loop.cli import execute, parser
from kanban_loop.engine import Engine
from kanban_loop.model import (
    KanbanError,
    feature_status,
    parse_ticket,
    render_markdown,
)
from kanban_loop.providers import (
    IMPLEMENTER_SCHEMA,
    AgentResult,
    ClaudeAdapter,
    CodexAdapter,
    OpenCodeAdapter,
    ProviderFailure,
    parse_agent_result,
)
from kanban_loop.storage import (
    BoardStore,
    SessionStore,
    apply_migration,
    migration_preview,
    restore_migration,
)


def command(root: Path, *arguments: str) -> str:
    completed = subprocess.run(
        list(arguments), cwd=root, text=True, capture_output=True, check=True
    )
    return completed.stdout.strip()


def feature_text(slug: str = "loop-redesign", prefix: str = "LR") -> str:
    return render_markdown(
        {
            "schema-version": 3,
            "kind": "feature",
            "feature": slug,
            "ticket-prefix": prefix,
            "title": "Loop redesign",
            "priority": 0,
        }
    )


def ticket_text(
    *,
    number: int = 1,
    slug: str = "deliver-outcome",
    prefix: str = "LR",
    feature: str = "loop-redesign",
    depends_on: list[str] | None = None,
    priority: int = 0,
    mode: str = "inherit",
    verification: list[Any] | None = None,
    strict_tdd: bool = False,
    tdd_command: str | None = None,
    likely_files: list[str] | None = None,
) -> str:
    metadata: dict[str, Any] = {
        "schema-version": 3,
        "kind": "ticket",
        "feature": feature,
        "ticket-prefix": prefix,
        "id": number,
        "slug": slug,
        "title": slug.replace("-", " ").title(),
        "depends-on": depends_on or [],
        "priority": priority,
        "mode": mode,
        "acceptance": ["The requested observable outcome is delivered."],
        "constraints": ["Preserve unrelated behavior."],
        "out-of-scope": ["Unrelated cleanup."],
        "verification": verification
        if verification is not None
        else ["python -c 'print(1)'"],
        "strict-tdd": strict_tdd,
        "implementation-hints": [],
        "likely-files": likely_files or [],
    }
    if tdd_command is not None:
        metadata["tdd-test-command"] = tdd_command
    return render_markdown(metadata, "## Context\n\nDeliver one outcome.")


class RepoCase(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        command(self.root, "git", "init", "-b", "topic")
        command(self.root, "git", "config", "user.name", "Test User")
        command(self.root, "git", "config", "user.email", "test@example.com")
        (self.root / "src").mkdir()
        (self.root / "src/app.py").write_text("VALUE = 0\n", encoding="utf-8")
        (self.root / "README.md").write_text("baseline\n", encoding="utf-8")
        command(self.root, "git", "add", "src/app.py", "README.md")
        command(self.root, "git", "commit", "-m", "initial")
        self.store = BoardStore(self.root)
        self.store.initialise()
        (self.store.features_dir / "loop-redesign.md").write_text(
            feature_text(), encoding="utf-8"
        )

    def tearDown(self) -> None:
        self.temporary.cleanup()

    def write_ticket(
        self,
        *,
        column: str = "ready",
        number: int = 1,
        slug: str = "deliver-outcome",
        **kwargs: Any,
    ) -> Path:
        key = f"LR-{number:02d}-{slug}"
        path = self.store.tickets_dir / column / f"{key}.md"
        path.write_text(
            ticket_text(number=number, slug=slug, **kwargs), encoding="utf-8"
        )
        return path


class ModelTests(RepoCase):
    def test_intent_ticket_needs_no_file_allowlist_or_commit_message(self) -> None:
        path = self.write_ticket(likely_files=["tests/test_app.py"])
        ticket = parse_ticket(path)
        self.assertEqual(ticket.key, "LR-01-deliver-outcome")
        self.assertEqual(ticket.likely_files, ("tests/test_app.py",))
        self.assertEqual(
            ticket.acceptance[0], "The requested observable outcome is delivered."
        )

    def test_strict_tdd_requires_a_command(self) -> None:
        path = self.write_ticket(strict_tdd=True)
        with self.assertRaisesRegex(KanbanError, "requires tdd-test-command"):
            parse_ticket(path)

    def test_feature_prefix_and_ticket_identity_must_agree(self) -> None:
        path = self.write_ticket()
        path.write_text(
            path.read_text().replace("ticket-prefix: LR", "ticket-prefix: XX")
        )
        with self.assertRaisesRegex(KanbanError, "identity fields disagree"):
            parse_ticket(path)

    def test_board_rejects_cycles(self) -> None:
        self.write_ticket(depends_on=["LR-02-second"])
        self.write_ticket(number=2, slug="second", depends_on=["LR-01-deliver-outcome"])
        with self.assertRaisesRegex(KanbanError, "dependency cycle"):
            self.store.load()

    def test_eligibility_uses_dependencies_then_priority(self) -> None:
        self.write_ticket(number=1, slug="first", priority=1)
        self.write_ticket(
            number=2, slug="second", priority=9, depends_on=["LR-01-first"]
        )
        board = self.store.load()
        self.assertEqual(
            [item.ticket.key for item in board.eligible()], ["LR-01-first"]
        )
        first = board.tickets["LR-01-first"]
        self.store.transition(first.ticket, "ready", "done")
        self.assertEqual(
            [item.ticket.key for item in self.store.load().eligible()], ["LR-02-second"]
        )

    def test_feature_completion_is_derived(self) -> None:
        self.write_ticket(column="done")
        self.assertEqual(
            feature_status(self.store.load(), "loop-redesign"), "completed"
        )
        self.write_ticket(number=2, slug="more")
        self.assertEqual(feature_status(self.store.load(), "loop-redesign"), "ready")

    def test_feature_status_is_blocked_when_ready_ticket_dependency_is_paused(
        self,
    ) -> None:
        self.write_ticket(column="paused", number=1, slug="first")
        (self.store.features_dir / "dependent-feature.md").write_text(
            feature_text("dependent-feature", "DF"), encoding="utf-8"
        )
        (self.store.tickets_dir / "ready/DF-01-second.md").write_text(
            ticket_text(
                number=1,
                slug="second",
                prefix="DF",
                feature="dependent-feature",
                depends_on=["LR-01-first"],
            ),
            encoding="utf-8",
        )
        self.assertEqual(
            feature_status(self.store.load(), "dependent-feature"), "blocked"
        )


class StorageTests(RepoCase):
    def test_initialise_adds_checkout_local_workflow_exclusion(self) -> None:
        exclude = Path(
            command(self.root, "git", "rev-parse", "--git-path", "info/exclude")
        )
        if not exclude.is_absolute():
            exclude = self.root / exclude
        self.assertIn("/.workflow/", exclude.read_text().splitlines())

    def test_individual_pause_survives_feature_resume(self) -> None:
        self.write_ticket(number=1, slug="one")
        self.write_ticket(number=2, slug="two")
        self.store.pause_ticket("LR-01-one")
        self.store.pause_feature("loop-redesign")
        self.store.resume_feature("loop-redesign")
        board = self.store.load()
        self.assertEqual(board.tickets["LR-01-one"].column, "paused")
        self.assertEqual(board.tickets["LR-02-two"].column, "ready")

    def test_feature_pause_preserves_completed_ticket(self) -> None:
        self.write_ticket(column="done", number=1, slug="done")
        self.write_ticket(number=2, slug="todo")
        keys = self.store.pause_feature("loop-redesign")
        self.assertEqual(keys, ["LR-02-todo"])
        board = self.store.load()
        self.assertEqual(board.tickets["LR-01-done"].column, "done")
        self.assertEqual(board.tickets["LR-02-todo"].column, "paused")

    def test_completed_feature_archives_and_restores(self) -> None:
        self.write_ticket(column="done")
        target = self.store.archive_feature("loop-redesign")
        self.assertTrue((target / "feature.md").exists())
        board = self.store.load()
        self.assertIn("loop-redesign", board.archived_features)
        self.assertIn("LR-01-deliver-outcome", board.completed_keys)
        self.store.restore_feature("loop-redesign")
        self.assertEqual(
            self.store.load().tickets["LR-01-deliver-outcome"].column, "done"
        )

    def test_cancelled_feature_cannot_archive(self) -> None:
        self.write_ticket(column="cancelled")
        with self.assertRaisesRegex(KanbanError, "only completed"):
            self.store.archive_feature("loop-redesign")

    def test_session_state_updates_atomically_and_events_persist(self) -> None:
        sessions = SessionStore(self.root)
        run_id = sessions.create({"ticket": "LR-01-x", "phase": "active"})
        state = sessions.save(run_id, {"phase": "review"})
        self.assertEqual(state["revision"], 1)
        events = (sessions.path(run_id) / "events.jsonl").read_text().splitlines()
        self.assertEqual(json.loads(events[0])["event"], "session-created")

    def test_session_lock_rejects_a_concurrent_writer(self) -> None:
        sessions = SessionStore(self.root)
        with (
            sessions.lock(),
            self.assertRaisesRegex(KanbanError, "Another kanban-loop"),
            sessions.lock(),
        ):
            self.fail("Concurrent lock unexpectedly succeeded")


class MigrationTests(RepoCase):
    def setUp(self) -> None:
        super().setUp()
        import shutil

        shutil.rmtree(self.store.root)
        for column in ("backlog", "doing", "paused", "done"):
            (self.store.root / column).mkdir(parents=True)

    def legacy_ticket(
        self, column: str, number: int, slug: str, *, prefixed: bool = True
    ) -> None:
        metadata = {
            "schema-version": 2,
            "feature": "legacy-feature",
            "ticket-prefix": "LF",
            "id": number,
            "slug": slug,
            "title": slug.replace("-", " ").title(),
            "language": "python",
            "depends-on": [],
            "human-required": column == "doing",
            "acceptance": "Legacy behavior remains represented.",
            "allowed-changes": [{"path": "src/app.py", "operation": "modify"}],
            "failing-tests": ["tests/test_app.py::test_behavior"],
            "tdd-test-command": "python -m unittest",
            "verification": [{"command": "python -c 'print(1)'", "expected-exit": 0}],
            "commit-message": "feat: legacy",
        }
        filename = (
            f"LF-{number:02d}-{slug}.md" if prefixed else f"{number:02d}-{slug}.md"
        )
        path = self.store.root / column / filename
        path.write_text(render_markdown(metadata, "Legacy context."), encoding="utf-8")

    def test_migration_preview_is_non_mutating(self) -> None:
        self.legacy_ticket("backlog", 1, "first")
        legacy_run = SessionStore(self.root).root / "runs/legacy-run"
        legacy_run.mkdir(parents=True)
        (legacy_run / "state.json").write_text("{}\n", encoding="utf-8")
        preview = migration_preview(self.store)
        self.assertEqual(preview["status"], "ready")
        self.assertTrue((self.store.root / "backlog/LF-01-first.md").exists())
        self.assertFalse(self.store.features_dir.exists())
        self.assertEqual(preview["legacy-runtime"]["runs"], ["legacy-run"])
        self.assertTrue(legacy_run.exists())

    def test_apply_migration_preserves_identity_and_pauses_active_work(self) -> None:
        self.legacy_ticket("backlog", 1, "first")
        self.legacy_ticket("doing", 2, "second")
        result = apply_migration(self.store)
        self.assertEqual(result["status"], "migrated")
        self.assertTrue(Path(result["backup"]).exists())
        board = self.store.load()
        self.assertEqual(board.tickets["LF-01-first"].column, "ready")
        self.assertEqual(board.tickets["LF-02-second"].column, "paused")
        self.assertEqual(board.tickets["LF-02-second"].ticket.mode, "hitl")
        key, destination = self.store.resume_ticket("LF-02-second", "migration")
        self.assertEqual((key, destination), ("LF-02-second", "ready"))

    def test_migration_rejects_duplicate_legacy_dependency_slugs(self) -> None:
        self.legacy_ticket("backlog", 1, "duplicate")
        self.legacy_ticket("done", 2, "duplicate")
        preview = migration_preview(self.store)
        self.assertEqual(preview["status"], "blocked")
        self.assertIn("ambiguous", "\n".join(preview["errors"]))

    def test_migration_adds_stable_prefix_to_legacy_unprefixed_filename(self) -> None:
        self.legacy_ticket("backlog", 1, "first", prefixed=False)
        result = apply_migration(self.store)
        self.assertEqual(result["status"], "migrated")
        self.assertIn("LF-01-first", self.store.load().tickets)

    def test_migration_restore_reinstates_v2_and_backs_up_v3(self) -> None:
        self.legacy_ticket("backlog", 1, "first")
        migrated = apply_migration(self.store)
        restored = restore_migration(self.store, migrated["backup"])
        self.assertEqual(restored["status"], "restored-schema-v2")
        self.assertTrue((self.store.root / "backlog/LF-01-first.md").exists())
        self.assertTrue(Path(restored["schema-v3-backup"]).exists())


class GitTests(RepoCase):
    def test_baseline_tolerates_unrelated_dirty_work(self) -> None:
        (self.root / "README.md").write_text("user work\n")
        baseline = gitops.capture_baseline(self.root)
        (self.root / "src/app.py").write_text("VALUE = 1\n")
        paths, overlap = gitops.session_delta(self.root, baseline)
        self.assertEqual(paths, {"src/app.py"})
        self.assertEqual(overlap, set())

    def test_modifying_preexisting_dirty_path_is_overlap(self) -> None:
        (self.root / "README.md").write_text("user work\n")
        baseline = gitops.capture_baseline(self.root)
        (self.root / "README.md").write_text("agent rewrote user work\n")
        _, overlap = gitops.session_delta(self.root, baseline)
        self.assertEqual(overlap, {"README.md"})

    def test_session_rejects_branch_change_even_when_head_is_unchanged(self) -> None:
        baseline = gitops.capture_baseline(self.root)
        command(self.root, "git", "switch", "-c", "other-topic")
        with self.assertRaisesRegex(KanbanError, "branch changed"):
            gitops.session_delta(self.root, baseline)

    def test_patch_shelving_and_restore(self) -> None:
        baseline = gitops.capture_baseline(self.root)
        (self.root / "src/app.py").write_text("VALUE = 2\n")
        patch = gitops.patch_for_paths(self.root, {"src/app.py"})
        patch_path = self.root / "saved.patch"
        patch_path.write_text(patch)
        gitops.restore_paths(self.root, {"src/app.py"}, baseline["base-commit"])
        self.assertEqual((self.root / "src/app.py").read_text(), "VALUE = 0\n")
        gitops.restore_patch(self.root, patch_path, {"src/app.py"})
        self.assertEqual((self.root / "src/app.py").read_text(), "VALUE = 2\n")

    def test_commit_contains_only_session_paths(self) -> None:
        (self.root / "README.md").write_text("user work\n")
        (self.root / "src/app.py").write_text("VALUE = 3\n")
        sha = gitops.commit_paths(self.root, {"src/app.py"}, "feat: update value")
        self.assertEqual(
            command(self.root, "git", "show", "--format=", "--name-only", sha),
            "src/app.py",
        )
        self.assertIn("README.md", command(self.root, "git", "status", "--short"))

    def test_verification_worktree_mutation_is_reported_with_results(self) -> None:
        with self.assertRaises(gitops.CommandFailure) as caught:
            gitops.run_verification(
                self.root,
                [
                    {
                        "command": 'python -c \'from pathlib import Path; Path("generated.txt").write_text("side effect")\'',
                        "expected-exit": 0,
                        "required": True,
                    }
                ],
            )
        self.assertEqual(
            caught.exception.diagnostics["reason"],
            "verification-mutated-worktree",
        )
        self.assertEqual(
            caught.exception.diagnostics["changed-paths"], ["generated.txt"]
        )
        self.assertEqual(caught.exception.diagnostics["results"][0]["exit"], 0)


class ProviderTests(unittest.TestCase):
    def implementer(self, **updates: Any) -> dict[str, Any]:
        value = {
            "status": "complete",
            "summary": "done",
            "files_changed": [],
            "verification_commands": [],
            "proposed_commit_message": "feat: deliver outcome",
            "assumptions": [],
            "scope_notes": [],
            "blocker": None,
        }
        value.update(updates)
        return value

    def test_last_schema_valid_candidate_wins_and_candidates_are_retained(self) -> None:
        invalid = {"status": "complete"}
        final = self.implementer(summary="final")
        parsed, candidates = parse_agent_result(
            json.dumps(invalid) + "\n" + json.dumps(final), IMPLEMENTER_SCHEMA
        )
        self.assertEqual(parsed["summary"], "final")
        self.assertFalse(candidates[0]["valid"])
        self.assertTrue(candidates[-1]["valid"])

    def test_missing_fields_are_reported_before_failure(self) -> None:
        with self.assertRaises(ProviderFailure) as raised:
            parse_agent_result('{"status":"complete"}', IMPLEMENTER_SCHEMA)
        diagnostics = raised.exception.diagnostics
        self.assertIn("missing fields", diagnostics["candidates"][0]["error"])
        self.assertIn("raw-output", diagnostics)

    def test_ambiguous_prose_cannot_authorize(self) -> None:
        with self.assertRaises(ProviderFailure):
            parse_agent_result("Looks good, probably complete.", IMPLEMENTER_SCHEMA)

    def test_explicit_labelled_prose_is_normalized(self) -> None:
        parsed, candidates = parse_agent_result(
            "Implementation finished.\nStatus: complete", IMPLEMENTER_SCHEMA
        )
        self.assertEqual(parsed["status"], "complete")
        self.assertEqual(candidates[-1]["source"], "labelled-prose")

    def test_final_valid_result_wins_over_earlier_provider_error(self) -> None:
        raw = '{"type":"error","error":"transient"}\n' + json.dumps(self.implementer())
        parsed, _ = parse_agent_result(raw, IMPLEMENTER_SCHEMA)
        self.assertEqual(parsed["status"], "complete")

    def test_adapter_capabilities_are_explicit(self) -> None:
        for adapter in (ClaudeAdapter(), CodexAdapter(), OpenCodeAdapter()):
            capabilities = adapter.capabilities()
            self.assertTrue(capabilities["writable-execution"])
            self.assertTrue(capabilities["read-only-review"])
            self.assertIn("session-resume", capabilities)


class FakeAdapter:
    name = "fake"
    executable = "fake"

    def __init__(
        self,
        root: Path,
        steps: list[tuple[str, dict[str, Any], Callable[[Any], None] | None]],
    ) -> None:
        self.root = root
        self.steps = list(steps)
        self.calls: list[str] = []

    def run(self, request: Any) -> AgentResult:
        if not self.steps:
            raise AssertionError(f"Unexpected provider call: {request.role}")
        role, data, callback = self.steps.pop(0)
        if role != request.role:
            raise AssertionError(f"Expected {role}, got {request.role}")
        self.calls.append(role)
        if callback:
            callback(request)
        raw = json.dumps(data)
        return AgentResult(
            data, raw, raw, "", ("fake", role), ({"value": data, "valid": True},)
        )


def implementer_result(
    *,
    status: str = "complete",
    blocker: str | None = None,
    message: str = "feat: deliver outcome",
) -> dict[str, Any]:
    return {
        "status": status,
        "summary": "implemented" if status == "complete" else "needs a decision",
        "files_changed": ["src/app.py"] if status == "complete" else [],
        "verification_commands": [],
        "proposed_commit_message": message if status == "complete" else None,
        "assumptions": [],
        "scope_notes": ["Production code was required."],
        "blocker": blocker,
    }


def review_result(verdict: str = "accept", blocking: bool = False) -> dict[str, Any]:
    findings = []
    if verdict != "accept" or blocking:
        findings = [
            {
                "id": "R1",
                "classification": "blocking" if blocking else "advisory",
                "category": "correctness" if blocking else "maintainability",
                "summary": "Needs correction" if blocking else "Optional improvement",
                "evidence": "Observed in patch",
                "path": "src/app.py",
                "required_outcome": "Correct it" if blocking else None,
            }
        ]
    return {
        "verdict": verdict,
        "summary": verdict,
        "findings": findings,
        "assumptions": [],
    }


class EngineTests(RepoCase):
    def engine(self, adapter: FakeAdapter) -> Engine:
        engine = Engine(self.root)
        engine.provider = lambda state=None: adapter  # type: ignore[method-assign]
        return engine

    def change_value(self, value: int) -> Callable[[Any], None]:
        def callback(_: Any) -> None:
            (self.root / "src/app.py").write_text(
                f"VALUE = {value}\n", encoding="utf-8"
            )

        return callback

    def test_new_run_rejects_another_active_implementation_session(self) -> None:
        self.write_ticket(column="active", number=1, slug="first")
        self.write_ticket(number=2, slug="second")
        sessions = SessionStore(self.root)
        sessions.create(
            {
                "ticket": "LR-01-first",
                "phase": "implementing",
                "baseline": gitops.capture_baseline(self.root),
            }
        )
        engine = Engine(self.root)
        with self.assertRaisesRegex(KanbanError, "active implementation session"):
            engine.start(
                ticket_ref=None,
                feature=None,
                all_tickets=True,
                mode="hitl",
                branch=None,
                max_attempts=3,
            )

    def test_hitl_discovers_production_scope_not_listed_by_ticket(self) -> None:
        self.write_ticket(likely_files=["tests/test_app.py"])
        adapter = FakeAdapter(
            self.root,
            [
                ("implementer", implementer_result(), self.change_value(1)),
                ("reviewer", review_result(), None),
            ],
        )
        result = self.engine(adapter).start(
            ticket_ref=None,
            feature=None,
            all_tickets=True,
            mode="hitl",
            branch=None,
            max_attempts=3,
        )
        self.assertEqual(result["status"], "awaiting-review")
        self.assertEqual(result["review-packet"]["changed-files"], ["src/app.py"])

    def test_hitl_revision_can_expand_to_another_file(self) -> None:
        self.write_ticket()

        def revision(_: Any) -> None:
            (self.root / "src/app.py").write_text("VALUE = 2\n")
            (self.root / "docs.md").write_text("supporting detail\n")

        adapter = FakeAdapter(
            self.root,
            [
                ("implementer", implementer_result(), self.change_value(1)),
                ("reviewer", review_result(), None),
                (
                    "implementer",
                    implementer_result(message="refactor: use peek"),
                    revision,
                ),
                ("reviewer", review_result(), None),
            ],
        )
        engine = self.engine(adapter)
        initial = engine.start(
            ticket_ref=None,
            feature=None,
            all_tickets=True,
            mode="hitl",
            branch=None,
            max_attempts=3,
        )
        revised = engine.review_action(
            initial["run-id"],
            "revise",
            feedback="Use peek instead of map and update docs.",
        )
        self.assertEqual(revised["status"], "awaiting-review")
        self.assertEqual(
            revised["review-packet"]["changed-files"], ["docs.md", "src/app.py"]
        )

    def test_approve_commits_descriptive_message_and_completes_ticket(self) -> None:
        self.write_ticket()
        adapter = FakeAdapter(
            self.root,
            [
                (
                    "implementer",
                    implementer_result(message="refactor: use peek for lazy traversal"),
                    self.change_value(1),
                ),
                ("reviewer", review_result(), None),
            ],
        )
        engine = self.engine(adapter)
        candidate = engine.start(
            ticket_ref=None,
            feature=None,
            all_tickets=True,
            mode="hitl",
            branch=None,
            max_attempts=3,
        )
        result = engine.review_action(candidate["run-id"], "approve")
        self.assertEqual(result["status"], "completed")
        self.assertEqual(
            command(self.root, "git", "log", "-1", "--pretty=%s"),
            "refactor: use peek for lazy traversal",
        )
        self.assertEqual(
            self.store.load().tickets["LR-01-deliver-outcome"].column, "done"
        )

    def test_commit_fallback_uses_title_without_local_ticket_key(self) -> None:
        self.write_ticket()
        adapter = FakeAdapter(
            self.root,
            [
                (
                    "implementer",
                    implementer_result(message=None),
                    self.change_value(1),
                ),
                ("reviewer", review_result(), None),
            ],
        )
        engine = self.engine(adapter)
        candidate = engine.start(
            ticket_ref=None,
            feature=None,
            all_tickets=True,
            mode="hitl",
            branch=None,
            max_attempts=3,
        )
        result = engine.review_action(candidate["run-id"], "approve")
        self.assertEqual(result["commit-message"], "Deliver Outcome")
        self.assertNotIn("LR-01", result["commit-message"])

    def test_interrupted_matching_commit_is_completed_without_duplicate(self) -> None:
        self.write_ticket()
        adapter = FakeAdapter(
            self.root,
            [
                ("implementer", implementer_result(), self.change_value(6)),
                ("reviewer", review_result(), None),
            ],
        )
        engine = self.engine(adapter)
        candidate = engine.start(
            ticket_ref=None,
            feature=None,
            all_tickets=True,
            mode="hitl",
            branch=None,
            max_attempts=3,
        )
        sessions = SessionStore(self.root)
        state = sessions.load(candidate["run-id"])
        pre_commit_head = gitops.current_head(self.root)
        message = state["proposed-commit-message"]
        sessions.save(
            candidate["run-id"],
            {
                "phase": "committing",
                "pre-commit-head": pre_commit_head,
                "commit-message": message,
            },
        )
        commit_sha = gitops.commit_paths(self.root, state["session-paths"], message)
        recovered = engine.start(
            ticket_ref="LR-01-deliver-outcome",
            feature=None,
            all_tickets=False,
            mode="hitl",
            branch=None,
            max_attempts=3,
        )
        self.assertEqual(recovered["status"], "completed")
        self.assertEqual(recovered["commit"], commit_sha)
        self.assertEqual(command(self.root, "git", "rev-list", "--count", "HEAD"), "2")
        self.assertEqual(
            self.store.load().tickets["LR-01-deliver-outcome"].column, "done"
        )

    def test_hitl_feature_scope_continues_after_approved_commit(self) -> None:
        self.write_ticket(number=1, slug="first")
        self.write_ticket(number=2, slug="second", depends_on=["LR-01-first"])
        adapter = FakeAdapter(
            self.root,
            [
                ("implementer", implementer_result(), self.change_value(1)),
                ("reviewer", review_result(), None),
                ("implementer", implementer_result(), self.change_value(2)),
                ("reviewer", review_result(), None),
            ],
        )
        engine = self.engine(adapter)
        first = engine.start(
            ticket_ref=None,
            feature="loop-redesign",
            all_tickets=False,
            mode="hitl",
            branch=None,
            max_attempts=3,
        )
        completed = engine.review_action(first["run-id"], "approve")
        second = engine.continue_scope(completed)
        self.assertEqual(second["status"], "awaiting-review")
        self.assertEqual(second["review-packet"]["ticket"], "LR-02-second")

    def test_cancel_preserves_reason_and_does_not_complete_feature(self) -> None:
        self.write_ticket()
        adapter = FakeAdapter(
            self.root,
            [
                ("implementer", implementer_result(), self.change_value(1)),
                ("reviewer", review_result(), None),
            ],
        )
        engine = self.engine(adapter)
        candidate = engine.start(
            ticket_ref=None,
            feature=None,
            all_tickets=True,
            mode="hitl",
            branch=None,
            max_attempts=3,
        )
        cancelled = engine.review_action(
            candidate["run-id"], "cancel", reason="Requirement withdrawn"
        )
        self.assertEqual(cancelled["status"], "cancelled")
        board = self.store.load()
        self.assertEqual(board.tickets["LR-01-deliver-outcome"].column, "cancelled")
        self.assertEqual(
            feature_status(board, "loop-redesign"), "closed-with-cancellations"
        )
        state = SessionStore(self.root).load(candidate["run-id"])
        self.assertEqual(state["termination-reason"], "Requirement withdrawn")
        ticket_status = Engine(self.root).status()["tickets"][0]
        self.assertEqual(ticket_status["cancellation-reason"], "Requirement withdrawn")

    def test_failed_verification_requires_explicit_override(self) -> None:
        self.write_ticket(verification=["python -c 'raise SystemExit(1)'"])
        adapter = FakeAdapter(
            self.root,
            [
                ("implementer", implementer_result(), self.change_value(1)),
                ("reviewer", review_result(), None),
            ],
        )
        engine = self.engine(adapter)
        candidate = engine.start(
            ticket_ref=None,
            feature=None,
            all_tickets=True,
            mode="hitl",
            branch=None,
            max_attempts=3,
        )
        with self.assertRaisesRegex(KanbanError, "use override"):
            engine.review_action(candidate["run-id"], "approve")
        result = engine.review_action(
            candidate["run-id"], "override", reason="Known environment-only failure"
        )
        self.assertEqual(result["status"], "completed")
        state = SessionStore(self.root).load(candidate["run-id"])
        self.assertEqual(state["override"]["reason"], "Known environment-only failure")

    def test_ticket_verification_cannot_run_git_or_remote_tools(self) -> None:
        self.write_ticket(verification=["git status --short"])
        adapter = FakeAdapter(
            self.root,
            [
                ("implementer", implementer_result(), self.change_value(1)),
                ("reviewer", review_result(), None),
            ],
        )
        candidate = self.engine(adapter).start(
            ticket_ref=None,
            feature=None,
            all_tickets=True,
            mode="hitl",
            branch=None,
            max_attempts=3,
        )
        evidence = candidate["review-packet"]["verification"]
        self.assertFalse(candidate["review-packet"]["verification-passed"])
        self.assertTrue(evidence[0]["not-run"])
        self.assertIn("integration tool", evidence[0]["reason"])

    def test_auto_blocker_shelves_work_and_marks_ticket_blocked(self) -> None:
        self.write_ticket()
        adapter = FakeAdapter(
            self.root,
            [
                (
                    "implementer",
                    implementer_result(status="blocked", blocker="Choose a public API"),
                    None,
                )
            ],
        )
        result = self.engine(adapter).start(
            ticket_ref=None,
            feature=None,
            all_tickets=True,
            mode="auto",
            branch=None,
            max_attempts=3,
        )
        self.assertEqual(result["status"], "blocked")
        self.assertEqual(
            self.store.load().tickets["LR-01-deliver-outcome"].column, "blocked"
        )

    def test_auto_revises_blocking_review_then_commits(self) -> None:
        self.write_ticket()
        adapter = FakeAdapter(
            self.root,
            [
                ("implementer", implementer_result(), self.change_value(1)),
                ("reviewer", review_result("revise", blocking=True), None),
                (
                    "implementer",
                    implementer_result(message="fix: correct outcome"),
                    self.change_value(2),
                ),
                ("reviewer", review_result(), None),
            ],
        )
        result = self.engine(adapter).start(
            ticket_ref=None,
            feature=None,
            all_tickets=True,
            mode="auto",
            branch=None,
            max_attempts=3,
        )
        self.assertEqual(result["status"], "completed")
        self.assertEqual(
            adapter.calls, ["implementer", "reviewer", "implementer", "reviewer"]
        )

    def test_strict_tdd_records_red_before_implementation(self) -> None:
        self.write_ticket(
            strict_tdd=True,
            tdd_command="python -c 'print(\"AssertionError\"); raise SystemExit(1)'",
        )

        def write_test(_: Any) -> None:
            (self.root / "tests").mkdir()
            (self.root / "tests/test_app.py").write_text(
                "def test_value(): assert False\n", encoding="utf-8"
            )

        adapter = FakeAdapter(
            self.root,
            [
                ("implementer-tests", implementer_result(), write_test),
                ("implementer", implementer_result(), self.change_value(1)),
                ("reviewer", review_result(), None),
            ],
        )
        result = self.engine(adapter).start(
            ticket_ref=None,
            feature=None,
            all_tickets=True,
            mode="hitl",
            branch=None,
            max_attempts=3,
        )
        self.assertEqual(result["status"], "awaiting-review")
        red_path = (
            SessionStore(self.root).path(result["run-id"]) / "attempt-01-red.json"
        )
        self.assertTrue(red_path.exists())
        self.assertEqual(adapter.calls[0], "implementer-tests")

    def test_review_pause_shelves_and_resume_restores_patch(self) -> None:
        self.write_ticket()
        adapter = FakeAdapter(
            self.root,
            [
                ("implementer", implementer_result(), self.change_value(7)),
                ("reviewer", review_result(), None),
            ],
        )
        engine = self.engine(adapter)
        candidate = engine.start(
            ticket_ref=None,
            feature=None,
            all_tickets=True,
            mode="hitl",
            branch=None,
            max_attempts=3,
        )
        engine.review_action(candidate["run-id"], "pause")
        self.assertEqual((self.root / "src/app.py").read_text(), "VALUE = 0\n")
        resumed = engine.resume("LR-01-deliver-outcome")
        self.assertEqual(resumed["status"], "awaiting-review")
        self.assertEqual((self.root / "src/app.py").read_text(), "VALUE = 7\n")

    def test_feature_pause_and_resume_restores_review_session(self) -> None:
        self.write_ticket()
        adapter = FakeAdapter(
            self.root,
            [
                ("implementer", implementer_result(), self.change_value(8)),
                ("reviewer", review_result(), None),
            ],
        )
        engine = self.engine(adapter)
        candidate = engine.start(
            ticket_ref=None,
            feature=None,
            all_tickets=True,
            mode="hitl",
            branch=None,
            max_attempts=3,
        )
        paused = engine.pause_feature("loop-redesign")
        self.assertEqual(paused["status"], "paused")
        self.assertEqual((self.root / "src/app.py").read_text(), "VALUE = 0\n")
        resumed = engine.resume_feature("loop-redesign")
        self.assertEqual(resumed["tickets"][0]["status"], "awaiting-review")
        self.assertEqual((self.root / "src/app.py").read_text(), "VALUE = 8\n")
        self.assertEqual(
            SessionStore(self.root).load(candidate["run-id"])["phase"],
            "awaiting-review",
        )

    def test_feature_resume_preserves_independent_ticket_pause(self) -> None:
        self.write_ticket()
        adapter = FakeAdapter(
            self.root,
            [
                ("implementer", implementer_result(), self.change_value(9)),
                ("reviewer", review_result(), None),
            ],
        )
        engine = self.engine(adapter)
        candidate = engine.start(
            ticket_ref=None,
            feature=None,
            all_tickets=True,
            mode="hitl",
            branch=None,
            max_attempts=3,
        )
        engine.review_action(candidate["run-id"], "pause")
        engine.pause_feature("loop-redesign")
        resumed_feature = engine.resume_feature("loop-redesign")
        self.assertEqual(resumed_feature["tickets"][0]["status"], "paused")
        self.assertEqual((self.root / "src/app.py").read_text(), "VALUE = 0\n")
        resumed_ticket = engine.resume("LR-01-deliver-outcome")
        self.assertEqual(resumed_ticket["status"], "awaiting-review")
        self.assertEqual((self.root / "src/app.py").read_text(), "VALUE = 9\n")

    def test_feature_pause_and_resume_unblocks_saved_session(self) -> None:
        self.write_ticket()
        adapter = FakeAdapter(
            self.root,
            [
                (
                    "implementer",
                    implementer_result(status="blocked", blocker="Need a choice"),
                    None,
                )
            ],
        )
        engine = self.engine(adapter)
        blocked = engine.start(
            ticket_ref=None,
            feature=None,
            all_tickets=True,
            mode="auto",
            branch=None,
            max_attempts=3,
        )
        self.assertEqual(blocked["status"], "blocked")
        engine.pause_feature("loop-redesign")
        resumed = engine.resume_feature("loop-redesign")
        self.assertEqual(resumed["tickets"][0]["status"], "active")
        self.assertEqual(
            self.store.load().tickets["LR-01-deliver-outcome"].column, "active"
        )

    def test_blocked_session_can_resume_with_human_feedback(self) -> None:
        self.write_ticket()
        adapter = FakeAdapter(
            self.root,
            [
                (
                    "implementer",
                    implementer_result(status="blocked", blocker="Choose behavior"),
                    self.change_value(1),
                ),
                ("implementer", implementer_result(), self.change_value(2)),
                ("reviewer", review_result(), None),
            ],
        )
        engine = self.engine(adapter)
        blocked = engine.start(
            ticket_ref=None,
            feature=None,
            all_tickets=True,
            mode="auto",
            branch=None,
            max_attempts=3,
        )
        self.assertEqual(blocked["status"], "blocked")
        resumed = engine.review_action(
            blocked["run-id"],
            "revise",
            feedback="Use the backward-compatible behavior.",
        )
        self.assertEqual(resumed["status"], "awaiting-review")

    def test_provider_failure_is_persisted_before_exception(self) -> None:
        self.write_ticket()
        self.store.config_path.write_text("provider-retries: 0\n", encoding="utf-8")
        root = self.root

        class BrokenAdapter:
            name = "broken"

            def run(self, request: Any) -> AgentResult:
                (root / "src/app.py").write_text("VALUE = 12\n", encoding="utf-8")
                raise ProviderFailure(
                    "missing authority data",
                    {
                        "raw-output": '{"status":"complete"}',
                        "candidates": [
                            {"valid": False, "error": "missing fields ['summary']"}
                        ],
                    },
                )

        engine = Engine(self.root)
        engine.provider = lambda state=None: BrokenAdapter()  # type: ignore[method-assign]
        with self.assertRaisesRegex(KanbanError, "diagnostics"):
            engine.start(
                ticket_ref=None,
                feature=None,
                all_tickets=True,
                mode="hitl",
                branch=None,
                max_attempts=3,
            )
        failures = list(SessionStore(self.root).failures.glob("*.json"))
        self.assertGreaterEqual(len(failures), 1)
        combined = "\n".join(path.read_text() for path in failures)
        self.assertIn("missing fields", combined)
        self.assertIn("raw-output", combined)
        self.assertIn("patch-hash", combined)
        self.assertIn("src/app.py", combined)

    def test_interruption_shelves_patch_and_records_resumable_block(self) -> None:
        self.write_ticket()
        root = self.root

        class InterruptedAdapter:
            name = "interrupted"

            def run(self, request: Any) -> AgentResult:
                (root / "src/app.py").write_text("VALUE = 13\n", encoding="utf-8")
                raise KeyboardInterrupt

        engine = Engine(self.root)
        engine.provider = lambda state=None: InterruptedAdapter()  # type: ignore[method-assign]
        with self.assertRaises(KeyboardInterrupt):
            engine.start(
                ticket_ref=None,
                feature=None,
                all_tickets=True,
                mode="hitl",
                branch=None,
                max_attempts=3,
            )
        self.assertEqual((self.root / "src/app.py").read_text(), "VALUE = 0\n")
        ticket = self.store.load().tickets["LR-01-deliver-outcome"]
        self.assertEqual(ticket.column, "blocked")
        run_id, state = SessionStore(self.root).active_for_ticket(
            ticket.ticket.key
        ) or (
            None,
            {},
        )
        self.assertIsNotNone(run_id)
        self.assertEqual(state["phase"], "blocked")
        self.assertTrue(state["shelf-patch"])

    def test_ticket_edit_is_reconciled_instead_of_treated_as_corruption(self) -> None:
        ticket_path = self.write_ticket()

        def edit_code_and_ticket(_: Any) -> None:
            self.change_value(4)(None)
            text = ticket_path.parent.parent.joinpath(
                "active", ticket_path.name
            ).read_text()
            active_path = ticket_path.parent.parent / "active" / ticket_path.name
            active_path.write_text(
                text.replace("requested observable", "amended observable")
            )

        adapter = FakeAdapter(
            self.root,
            [
                ("implementer", implementer_result(), edit_code_and_ticket),
                ("reviewer", review_result(), None),
            ],
        )
        engine = self.engine(adapter)
        result = engine.start(
            ticket_ref=None,
            feature=None,
            all_tickets=True,
            mode="hitl",
            branch=None,
            max_attempts=3,
        )
        self.assertEqual(result["status"], "awaiting-amendment")
        incorporated = engine.review_action(result["run-id"], "incorporate")
        self.assertEqual(incorporated["status"], "awaiting-review")

    def test_ticket_edit_at_review_defers_approval_for_reconciliation(self) -> None:
        self.write_ticket()
        adapter = FakeAdapter(
            self.root,
            [
                ("implementer", implementer_result(), self.change_value(5)),
                ("reviewer", review_result(), None),
            ],
        )
        engine = self.engine(adapter)
        candidate = engine.start(
            ticket_ref=None,
            feature=None,
            all_tickets=True,
            mode="hitl",
            branch=None,
            max_attempts=3,
        )
        ticket = self.store.load().tickets["LR-01-deliver-outcome"].ticket.path
        ticket.write_text(
            ticket.read_text().replace("requested observable", "edited observable"),
            encoding="utf-8",
        )
        result = engine.review_action(candidate["run-id"], "approve")
        self.assertEqual(result["status"], "awaiting-amendment")
        self.assertEqual(
            SessionStore(self.root).load(candidate["run-id"])["phase"],
            "awaiting-amendment",
        )

    def test_read_only_investigation_does_not_change_candidate(self) -> None:
        self.write_ticket()
        investigation = {
            "status": "complete",
            "summary": "The change is lazy.",
            "evidence": ["src/app.py"],
            "blocker": None,
        }
        adapter = FakeAdapter(
            self.root,
            [
                ("implementer", implementer_result(), self.change_value(1)),
                ("reviewer", review_result(), None),
                ("investigator", investigation, None),
            ],
        )
        engine = self.engine(adapter)
        candidate = engine.start(
            ticket_ref=None,
            feature=None,
            all_tickets=True,
            mode="hitl",
            branch=None,
            max_attempts=3,
        )
        result = engine.review_action(
            candidate["run-id"], "ask", feedback="Is this lazy?"
        )
        self.assertEqual(result["result"]["summary"], "The change is lazy.")
        self.assertEqual((self.root / "src/app.py").read_text(), "VALUE = 1\n")

    def test_status_explains_dependency_blockers(self) -> None:
        self.write_ticket(number=1, slug="first", column="paused")
        self.write_ticket(number=2, slug="second", depends_on=["LR-01-first"])
        status = Engine(self.root).status()
        second = next(
            item for item in status["tickets"] if item["key"] == "LR-02-second"
        )
        self.assertEqual(second["state"], "blocked")
        self.assertEqual(second["unresolved-dependencies"], ["LR-01-first"])

    def test_status_reports_effective_policy_values_and_sources(self) -> None:
        self.write_ticket()
        self.store.config_path.write_text(
            "max-attempts: 5\nprotected-branches: [release]\n", encoding="utf-8"
        )
        status = Engine(self.root).status()
        effective = status["effective-config"]
        self.assertEqual(effective["values"]["max-attempts"], 5)
        self.assertEqual(
            effective["values"]["protected-branches"],
            ["develop", "main", "master", "release"],
        )
        self.assertEqual(effective["sources"]["provider"], "built-in")
        self.assertIn("config.yaml", effective["sources"]["max-attempts"])
        ticket = next(
            item for item in status["tickets"] if item["key"].startswith("LR")
        )
        self.assertIn("tickets/ready", ticket["policy"]["mode"]["source"])


class CliTests(RepoCase):
    def test_plan_is_read_only_and_reports_eligibility(self) -> None:
        self.write_ticket()
        args = parser().parse_args(["plan"])
        result = execute(args, self.root)
        self.assertFalse(result["mutation"])
        self.assertEqual(result["eligible"], ["LR-01-deliver-outcome"])

    def test_pause_requires_exactly_one_target_kind(self) -> None:
        args = parser().parse_args(["pause"])
        with self.assertRaisesRegex(KanbanError, "requires ticket references"):
            execute(args, self.root)


if __name__ == "__main__":
    unittest.main()
