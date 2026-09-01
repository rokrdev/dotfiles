"""Command-line interface for the local Kanban delivery engine."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from .engine import Engine
from .model import KanbanError
from .providers import ADAPTERS, redact
from .storage import BoardStore, SessionStore, repository_root


def parser() -> argparse.ArgumentParser:
    root = argparse.ArgumentParser(
        prog="kanban-loop",
        description="Intent-based local delivery workflow for coding agents.",
    )
    root.add_argument("--version", action="version", version="kanban-loop 3")
    commands = root.add_subparsers(dest="command", required=True)
    commands.add_parser("init", help="Create an empty local schema-v3 board")
    commands.add_parser("validate", help="Validate local board structure and contracts")
    commands.add_parser("status", help="Explain board, blockers, sessions, and policy")
    commands.add_parser("plan", help="Preview eligibility without mutation")

    run = commands.add_parser("run", help="Run one serial delivery scope")
    target = run.add_mutually_exclusive_group()
    target.add_argument("--ticket", metavar="KEY")
    target.add_argument("--feature", metavar="SLUG")
    target.add_argument("--all", action="store_true", dest="all_tickets")
    run.add_argument("--mode", choices=["hitl", "auto"], default="hitl")
    run.add_argument("--provider", choices=["auto", *ADAPTERS], default="auto")
    run.add_argument("--model")
    run.add_argument("--branch")
    run.add_argument("--max-attempts", type=int)

    for name in ("pause", "resume"):
        command = commands.add_parser(name, help=f"{name.title()} tickets or a feature")
        command.add_argument("tickets", nargs="*")
        command.add_argument("--feature")
        if name == "resume":
            command.add_argument("--feedback")

    review = commands.add_parser("review", aliases=["decide"], help="Act on a session")
    review.add_argument("run_id")
    review.add_argument(
        "action",
        choices=[
            "approve",
            "revise",
            "ask",
            "override",
            "pause",
            "abandon",
            "cancel",
            "incorporate",
            "defer",
            "restart",
        ],
    )
    review.add_argument("--feedback")
    review.add_argument("--reason")
    review.add_argument("--message", help="Conventional Commit subject override")
    review.add_argument("--provider", choices=["auto", *ADAPTERS], default="auto")
    review.add_argument("--model")

    migrate = commands.add_parser(
        "migrate", help="Preview or apply schema-v2 migration"
    )
    migration_action = migrate.add_mutually_exclusive_group()
    migration_action.add_argument("--apply", action="store_true")
    migration_action.add_argument("--restore", metavar="BACKUP")
    archive = commands.add_parser("archive", help="Archive a completed feature")
    archive.add_argument("feature")
    restore = commands.add_parser("restore", help="Restore an archived feature")
    restore.add_argument("feature")
    prune = commands.add_parser(
        "prune", help="Preview or prune bulky completed evidence"
    )
    prune.add_argument("--apply", action="store_true")
    commands.add_parser(
        "providers", help="Report provider availability and capabilities"
    )
    return root


def _print(value: Any) -> None:
    print(json.dumps(value, indent=2, sort_keys=True))


def _requires_lock(args: argparse.Namespace) -> bool:
    if args.command in {
        "run",
        "pause",
        "resume",
        "review",
        "decide",
        "archive",
        "restore",
        "init",
    }:
        return True
    if args.command in {"migrate", "prune"}:
        return bool(args.apply or getattr(args, "restore", None))
    return False


def _continue(engine: Engine, result: dict[str, Any]) -> dict[str, Any]:
    current = result
    while (
        current.get("status") == "completed"
        and current.get("scope", {}).get("kind") != "ticket"
    ):
        current = engine.continue_scope(current)
    return current


def execute(args: argparse.Namespace, repo: Path) -> dict[str, Any]:
    if args.command == "init":
        store = BoardStore(repo)
        if store.legacy_columns():
            raise KanbanError(
                "Legacy board exists; preview it with `kanban-loop migrate`"
            )
        store.initialise()
        return {"status": "initialised", "schema-version": 3, "path": str(store.root)}
    if args.command == "providers":
        values = []
        for name, adapter_type in ADAPTERS.items():
            adapter = adapter_type()
            values.append(
                {
                    "provider": name,
                    "executable": adapter.executable,
                    "available": adapter.available(),
                    "capabilities": adapter.capabilities(),
                }
            )
        return {"providers": values}
    provider = getattr(args, "provider", "auto")
    model = getattr(args, "model", None)
    engine = Engine(repo, provider_name=provider, model=model)
    if args.command == "validate":
        return engine.validate()
    if args.command in {"status", "plan"}:
        status = engine.status()
        if args.command == "plan":
            board = engine.board.load()
            status = {
                **status,
                "eligible": [item.ticket.key for item in board.eligible()],
                "mutation": False,
            }
        return status
    if args.command == "run":
        configured_attempts = engine.board.config().get("max-attempts", 3)
        max_attempts = args.max_attempts or configured_attempts
        if not isinstance(max_attempts, int) or isinstance(max_attempts, bool):
            raise KanbanError("max-attempts must be an integer")
        if max_attempts < 1:
            raise KanbanError("--max-attempts must be positive")
        result = engine.start(
            ticket_ref=args.ticket,
            feature=args.feature,
            all_tickets=args.all_tickets or not (args.ticket or args.feature),
            mode=args.mode,
            branch=args.branch,
            max_attempts=max_attempts,
        )
        return _continue(engine, result) if args.mode == "auto" else result
    if args.command == "pause":
        if bool(args.feature) == bool(args.tickets):
            raise KanbanError(
                "pause requires ticket references or exactly one --feature"
            )
        if args.feature:
            return engine.pause_feature(args.feature)
        return {
            "status": "paused",
            "tickets": [engine.pause(item) for item in args.tickets],
        }
    if args.command == "resume":
        if bool(args.feature) == bool(args.tickets):
            raise KanbanError(
                "resume requires ticket references or exactly one --feature"
            )
        if args.feature:
            return engine.resume_feature(args.feature)
        return {
            "status": "resumed",
            "tickets": [engine.resume(item, args.feedback) for item in args.tickets],
        }
    if args.command in {"review", "decide"}:
        result = engine.review_action(
            args.run_id,
            args.action,
            feedback=args.feedback,
            reason=args.reason,
            message=args.message,
        )
        return (
            _continue(engine, result) if result.get("status") == "completed" else result
        )
    if args.command == "migrate":
        return engine.migrate(apply=args.apply, restore=args.restore)
    if args.command == "archive":
        return engine.archive(args.feature)
    if args.command == "restore":
        return engine.restore_archive(args.feature)
    if args.command == "prune":
        return engine.prune(apply=args.apply)
    raise KanbanError(f"Unknown command: {args.command}")


def main(argv: list[str] | None = None) -> int:
    args = parser().parse_args(argv)
    run_id = getattr(args, "run_id", None)
    try:
        repo = repository_root(Path.cwd())
        if _requires_lock(args):
            with SessionStore(repo).lock():
                result = execute(args, repo)
        else:
            result = execute(args, repo)
        _print(result)
        return 0
    except (Exception, KeyboardInterrupt) as error:  # noqa: BLE001 - failure boundary
        message = "Interrupted" if isinstance(error, KeyboardInterrupt) else str(error)
        failure_path: Path | None = None
        try:
            repo = repository_root(Path.cwd())
            sessions = SessionStore(repo)
            failure_path = sessions.record_failure(
                redact(
                    {
                        "phase": f"cli:{getattr(args, 'command', 'unknown')}",
                        "run-id": run_id,
                        "error-type": type(error).__name__,
                        "message": message,
                        "traceback": "".join(
                            __import__("traceback").format_exception(
                                type(error), error, error.__traceback__
                            )
                        ),
                        "diagnostics": getattr(error, "diagnostics", {}),
                        "cwd": str(Path.cwd()),
                    }
                )
            )
        except Exception:  # noqa: BLE001 - diagnostics must not mask original error
            failure_path = None
        print(f"ERROR: {message}", file=sys.stderr)
        if failure_path:
            print(f"Diagnostics: {failure_path}", file=sys.stderr)
        return 130 if isinstance(error, KeyboardInterrupt) else 1


if __name__ == "__main__":
    raise SystemExit(main())
