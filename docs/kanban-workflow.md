# Deterministic Kanban Workflow

The Kanban workflow turns an approved product decision into a sequence of independently validated commits. Markdown captures human intent; the `kanban-loop` executable owns orchestration and Git state.

## Pipeline

```text
grill-me
  → discovery contract
  → to-prd
  → approved PRD
  → to-tickets
  → immutable schema-v2 tickets
  → kanban-loop
  → TDD implementation
  → independent validation
  → AUTO commit or HITL approval
  → done
```

No skill or worker agent may reproduce the runner's state machine.

## Board

The board lives locally at the repository root:

```text
.workflow/kanban/
├── backlog/
├── doing/
├── paused/
└── done/
```

`.workflow/` is local-only tracking and must never be staged or committed.
Ticket location is the coarse state. `paused/` holds valid unfinished tickets
that must not be selected by the loop. Existing three-column boards remain
valid; `kanban-loop pause` creates `paused/` on first use. Ephemeral attempt
data, raw worker output, and failure records live under
`.git/kanban-loop/runs/<run-id>/`; none of this pollutes a patch or commit.

## Ticket Contract

Tickets are Markdown with YAML frontmatter. Schema version 2 is intentionally strict:

```yaml
---
schema-version: 2
id: 0
slug: json-output
title: Add JSON output
language: typescript
depends-on: []
parallel-safe: false
human-required: false
acceptance: "Running `app show --json` prints the requested record as valid JSON."
allowed-changes:
  - path: src/cli.ts
    operation: modify
  - path: test/cli.test.ts
    operation: modify
failing-tests:
  - test/cli.test.ts::prints_requested_record_as_json
tdd-test-command: npm test -- test/cli.test.ts
verification:
  - command: npm test -- test/cli.test.ts
    expected-exit: 0
  - command: npm test
    expected-exit: 0
commit-message: "feat(cli): add JSON output"
---
```

`allowed-changes` contains exact repository-relative files. Directories, globs, `.workflow` paths, and implicit files are invalid. Every test named by `failing-tests` must belong to `allowed-changes`.

The ticket stays unchanged after entering `doing/`. Pausing and resuming move an
unchanged ticket between `backlog/` and `paused/`; execution moves it through
backlog → doing → done. All ticket transitions stay local. Base commit,
attempts, raw agent output, test output, validation findings, failure logs,
diff hashes, and final commit SHA belong under `.git/kanban-loop/runs/`.

## Eligibility

A backlog ticket is eligible when every slug in `depends-on` exists in `done/`.
Tickets in `paused/` are validated and reported by `plan`, but are never
eligible. Selection is stable: lowest numeric ID, then slug. The runner is
serial; parallel execution is outside the current contract.

## Execution

The runner uses the current checkout. It detects and reuses a Claude- or Codex-created worktree; it never requests another worktree. The checkout must be clean outside `.workflow/`, with an entirely clean Git index, and on a non-protected branch. Passing `--branch NAME` creates that exact branch when starting on `main`, `master`, or `develop`.

For each ticket:

1. Move backlog → doing.
2. Launch a test-only implementation worker.
3. Verify only declared test files changed.
4. Run `tdd-test-command` and require RED.
5. Launch a production-only implementation worker.
6. Verify only declared production files changed.
7. Run every verification command and require the declared exit code.
8. Hash the complete patch, including new files.
9. Launch a fresh read-only validator.
10. On rejection, restore only the ticket's allowed implementation files to HEAD, then feed blocking findings into another RED→GREEN attempt.
11. On acceptance, commit automatically or pause at HITL. The commit contains only the accepted implementation patch; the deterministic doing→done ticket move happens locally after the commit.

Three rejected attempts trip the circuit breaker.

## Validator Boundary

The validator may reject only for acceptance failure, regression, missing meaningful coverage, scope violation, correctness, security, data-loss risk, or an unverifiable requirement. Style preferences and optional improvements are non-blocking. The validator cannot edit, stage, commit, move tickets, or invent scope.

## Modes

```text
kanban-loop run --provider <provider> --mode auto
kanban-loop run --provider <provider> --mode hitl
kanban-loop pause <slug> [<slug> ...]
kanban-loop resume <slug> [<slug> ...]
```

`human-required: true` upgrades one AUTO ticket to HITL.

`pause` validates all named tickets and destinations, then moves them into
`paused/` while holding the same board lock used by `run`. `resume` returns
named paused tickets to `backlog/`. Neither command edits ticket contents,
invokes a provider, runs tests, or changes Git HEAD or the index. For example,
pause three tickets belonging to XYZ before draining ABC:

```text
kanban-loop pause xyz-api xyz-cli xyz-tests
kanban-loop plan --provider <provider>
```

In HITL, the runner persists the accepted diff and returns a run ID:

```text
kanban-loop decide <run-id> approve
kanban-loop decide <run-id> reject --feedback "..."
kanban-loop decide <run-id> abort
kanban-loop decide <run-id> continue
```

Approval is valid only while HEAD, ticket hash, and diff hash still match what was reviewed.

## Providers

Provider selection order is `--provider`, `KANBAN_AGENT_PROVIDER`, `.workflow/kanban/config.yaml`, current host detection, then executable discovery. Host detection prefers Claude when `CLAUDECODE` is present, Codex when its session identifiers are present, and OpenCode when its session identifiers are present.

Adapters currently support:

- `claude -p`
- `codex exec`
- `opencode2 run --standalone` (preferred when installed)
- `opencode run` (v1 fallback)

Provider adapters own command construction and output parsing only. They never own board state, tests, validation policy, staging, or commits. JSON results are strictly schema-validated. If a provider emits prose instead, the runner preserves the raw output and accepts it only when it contains an unambiguous status/verdict label or decision phrase (for example, `Implementation complete` or `I accept this patch`), which it normalizes and validates against the same schema. Conflicting decisions fail closed.

The executable requires `uv` and at least one provider CLI on `PATH`. A Claude
skill should pass `--provider claude`; equivalent Codex or OpenCode wrappers can
pass their own provider explicitly. Direct invocations may leave it on `auto`.

## Ownership

The runner is the only actor allowed to:

- select or move tickets;
- execute verification commands;
- decide whether a gate passed;
- stage files;
- create commits;
- advance to the next ticket.

Implementers and validators are disposable workers. Their reports are evidence, not authority.
