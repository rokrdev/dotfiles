"""Intent-based serial delivery engine for AUTO and HITL sessions."""

from __future__ import annotations

import datetime as dt
import hashlib
import json
import re
import shlex
import traceback
from pathlib import Path
from typing import Any

from . import gitops
from .model import KanbanError, LocatedTicket, Ticket, feature_status, parse_ticket
from .providers import (
    IMPLEMENTER_SCHEMA,
    INVESTIGATION_SCHEMA,
    REVIEWER_SCHEMA,
    AgentRequest,
    AgentResult,
    ProviderAdapter,
    redact,
    select_provider,
)
from .storage import (
    BoardStore,
    SessionStore,
    apply_migration,
    migration_preview,
    restore_migration,
)


def sha256_text(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def _test_path(path: str) -> bool:
    lower = path.lower()
    name = Path(lower).name
    return (
        any(part in {"test", "tests", "spec", "specs"} for part in Path(lower).parts)
        or name.startswith("test_")
        or name.endswith("_test.py")
        or ".test." in name
        or ".spec." in name
    )


def _command_is_safe(command: str) -> tuple[bool, str | None]:
    try:
        tokens = shlex.split(command)
    except ValueError as error:
        return False, f"command is not parseable: {error}"
    if not tokens:
        return False, "command is empty"
    forbidden = {
        "rm",
        "rmdir",
        "mv",
        "dd",
        "mkfs",
        "sudo",
        "git",
        "curl",
        "wget",
        "ssh",
        "scp",
        "rsync",
    }
    executable = Path(tokens[0]).name.lower()
    if executable in {"env", "command"}:
        executable = next(
            (
                Path(token).name.lower()
                for token in tokens[1:]
                if not token.startswith("-") and "=" not in token
            ),
            executable,
        )
    if executable in {"sh", "bash", "zsh", "fish"} and "-c" in tokens:
        index = tokens.index("-c")
        if index + 1 >= len(tokens):
            return False, "shell -c command is missing"
        return _command_is_safe(tokens[index + 1])
    if executable in forbidden:
        return (
            False,
            f"command invokes destructive or integration tool: {executable}",
        )
    if re.search(r"(?:^|\s)(?:>|>>|<|&&|\|\|?|;)(?:\s|$)|\$\(|`", command):
        return (
            False,
            "shell chaining, redirection, or command substitution is not allowed",
        )
    return True, None


def _ticket_contract(ticket: Ticket) -> dict[str, Any]:
    return {
        "key": ticket.key,
        "feature": ticket.feature,
        "title": ticket.title,
        "acceptance": list(ticket.acceptance),
        "constraints": list(ticket.constraints),
        "out-of-scope": list(ticket.exclusions),
        "dependencies": list(ticket.depends_on),
        "implementation-hints": list(ticket.implementation_hints),
        "likely-files": list(ticket.likely_files),
        "strict-tdd": ticket.strict_tdd,
        "verification": [
            {
                "command": item.command,
                "expected-exit": item.expected_exit,
                "required": item.required,
            }
            for item in ticket.verification
        ],
    }


def implementer_prompt(
    ticket: Ticket,
    *,
    mode: str,
    feedback: str | None,
    amendments: list[dict[str, Any]],
    strict_test_phase: bool = False,
) -> str:
    if strict_test_phase:
        task = """
This ticket explicitly requires strict test-first development. Modify only test
files and add a focused test that fails because the requested behavior is not
implemented. Do not modify production files. Do not run commands; the runner
will execute the declared TDD command and require a behavioral failure.
"""
    else:
        task = """
Implement the requested outcome. Inspect the repository and modify every file
reasonably necessary, including directly required tests and documentation.
Likely files are hints, never permissions. Do not make unrelated cleanup or
material product, dependency, public API, schema, security, or architecture
decisions that the contract does not settle. If one is required, return blocked
with the decision and options instead of guessing.

Do not run commands, stage or commit files, modify Git state, edit anything
under .workflow, or start another agent. The runner owns verification, review,
Git, and workflow state.
"""
    feedback_text = feedback or "none"
    return f"""You are the implementation worker in a local Kanban delivery session.

Mode: {mode.upper()}
{task.strip()}

Ticket contract:
{json.dumps(_ticket_contract(ticket), indent=2)}

Accepted HITL amendments:
{json.dumps(amendments, indent=2)}

Current human or reviewer feedback:
{feedback_text}

Ticket body:
{ticket.body.strip() or "(none)"}

Return exactly one structured result. `files_changed` is your best report, not
an authority boundary. `verification_commands` may contain only focused,
non-destructive test/build/lint commands. `proposed_commit_message` must be a
normal descriptive project commit subject and must not mention the ticket key.
If structured output is unavailable, end with exactly one standalone line:
`Status: complete` or `Status: blocked`.
"""


def reviewer_prompt(
    ticket: Ticket,
    patch: str,
    verification: list[dict[str, Any]],
    amendments: list[dict[str, Any]],
) -> str:
    return f"""You are a fresh independent read-only reviewer. You did not implement
this patch. Inspect the repository as needed, but do not edit files, run agents,
stage, commit, or mutate workflow state.

Review the complete patch against the ticket plus accepted amendments. Blocking
findings are limited to unmet acceptance, correctness, regression, meaningful
coverage, security, data-loss, unrelated scope, or unverifiable behavior.
Style, optional cleanup, and nonessential improvements are advisory and cannot
produce a revise verdict by themselves. Do not invent requirements.

Ticket contract:
{json.dumps(_ticket_contract(ticket), indent=2)}

Accepted amendments:
{json.dumps(amendments, indent=2)}

Verification evidence:
{json.dumps(verification, indent=2)}

Patch:
```diff
{patch}
```

Return exactly one structured result. If structured output is unavailable, end
with exactly one standalone line: `Verdict: accept`, `Verdict: revise`, or
`Verdict: blocked`.
"""


class Engine:
    def __init__(
        self,
        repo: Path,
        *,
        provider_name: str = "auto",
        model: str | None = None,
    ) -> None:
        self.repo = repo
        self.board = BoardStore(repo)
        self.sessions = SessionStore(repo)
        self.provider_name = provider_name
        self.model = model

    def provider(self, state: dict[str, Any] | None = None) -> ProviderAdapter:
        requested = (
            state.get("provider", self.provider_name) if state else self.provider_name
        )
        return select_provider(requested, self.board.config())

    def _protected_branches(self) -> list[str] | None:
        configured = self.board.config().get("protected-branches")
        protected = set(gitops.PROTECTED_BRANCHES)
        if configured is None:
            return sorted(protected)
        if not isinstance(configured, list) or any(
            not isinstance(item, str) or not item.strip() for item in configured
        ):
            raise KanbanError("protected-branches must be a list of branch names")
        protected.update(item.strip() for item in configured)
        return sorted(protected)

    def _effective_policy(self) -> dict[str, Any]:
        configured = self.board.config()
        defaults: dict[str, Any] = {
            "provider": "auto",
            "model": None,
            "provider-retries": 2,
            "max-attempts": 3,
            "protected-branches": sorted(gitops.PROTECTED_BRANCHES),
        }
        values = {**defaults, **configured}
        values["protected-branches"] = self._protected_branches()
        sources = {
            key: (
                str(self.board.config_path.relative_to(self.repo))
                if key in configured
                else "built-in"
            )
            for key in values
        }
        if "protected-branches" in configured:
            sources["protected-branches"] = "built-in safety minimum + " + str(
                self.board.config_path.relative_to(self.repo)
            )
        return {"values": values, "sources": sources}

    def _workflow_snapshot(self, *, exclude: set[str] | None = None) -> dict[str, str]:
        if not self.board.root.exists():
            return {}
        exclude = exclude or set()
        result: dict[str, str] = {}
        for path in sorted(
            item for item in self.board.root.rglob("*") if item.is_file()
        ):
            relative = str(path.relative_to(self.repo))
            if "/.state/" in f"/{relative}/":
                continue
            if relative in exclude:
                continue
            result[relative] = hashlib.sha256(path.read_bytes()).hexdigest()
        return result

    def _record_failure(
        self,
        error: BaseException,
        *,
        run_id: str | None,
        phase: str,
        extra: dict[str, Any] | None = None,
    ) -> Path:
        state: dict[str, Any] | None = None
        if run_id:
            try:
                state = self.sessions.load(run_id)
            except KanbanError:
                state = None
        diagnostics = getattr(error, "diagnostics", {})
        recovery: dict[str, Any] = {}
        if run_id and state and isinstance(state.get("baseline"), dict):
            try:
                session_paths, overlap = gitops.session_delta(
                    self.repo, state["baseline"]
                )
                patch = gitops.patch_for_paths(
                    self.repo,
                    session_paths,
                    state["baseline"]["base-commit"],
                )
                recovery = {
                    "session-paths": sorted(session_paths),
                    "overlap-paths": sorted(overlap),
                    "patch-hash": gitops.patch_hash(patch) if patch else None,
                }
                if patch:
                    patch_name = (
                        "failure-"
                        + dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%S%f")
                        + ".patch"
                    )
                    recovery["patch-file"] = str(
                        self.sessions.write_text(run_id, patch_name, patch)
                    )
            except Exception as capture_error:  # noqa: BLE001 - retain root failure
                recovery = {
                    "capture-error-type": type(capture_error).__name__,
                    "capture-error": str(capture_error),
                }
        record = redact(
            {
                "at": dt.datetime.now(dt.timezone.utc).isoformat(),
                "run-id": run_id,
                "phase": phase,
                "error-type": type(error).__name__,
                "message": str(error),
                "state": state,
                "diagnostics": diagnostics,
                "extra": extra or {},
                "recovery": recovery,
                "traceback": "".join(
                    traceback.format_exception(type(error), error, error.__traceback__)
                ),
                "cause": repr(error.__cause__) if error.__cause__ else None,
            }
        )
        path = self.sessions.record_failure(record)
        if run_id:
            try:
                self.sessions.write_json(
                    run_id,
                    f"failure-{dt.datetime.now(dt.timezone.utc).strftime('%Y%m%dT%H%M%S%f')}.json",
                    record,
                )
                self.sessions.event(
                    run_id, "failure", {"phase": phase, "path": str(path)}
                )
            except KanbanError:
                pass
        return path

    def _agent_call(
        self,
        run_id: str,
        request: AgentRequest,
        artifact_prefix: str,
        *,
        retries: int,
    ) -> AgentResult:
        provider = self.provider(self.sessions.load(run_id))
        last_error: BaseException | None = None
        for attempt in range(1, retries + 2):
            state = self.sessions.load(run_id)
            ticket_path = state.get("ticket-path")
            excluded = {ticket_path} if isinstance(ticket_path, str) else set()
            before_head = gitops.current_head(self.repo)
            before_index = gitops.git(self.repo, "diff", "--cached", "--binary")
            workflow_before = self._workflow_snapshot(exclude=excluded)
            try:
                result = provider.run(request)
                if gitops.current_head(self.repo) != before_head:
                    raise KanbanError("Agent changed Git HEAD")
                if (
                    gitops.git(self.repo, "diff", "--cached", "--binary")
                    != before_index
                ):
                    raise KanbanError("Agent changed the Git index")
                workflow_after = self._workflow_snapshot(exclude=excluded)
                if workflow_after != workflow_before:
                    changed = sorted(
                        key
                        for key in set(workflow_before) | set(workflow_after)
                        if workflow_before.get(key) != workflow_after.get(key)
                    )
                    raise KanbanError(
                        f"Agent changed local workflow metadata: {changed}"
                    )
                safe_data = redact(result.data)
                safe_candidates = redact(list(result.candidates))
                if not isinstance(safe_data, dict) or not isinstance(
                    safe_candidates, list
                ):
                    raise KanbanError("Provider result could not be safely persisted")
                safe_result = AgentResult(
                    data=safe_data,
                    raw_output=str(redact(result.raw_output)),
                    stdout=str(redact(result.stdout)),
                    stderr=str(redact(result.stderr)),
                    command=result.command,
                    candidates=tuple(
                        item for item in safe_candidates if isinstance(item, dict)
                    ),
                )
                self.sessions.write_text(
                    run_id,
                    f"{artifact_prefix}-{attempt}.raw.txt",
                    safe_result.raw_output,
                )
                self.sessions.write_json(
                    run_id, f"{artifact_prefix}-{attempt}.json", safe_result.data
                )
                self.sessions.write_json(
                    run_id,
                    f"{artifact_prefix}-{attempt}.candidates.json",
                    list(safe_result.candidates),
                )
                return safe_result
            except Exception as error:
                last_error = error
                path = self._record_failure(
                    error,
                    run_id=run_id,
                    phase=request.role,
                    extra={
                        "provider-attempt": attempt,
                        "artifact-prefix": artifact_prefix,
                    },
                )
                if attempt > retries:
                    raise KanbanError(
                        f"{request.role} failed after {attempt} attempt(s); diagnostics: {path}"
                    ) from error
        assert last_error is not None
        raise last_error

    def _resolve_mode(self, ticket: Ticket, requested: str) -> str:
        if ticket.mode == "hitl":
            return "hitl"
        if ticket.mode == "auto":
            return requested if requested == "hitl" else "auto"
        return requested

    def _select(
        self, *, ticket_ref: str | None, feature: str | None
    ) -> LocatedTicket | None:
        board = self.board.load()
        if ticket_ref:
            located = self.board.find_ticket(ticket_ref, board)
            if located.column != "ready":
                raise KanbanError(
                    f"Ticket {located.ticket.key} is {located.column}, not ready"
                )
            unresolved = board.unresolved_dependencies(located.ticket)
            if unresolved:
                raise KanbanError(
                    f"Ticket {located.ticket.key} is dependency-blocked: {list(unresolved)}"
                )
            return located
        eligible = board.eligible(feature)
        return eligible[0] if eligible else None

    def start(
        self,
        *,
        ticket_ref: str | None,
        feature: str | None,
        all_tickets: bool,
        mode: str,
        branch: str | None,
        max_attempts: int,
    ) -> dict[str, Any]:
        gitops.assert_index_clean(self.repo)
        gitops.ensure_topic_branch(self.repo, branch, self._protected_branches())
        if ticket_ref:
            try:
                existing_ticket = self.board.find_ticket(ticket_ref)
            except KanbanError:
                existing_ticket = None
            if existing_ticket is not None:
                existing = self.sessions.active_for_ticket(existing_ticket.ticket.key)
                if existing:
                    run_id, existing_state = existing
                    phase = existing_state.get("phase")
                    if phase in {"active", "implementing"}:
                        return self._attempt(
                            run_id, "Resume from the last safe checkpoint."
                        )
                    if phase == "awaiting-review":
                        packet = self.sessions.load(run_id).get("review-packet")
                        return {
                            "status": "awaiting-review",
                            "run-id": run_id,
                            "review-packet": (
                                json.loads(
                                    (self.sessions.path(run_id) / packet).read_text(
                                        encoding="utf-8"
                                    )
                                )
                                if packet
                                else None
                            ),
                        }
                    if phase in {"committing", "commit-created"}:
                        return self._recover_commit(run_id, existing_state)
                    if phase in {"paused", "blocked"}:
                        return {
                            "status": phase,
                            "run-id": run_id,
                            "ticket": existing_ticket.ticket.key,
                            "reason": existing_state.get("blocker"),
                        }
        running = [
            state
            for state in self.sessions.list_states()
            if state.get("phase")
            in {"starting", "active", "implementing", "committing", "commit-created"}
        ]
        if running:
            details = [
                f"{state.get('ticket')} ({state.get('run-id')}, {state.get('phase')})"
                for state in running
            ]
            raise KanbanError(
                "Another ticket has an active implementation session: "
                + ", ".join(details)
                + ". Resume it explicitly with --ticket before starting new work."
            )
        scope = (
            {"kind": "ticket", "value": ticket_ref}
            if ticket_ref
            else {"kind": "feature", "value": feature}
            if feature
            else {"kind": "all", "value": None}
        )
        located = self._select(ticket_ref=ticket_ref, feature=feature)
        if located is None:
            board = self.board.load()
            blocked = {
                key: list(board.unresolved_dependencies(item.ticket))
                for key, item in board.tickets.items()
                if item.column == "ready"
                and (feature is None or item.ticket.feature == feature)
            }
            return {"status": "no-eligible-ticket", "scope": scope, "blocked": blocked}
        ticket = located.ticket
        if self.sessions.active_for_ticket(ticket.key):
            raise KanbanError(f"Ticket already has an active session: {ticket.key}")
        effective_mode = self._resolve_mode(ticket, mode)
        baseline = gitops.capture_baseline(self.repo)
        provider = self.provider()
        configured_model = self.board.config().get("model")
        if configured_model is not None and not isinstance(configured_model, str):
            raise KanbanError("model must be a string when configured")
        run_id = self.sessions.create(
            {
                "ticket": ticket.key,
                "feature": ticket.feature,
                "phase": "starting",
                "mode": effective_mode,
                "provider": provider.name,
                "model": self.model or configured_model,
                "scope": scope,
                "max-attempts": max_attempts,
                "attempt": 0,
                "amendments": [],
                "baseline": baseline,
                "ticket-contract-hash": sha256_text(ticket.raw),
                "ticket-contract-source": f"contracts/start/{ticket.key}.md",
            }
        )
        self.sessions.write_text(run_id, f"contracts/start/{ticket.key}.md", ticket.raw)
        moved = self.board.transition(ticket, "ready", "active")
        self.sessions.save(
            run_id,
            {"phase": "active", "ticket-path": str(moved.path.relative_to(self.repo))},
        )
        self.sessions.event(
            run_id, "ticket-started", {"mode": effective_mode, "scope": scope}
        )
        return self._attempt(run_id, feedback=None)

    def _current_ticket(self, state: dict[str, Any]) -> tuple[Ticket, str]:
        board = self.board.load()
        located = board.tickets.get(state["ticket"])
        if located is None:
            raise KanbanError(f"Session ticket is missing: {state['ticket']}")
        return located.ticket, located.column

    def _contract_ticket(self, state: dict[str, Any]) -> Ticket:
        source = self.sessions.path(state["run-id"]) / state["ticket-contract-source"]
        return parse_ticket(source)

    def _strict_red(
        self, run_id: str, ticket: Ticket, state: dict[str, Any], feedback: str | None
    ) -> list[str]:
        before_paths, overlap = gitops.session_delta(self.repo, state["baseline"])
        if overlap:
            raise KanbanError(
                f"Session overlaps pre-existing user changes: {sorted(overlap)}"
            )
        request = AgentRequest(
            role="implementer-tests",
            prompt=implementer_prompt(
                ticket,
                mode=state["mode"],
                feedback=feedback,
                amendments=state.get("amendments", []),
                strict_test_phase=True,
            ),
            schema=IMPLEMENTER_SCHEMA,
            cwd=self.repo,
            writable=True,
            model=state.get("model"),
        )
        result = self._agent_call(
            run_id,
            request,
            f"attempt-{state['attempt']:02d}-tests",
            retries=int(self.board.config().get("provider-retries", 2)),
        )
        if result.data["status"] == "blocked":
            raise KanbanError(f"Test authoring blocked: {result.data['blocker']}")
        after_paths, overlap = gitops.session_delta(self.repo, state["baseline"])
        if overlap:
            raise KanbanError(
                f"Test phase overlaps pre-existing user changes: {sorted(overlap)}"
            )
        changed = after_paths - before_paths
        if not changed:
            raise KanbanError("Strict TDD test phase did not change a test")
        non_tests = sorted(path for path in changed if not _test_path(path))
        if non_tests:
            raise KanbanError(
                f"Strict TDD test phase changed non-test paths: {non_tests}"
            )
        assert ticket.tdd_test_command
        safe, reason = _command_is_safe(ticket.tdd_test_command)
        if not safe:
            raise KanbanError(f"Unsafe tdd-test-command: {reason}")
        red = gitops.run_verification(
            self.repo,
            [
                {
                    "command": ticket.tdd_test_command,
                    "expected-exit": 0,
                    "required": True,
                }
            ],
        )[0]
        combined = f"{red.get('stdout', '')}\n{red.get('stderr', '')}".lower()
        if (
            red.get("timeout")
            or red.get("exit") in {None, 0}
            or not any(
                marker in combined for marker in ("fail", "assert", "expected", "panic")
            )
        ):
            raise KanbanError(
                "Strict TDD RED gate did not produce a recognizable behavior failure"
            )
        self.sessions.write_json(
            run_id, f"attempt-{state['attempt']:02d}-red.json", red
        )
        return sorted(changed)

    def _verification_specs(
        self, ticket: Ticket, implementer: dict[str, Any]
    ) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
        accepted: list[dict[str, Any]] = []
        rejected: list[dict[str, Any]] = []
        for item in ticket.verification:
            specification = {
                "command": item.command,
                "expected-exit": item.expected_exit,
                "required": item.required,
                "source": "ticket",
            }
            safe, reason = _command_is_safe(item.command)
            if safe:
                accepted.append(specification)
            else:
                rejected.append(
                    {
                        **specification,
                        "passed": False,
                        "not-run": True,
                        "reason": reason,
                    }
                )
        seen = {item["command"] for item in accepted}
        for command in implementer.get("verification_commands", []):
            if command in seen:
                continue
            safe, reason = _command_is_safe(command)
            if safe:
                accepted.append(
                    {
                        "command": command,
                        "expected-exit": 0,
                        "required": True,
                        "source": "implementer",
                    }
                )
                seen.add(command)
            else:
                rejected.append(
                    {
                        "command": command,
                        "expected-exit": 0,
                        "required": True,
                        "source": "implementer",
                        "passed": False,
                        "not-run": True,
                        "reason": reason,
                    }
                )
        return accepted, rejected

    def _attempt(self, run_id: str, feedback: str | None) -> dict[str, Any]:
        state = self.sessions.load(run_id)
        ticket, column = self._current_ticket(state)
        if column not in {"active", "review"}:
            raise KanbanError(f"Cannot implement ticket in {column}")
        if column == "review":
            ticket = self.board.transition(ticket, "review", "active")
        attempt = int(state.get("attempt", 0)) + 1
        state = self.sessions.save(
            run_id,
            {"phase": "implementing", "attempt": attempt, "last-feedback": feedback},
        )
        contract = self._contract_ticket(state)
        strict_test_paths: list[str] = []
        try:
            if contract.strict_tdd and attempt == 1:
                strict_test_paths = self._strict_red(run_id, contract, state, feedback)
            test_fingerprints = gitops.fingerprints(self.repo, strict_test_paths)
            request = AgentRequest(
                role="implementer",
                prompt=implementer_prompt(
                    contract,
                    mode=state["mode"],
                    feedback=feedback,
                    amendments=state.get("amendments", []),
                ),
                schema=IMPLEMENTER_SCHEMA,
                cwd=self.repo,
                writable=True,
                model=state.get("model"),
            )
            implementation = self._agent_call(
                run_id,
                request,
                f"attempt-{attempt:02d}-implementation",
                retries=int(self.board.config().get("provider-retries", 2)),
            )
            if contract.strict_tdd and strict_test_paths:
                current_paths, current_overlap = gitops.session_delta(
                    self.repo, state["baseline"]
                )
                if current_overlap:
                    raise KanbanError(
                        "Strict TDD implementation overlapped pre-existing work: "
                        f"{sorted(current_overlap)}"
                    )
                extra_test_paths = {
                    path
                    for path in current_paths
                    if _test_path(path) and path not in strict_test_paths
                }
                if extra_test_paths:
                    raise KanbanError(
                        "Strict TDD implementation phase changed additional test paths: "
                        f"{sorted(extra_test_paths)}"
                    )
                changed_tests = {
                    path
                    for path, before in test_fingerprints.items()
                    if gitops.file_fingerprint(self.repo / path) != before
                }
                if changed_tests:
                    raise KanbanError(
                        f"Strict TDD implementation phase rewrote test paths: {sorted(changed_tests)}"
                    )
            if implementation.data["status"] == "blocked":
                return self._block(
                    run_id,
                    f"Implementation blocked: {implementation.data.get('blocker')}",
                    technical=False,
                )
            current_ticket, _ = self._current_ticket(state)
            if sha256_text(current_ticket.raw) != state["ticket-contract-hash"]:
                self.sessions.write_text(
                    run_id,
                    f"contracts/amendment-{attempt:02d}/{current_ticket.key}.md",
                    current_ticket.raw,
                )
                if state["mode"] == "auto":
                    return self._block(
                        run_id,
                        "Ticket changed during AUTO execution; human reconciliation is required.",
                        technical=False,
                    )
                self.sessions.save(
                    run_id,
                    {
                        "phase": "awaiting-amendment",
                        "pending-ticket-source": f"contracts/amendment-{attempt:02d}/{current_ticket.key}.md",
                        "implementer": implementation.data,
                    },
                )
                return {
                    "status": "awaiting-amendment",
                    "run-id": run_id,
                    "ticket": state["ticket"],
                    "actions": ["incorporate", "defer", "restart", "pause", "cancel"],
                }
            return self._finalize_candidate(run_id, contract, implementation.data)
        except KeyboardInterrupt as error:
            path = self._record_failure(
                error,
                run_id=run_id,
                phase="interrupted",
                extra={"attempt": attempt},
            )
            try:
                self._shelf(
                    run_id,
                    "blocked",
                    f"Execution interrupted; diagnostics: {path}",
                )
            except Exception as shelf_error:  # noqa: BLE001 - preserve interruption
                self._record_failure(
                    shelf_error,
                    run_id=run_id,
                    phase="interruption-shelving",
                    extra={"original-diagnostics": str(path)},
                )
            raise
        except Exception as error:
            path = self._record_failure(
                error, run_id=run_id, phase="implementation", extra={"attempt": attempt}
            )
            if state["mode"] == "auto":
                return self._block(
                    run_id,
                    f"Implementation failure; diagnostics: {path}",
                    technical=True,
                )
            raise KanbanError(f"Implementation failed; diagnostics: {path}") from error

    def _finalize_candidate(
        self, run_id: str, ticket: Ticket, implementer: dict[str, Any]
    ) -> dict[str, Any]:
        state = self.sessions.load(run_id)
        session_paths, overlap = gitops.session_delta(self.repo, state["baseline"])
        if overlap:
            raise KanbanError(
                f"Session modified pre-existing user work: {sorted(overlap)}"
            )
        if not session_paths:
            raise KanbanError(
                "Implementation produced no attributable repository changes"
            )
        patch = gitops.patch_for_paths(
            self.repo, session_paths, state["baseline"]["base-commit"]
        )
        digest = gitops.patch_hash(patch)
        attempt = state["attempt"]
        self.sessions.write_text(run_id, f"attempt-{attempt:02d}.patch", patch)
        specs, rejected = self._verification_specs(ticket, implementer)
        verification = gitops.run_verification(self.repo, specs) if specs else []
        verification.extend(rejected)
        if not verification:
            verification.append(
                {
                    "command": None,
                    "required": True,
                    "passed": False,
                    "not-run": True,
                    "reason": "No verification command or equivalent executable evidence was supplied.",
                }
            )
        self.sessions.write_json(
            run_id, f"attempt-{attempt:02d}-verification.json", verification
        )
        review = self._agent_call(
            run_id,
            AgentRequest(
                role="reviewer",
                prompt=reviewer_prompt(
                    ticket, patch, verification, state.get("amendments", [])
                ),
                schema=REVIEWER_SCHEMA,
                cwd=self.repo,
                writable=False,
                model=state.get("model"),
            ),
            f"attempt-{attempt:02d}-review",
            retries=int(self.board.config().get("provider-retries", 2)),
        ).data
        if (
            gitops.patch_hash(
                gitops.patch_for_paths(
                    self.repo, session_paths, state["baseline"]["base-commit"]
                )
            )
            != digest
        ):
            raise KanbanError("Candidate patch changed during independent review")
        blocking = [
            item for item in review["findings"] if item["classification"] == "blocking"
        ]
        if review["verdict"] == "accept" and blocking:
            review = {
                **review,
                "verdict": "revise",
                "summary": review["summary"] + " (blocking findings require revision)",
            }
        verification_ok = gitops.required_verification_passed(verification)
        suggested = implementer.get("proposed_commit_message")
        if (
            not isinstance(suggested, str)
            or not suggested.strip()
            or ticket.key.casefold() in suggested.casefold()
        ):
            suggested = ticket.title
        packet = {
            "ticket": ticket.key,
            "feature": ticket.feature,
            "summary": implementer["summary"],
            "changed-files": sorted(session_paths),
            "scope-notes": implementer.get("scope_notes", []),
            "assumptions": implementer.get("assumptions", []),
            "verification": verification,
            "verification-passed": verification_ok,
            "review": review,
            "patch-hash": digest,
            "patch-file": str(
                (
                    self.sessions.path(run_id) / f"attempt-{attempt:02d}.patch"
                ).relative_to(self.repo)
            )
            if self.sessions.path(run_id).is_relative_to(self.repo)
            else str(self.sessions.path(run_id) / f"attempt-{attempt:02d}.patch"),
            "proposed-commit-message": suggested.strip(),
            "amendments": state.get("amendments", []),
        }
        self.sessions.write_json(
            run_id, f"attempt-{attempt:02d}-review-packet.json", packet
        )
        state = self.sessions.save(
            run_id,
            {
                "phase": "awaiting-review",
                "session-paths": sorted(session_paths),
                "patch-hash": digest,
                "verification": verification,
                "verification-passed": verification_ok,
                "review": review,
                "review-packet": f"attempt-{attempt:02d}-review-packet.json",
                "proposed-commit-message": suggested.strip(),
                "implementer": implementer,
            },
        )
        current_ticket, column = self._current_ticket(state)
        if column == "active":
            self.board.transition(current_ticket, "active", "review")
        self.sessions.event(
            run_id,
            "candidate-reviewed",
            {"verdict": review["verdict"], "verification-passed": verification_ok},
        )
        if state["mode"] == "auto":
            if verification_ok and review["verdict"] == "accept":
                return self._commit(run_id, override_reason=None, message=None)
            if (
                review["verdict"] == "revise"
                and state["attempt"] < state["max-attempts"]
            ):
                feedback = json.dumps(blocking or review["findings"], indent=2)
                return self._attempt(run_id, feedback)
            return self._block(
                run_id,
                "AUTO candidate requires human review after verification or review did not pass.",
                technical=False,
            )
        return {
            "status": "awaiting-review",
            "run-id": run_id,
            "review-packet": packet,
            "actions": [
                "approve",
                "revise",
                "ask",
                "override",
                "pause",
                "abandon",
                "cancel",
            ],
        }

    def _shelf(
        self,
        run_id: str,
        destination: str,
        reason: str,
        *,
        pause_origin: str = "ticket",
    ) -> dict[str, Any]:
        state = self.sessions.load(run_id)
        ticket, column = self._current_ticket(state)
        session_paths, overlap = gitops.session_delta(self.repo, state["baseline"])
        if overlap:
            raise KanbanError(
                f"Cannot shelf session because it overlaps user work: {sorted(overlap)}"
            )
        patch_name: str | None = None
        if session_paths:
            patch = gitops.patch_for_paths(
                self.repo, session_paths, state["baseline"]["base-commit"]
            )
            patch_name = f"shelf-{state['revision'] + 1:04d}.patch"
            self.sessions.write_text(run_id, patch_name, patch)
            gitops.restore_paths(
                self.repo, session_paths, state["baseline"]["base-commit"]
            )
        if destination == "paused":
            self.board.pause_ticket(ticket.key, pause_origin)
        else:
            self.board.transition(ticket, column, destination)
        phase = "paused" if destination == "paused" else "blocked"
        self.sessions.save(
            run_id,
            {
                "phase": phase,
                "resume-column": column,
                "shelf-patch": patch_name,
                "session-paths": sorted(session_paths),
                "blocker": reason if phase == "blocked" else None,
            },
        )
        self.sessions.event(run_id, f"session-{phase}", {"reason": reason})
        return {
            "status": phase,
            "run-id": run_id,
            "ticket": ticket.key,
            "reason": reason,
        }

    def _block(self, run_id: str, reason: str, *, technical: bool) -> dict[str, Any]:
        result = self._shelf(run_id, "blocked", reason)
        state = self.sessions.load(run_id)
        self.sessions.save(
            run_id,
            {
                "technical-blocker": technical,
                "mode": "hitl" if state.get("mode") == "auto" else state.get("mode"),
                "escalated-from": "auto" if state.get("mode") == "auto" else None,
            },
        )
        return result

    def pause(self, reference: str) -> dict[str, Any]:
        board = self.board.load()
        located = self.board.find_ticket(reference, board)
        active = self.sessions.active_for_ticket(located.ticket.key)
        if active and located.column in {"active", "review", "blocked"}:
            run_id, state = active
            if state["phase"] == "blocked":
                # A blocked session is already shelved; preserve its original resume column.
                self.board.pause_ticket(located.ticket.key)
                self.sessions.save(
                    run_id, {"phase": "paused", "paused-blocker": state.get("blocker")}
                )
                return {
                    "status": "paused",
                    "run-id": run_id,
                    "ticket": located.ticket.key,
                }
            return self._shelf(run_id, "paused", "Paused by user")
        key = self.board.pause_ticket(reference)
        return {"status": "paused", "ticket": key}

    def resume(self, reference: str, feedback: str | None = None) -> dict[str, Any]:
        board = self.board.load()
        located = self.board.find_ticket(reference, board)
        active = self.sessions.active_for_ticket(located.ticket.key)
        if located.column == "blocked":
            if not active:
                raise KanbanError(
                    f"Blocked ticket has no resumable session: {located.ticket.key}"
                )
            key = located.ticket.key
            destination = active[1].get("resume-column", "active")
            if destination not in {"active", "review"}:
                destination = "active"
            self.board.transition(located.ticket, "blocked", destination)
        else:
            key, destination = self.board.resume_ticket(reference)
        if not active:
            return {"status": destination, "ticket": key}
        if destination == "paused":
            return {
                "status": "paused",
                "ticket": key,
                "run-id": active[0],
                "reason": "Other pause origins remain active",
            }
        run_id, state = active
        patch_name = state.get("shelf-patch")
        baseline = gitops.capture_baseline(self.repo)
        if patch_name:
            try:
                gitops.restore_patch(
                    self.repo,
                    self.sessions.path(run_id) / patch_name,
                    state.get("session-paths", []),
                )
            except Exception as error:  # noqa: BLE001 - persist resume diagnostics
                path = self._record_failure(
                    error, run_id=run_id, phase="resume", extra={"patch": patch_name}
                )
                current = self.board.load().tickets[key]
                if current.column != "blocked":
                    self.board.transition(current.ticket, current.column, "blocked")
                self.sessions.save(
                    run_id,
                    {
                        "phase": "blocked",
                        "blocker": f"Saved work conflicts with current checkout; diagnostics: {path}",
                    },
                )
                return {"status": "blocked", "run-id": run_id, "diagnostics": str(path)}
        resume_column = state.get("resume-column", destination)
        current = self.board.load().tickets[key]
        if current.column != resume_column and resume_column in {"active", "review"}:
            self.board.transition(current.ticket, current.column, resume_column)
        phase = "awaiting-review" if resume_column == "review" else "active"
        self.sessions.save(
            run_id,
            {
                "phase": phase,
                "baseline": baseline,
                "shelf-patch": None,
                "blocker": None,
            },
        )
        if phase == "active" and feedback:
            return self._attempt(run_id, feedback)
        if phase == "awaiting-review" and feedback:
            return self.review_action(run_id, "revise", feedback=feedback)
        return {"status": phase, "run-id": run_id, "ticket": key}

    def pause_feature(self, feature: str) -> dict[str, Any]:
        board = self.board.load()
        for located in board.feature_tickets(feature):
            if located.column in {"active", "review"}:
                active = self.sessions.active_for_ticket(located.ticket.key)
                if active:
                    self._shelf(
                        active[0],
                        "paused",
                        f"Feature {feature} paused",
                        pause_origin=f"feature:{feature}",
                    )
            elif located.column == "blocked":
                self.board.pause_ticket(located.ticket.key, f"feature:{feature}")
                active = self.sessions.active_for_ticket(located.ticket.key)
                if active:
                    self.sessions.save(active[0], {"phase": "paused"})
        keys = self.board.pause_feature(feature)
        return {"status": "paused", "feature": feature, "tickets": keys}

    def resume_feature(self, feature: str) -> dict[str, Any]:
        results = self.board.resume_feature(feature)
        restored: list[dict[str, Any]] = []
        for key, destination in results:
            active = self.sessions.active_for_ticket(key)
            if not active:
                restored.append({"ticket": key, "status": destination})
                continue
            run_id, state = active
            if state.get("phase") != "paused":
                continue
            if destination == "paused":
                restored.append(
                    {
                        "ticket": key,
                        "status": "paused",
                        "run-id": run_id,
                        "reason": "Other pause origins remain active",
                    }
                )
                continue
            if destination == "blocked":
                destination = state.get("resume-column", "active")
                if destination not in {"active", "review"}:
                    destination = "active"
                current = self.board.load().tickets[key]
                self.board.transition(current.ticket, "blocked", destination)
            # The feature operation already moved the ticket, so restore only its patch/state.
            baseline = gitops.capture_baseline(self.repo)
            patch_name = state.get("shelf-patch")
            if patch_name:
                try:
                    gitops.restore_patch(
                        self.repo,
                        self.sessions.path(run_id) / patch_name,
                        state.get("session-paths", []),
                    )
                except Exception as error:  # noqa: BLE001 - persist resume diagnostics
                    path = self._record_failure(
                        error, run_id=run_id, phase="feature-resume"
                    )
                    current = self.board.load().tickets[key]
                    self.board.transition(current.ticket, current.column, "blocked")
                    self.sessions.save(
                        run_id,
                        {"phase": "blocked", "blocker": f"Resume conflict: {path}"},
                    )
                    restored.append({"ticket": key, "status": "blocked"})
                    continue
            phase = "awaiting-review" if destination == "review" else "active"
            self.sessions.save(
                run_id,
                {"phase": phase, "baseline": baseline, "shelf-patch": None},
            )
            restored.append({"ticket": key, "status": phase, "run-id": run_id})
        return {"status": "resumed", "feature": feature, "tickets": restored}

    def review_action(
        self,
        run_id: str,
        action: str,
        *,
        feedback: str | None = None,
        reason: str | None = None,
        message: str | None = None,
    ) -> dict[str, Any]:
        state = self.sessions.load(run_id)
        if (
            action in {"incorporate", "defer", "restart"}
            and state["phase"] == "awaiting-amendment"
        ):
            return self._amendment_action(run_id, action)
        if action in {"approve", "revise", "ask", "override"}:
            amendment = self._detect_review_ticket_edit(run_id, state)
            if amendment is not None:
                return amendment
        if action == "pause":
            return self.pause(state["ticket"])
        if action == "ask":
            if not feedback:
                raise KanbanError("ask requires --feedback")
            return self._investigate(run_id, feedback)
        if action == "revise":
            if state["phase"] == "blocked":
                if not feedback:
                    raise KanbanError("revising a blocked session requires --feedback")
                self.resume(state["ticket"])
                state = self.sessions.load(run_id)
            if state["phase"] not in {"awaiting-review", "active"}:
                raise KanbanError(f"Cannot revise session in phase {state['phase']}")
            if not feedback:
                raise KanbanError("revise requires --feedback")
            amendment = {
                "at": dt.datetime.now(dt.timezone.utc).isoformat(),
                "source": "human",
                "feedback": feedback,
            }
            self.sessions.save(
                run_id,
                {"amendments": [*state.get("amendments", []), amendment]},
            )
            return self._attempt(run_id, feedback)
        if action == "approve":
            if state["phase"] != "awaiting-review":
                raise KanbanError(f"Cannot approve session in phase {state['phase']}")
            if (
                not state.get("verification-passed")
                or state.get("review", {}).get("verdict") != "accept"
            ):
                raise KanbanError(
                    "Candidate has failed verification or blocking review; use override with a reason"
                )
            return self._commit(run_id, override_reason=None, message=message)
        if action == "override":
            if state["phase"] != "awaiting-review":
                raise KanbanError(f"Cannot override session in phase {state['phase']}")
            if not reason or not reason.strip():
                raise KanbanError("override requires --reason")
            return self._commit(run_id, override_reason=reason.strip(), message=message)
        if action in {"abandon", "cancel"}:
            if action == "cancel" and (not reason or not reason.strip()):
                raise KanbanError("cancel requires --reason")
            return self._terminate(run_id, action, reason)
        raise KanbanError(f"Unsupported review action: {action}")

    def _detect_review_ticket_edit(
        self, run_id: str, state: dict[str, Any]
    ) -> dict[str, Any] | None:
        if state.get("phase") != "awaiting-review":
            return None
        current, _ = self._current_ticket(state)
        if sha256_text(current.raw) == state.get("ticket-contract-hash"):
            return None
        source = (
            f"contracts/review-amendment-{state['revision'] + 1:04d}/{current.key}.md"
        )
        self.sessions.write_text(run_id, source, current.raw)
        self.sessions.save(
            run_id,
            {
                "phase": "awaiting-amendment",
                "pending-ticket-source": source,
            },
        )
        self.sessions.event(
            run_id,
            "ticket-edit-detected",
            {"source": source, "previous-action-deferred": True},
        )
        return {
            "status": "awaiting-amendment",
            "run-id": run_id,
            "ticket": current.key,
            "actions": ["incorporate", "defer", "restart", "pause", "cancel"],
        }

    def _amendment_action(self, run_id: str, action: str) -> dict[str, Any]:
        state = self.sessions.load(run_id)
        current, _ = self._current_ticket(state)
        if action == "incorporate":
            source = state["pending-ticket-source"]
            amendments = [
                *state.get("amendments", []),
                {
                    "at": dt.datetime.now(dt.timezone.utc).isoformat(),
                    "source": "ticket-edit",
                    "contract-file": source,
                },
            ]
            self.sessions.save(
                run_id,
                {
                    "ticket-contract-hash": sha256_text(current.raw),
                    "ticket-contract-source": source,
                    "amendments": amendments,
                    "phase": "implementing",
                },
            )
            implementer = state.get("implementer")
            if not isinstance(implementer, dict):
                return self._attempt(run_id, "Incorporate the edited ticket contract.")
            return self._finalize_candidate(run_id, current, implementer)
        if action == "defer":
            self.sessions.save(
                run_id,
                {
                    "phase": "implementing",
                    "deferred-ticket-source": state["pending-ticket-source"],
                },
            )
            contract = self._contract_ticket(state)
            implementer = state.get("implementer")
            if not isinstance(implementer, dict):
                raise KanbanError("No implementation result exists to defer against")
            return self._finalize_candidate(run_id, contract, implementer)
        if action == "restart":
            session_paths, overlap = gitops.session_delta(self.repo, state["baseline"])
            if overlap:
                raise KanbanError(
                    f"Cannot restart overlapping session: {sorted(overlap)}"
                )
            gitops.restore_paths(
                self.repo, session_paths, state["baseline"]["base-commit"]
            )
            source = state["pending-ticket-source"]
            self.sessions.save(
                run_id,
                {
                    "phase": "active",
                    "ticket-contract-hash": sha256_text(current.raw),
                    "ticket-contract-source": source,
                    "baseline": gitops.capture_baseline(self.repo),
                },
            )
            return self._attempt(run_id, "Restart using the edited ticket contract.")
        raise KanbanError(f"Unsupported amendment action: {action}")

    def _investigate(self, run_id: str, question: str) -> dict[str, Any]:
        state = self.sessions.load(run_id)
        ticket = self._contract_ticket(state)
        paths = state.get("session-paths", [])
        before_patch = gitops.patch_for_paths(
            self.repo, paths, state["baseline"]["base-commit"]
        )
        result = self._agent_call(
            run_id,
            AgentRequest(
                role="investigator",
                prompt=f"""Investigate this question about the current candidate without editing files:
{question}

Ticket:
{json.dumps(_ticket_contract(ticket), indent=2)}

Patch:
```diff
{before_patch}
```

Return structured evidence. If unavailable, end with `Status: complete` or
`Status: blocked`.""",
                schema=INVESTIGATION_SCHEMA,
                cwd=self.repo,
                writable=False,
                model=state.get("model"),
            ),
            f"investigation-{state['revision'] + 1:04d}",
            retries=int(self.board.config().get("provider-retries", 2)),
        )
        after_patch = gitops.patch_for_paths(
            self.repo, paths, state["baseline"]["base-commit"]
        )
        if after_patch != before_patch:
            raise KanbanError("Read-only investigation changed the candidate patch")
        self.sessions.event(
            run_id, "investigation", {"question": question, "result": result.data}
        )
        return {"status": "investigated", "run-id": run_id, "result": result.data}

    def _commit(
        self, run_id: str, *, override_reason: str | None, message: str | None
    ) -> dict[str, Any]:
        state = self.sessions.load(run_id)
        ticket, column = self._current_ticket(state)
        if column != "review":
            raise KanbanError(f"Cannot commit ticket in {column}")
        session_paths, overlap = gitops.session_delta(self.repo, state["baseline"])
        if overlap:
            raise KanbanError(f"Candidate now overlaps user changes: {sorted(overlap)}")
        patch = gitops.patch_for_paths(
            self.repo, session_paths, state["baseline"]["base-commit"]
        )
        if gitops.patch_hash(patch) != state["patch-hash"]:
            raise KanbanError("Candidate patch differs from the reviewed patch")
        commit_message = (message or state["proposed-commit-message"]).strip()
        if not commit_message:
            raise KanbanError("Commit message must not be empty")
        if "\n" in commit_message or "\r" in commit_message:
            raise KanbanError("Commit message must be a single descriptive subject")
        if ticket.key.casefold() in commit_message.casefold():
            raise KanbanError("Commit message must not mention the local ticket key")
        gitops.ensure_topic_branch(self.repo, None, self._protected_branches())
        pre_commit_head = gitops.current_head(self.repo)
        self.sessions.save(
            run_id,
            {
                "phase": "committing",
                "pre-commit-head": pre_commit_head,
                "commit-message": commit_message,
                "session-paths": sorted(session_paths),
            },
        )
        try:
            commit_sha = gitops.commit_paths(self.repo, session_paths, commit_message)
            self.sessions.save(
                run_id,
                {"phase": "commit-created", "commit": commit_sha},
            )
            done_ticket = self.board.transition(ticket, "review", "done")
        except Exception as error:
            path = self._record_failure(
                error,
                run_id=run_id,
                phase="commit",
                extra={"pre-commit-head": pre_commit_head},
            )
            if gitops.current_head(self.repo) == pre_commit_head:
                self.sessions.save(run_id, {"phase": "awaiting-review"})
            raise KanbanError(f"Commit failed; diagnostics: {path}") from error
        completed = self.sessions.save(
            run_id,
            {
                "phase": "completed",
                "commit": commit_sha,
                "commit-message": commit_message,
                "override": (
                    {
                        "reason": override_reason,
                        "verification": state.get("verification"),
                        "review": state.get("review"),
                    }
                    if override_reason
                    else None
                ),
                "ticket-path": str(done_ticket.path.relative_to(self.repo)),
                "completed-at": dt.datetime.now(dt.timezone.utc).isoformat(),
            },
        )
        self.sessions.event(
            run_id,
            "ticket-completed",
            {"commit": commit_sha, "override": bool(override_reason)},
        )
        return {
            "status": "completed",
            "run-id": run_id,
            "ticket": ticket.key,
            "commit": commit_sha,
            "commit-message": commit_message,
            "override": completed.get("override"),
            "scope": state["scope"],
            "mode": state["mode"],
            "max-attempts": state["max-attempts"],
        }

    def _recover_commit(self, run_id: str, state: dict[str, Any]) -> dict[str, Any]:
        pre_commit_head = state.get("pre-commit-head")
        if not isinstance(pre_commit_head, str):
            raise KanbanError(f"Session {run_id} lacks pre-commit recovery data")
        current_head = gitops.current_head(self.repo)
        ticket, column = self._current_ticket(state)
        if current_head == pre_commit_head:
            if column != "review":
                raise KanbanError(
                    f"Interrupted pre-commit session has ticket in {column}, expected review"
                )
            self.sessions.save(run_id, {"phase": "awaiting-review"})
            packet_name = state.get("review-packet")
            packet = (
                json.loads(
                    (self.sessions.path(run_id) / packet_name).read_text(
                        encoding="utf-8"
                    )
                )
                if isinstance(packet_name, str)
                else None
            )
            return {
                "status": "awaiting-review",
                "run-id": run_id,
                "review-packet": packet,
                "recovered": "commit-not-created",
            }
        parent = gitops.git(self.repo, "rev-parse", f"{current_head}^")
        committed_paths = {
            item
            for item in gitops.git(
                self.repo,
                "diff-tree",
                "--no-commit-id",
                "--name-only",
                "--no-renames",
                "-r",
                "-z",
                current_head,
            ).split("\0")
            if item
        }
        expected_paths = set(state.get("session-paths", []))
        subject = gitops.git(self.repo, "show", "-s", "--format=%s", current_head)
        if (
            parent != pre_commit_head
            or committed_paths != expected_paths
            or subject != state.get("commit-message")
        ):
            raise KanbanError(
                "HEAD changed after an interrupted commit, but it does not match "
                "the reviewed session commit; manual reconciliation is required"
            )
        if column == "review":
            done_ticket = self.board.transition(ticket, "review", "done")
        elif column == "done":
            done_ticket = ticket
        else:
            raise KanbanError(
                f"Recovered commit has ticket in {column}, expected review or done"
            )
        completed = self.sessions.save(
            run_id,
            {
                "phase": "completed",
                "commit": current_head,
                "ticket-path": str(done_ticket.path.relative_to(self.repo)),
                "completed-at": dt.datetime.now(dt.timezone.utc).isoformat(),
            },
        )
        self.sessions.event(
            run_id,
            "commit-recovered",
            {"commit": current_head, "phase-before": state.get("phase")},
        )
        return {
            "status": "completed",
            "run-id": run_id,
            "ticket": ticket.key,
            "commit": current_head,
            "commit-message": completed.get("commit-message"),
            "override": completed.get("override"),
            "scope": completed["scope"],
            "mode": completed["mode"],
            "max-attempts": completed["max-attempts"],
            "recovered": "matching-commit",
        }

    def _terminate(
        self, run_id: str, action: str, reason: str | None
    ) -> dict[str, Any]:
        state = self.sessions.load(run_id)
        ticket, column = self._current_ticket(state)
        if column not in {"active", "review", "blocked", "paused"}:
            raise KanbanError(f"Cannot {action} ticket in {column}")
        if state.get("shelf-patch") is None and column in {"active", "review"}:
            session_paths, overlap = gitops.session_delta(self.repo, state["baseline"])
            if overlap:
                raise KanbanError(
                    f"Cannot {action} overlapping session: {sorted(overlap)}"
                )
            if session_paths:
                name = f"{action}-final.patch"
                self.sessions.write_text(
                    run_id,
                    name,
                    gitops.patch_for_paths(
                        self.repo, session_paths, state["baseline"]["base-commit"]
                    ),
                )
                gitops.restore_paths(
                    self.repo, session_paths, state["baseline"]["base-commit"]
                )
        destination = "cancelled" if action == "cancel" else "ready"
        current = self.board.load().tickets[ticket.key]
        if current.column == "paused":
            # Clear pause origins first, then place in the requested terminal/ready state.
            control = self.board.control()
            control["tickets"].pop(ticket.key, None)
            self.board.save_control(control)
        self.board.transition(current.ticket, current.column, destination)
        self.sessions.save(
            run_id,
            {
                "phase": "cancelled" if action == "cancel" else "abandoned",
                "termination-reason": reason,
            },
        )
        self.sessions.event(run_id, f"session-{action}", {"reason": reason})
        return {
            "status": "cancelled" if action == "cancel" else "abandoned",
            "ticket": ticket.key,
        }

    def continue_scope(self, result: dict[str, Any]) -> dict[str, Any]:
        if result.get("status") != "completed":
            return result
        scope = result.get("scope", {})
        if scope.get("kind") == "ticket":
            return result
        return self.start(
            ticket_ref=None,
            feature=scope.get("value") if scope.get("kind") == "feature" else None,
            all_tickets=scope.get("kind") == "all",
            mode=result.get("mode", "hitl"),
            branch=None,
            max_attempts=int(
                result.get("max-attempts", self.board.config().get("max-attempts", 3))
            ),
        )

    def status(self) -> dict[str, Any]:
        board = self.board.load()
        control = self.board.control()
        session_states = self.sessions.list_states()
        latest_session: dict[str, dict[str, Any]] = {}
        for state in session_states:
            key = state.get("ticket")
            if isinstance(key, str):
                latest_session[key] = state
        tickets: list[dict[str, Any]] = []
        for key, located in sorted(board.tickets.items()):
            unresolved = board.unresolved_dependencies(located.ticket)
            display = located.column
            if located.column == "ready" and unresolved:
                display = "blocked"
            tickets.append(
                {
                    "key": key,
                    "feature": located.ticket.feature,
                    "state": display,
                    "stored-state": located.column,
                    "dependencies": list(located.ticket.depends_on),
                    "unresolved-dependencies": list(unresolved),
                    "dependency-chains": board.dependency_chain(key)
                    if unresolved
                    else [],
                    "blocker": latest_session.get(key, {}).get("blocker")
                    if display == "blocked"
                    else None,
                    "cancellation-reason": latest_session.get(key, {}).get(
                        "termination-reason"
                    )
                    if located.column == "cancelled"
                    else None,
                    "priority": located.ticket.priority,
                    "pause": control["tickets"].get(key),
                    "policy": {
                        "mode": {
                            "value": located.ticket.mode,
                            "source": str(located.ticket.path.relative_to(self.repo)),
                        },
                        "priority": {
                            "value": located.ticket.priority,
                            "source": str(located.ticket.path.relative_to(self.repo)),
                        },
                    },
                    "session": (
                        self.sessions.active_for_ticket(key)[0]
                        if self.sessions.active_for_ticket(key)
                        else None
                    ),
                }
            )
        features = [
            {
                "feature": slug,
                "ticket-prefix": feature.prefix,
                "status": feature_status(board, slug),
                "paused": slug in control["features"],
                "policy": {
                    "priority": {
                        "value": feature.priority,
                        "source": str(feature.path.relative_to(self.repo)),
                    }
                },
                "tickets": [item.ticket.key for item in board.feature_tickets(slug)],
            }
            for slug, feature in sorted(board.features.items())
        ]
        return {
            "schema-version": 3,
            "features": features,
            "tickets": tickets,
            "archived-features": sorted(board.archived_features),
            "legacy-v2-runtime": {
                "path": str(self.sessions.root / "runs"),
                "runs": sorted(
                    path.name
                    for path in (self.sessions.root / "runs").glob("*")
                    if path.is_dir()
                ),
            },
            "sessions": session_states,
            "effective-config": self._effective_policy(),
        }

    def validate(self) -> dict[str, Any]:
        board = self.board.load()
        return {
            "status": "valid",
            "schema-version": 3,
            "features": len(board.features),
            "tickets": len(board.tickets),
            "archived-features": len(board.archived_features),
        }

    def migrate(self, *, apply: bool, restore: str | None = None) -> dict[str, Any]:
        if restore:
            return restore_migration(self.board, restore)
        return apply_migration(self.board) if apply else migration_preview(self.board)

    def archive(self, feature: str) -> dict[str, Any]:
        target = self.board.archive_feature(feature)
        return {"status": "archived", "feature": feature, "path": str(target)}

    def restore_archive(self, feature: str) -> dict[str, Any]:
        self.board.restore_feature(feature)
        return {"status": "restored", "feature": feature}

    def prune(self, *, apply: bool) -> dict[str, Any]:
        candidates: list[str] = []
        for state in self.sessions.list_states():
            if state.get("phase") != "completed":
                continue
            path = self.sessions.path(state["run-id"])
            for artifact in path.iterdir():
                if artifact.name.endswith((".raw.txt", ".patch")):
                    candidates.append(str(artifact))
        if apply:
            for item in candidates:
                Path(item).unlink(missing_ok=True)
        return {"status": "pruned" if apply else "preview", "artifacts": candidates}
