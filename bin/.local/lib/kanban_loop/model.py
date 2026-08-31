"""Human-authored feature/ticket contracts and board validation."""

from __future__ import annotations

import dataclasses
import re
from collections.abc import Iterable
from pathlib import Path
from typing import Any

import yaml

SCHEMA_VERSION = 3
FEATURE_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
PREFIX_RE = re.compile(r"^[A-Z][A-Z0-9]{0,7}$")
TICKET_KEY_RE = re.compile(
    r"^(?P<prefix>[A-Z][A-Z0-9]{0,7})-(?P<number>[0-9]{2,})-(?P<slug>[a-z0-9]+(?:-[a-z0-9]+)*)$"
)
TICKET_COLUMNS = (
    "ready",
    "active",
    "review",
    "paused",
    "blocked",
    "done",
    "cancelled",
)
ACTIVE_COLUMNS = TICKET_COLUMNS[:-2]


class KanbanError(RuntimeError):
    """A user-visible workflow error."""


@dataclasses.dataclass(frozen=True)
class Verification:
    command: str
    expected_exit: int = 0
    required: bool = True


@dataclasses.dataclass(frozen=True)
class Feature:
    path: Path
    raw: str
    slug: str
    prefix: str
    title: str
    priority: int = 0


@dataclasses.dataclass(frozen=True)
class Ticket:
    path: Path
    raw: str
    body: str
    feature: str
    prefix: str
    number: int
    slug: str
    title: str
    depends_on: tuple[str, ...]
    priority: int
    mode: str
    acceptance: tuple[str, ...]
    constraints: tuple[str, ...]
    exclusions: tuple[str, ...]
    verification: tuple[Verification, ...]
    strict_tdd: bool
    tdd_test_command: str | None
    implementation_hints: tuple[str, ...]
    likely_files: tuple[str, ...]

    @property
    def key(self) -> str:
        return self.path.stem


@dataclasses.dataclass(frozen=True)
class LocatedTicket:
    ticket: Ticket
    column: str


@dataclasses.dataclass(frozen=True)
class Board:
    features: dict[str, Feature]
    tickets: dict[str, LocatedTicket]
    archived_features: dict[str, Feature]
    archived_tickets: dict[str, LocatedTicket]

    @property
    def all_tickets(self) -> dict[str, LocatedTicket]:
        return {**self.archived_tickets, **self.tickets}

    @property
    def completed_keys(self) -> set[str]:
        return {
            key
            for key, located in self.all_tickets.items()
            if located.column in {"done", "archived"}
        }

    def feature_tickets(
        self, feature: str, *, include_archived: bool = False
    ) -> list[LocatedTicket]:
        source = self.all_tickets if include_archived else self.tickets
        return sorted(
            (
                located
                for located in source.values()
                if located.ticket.feature == feature
            ),
            key=lambda item: (item.ticket.number, item.ticket.key),
        )

    def unresolved_dependencies(self, ticket: Ticket) -> tuple[str, ...]:
        return tuple(dep for dep in ticket.depends_on if dep not in self.completed_keys)

    def dependency_chain(self, ticket_key: str) -> list[list[str]]:
        """Return unresolved dependency paths without recursing forever."""
        paths: list[list[str]] = []

        def visit(key: str, chain: list[str]) -> None:
            if key in chain:
                paths.append([*chain, key])
                return
            located = self.all_tickets.get(key)
            if located is None:
                paths.append([*chain, key])
                return
            unresolved = self.unresolved_dependencies(located.ticket)
            if not unresolved:
                return
            for dependency in unresolved:
                visit(dependency, [*chain, key])

        visit(ticket_key, [])
        return paths

    def eligible(self, feature: str | None = None) -> list[LocatedTicket]:
        candidates = [
            located
            for located in self.tickets.values()
            if located.column == "ready"
            and (feature is None or located.ticket.feature == feature)
            and not self.unresolved_dependencies(located.ticket)
        ]
        return sorted(
            candidates,
            key=lambda item: (
                -item.ticket.priority,
                item.ticket.number,
                item.ticket.key,
            ),
        )


def _frontmatter(path: Path) -> tuple[dict[str, Any], str, str]:
    try:
        raw = path.read_text(encoding="utf-8")
    except OSError as error:
        raise KanbanError(f"Unable to read {path}: {error}") from error
    if not raw.startswith("---\n"):
        raise KanbanError(f"{path}: missing YAML frontmatter")
    try:
        yaml_text, body = raw[4:].split("\n---\n", 1)
    except ValueError as error:
        raise KanbanError(f"{path}: unterminated YAML frontmatter") from error
    try:
        metadata = yaml.safe_load(yaml_text)
    except yaml.YAMLError as error:
        raise KanbanError(f"{path}: invalid YAML: {error}") from error
    if not isinstance(metadata, dict):
        raise KanbanError(f"{path}: frontmatter must be a mapping")
    return metadata, body, raw


def _string(metadata: dict[str, Any], key: str, path: Path) -> str:
    value = metadata.get(key)
    if not isinstance(value, str) or not value.strip():
        raise KanbanError(f"{path}: {key} must be a non-empty string")
    return value.strip()


def _strings(
    metadata: dict[str, Any], key: str, path: Path, *, required: bool = False
) -> tuple[str, ...]:
    value = metadata.get(key)
    if value is None and not required:
        return ()
    if isinstance(value, str):
        value = [value]
    if not isinstance(value, list) or (required and not value):
        qualifier = "non-empty " if required else ""
        raise KanbanError(f"{path}: {key} must be a {qualifier}string list")
    if any(not isinstance(item, str) or not item.strip() for item in value):
        raise KanbanError(f"{path}: {key} entries must be non-empty strings")
    return tuple(item.strip() for item in value)


def parse_feature(path: Path) -> Feature:
    metadata, _, raw = _frontmatter(path)
    if metadata.get("schema-version") != SCHEMA_VERSION:
        raise KanbanError(f"{path}: schema-version must be {SCHEMA_VERSION}")
    if metadata.get("kind") != "feature":
        raise KanbanError(f"{path}: kind must be feature")
    slug = _string(metadata, "feature", path)
    prefix = _string(metadata, "ticket-prefix", path)
    title = _string(metadata, "title", path)
    priority = metadata.get("priority", 0)
    if not FEATURE_RE.fullmatch(slug):
        raise KanbanError(f"{path}: feature must be kebab-case")
    if not PREFIX_RE.fullmatch(prefix):
        raise KanbanError(f"{path}: invalid ticket-prefix {prefix!r}")
    if path.name != "feature.md" and path.stem != slug:
        raise KanbanError(f"{path}: filename must match feature {slug!r}")
    if not isinstance(priority, int) or isinstance(priority, bool):
        raise KanbanError(f"{path}: priority must be an integer")
    return Feature(path, raw, slug, prefix, title, priority)


def parse_ticket(path: Path) -> Ticket:
    metadata, body, raw = _frontmatter(path)
    if metadata.get("schema-version") != SCHEMA_VERSION:
        raise KanbanError(f"{path}: schema-version must be {SCHEMA_VERSION}")
    if metadata.get("kind") != "ticket":
        raise KanbanError(f"{path}: kind must be ticket")
    match = TICKET_KEY_RE.fullmatch(path.stem)
    if match is None:
        raise KanbanError(f"{path}: filename must be PREFIX-NN-kebab-slug")
    feature = _string(metadata, "feature", path)
    prefix = _string(metadata, "ticket-prefix", path)
    slug = _string(metadata, "slug", path)
    title = _string(metadata, "title", path)
    number = metadata.get("id")
    priority = metadata.get("priority", 0)
    mode = metadata.get("mode", "inherit")
    if not FEATURE_RE.fullmatch(feature):
        raise KanbanError(f"{path}: feature must be kebab-case")
    if not PREFIX_RE.fullmatch(prefix):
        raise KanbanError(f"{path}: invalid ticket-prefix {prefix!r}")
    if not FEATURE_RE.fullmatch(slug):
        raise KanbanError(f"{path}: slug must be kebab-case")
    if not isinstance(number, int) or isinstance(number, bool) or number < 1:
        raise KanbanError(f"{path}: id must be a positive integer")
    if not isinstance(priority, int) or isinstance(priority, bool):
        raise KanbanError(f"{path}: priority must be an integer")
    if mode not in {"inherit", "hitl", "auto"}:
        raise KanbanError(f"{path}: mode must be inherit, hitl, or auto")
    if prefix != match.group("prefix") or number != int(match.group("number")):
        raise KanbanError(f"{path}: identity fields disagree with filename")
    if slug != match.group("slug"):
        raise KanbanError(f"{path}: slug disagrees with filename")
    strict_tdd = metadata.get("strict-tdd", False)
    if not isinstance(strict_tdd, bool):
        raise KanbanError(f"{path}: strict-tdd must be boolean")
    tdd_test_command = metadata.get("tdd-test-command")
    if tdd_test_command is not None and (
        not isinstance(tdd_test_command, str) or not tdd_test_command.strip()
    ):
        raise KanbanError(f"{path}: tdd-test-command must be a non-empty string")
    if strict_tdd and not tdd_test_command:
        raise KanbanError(f"{path}: strict-tdd requires tdd-test-command")
    verification_items = metadata.get("verification", [])
    if not isinstance(verification_items, list):
        raise KanbanError(f"{path}: verification must be a list")
    verification: list[Verification] = []
    for index, item in enumerate(verification_items):
        if isinstance(item, str) and item.strip():
            verification.append(Verification(item.strip()))
            continue
        if not isinstance(item, dict):
            raise KanbanError(f"{path}: verification[{index}] must be a command")
        command = item.get("command")
        expected = item.get("expected-exit", 0)
        required = item.get("required", True)
        if not isinstance(command, str) or not command.strip():
            raise KanbanError(f"{path}: verification[{index}].command is required")
        if not isinstance(expected, int) or isinstance(expected, bool):
            raise KanbanError(f"{path}: verification[{index}].expected-exit is invalid")
        if not isinstance(required, bool):
            raise KanbanError(f"{path}: verification[{index}].required is invalid")
        verification.append(Verification(command.strip(), expected, required))
    return Ticket(
        path=path,
        raw=raw,
        body=body,
        feature=feature,
        prefix=prefix,
        number=number,
        slug=slug,
        title=title,
        depends_on=_strings(metadata, "depends-on", path),
        priority=priority,
        mode=mode,
        acceptance=_strings(metadata, "acceptance", path, required=True),
        constraints=_strings(metadata, "constraints", path),
        exclusions=_strings(metadata, "out-of-scope", path),
        verification=tuple(verification),
        strict_tdd=strict_tdd,
        tdd_test_command=tdd_test_command.strip() if tdd_test_command else None,
        implementation_hints=_strings(metadata, "implementation-hints", path),
        likely_files=_strings(metadata, "likely-files", path),
    )


def validate_board(board: Board) -> None:
    errors: list[str] = []
    prefixes: dict[str, str] = {}
    numbers: set[tuple[str, int]] = set()
    slugs: set[str] = set()
    for feature in [*board.archived_features.values(), *board.features.values()]:
        owner = prefixes.get(feature.prefix)
        if owner not in {None, feature.slug}:
            errors.append(
                f"ticket-prefix {feature.prefix} belongs to both {owner} and {feature.slug}"
            )
        prefixes[feature.prefix] = feature.slug
    all_tickets = board.all_tickets
    for key, located in all_tickets.items():
        ticket = located.ticket
        feature = board.features.get(ticket.feature) or board.archived_features.get(
            ticket.feature
        )
        if feature is None:
            errors.append(f"{key}: unknown feature {ticket.feature}")
        elif feature.prefix != ticket.prefix:
            errors.append(f"{key}: prefix disagrees with feature {ticket.feature}")
        number_key = (ticket.prefix, ticket.number)
        if number_key in numbers:
            errors.append(
                f"{key}: duplicate number {ticket.prefix}-{ticket.number:02d}"
            )
        numbers.add(number_key)
        if ticket.slug in slugs:
            errors.append(f"{key}: duplicate ticket slug {ticket.slug}")
        slugs.add(ticket.slug)
        for dependency in ticket.depends_on:
            if dependency not in all_tickets:
                errors.append(f"{key}: missing dependency {dependency}")
            elif dependency == key:
                errors.append(f"{key}: cannot depend on itself")
    _validate_cycles(all_tickets, errors)
    if errors:
        raise KanbanError(
            "Invalid board:\n" + "\n".join(f"- {item}" for item in errors)
        )


def _validate_cycles(tickets: dict[str, LocatedTicket], errors: list[str]) -> None:
    visiting: list[str] = []
    visited: set[str] = set()

    def visit(key: str) -> None:
        if key in visited:
            return
        if key in visiting:
            cycle = visiting[visiting.index(key) :] + [key]
            errors.append("dependency cycle: " + " -> ".join(cycle))
            return
        visiting.append(key)
        located = tickets[key]
        for dependency in located.ticket.depends_on:
            if dependency in tickets:
                visit(dependency)
        visiting.pop()
        visited.add(key)

    for key in tickets:
        visit(key)


def feature_status(board: Board, feature: str) -> str:
    tickets = board.feature_tickets(feature)
    if not tickets:
        return "empty"
    columns = {item.column for item in tickets}
    if columns == {"done"}:
        return "completed"
    if columns <= {"done", "cancelled"} and "cancelled" in columns:
        return "closed-with-cancellations"
    if "review" in columns:
        return "awaiting-review"
    if "active" in columns:
        return "active"
    if "blocked" in columns:
        return "blocked"
    if "paused" in columns:
        return "paused"
    if any(
        item.column == "ready" and board.unresolved_dependencies(item.ticket)
        for item in tickets
    ):
        return "blocked"
    return "ready"


def render_markdown(metadata: dict[str, Any], body: str = "") -> str:
    dumped = yaml.safe_dump(metadata, sort_keys=False, allow_unicode=True).rstrip()
    suffix = body.strip()
    return f"---\n{dumped}\n---\n" + (f"\n{suffix}\n" if suffix else "")


def stable_ticket_order(tickets: Iterable[Ticket]) -> list[Ticket]:
    return sorted(tickets, key=lambda item: (-item.priority, item.number, item.key))
