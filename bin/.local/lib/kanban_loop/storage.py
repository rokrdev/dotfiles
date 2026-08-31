"""Local board, session, event, archive, and migration storage."""

from __future__ import annotations

import contextlib
import datetime as dt
import fcntl
import json
import os
import shutil
import tempfile
import uuid
from collections.abc import Iterator
from pathlib import Path
from typing import Any

import yaml

from .model import (
    ACTIVE_COLUMNS,
    FEATURE_RE,
    PREFIX_RE,
    SCHEMA_VERSION,
    TICKET_COLUMNS,
    Board,
    Feature,
    KanbanError,
    LocatedTicket,
    Ticket,
    feature_status,
    parse_feature,
    parse_ticket,
    render_markdown,
    validate_board,
)


def run_process(
    command: list[str], cwd: Path, *, check: bool = True
) -> tuple[int, str, str]:
    import subprocess

    completed = subprocess.run(
        command, cwd=cwd, text=True, capture_output=True, check=False
    )
    if check and completed.returncode:
        raise KanbanError(
            f"Command failed ({completed.returncode}): {' '.join(command)}\n"
            f"stdout:\n{completed.stdout}\nstderr:\n{completed.stderr}"
        )
    return completed.returncode, completed.stdout, completed.stderr


def repository_root(start: Path) -> Path:
    code, stdout, _ = run_process(
        ["git", "rev-parse", "--show-toplevel"], start, check=False
    )
    if code:
        raise KanbanError("kanban-loop must run inside a Git repository")
    return Path(stdout.strip()).resolve()


def atomic_json(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, name = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    temporary = Path(name)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as handle:
            json.dump(value, handle, indent=2, sort_keys=True)
            handle.write("\n")
            handle.flush()
            os.fsync(handle.fileno())
        temporary.replace(path)
    finally:
        temporary.unlink(missing_ok=True)


def read_json(path: Path, default: Any) -> Any:
    if not path.exists():
        return default
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise KanbanError(f"Unable to read state {path}: {error}") from error


class BoardStore:
    def __init__(self, repo: Path) -> None:
        self.repo = repo
        self.root = repo / ".workflow" / "kanban"
        self.features_dir = self.root / "features"
        self.tickets_dir = self.root / "tickets"
        self.archive_dir = self.root / "archive"
        self.state_dir = self.root / ".state"
        self.control_path = self.state_dir / "control.json"
        self.config_path = self.root / "config.yaml"

    def initialise(self) -> None:
        self.ensure_local_exclusion()
        self.features_dir.mkdir(parents=True, exist_ok=True)
        for column in TICKET_COLUMNS:
            (self.tickets_dir / column).mkdir(parents=True, exist_ok=True)
        self.archive_dir.mkdir(parents=True, exist_ok=True)
        self.state_dir.mkdir(parents=True, exist_ok=True)

    def ensure_local_exclusion(self) -> None:
        _, value, _ = run_process(
            ["git", "rev-parse", "--git-path", "info/exclude"],
            self.repo,
            check=True,
        )
        path = Path(value.strip())
        if not path.is_absolute():
            path = self.repo / path
        path.parent.mkdir(parents=True, exist_ok=True)
        existing = path.read_text(encoding="utf-8") if path.exists() else ""
        if "/.workflow/" in {line.strip() for line in existing.splitlines()}:
            return
        prefix = "" if not existing or existing.endswith("\n") else "\n"
        path.write_text(existing + prefix + "/.workflow/\n", encoding="utf-8")

    def is_v3(self) -> bool:
        return self.features_dir.is_dir() and self.tickets_dir.is_dir()

    def legacy_columns(self) -> list[str]:
        return [
            name
            for name in ("backlog", "doing", "paused", "done")
            if (self.root / name).is_dir()
        ]

    def load(self) -> Board:
        if not self.is_v3():
            legacy = self.legacy_columns()
            if legacy:
                raise KanbanError(
                    "Legacy Kanban board detected. Run `kanban-loop migrate` "
                    "for a preview before execution."
                )
            raise KanbanError(
                "Kanban board is not initialised. Create schema-v3 feature and "
                "ticket files or migrate an existing board."
            )
        errors: list[str] = []
        features: dict[str, Feature] = {}
        tickets: dict[str, LocatedTicket] = {}
        archived_features: dict[str, Feature] = {}
        archived_tickets: dict[str, LocatedTicket] = {}
        for path in sorted(self.features_dir.glob("*.md")):
            try:
                feature = parse_feature(path)
                if feature.slug in features:
                    raise KanbanError(f"{path}: duplicate feature {feature.slug}")
                features[feature.slug] = feature
            except KanbanError as error:
                errors.append(str(error))
        for column in TICKET_COLUMNS:
            directory = self.tickets_dir / column
            if not directory.is_dir():
                errors.append(f"Missing ticket column: {directory}")
                continue
            for path in sorted(directory.glob("*.md")):
                try:
                    ticket = parse_ticket(path)
                    if ticket.key in tickets:
                        raise KanbanError(f"{path}: duplicate ticket {ticket.key}")
                    tickets[ticket.key] = LocatedTicket(ticket, column)
                except KanbanError as error:
                    errors.append(str(error))
        if self.archive_dir.exists():
            for directory in sorted(
                path for path in self.archive_dir.iterdir() if path.is_dir()
            ):
                feature_path = directory / "feature.md"
                if not feature_path.exists():
                    errors.append(f"{directory}: archived feature.md is missing")
                    continue
                try:
                    feature = parse_feature(feature_path)
                    archived_features[feature.slug] = feature
                except KanbanError as error:
                    errors.append(str(error))
                for path in sorted((directory / "tickets").glob("*.md")):
                    try:
                        ticket = parse_ticket(path)
                        if ticket.key in tickets or ticket.key in archived_tickets:
                            raise KanbanError(f"{path}: duplicate ticket {ticket.key}")
                        archived_tickets[ticket.key] = LocatedTicket(ticket, "archived")
                    except KanbanError as error:
                        errors.append(str(error))
        if errors:
            raise KanbanError(
                "Invalid board:\n" + "\n".join(f"- {item}" for item in errors)
            )
        board = Board(features, tickets, archived_features, archived_tickets)
        validate_board(board)
        return board

    def config(self) -> dict[str, Any]:
        if not self.config_path.exists():
            return {}
        try:
            value = yaml.safe_load(self.config_path.read_text(encoding="utf-8")) or {}
        except yaml.YAMLError as error:
            raise KanbanError(f"Invalid {self.config_path}: {error}") from error
        if not isinstance(value, dict):
            raise KanbanError(f"{self.config_path}: configuration must be a mapping")
        return value

    def control(self) -> dict[str, Any]:
        value = read_json(
            self.control_path,
            {"schema-version": 1, "tickets": {}, "features": {}},
        )
        if not isinstance(value, dict) or value.get("schema-version") != 1:
            raise KanbanError(f"Invalid control state: {self.control_path}")
        value.setdefault("tickets", {})
        value.setdefault("features", {})
        return value

    def save_control(self, value: dict[str, Any]) -> None:
        atomic_json(self.control_path, value)

    def find_ticket(self, reference: str, board: Board | None = None) -> LocatedTicket:
        board = board or self.load()
        matches = [
            located
            for key, located in board.tickets.items()
            if reference in {key, located.ticket.slug}
        ]
        if not matches:
            raise KanbanError(f"No active ticket matches {reference!r}")
        if len(matches) > 1:
            raise KanbanError(f"Ticket reference is ambiguous: {reference!r}")
        return matches[0]

    def transition(self, ticket: Ticket, source: str, destination: str) -> Ticket:
        if source not in TICKET_COLUMNS or destination not in TICKET_COLUMNS:
            raise KanbanError(f"Invalid transition {source} -> {destination}")
        expected = self.tickets_dir / source / ticket.path.name
        target = self.tickets_dir / destination / ticket.path.name
        if ticket.path != expected or not expected.exists():
            raise KanbanError(f"Ticket is no longer in {source}: {ticket.key}")
        if target.exists():
            raise KanbanError(f"Refusing to overwrite ticket: {target}")
        target.parent.mkdir(parents=True, exist_ok=True)
        expected.replace(target)
        return parse_ticket(target)

    def pause_ticket(self, reference: str, origin: str = "ticket") -> str:
        board = self.load()
        located = self.find_ticket(reference, board)
        if located.column in {"done", "cancelled"}:
            raise KanbanError(
                f"Cannot pause {located.column} ticket {located.ticket.key}"
            )
        control = self.control()
        record = control["tickets"].setdefault(
            located.ticket.key,
            {"origins": [], "prior-state": located.column},
        )
        origins = set(record.get("origins", []))
        origins.add(origin)
        record["origins"] = sorted(origins)
        if located.column != "paused":
            record["prior-state"] = located.column
            self.transition(located.ticket, located.column, "paused")
        self.save_control(control)
        return located.ticket.key

    def resume_ticket(self, reference: str, origin: str = "ticket") -> tuple[str, str]:
        board = self.load()
        located = self.find_ticket(reference, board)
        control = self.control()
        record = control["tickets"].get(located.ticket.key)
        if located.column != "paused" or not isinstance(record, dict):
            raise KanbanError(f"Ticket is not paused: {located.ticket.key}")
        origins = set(record.get("origins", []))
        origins.discard(origin)
        if origins:
            record["origins"] = sorted(origins)
            self.save_control(control)
            return located.ticket.key, "paused"
        destination = record.get("prior-state", "ready")
        if destination not in ACTIVE_COLUMNS or destination == "paused":
            destination = "ready"
        self.transition(located.ticket, "paused", destination)
        del control["tickets"][located.ticket.key]
        self.save_control(control)
        return located.ticket.key, destination

    def pause_feature(self, feature: str) -> list[str]:
        board = self.load()
        if feature not in board.features:
            raise KanbanError(f"Unknown active feature: {feature}")
        control = self.control()
        if feature in control["features"]:
            raise KanbanError(f"Feature is already paused: {feature}")
        keys: list[str] = []
        for located in board.feature_tickets(feature):
            if located.column in {"done", "cancelled"}:
                continue
            keys.append(self.pause_ticket(located.ticket.key, f"feature:{feature}"))
        control = self.control()
        control["features"][feature] = {
            "paused-at": dt.datetime.now(dt.timezone.utc).isoformat(),
            "tickets": keys,
        }
        self.save_control(control)
        return keys

    def resume_feature(self, feature: str) -> list[tuple[str, str]]:
        control = self.control()
        if feature not in control["features"]:
            raise KanbanError(f"Feature is not paused: {feature}")
        board = self.load()
        results: list[tuple[str, str]] = []
        for located in board.feature_tickets(feature):
            if located.column != "paused":
                continue
            record = self.control()["tickets"].get(located.ticket.key, {})
            if f"feature:{feature}" in record.get("origins", []):
                results.append(
                    self.resume_ticket(located.ticket.key, f"feature:{feature}")
                )
        control = self.control()
        control["features"].pop(feature, None)
        self.save_control(control)
        return results

    def archive_feature(self, feature: str) -> Path:
        board = self.load()
        if feature not in board.features:
            raise KanbanError(f"Unknown active feature: {feature}")
        status = feature_status(board, feature)
        if status != "completed":
            raise KanbanError(
                f"Feature {feature} is {status}; only completed features may be archived"
            )
        target = self.archive_dir / feature
        if target.exists():
            raise KanbanError(f"Archive already exists: {target}")
        (target / "tickets").mkdir(parents=True)
        board.features[feature].path.replace(target / "feature.md")
        for located in board.feature_tickets(feature):
            located.ticket.path.replace(target / "tickets" / located.ticket.path.name)
        return target

    def restore_feature(self, feature: str) -> None:
        board = self.load()
        if feature not in board.archived_features:
            raise KanbanError(f"Unknown archived feature: {feature}")
        source = self.archive_dir / feature
        feature_target = self.features_dir / f"{feature}.md"
        if feature_target.exists():
            raise KanbanError(f"Active feature already exists: {feature}")
        (source / "feature.md").replace(feature_target)
        for path in sorted((source / "tickets").glob("*.md")):
            target = self.tickets_dir / "done" / path.name
            if target.exists():
                raise KanbanError(f"Active ticket already exists: {path.stem}")
            path.replace(target)
        (source / "tickets").rmdir()
        source.rmdir()


class SessionStore:
    def __init__(self, repo: Path) -> None:
        self.repo = repo
        _, git_dir_text, _ = run_process(
            ["git", "rev-parse", "--git-dir"], repo, check=True
        )
        git_dir = Path(git_dir_text.strip())
        if not git_dir.is_absolute():
            git_dir = repo / git_dir
        self.root = git_dir.resolve() / "kanban-loop"
        self.sessions = self.root / "sessions"
        self.failures = self.root / "failures"
        self.lock_path = self.root / ".lock"

    def initialise(self) -> None:
        self.sessions.mkdir(parents=True, exist_ok=True)
        self.failures.mkdir(parents=True, exist_ok=True)

    @contextlib.contextmanager
    def lock(self) -> Iterator[None]:
        self.initialise()
        with self.lock_path.open("w", encoding="utf-8") as handle:
            try:
                fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError as error:
                raise KanbanError(
                    "Another kanban-loop process holds the workflow lock"
                ) from error
            try:
                yield
            finally:
                fcntl.flock(handle, fcntl.LOCK_UN)

    def create(self, state: dict[str, Any]) -> str:
        self.initialise()
        run_id = state.get("run-id") or uuid.uuid4().hex[:12]
        path = self.sessions / run_id
        if path.exists():
            raise KanbanError(f"Session already exists: {run_id}")
        path.mkdir()
        payload = {
            "schema-version": 1,
            "run-id": run_id,
            "revision": 0,
            "created-at": dt.datetime.now(dt.timezone.utc).isoformat(),
            **state,
        }
        atomic_json(path / "state.json", payload)
        self.event(run_id, "session-created", {"phase": payload.get("phase")})
        return run_id

    def path(self, run_id: str) -> Path:
        if not run_id or Path(run_id).name != run_id:
            raise KanbanError(f"Invalid run id: {run_id!r}")
        path = self.sessions / run_id
        if not path.is_dir():
            raise KanbanError(f"Unknown run id: {run_id}")
        return path

    def load(self, run_id: str) -> dict[str, Any]:
        value = read_json(self.path(run_id) / "state.json", None)
        if not isinstance(value, dict) or value.get("run-id") != run_id:
            raise KanbanError(f"Invalid session state: {run_id}")
        return value

    def save(self, run_id: str, updates: dict[str, Any]) -> dict[str, Any]:
        state = self.load(run_id)
        value = {
            **state,
            **updates,
            "revision": int(state.get("revision", 0)) + 1,
            "updated-at": dt.datetime.now(dt.timezone.utc).isoformat(),
        }
        atomic_json(self.path(run_id) / "state.json", value)
        return value

    def event(self, run_id: str, kind: str, data: dict[str, Any]) -> None:
        path = self.path(run_id) / "events.jsonl"
        record = {
            "at": dt.datetime.now(dt.timezone.utc).isoformat(),
            "event": kind,
            "data": data,
        }
        with path.open("a", encoding="utf-8") as handle:
            handle.write(json.dumps(record, sort_keys=True) + "\n")
            handle.flush()
            os.fsync(handle.fileno())

    def write_text(self, run_id: str, name: str, value: str) -> Path:
        path = self.path(run_id) / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(value, encoding="utf-8")
        return path

    def write_json(self, run_id: str, name: str, value: Any) -> Path:
        path = self.path(run_id) / name
        path.parent.mkdir(parents=True, exist_ok=True)
        atomic_json(path, value)
        return path

    def active_for_ticket(self, key: str) -> tuple[str, dict[str, Any]] | None:
        self.initialise()
        matches: list[tuple[str, dict[str, Any]]] = []
        for path in sorted(self.sessions.glob("*/state.json")):
            state = read_json(path, {})
            if state.get("ticket") == key and state.get("phase") not in {
                "completed",
                "cancelled",
                "abandoned",
            }:
                matches.append((path.parent.name, state))
        if len(matches) > 1:
            raise KanbanError(f"Multiple active sessions exist for ticket {key}")
        return matches[0] if matches else None

    def record_failure(self, context: dict[str, Any]) -> Path:
        self.initialise()
        identifier = (
            dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%S.%fZ")
            + "-"
            + uuid.uuid4().hex[:8]
        )
        path = self.failures / f"{identifier}.json"
        atomic_json(path, context)
        return path

    def list_states(self) -> list[dict[str, Any]]:
        self.initialise()
        return [
            read_json(path, {}) for path in sorted(self.sessions.glob("*/state.json"))
        ]


def backup_tree(source: Path, destination: Path) -> None:
    if destination.exists():
        raise KanbanError(f"Backup already exists: {destination}")
    shutil.copytree(source, destination)


def legacy_ticket_metadata(path: Path) -> tuple[dict[str, Any], str]:
    raw = path.read_text(encoding="utf-8")
    if not raw.startswith("---\n"):
        raise KanbanError(f"{path}: missing YAML frontmatter")
    try:
        yaml_text, body = raw[4:].split("\n---\n", 1)
    except ValueError as error:
        raise KanbanError(f"{path}: unterminated YAML frontmatter") from error
    metadata = yaml.safe_load(yaml_text)
    if not isinstance(metadata, dict):
        raise KanbanError(f"{path}: frontmatter must be a mapping")
    if metadata.get("schema-version") != 2:
        raise KanbanError(f"{path}: only schema-version 2 migration is supported")
    return metadata, body


def migration_preview(store: BoardStore) -> dict[str, Any]:
    columns = store.legacy_columns()
    if not columns:
        if store.is_v3():
            return {"status": "already-current", "schema-version": SCHEMA_VERSION}
        raise KanbanError("No legacy Kanban board found")
    tickets: list[dict[str, Any]] = []
    errors: list[str] = []
    features: dict[str, str] = {}
    prefix_owners: dict[str, str] = {}
    slug_to_key: dict[str, str] = {}
    target_keys: set[str] = set()
    legacy_runtime = SessionStore(store.repo).root / "runs"
    legacy_runs = (
        sorted(path.name for path in legacy_runtime.iterdir() if path.is_dir())
        if legacy_runtime.is_dir()
        else []
    )
    for column in columns:
        for path in sorted((store.root / column).glob("*.md")):
            try:
                metadata, _ = legacy_ticket_metadata(path)
                feature = metadata.get("feature")
                prefix = metadata.get("ticket-prefix")
                if not isinstance(feature, str) or not isinstance(prefix, str):
                    raise KanbanError(
                        f"{path}: migration requires feature and ticket-prefix"
                    )
                if not FEATURE_RE.fullmatch(feature):
                    raise KanbanError(f"{path}: feature must be kebab-case")
                if not PREFIX_RE.fullmatch(prefix):
                    raise KanbanError(f"{path}: invalid ticket-prefix {prefix!r}")
                existing = features.get(feature)
                if existing not in {None, prefix}:
                    raise KanbanError(f"{path}: conflicting prefix for {feature}")
                owner = prefix_owners.get(prefix)
                if owner not in {None, feature}:
                    raise KanbanError(
                        f"{path}: ticket-prefix {prefix} belongs to both {owner} and {feature}"
                    )
                features[feature] = prefix
                prefix_owners[prefix] = feature
                number = metadata.get("id")
                if (
                    not isinstance(number, int)
                    or isinstance(number, bool)
                    or number < 1
                ):
                    raise KanbanError(f"{path}: id must be a positive integer")
                slug = metadata.get("slug")
                if not isinstance(slug, str) or not FEATURE_RE.fullmatch(slug):
                    raise KanbanError(f"{path}: slug must be kebab-case")
                if slug in slug_to_key:
                    raise KanbanError(
                        f"{path}: duplicate legacy slug {slug!r}; dependency migration is ambiguous"
                    )
                title = metadata.get("title")
                acceptance = metadata.get("acceptance")
                dependencies = metadata.get("depends-on", [])
                if not isinstance(title, str) or not title.strip():
                    raise KanbanError(f"{path}: title must be a non-empty string")
                if not isinstance(acceptance, str) or not acceptance.strip():
                    raise KanbanError(f"{path}: acceptance must be a non-empty string")
                if not isinstance(dependencies, list) or any(
                    not isinstance(item, str) or not item.strip()
                    for item in dependencies
                ):
                    raise KanbanError(f"{path}: depends-on must be a string list")
                verification = metadata.get("verification", [])
                if not isinstance(verification, list):
                    raise KanbanError(f"{path}: verification must be a list")
                for index, specification in enumerate(verification):
                    if isinstance(specification, str) and specification.strip():
                        continue
                    if not isinstance(specification, dict) or not isinstance(
                        specification.get("command"), str
                    ):
                        raise KanbanError(
                            f"{path}: verification[{index}] must contain a command"
                        )
                    expected = specification.get("expected-exit", 0)
                    if not isinstance(expected, int) or isinstance(expected, bool):
                        raise KanbanError(
                            f"{path}: verification[{index}].expected-exit is invalid"
                        )
                tdd_command = metadata.get("tdd-test-command")
                if tdd_command is not None and (
                    not isinstance(tdd_command, str) or not tdd_command.strip()
                ):
                    raise KanbanError(
                        f"{path}: tdd-test-command must be a non-empty string"
                    )
                target_key = f"{prefix}-{number:02d}-{slug}"
                if target_key in target_keys:
                    raise KanbanError(
                        f"{path}: duplicate migrated ticket key {target_key}"
                    )
                target_keys.add(target_key)
                slug_to_key[slug] = target_key
                tickets.append(
                    {
                        "source": str(
                            path.relative_to(store.repo)
                            if path.is_relative_to(store.repo)
                            else path
                        ),
                        "column": column,
                        "key": target_key,
                        "feature": feature,
                        "prefix": prefix,
                        "depends-on": dependencies,
                    }
                )
            except (OSError, yaml.YAMLError, KanbanError) as error:
                errors.append(str(error))
    for item in tickets:
        for dependency in item["depends-on"]:
            if dependency not in slug_to_key:
                errors.append(
                    f"{item['source']}: dependency {dependency!r} cannot be migrated"
                )
    return {
        "status": "ready" if not errors else "blocked",
        "from-schema": 2,
        "to-schema": SCHEMA_VERSION,
        "features": [
            {"feature": feature, "ticket-prefix": prefix}
            for feature, prefix in sorted(features.items())
        ],
        "tickets": tickets,
        "slug-to-key": slug_to_key,
        "legacy-runtime": {
            "path": str(legacy_runtime),
            "runs": legacy_runs,
            "preserved-in-place": True,
        },
        "errors": errors,
    }


def apply_migration(store: BoardStore) -> dict[str, Any]:
    preview = migration_preview(store)
    if preview.get("status") != "ready":
        raise KanbanError(
            "Migration is not safe:\n"
            + "\n".join(f"- {item}" for item in preview.get("errors", []))
        )
    timestamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    backup = store.repo / ".workflow" / "kanban-backups" / timestamp
    backup.parent.mkdir(parents=True, exist_ok=True)
    backup_tree(store.root, backup)
    converted_root = store.repo / ".workflow" / f".kanban-v3-{uuid.uuid4().hex[:8]}"
    converted = BoardStore(store.repo)
    converted.root = converted_root
    converted.features_dir = converted_root / "features"
    converted.tickets_dir = converted_root / "tickets"
    converted.archive_dir = converted_root / "archive"
    converted.state_dir = converted_root / ".state"
    converted.control_path = converted.state_dir / "control.json"
    converted.config_path = converted_root / "config.yaml"
    converted.initialise()
    for item in preview["features"]:
        metadata = {
            "schema-version": SCHEMA_VERSION,
            "kind": "feature",
            "feature": item["feature"],
            "ticket-prefix": item["ticket-prefix"],
            "title": item["feature"].replace("-", " ").title(),
            "priority": 0,
        }
        (converted.features_dir / f"{item['feature']}.md").write_text(
            render_markdown(metadata), encoding="utf-8"
        )
    column_map = {
        "backlog": "ready",
        "doing": "paused",
        "paused": "paused",
        "done": "done",
    }
    pause_control = converted.control()
    for item in preview["tickets"]:
        source = store.repo / item["source"]
        metadata, body = legacy_ticket_metadata(source)
        depends = []
        for dependency in metadata.get("depends-on", []):
            key = preview["slug-to-key"].get(dependency)
            if key is None:
                raise KanbanError(
                    f"{source}: dependency {dependency!r} cannot be migrated"
                )
            depends.append(key)
        allowed = metadata.get("allowed-changes", [])
        likely_files = [
            change.get("path")
            for change in allowed
            if isinstance(change, dict) and isinstance(change.get("path"), str)
        ]
        verification = metadata.get("verification", [])
        new_metadata = {
            "schema-version": SCHEMA_VERSION,
            "kind": "ticket",
            "feature": item["feature"],
            "ticket-prefix": item["prefix"],
            "id": metadata.get("id"),
            "slug": metadata.get("slug"),
            "title": metadata.get("title"),
            "depends-on": depends,
            "priority": 0,
            "mode": "hitl" if metadata.get("human-required") else "inherit",
            "acceptance": [metadata.get("acceptance")],
            "constraints": [],
            "out-of-scope": [],
            "verification": verification,
            "strict-tdd": bool(metadata.get("tdd-test-command")),
            "tdd-test-command": metadata.get("tdd-test-command"),
            "implementation-hints": [],
            "likely-files": likely_files,
        }
        destination_column = column_map[item["column"]]
        destination = converted.tickets_dir / destination_column / f"{item['key']}.md"
        destination.write_text(render_markdown(new_metadata, body), encoding="utf-8")
        if destination_column == "paused":
            pause_control["tickets"][item["key"]] = {
                "origins": ["migration"],
                # There is no trustworthy resumable provider session in v2. Imported
                # in-flight work must return to ready after explicit review/resume.
                "prior-state": "ready",
            }
    converted.save_control(pause_control)
    converted.load()
    old = store.repo / ".workflow" / f".kanban-v2-replaced-{uuid.uuid4().hex[:8]}"
    store.root.replace(old)
    try:
        converted_root.replace(store.root)
    except BaseException:
        old.replace(store.root)
        raise
    shutil.rmtree(old)
    return {**preview, "status": "migrated", "backup": str(backup)}


def restore_migration(store: BoardStore, backup_value: str) -> dict[str, Any]:
    backup_root = (store.repo / ".workflow" / "kanban-backups").resolve()
    candidate = Path(backup_value)
    if not candidate.is_absolute():
        candidate = store.repo / candidate
    source = candidate.resolve()
    if source.parent != backup_root or not source.is_dir():
        raise KanbanError(
            f"Migration backup must be a direct child of {backup_root}: {source}"
        )
    shadow = BoardStore(store.repo)
    shadow.root = source
    shadow.features_dir = source / "features"
    shadow.tickets_dir = source / "tickets"
    shadow.archive_dir = source / "archive"
    shadow.state_dir = source / ".state"
    shadow.control_path = shadow.state_dir / "control.json"
    shadow.config_path = source / "config.yaml"
    preview = migration_preview(shadow)
    if preview.get("status") != "ready":
        raise KanbanError(
            "Backup is not a valid restorable schema-v2 board:\n"
            + "\n".join(f"- {item}" for item in preview.get("errors", []))
        )
    timestamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%S.%fZ")
    current_backup = backup_root / f"{timestamp}-pre-restore"
    backup_tree(store.root, current_backup)
    temporary = store.repo / ".workflow" / f".kanban-restore-{uuid.uuid4().hex[:8]}"
    backup_tree(source, temporary)
    displaced = store.repo / ".workflow" / f".kanban-displaced-{uuid.uuid4().hex[:8]}"
    store.root.replace(displaced)
    try:
        temporary.replace(store.root)
    except BaseException:
        displaced.replace(store.root)
        raise
    shutil.rmtree(displaced)
    return {
        "status": "restored-schema-v2",
        "restored-from": str(source),
        "schema-v3-backup": str(current_backup),
    }
