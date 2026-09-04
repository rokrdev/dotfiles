"""Capability-aware provider adapters and strict authority-result parsing."""

from __future__ import annotations

import dataclasses
import json
import os
import re
import shutil
import subprocess
import tempfile
from collections.abc import Iterable
from pathlib import Path
from typing import Any

from .model import KanbanError

IMPLEMENTER_SCHEMA = {
    "type": "object",
    "properties": {
        "status": {"enum": ["complete", "blocked"]},
        "summary": {"type": "string"},
        "files_changed": {"type": "array", "items": {"type": "string"}},
        "verification_commands": {
            "type": "array",
            "items": {"type": "string"},
        },
        "proposed_commit_message": {"type": ["string", "null"]},
        "assumptions": {"type": "array", "items": {"type": "string"}},
        "scope_notes": {"type": "array", "items": {"type": "string"}},
        "blocker": {"type": ["string", "null"]},
    },
    "required": [
        "status",
        "summary",
        "files_changed",
        "verification_commands",
        "proposed_commit_message",
        "assumptions",
        "scope_notes",
        "blocker",
    ],
    "additionalProperties": False,
}

FINDING_SCHEMA = {
    "type": "object",
    "properties": {
        "id": {"type": "string"},
        "classification": {"enum": ["blocking", "advisory"]},
        "category": {
            "enum": [
                "acceptance",
                "correctness",
                "regression",
                "coverage",
                "security",
                "data-loss",
                "scope",
                "verification",
                "maintainability",
                "style",
            ]
        },
        "summary": {"type": "string"},
        "evidence": {"type": "string"},
        "path": {"type": ["string", "null"]},
        "required_outcome": {"type": ["string", "null"]},
    },
    "required": [
        "id",
        "classification",
        "category",
        "summary",
        "evidence",
        "path",
        "required_outcome",
    ],
    "additionalProperties": False,
}

REVIEWER_SCHEMA = {
    "type": "object",
    "properties": {
        "verdict": {"enum": ["accept", "revise", "blocked"]},
        "summary": {"type": "string"},
        "findings": {"type": "array", "items": FINDING_SCHEMA},
        "assumptions": {"type": "array", "items": {"type": "string"}},
    },
    "required": ["verdict", "summary", "findings", "assumptions"],
    "additionalProperties": False,
}

INVESTIGATION_SCHEMA = {
    "type": "object",
    "properties": {
        "status": {"enum": ["complete", "blocked"]},
        "summary": {"type": "string"},
        "evidence": {"type": "array", "items": {"type": "string"}},
        "blocker": {"type": ["string", "null"]},
    },
    "required": ["status", "summary", "evidence", "blocker"],
    "additionalProperties": False,
}


@dataclasses.dataclass(frozen=True)
class AgentRequest:
    role: str
    prompt: str
    schema: dict[str, Any]
    cwd: Path
    writable: bool
    model: str | None = None
    effort: str | None = None
    timeout: int = 3600


@dataclasses.dataclass(frozen=True)
class AgentResult:
    data: dict[str, Any]
    raw_output: str
    stdout: str
    stderr: str
    command: tuple[str, ...]
    candidates: tuple[dict[str, Any], ...]


class ProviderFailure(KanbanError):
    def __init__(self, message: str, diagnostics: dict[str, Any]) -> None:
        super().__init__(message)
        self.diagnostics = diagnostics


def validate_schema(value: Any, schema: dict[str, Any], path: str = "$") -> None:
    expected = schema.get("type")
    expected_types = expected if isinstance(expected, list) else [expected]
    checks = {
        "object": lambda item: isinstance(item, dict),
        "array": lambda item: isinstance(item, list),
        "string": lambda item: isinstance(item, str),
        "boolean": lambda item: isinstance(item, bool),
        "integer": lambda item: isinstance(item, int) and not isinstance(item, bool),
        "null": lambda item: item is None,
    }
    if expected is not None and not any(checks[name](value) for name in expected_types):
        raise KanbanError(
            f"{path}: expected {' or '.join(expected_types)}, got {type(value).__name__}"
        )
    if "enum" in schema and value not in schema["enum"]:
        raise KanbanError(f"{path}: {value!r} is not one of {schema['enum']}")
    if isinstance(value, dict):
        properties = schema.get("properties", {})
        missing = set(schema.get("required", [])) - value.keys()
        if missing:
            raise KanbanError(f"{path}: missing fields {sorted(missing)}")
        if schema.get("additionalProperties") is False:
            extra = value.keys() - properties.keys()
            if extra:
                raise KanbanError(f"{path}: unexpected fields {sorted(extra)}")
        for key, item in value.items():
            if key in properties:
                validate_schema(item, properties[key], f"{path}.{key}")
    if isinstance(value, list) and isinstance(schema.get("items"), dict):
        for index, item in enumerate(value):
            validate_schema(item, schema["items"], f"{path}[{index}]")


def json_values(raw: str) -> list[Any]:
    values: list[Any] = []

    def decode(text: str) -> None:
        try:
            values.append(json.loads(text))
        except json.JSONDecodeError:
            return

    decode(raw)
    for line in raw.splitlines():
        decode(line)
    for fenced in re.findall(
        r"```(?:json)?\s*\n?(.*?)```", raw, re.IGNORECASE | re.DOTALL
    ):
        decode(fenced.strip())
    decoder = json.JSONDecoder()
    for index, character in enumerate(raw):
        if character not in "[{":
            continue
        try:
            value, _ = decoder.raw_decode(raw[index:])
        except json.JSONDecodeError:
            continue
        values.append(value)
    return values


def json_mappings(value: Any) -> Iterable[dict[str, Any]]:
    if isinstance(value, dict):
        yield value
        nested = value.values()
    elif isinstance(value, list):
        nested = value
    else:
        return
    for item in nested:
        if isinstance(item, str):
            for decoded in json_values(item):
                yield from json_mappings(decoded)
        else:
            yield from json_mappings(item)


def _provider_error(values: Iterable[Any]) -> str | None:
    for value in values:
        for mapping in json_mappings(value):
            kind = str(mapping.get("type", mapping.get("event", ""))).lower()
            error = mapping.get("error")
            if kind in {"error", "failed", "failure"} or error is not None:
                if isinstance(error, dict):
                    return str(error.get("message") or error.get("detail") or error)
                return str(error or mapping.get("message") or mapping)
    return None


def _labelled_fallback(raw: str, schema: dict[str, Any]) -> dict[str, Any] | None:
    plain = re.sub(r"[*_`]", "", raw)
    if "status" in schema.get("properties", {}):
        decisions = {
            item.lower()
            for item in re.findall(
                r"(?im)^\s*(?:#{1,6}\s*)?status\s*:\s*(complete|blocked)\s*$",
                plain,
            )
        }
        if len(decisions) != 1:
            return None
        status = decisions.pop()
        if schema is INVESTIGATION_SCHEMA:
            return {
                "status": status,
                "summary": raw.strip(),
                "evidence": [],
                "blocker": raw.strip() if status == "blocked" else None,
            }
        return {
            "status": status,
            "summary": raw.strip(),
            "files_changed": [],
            "verification_commands": [],
            "proposed_commit_message": None,
            "assumptions": [],
            "scope_notes": [],
            "blocker": raw.strip() if status == "blocked" else None,
        }
    decisions = {
        item.lower()
        for item in re.findall(
            r"(?im)^\s*(?:#{1,6}\s*)?verdict\s*:\s*(accept|revise|blocked)\s*$",
            plain,
        )
    }
    if len(decisions) != 1:
        return None
    verdict = decisions.pop()
    finding = []
    if verdict == "revise":
        finding = [
            {
                "id": "UNSTRUCTURED_REVIEW",
                "classification": "blocking",
                "category": "verification",
                "summary": "Reviewer returned an unstructured revision request",
                "evidence": raw.strip(),
                "path": None,
                "required_outcome": "Resolve the review report and return structured evidence.",
            }
        ]
    return {
        "verdict": verdict,
        "summary": raw.strip(),
        "findings": finding,
        "assumptions": [],
    }


def parse_agent_result(
    raw: str, schema: dict[str, Any]
) -> tuple[dict[str, Any], tuple[dict[str, Any], ...]]:
    values = json_values(raw)
    valid: list[dict[str, Any]] = []
    candidates: list[dict[str, Any]] = []
    properties = set(schema.get("properties", {}))
    for value in values:
        for mapping in json_mappings(value):
            if not mapping.keys() & properties:
                continue
            candidate: dict[str, Any] = {"value": mapping}
            try:
                validate_schema(mapping, schema)
            except KanbanError as error:
                candidate["valid"] = False
                candidate["error"] = str(error)
            else:
                candidate["valid"] = True
                valid.append(mapping)
            candidates.append(candidate)
    if valid:
        return valid[-1], tuple(candidates)
    provider_error = _provider_error(values)
    fallback_reports = [
        mapping.get("result")
        for value in values
        for mapping in json_mappings(value)
        if mapping.get("type") == "result" and isinstance(mapping.get("result"), str)
    ]
    fallback_source = fallback_reports[-1] if fallback_reports else raw
    fallback = _labelled_fallback(fallback_source, schema)
    if fallback is not None:
        validate_schema(fallback, schema)
        candidates.append(
            {"value": fallback, "valid": True, "source": "labelled-prose"}
        )
        return fallback, tuple(candidates)
    reason = (
        "provider reported an error"
        if provider_error
        else "no schema-valid authority result"
    )
    details = {
        "reason": reason,
        "provider-error": provider_error,
        "raw-output": raw,
        "decoded-json-values": values,
        "candidates": candidates,
        "expected-required-fields": schema.get("required", []),
    }
    if candidates:
        reason += f"; last validation error: {candidates[-1].get('error')}"
    raise ProviderFailure(reason, details)


class ProviderAdapter:
    name = "base"
    executable = ""

    def available(self) -> bool:
        return shutil.which(self.executable) is not None

    def capabilities(self) -> dict[str, bool]:
        return {
            "writable-execution": True,
            "read-only-review": True,
            "structured-results": True,
            "cancellation": True,
            "session-resume": False,
        }

    def build_command(
        self, request: AgentRequest, schema_path: Path, output_path: Path
    ) -> list[str]:
        raise NotImplementedError

    def environment(self, request: AgentRequest) -> dict[str, str]:
        return os.environ.copy()

    def run(self, request: AgentRequest) -> AgentResult:
        with tempfile.TemporaryDirectory(prefix="kanban-agent-") as directory:
            temporary = Path(directory)
            schema_path = temporary / "schema.json"
            output_path = temporary / "output.json"
            schema_path.write_text(json.dumps(request.schema), encoding="utf-8")
            command = self.build_command(request, schema_path, output_path)
            try:
                completed = subprocess.run(
                    command,
                    cwd=request.cwd,
                    text=True,
                    input=request.prompt if command[-1] == "-" else None,
                    capture_output=True,
                    check=False,
                    env=self.environment(request),
                    timeout=request.timeout,
                )
            except subprocess.TimeoutExpired as error:
                raise ProviderFailure(
                    f"Provider timed out after {request.timeout}s",
                    {
                        "reason": "timeout",
                        "timeout-seconds": request.timeout,
                        "command": command,
                        "stdout": error.stdout or "",
                        "stderr": error.stderr or "",
                    },
                ) from error
            output_parts = [completed.stdout] if completed.stdout.strip() else []
            if output_path.exists():
                result_text = output_path.read_text(encoding="utf-8")
                if result_text.strip():
                    output_parts.append(result_text)
            raw = "\n".join(output_parts)
            if completed.returncode:
                raise ProviderFailure(
                    f"Provider exited {completed.returncode}",
                    {
                        "reason": "non-zero-exit",
                        "exit": completed.returncode,
                        "command": command,
                        "stdout": completed.stdout,
                        "stderr": completed.stderr,
                        "raw-output": raw,
                    },
                )
            try:
                data, candidates = parse_agent_result(raw, request.schema)
            except ProviderFailure as error:
                raise ProviderFailure(
                    str(error),
                    {
                        **error.diagnostics,
                        "exit": completed.returncode,
                        "command": command,
                        "stdout": completed.stdout,
                        "stderr": completed.stderr,
                    },
                ) from error
            return AgentResult(
                data,
                raw,
                completed.stdout,
                completed.stderr,
                tuple(command),
                candidates,
            )


class ClaudeAdapter(ProviderAdapter):
    name = "claude"
    executable = "claude"

    def build_command(
        self, request: AgentRequest, schema_path: Path, output_path: Path
    ) -> list[str]:
        tools = ["Read", "Glob", "Grep"]
        if request.writable:
            tools.extend(["Edit", "Write"])
        name = f"kanban-{request.role}"
        agent = {
            name: {
                "description": f"Kanban {request.role}",
                "prompt": "Follow the supplied delivery contract and safety boundary.",
                "tools": tools,
                "disallowedTools": ["Agent", "Skill", "WebSearch", "WebFetch", "Bash"],
                "permissionMode": "dontAsk",
                "maxTurns": 100,
            }
        }
        command = [
            self.executable,
            "-p",
            "--output-format",
            "json",
            "--json-schema",
            json.dumps(request.schema, separators=(",", ":")),
            "--permission-mode",
            "dontAsk",
            "--disable-slash-commands",
            "--agents",
            json.dumps(agent, separators=(",", ":")),
            "--agent",
            name,
            "--no-session-persistence",
        ]
        if request.model:
            command.extend(["--model", request.model])
        if request.effort:
            command.extend(["--effort", request.effort])
        command.append(request.prompt)
        return command

    def environment(self, request: AgentRequest) -> dict[str, str]:
        environment = super().environment(request)
        environment.pop("CLAUDECODE", None)
        environment.pop("CLAUDE_CODE_ENTRYPOINT", None)
        return environment


class CodexAdapter(ProviderAdapter):
    name = "codex"
    executable = "codex"

    def build_command(
        self, request: AgentRequest, schema_path: Path, output_path: Path
    ) -> list[str]:
        command = [
            self.executable,
            "exec",
            "--ephemeral",
            "--ignore-user-config",
            "--output-schema",
            str(schema_path),
            "--output-last-message",
            str(output_path),
            "--color",
            "never",
            "--cd",
            str(request.cwd),
            "--sandbox",
            "workspace-write" if request.writable else "read-only",
            "-c",
            'approval_policy="never"',
        ]
        if request.model:
            command.extend(["--model", request.model])
        if request.effort:
            command.extend(["-c", f'model_reasoning_effort="{request.effort}"'])
        command.append("-")
        return command


class OpenCodeAdapter(ProviderAdapter):
    name = "opencode"

    def __init__(self) -> None:
        self.executable = next(
            (name for name in ("opencode2", "opencode") if shutil.which(name)),
            "opencode2",
        )

    def available(self) -> bool:
        return any(shutil.which(name) for name in ("opencode2", "opencode"))

    def build_command(
        self, request: AgentRequest, schema_path: Path, output_path: Path
    ) -> list[str]:
        prompt = (
            f"{request.prompt}\n\nReturn exactly one JSON object matching:\n"
            f"{json.dumps(request.schema, separators=(',', ':'))}"
        )
        command = [self.executable, "run"]
        if self.executable == "opencode2":
            command.append("--standalone")
        else:
            command.extend(["--dir", str(request.cwd)])
        command.extend(["--format", "json", "--agent", f"kanban-{request.role}"])
        if request.model:
            command.extend(["--model", request.model])
        command.append(prompt)
        return command

    def environment(self, request: AgentRequest) -> dict[str, str]:
        environment = super().environment(request)
        edit = "allow" if request.writable else "deny"
        config = {
            "agent": {
                f"kanban-{request.role}": {
                    "description": f"Kanban {request.role}",
                    "mode": "primary",
                    "permission": {
                        "*": "deny",
                        "read": "allow",
                        "glob": "allow",
                        "grep": "allow",
                        "edit": edit,
                        "bash": "deny",
                        "task": "deny",
                        "skill": "deny",
                        "webfetch": "deny",
                        "websearch": "deny",
                    },
                }
            }
        }
        environment["OPENCODE_CONFIG_CONTENT"] = json.dumps(
            config, separators=(",", ":")
        )
        return environment


ADAPTERS: dict[str, type[ProviderAdapter]] = {
    "claude": ClaudeAdapter,
    "codex": CodexAdapter,
    "opencode": OpenCodeAdapter,
}


def detect_host_provider(environment: dict[str, str]) -> str | None:
    if environment.get("CLAUDECODE") or environment.get("CLAUDE_CODE_ENTRYPOINT"):
        return "claude"
    if environment.get("CODEX_THREAD_ID") or environment.get("CODEX_SESSION_ID"):
        return "codex"
    if environment.get("OPENCODE_SESSION_ID") or environment.get("OPENCODE_PID"):
        return "opencode"
    return None


def select_provider(requested: str, config: dict[str, Any]) -> ProviderAdapter:
    candidates: list[str] = []
    strict = False
    if requested != "auto":
        candidates.append(requested)
        strict = True
    configured = config.get("provider")
    if not candidates and isinstance(configured, str):
        candidates.append(configured)
        strict = True
    if not candidates:
        host = detect_host_provider(os.environ)
        if host:
            candidates.append(host)
        candidates.extend(name for name in ADAPTERS if name not in candidates)
    for name in candidates:
        adapter_type = ADAPTERS.get(name)
        if adapter_type is None:
            raise KanbanError(
                f"Unknown provider {name!r}; choose {', '.join(ADAPTERS)}"
            )
        adapter = adapter_type()
        if adapter.available():
            return adapter
        if strict:
            raise KanbanError(f"Provider executable not found: {adapter.executable}")
    raise KanbanError("No supported provider executable found")


def redact(value: Any, environment: dict[str, str] | None = None) -> Any:
    environment = environment or os.environ
    secrets = [
        item
        for key, item in environment.items()
        if any(
            marker in key.upper()
            for marker in ("TOKEN", "SECRET", "PASSWORD", "API_KEY", "AUTH")
        )
        and len(item) >= 4
    ]

    def clean(text: str) -> str:
        result = text
        for secret in secrets:
            result = result.replace(secret, "<redacted>")
        result = re.sub(
            r"(?i)bearer\s+[A-Za-z0-9._~+/=-]+", "Bearer <redacted>", result
        )
        return result

    if isinstance(value, str):
        return clean(value)
    if isinstance(value, dict):
        return {str(key): redact(item, environment) for key, item in value.items()}
    if isinstance(value, list):
        return [redact(item, environment) for item in value]
    if isinstance(value, tuple):
        return [redact(item, environment) for item in value]
    return value
