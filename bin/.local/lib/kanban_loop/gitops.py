"""Git ownership, patch attribution, verification, shelving, and commits."""

from __future__ import annotations

import hashlib
import os
import shutil
import subprocess
import tempfile
from collections.abc import Iterable
from pathlib import Path
from typing import Any

from .model import KanbanError

PROTECTED_BRANCHES = {"main", "master", "develop"}


class CommandFailure(KanbanError):
    def __init__(self, message: str, diagnostics: dict[str, Any]) -> None:
        super().__init__(message)
        self.diagnostics = diagnostics


def run(
    command: list[str],
    repo: Path,
    *,
    check: bool = True,
    environment: dict[str, str] | None = None,
    input_text: str | None = None,
    timeout: int = 3600,
) -> subprocess.CompletedProcess[str]:
    try:
        completed = subprocess.run(
            command,
            cwd=repo,
            text=True,
            input=input_text,
            capture_output=True,
            check=False,
            env=environment,
            timeout=timeout,
        )
    except subprocess.TimeoutExpired as error:
        raise CommandFailure(
            f"Command timed out after {timeout}s: {' '.join(command)}",
            {
                "reason": "timeout",
                "command": command,
                "timeout-seconds": timeout,
                "stdout": error.stdout or "",
                "stderr": error.stderr or "",
            },
        ) from error
    if check and completed.returncode:
        raise CommandFailure(
            f"Command exited {completed.returncode}: {' '.join(command)}",
            {
                "reason": "non-zero-exit",
                "command": command,
                "exit": completed.returncode,
                "stdout": completed.stdout,
                "stderr": completed.stderr,
            },
        )
    return completed


def git(
    repo: Path,
    *arguments: str,
    check: bool = True,
    environment: dict[str, str] | None = None,
) -> str:
    return run(
        ["git", *arguments], repo, check=check, environment=environment
    ).stdout.strip()


def current_head(repo: Path) -> str:
    return git(repo, "rev-parse", "HEAD")


def current_branch(repo: Path) -> str:
    branch = git(repo, "symbolic-ref", "--quiet", "--short", "HEAD", check=False)
    if not branch:
        raise KanbanError("Detached HEAD is not supported")
    return branch


def assert_index_clean(repo: Path) -> None:
    paths = git(repo, "diff", "--cached", "--name-only")
    if paths:
        raise KanbanError(
            "Git index must be clean; staged changes have ambiguous ownership:\n"
            + paths
        )


def ensure_topic_branch(
    repo: Path,
    branch: str | None,
    protected_branches: Iterable[str] | None = None,
) -> str:
    current = current_branch(repo)
    protected = set(protected_branches or PROTECTED_BRANCHES)
    if current not in protected:
        return current
    if not branch:
        raise KanbanError(
            f"Refusing to commit on protected branch {current!r}; provide --branch"
        )
    exists = (
        run(
            ["git", "show-ref", "--verify", "--quiet", f"refs/heads/{branch}"],
            repo,
            check=False,
        ).returncode
        == 0
    )
    if exists:
        raise KanbanError(f"Branch already exists: {branch}")
    git(repo, "switch", "-c", branch)
    return branch


def changed_paths(repo: Path) -> set[str]:
    tracked = git(repo, "diff", "--name-only", "-z", "HEAD")
    untracked = git(repo, "ls-files", "--others", "--exclude-standard", "-z")
    return {
        item
        for item in f"{tracked}\0{untracked}".split("\0")
        if item and item != ".workflow" and not item.startswith(".workflow/")
    }


def file_fingerprint(path: Path) -> str | None:
    if path.is_symlink():
        return "symlink:" + os.readlink(path)
    if path.is_file():
        digest = hashlib.sha256()
        with path.open("rb") as handle:
            for chunk in iter(lambda: handle.read(1024 * 1024), b""):
                digest.update(chunk)
        return digest.hexdigest()
    if path.exists():
        return "<non-file>"
    return None


def fingerprints(repo: Path, paths: Iterable[str]) -> dict[str, str | None]:
    return {path: file_fingerprint(repo / path) for path in sorted(set(paths))}


def capture_baseline(repo: Path) -> dict[str, Any]:
    assert_index_clean(repo)
    paths = changed_paths(repo)
    return {
        "base-commit": current_head(repo),
        "branch": current_branch(repo),
        "baseline-paths": sorted(paths),
        "baseline-fingerprints": fingerprints(repo, paths),
    }


def session_delta(repo: Path, baseline: dict[str, Any]) -> tuple[set[str], set[str]]:
    if current_head(repo) != baseline["base-commit"]:
        raise KanbanError("HEAD changed during the active session")
    if current_branch(repo) != baseline["branch"]:
        raise KanbanError("Git branch changed during the active session")
    assert_index_clean(repo)
    before_paths = set(baseline.get("baseline-paths", []))
    after_paths = changed_paths(repo)
    session_paths = after_paths - before_paths
    overlap: set[str] = set()
    before_fingerprints = baseline.get("baseline-fingerprints", {})
    for path in before_paths:
        if file_fingerprint(repo / path) != before_fingerprints.get(path):
            overlap.add(path)
    return session_paths, overlap


def patch_for_paths(repo: Path, paths: Iterable[str], base: str = "HEAD") -> str:
    selected = sorted(set(paths))
    if not selected:
        return ""
    actual_index = Path(git(repo, "rev-parse", "--git-path", "index"))
    if not actual_index.is_absolute():
        actual_index = repo / actual_index
    with tempfile.NamedTemporaryFile(prefix="kanban-index-", delete=False) as handle:
        temporary = Path(handle.name)
    try:
        if actual_index.exists():
            shutil.copy2(actual_index, temporary)
        else:
            temporary.unlink(missing_ok=True)
        environment = os.environ.copy()
        environment["GIT_INDEX_FILE"] = str(temporary)
        run(["git", "add", "-A", "--", *selected], repo, environment=environment)
        return run(
            [
                "git",
                "diff",
                "--cached",
                "--binary",
                "--no-renames",
                base,
                "--",
                *selected,
            ],
            repo,
            environment=environment,
        ).stdout
    finally:
        temporary.unlink(missing_ok=True)


def patch_hash(patch: str) -> str:
    return hashlib.sha256(patch.encode("utf-8")).hexdigest()


def restore_paths(repo: Path, paths: Iterable[str], base: str) -> None:
    assert_index_clean(repo)
    for relative in sorted(set(paths)):
        target = repo / relative
        tracked = (
            run(
                ["git", "cat-file", "-e", f"{base}:{relative}"], repo, check=False
            ).returncode
            == 0
        )
        if tracked:
            git(repo, "restore", f"--source={base}", "--worktree", "--", relative)
        elif target.is_file() or target.is_symlink():
            target.unlink()
            parent = target.parent
            while parent != repo and parent.is_dir() and not any(parent.iterdir()):
                parent.rmdir()
                parent = parent.parent
        elif target.exists():
            raise KanbanError(f"Refusing to remove non-file session path: {relative}")


def restore_patch(repo: Path, patch_path: Path, expected_paths: Iterable[str]) -> None:
    assert_index_clean(repo)
    overlap = changed_paths(repo) & set(expected_paths)
    if overlap:
        raise KanbanError(
            f"Cannot resume; current work overlaps saved session: {sorted(overlap)}"
        )
    check = run(
        ["git", "apply", "--check", "--whitespace=nowarn", str(patch_path)],
        repo,
        check=False,
    )
    if check.returncode:
        raise CommandFailure(
            "Saved patch no longer applies cleanly",
            {
                "reason": "patch-conflict",
                "command": ["git", "apply", "--check", str(patch_path)],
                "exit": check.returncode,
                "stdout": check.stdout,
                "stderr": check.stderr,
                "patch": str(patch_path),
            },
        )
    run(["git", "apply", "--whitespace=nowarn", str(patch_path)], repo)


def run_verification(
    repo: Path, commands: Iterable[dict[str, Any]]
) -> list[dict[str, Any]]:
    results: list[dict[str, Any]] = []
    expected_head = current_head(repo)
    before_paths = changed_paths(repo)
    before_fingerprints = fingerprints(repo, before_paths)
    for specification in commands:
        command = specification["command"]
        expected = int(specification.get("expected-exit", 0))
        required = bool(specification.get("required", True))
        try:
            completed = subprocess.run(
                command,
                cwd=repo,
                shell=True,
                executable="/bin/sh",
                text=True,
                capture_output=True,
                check=False,
                timeout=int(specification.get("timeout", 3600)),
            )
            result = {
                "command": command,
                "exit": completed.returncode,
                "expected-exit": expected,
                "required": required,
                "passed": completed.returncode == expected,
                "stdout": completed.stdout,
                "stderr": completed.stderr,
            }
        except subprocess.TimeoutExpired as error:
            result = {
                "command": command,
                "exit": None,
                "expected-exit": expected,
                "required": required,
                "passed": False,
                "timeout": True,
                "stdout": error.stdout or "",
                "stderr": error.stderr or "",
            }
        results.append(result)
    if current_head(repo) != expected_head:
        raise KanbanError("Verification command changed Git HEAD")
    assert_index_clean(repo)
    after_paths = changed_paths(repo)
    after_fingerprints = fingerprints(repo, after_paths)
    if after_paths != before_paths or after_fingerprints != before_fingerprints:
        changed = sorted(
            path
            for path in before_paths | after_paths
            if before_fingerprints.get(path) != after_fingerprints.get(path)
        )
        raise CommandFailure(
            "Verification commands modified the working tree",
            {
                "reason": "verification-mutated-worktree",
                "changed-paths": changed,
                "results": results,
            },
        )
    return results


def required_verification_passed(results: Iterable[dict[str, Any]]) -> bool:
    return all(item.get("passed") or not item.get("required", True) for item in results)


def commit_paths(repo: Path, paths: Iterable[str], message: str) -> str:
    selected = sorted(set(paths))
    if not selected:
        raise KanbanError("No session changes to commit")
    assert_index_clean(repo)
    git(repo, "add", "-A", "--", *selected)
    staged = {
        item
        for item in git(
            repo, "diff", "--cached", "--name-only", "--no-renames", "-z", "HEAD"
        ).split("\0")
        if item
    }
    if staged != set(selected):
        git(repo, "restore", "--staged", "--", *selected, check=False)
        raise KanbanError(
            f"Staged patch ownership mismatch: expected {selected}, got {sorted(staged)}"
        )
    try:
        git(repo, "commit", "-m", message)
    except BaseException:
        git(repo, "restore", "--staged", "--", *selected, check=False)
        raise
    return current_head(repo)
