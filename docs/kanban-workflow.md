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
feature: ticket-naming-conventions
ticket-prefix: TNC
id: 1
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

New tickets are named `PREFIX-NN-slug.md`. The prefix is the uppercase initials
of the canonical kebab-case feature or branch slug, and numbering starts at
`01` within each feature. For example, `ticket-naming-conventions` becomes
`TNC`, so its first ticket could be `TNC-01-json-output.md`. The explicit
`feature` and `ticket-prefix` fields must agree with the filename. Prefixes are
1-8 uppercase letters or digits, start with a letter, and cannot represent two
different features on the same board. Ticket slugs remain globally unique
because dependencies continue to reference slugs.

Existing schema-v2 `NN-slug.md` tickets remain valid without `feature` or
`ticket-prefix`; they do not need to be renamed. The generator emits only the
new prefixed, one-based format.

`allowed-changes` contains exact repository-relative files. Directories, globs, `.workflow` paths, and implicit files are invalid. Every test named by `failing-tests` must belong to `allowed-changes`.

The ticket stays unchanged after entering `doing/`. Pausing and resuming move an
unchanged ticket between `backlog/` and `paused/`; execution moves it through
backlog → doing → done. All ticket transitions stay local. Base commit,
attempts, raw agent output, test output, validation findings, failure logs,
diff hashes, and final commit SHA belong under `.git/kanban-loop/runs/`.

## Eligibility

A backlog ticket is eligible when every slug in `depends-on` exists in `done/`.
Tickets in `paused/` are validated and reported by `plan`, but are never
eligible. Selection is stable: lowest numeric ID, then feature prefix and slug.
The runner is serial; parallel execution is outside the current contract.

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
10. On an actionable validator rejection, snapshot the ticket patch and feed the blocking findings into an in-place revision attempt. Revisions preserve the patch and may make a focused test-only, production-only, or combined change; they must change at least one allowed file and still pass full verification and independent validation. If tests change, the focused test command is recorded, but a passing result is allowed for coverage-only work.
11. On acceptance, commit automatically or pause at HITL. The commit contains only the accepted implementation patch; the deterministic doing→done ticket move happens locally after the commit.

Three rejected attempts trip the circuit breaker.

## Validator Boundary

The validator may reject only for acceptance failure, regression, missing meaningful coverage, scope violation, correctness, security, data-loss risk, or an unverifiable requirement. Style preferences and optional improvements are non-blocking. The validator cannot edit, stage, commit, move tickets, or invent scope.

## Modes

```text
kanban-loop run --provider <provider> --mode auto
kanban-loop run --provider <provider> --mode hitl
kanban-loop pause <ticket> [<ticket> ...]
kanban-loop resume <ticket> [<ticket> ...]
```

`human-required: true` upgrades one AUTO ticket to HITL.

`pause` validates all named tickets and destinations, then moves them into
`paused/` while holding the same board lock used by `run`. `resume` returns
named paused tickets to `backlog/`. Neither command edits ticket contents,
invokes a provider, runs tests, or changes Git HEAD or the index. For example,
pause three tickets belonging to the TNC feature before draining another
feature. Commands accept either globally unique slugs or full ticket keys:

```text
kanban-loop pause TNC-01-validate-prefix TNC-02-generate-filenames TNC-03-update-docs
kanban-loop plan --provider <provider>
```

In HITL, the runner persists the accepted diff and returns a run ID:

```text
kanban-loop decide <run-id> approve
kanban-loop decide <run-id> approve --include path/to/lsp-config --reason "Resolve LSP warning introduced by this ticket"
kanban-loop decide <run-id> revise --feedback "..."
kanban-loop decide <run-id> restart --feedback "..."
kanban-loop decide <run-id> abort
kanban-loop decide <run-id> continue
```

Normal approval is valid only while HEAD, ticket hash, and diff hash still match
what was reviewed. If a human needs to include one or more additional changed
files after the HITL gate, they must use repeated exact repository-relative
`--include PATH` options and a non-empty `--reason`. This is available only at
`awaiting-commit`; active implementer phases and AUTO mode remain strict.

Each included path must already be a changed file and must not be a directory,
glob, absolute/traversal path, `.git` path, `.workflow`/ticket-board path, or a
path already permitted by the ticket. The runner then re-runs ticket
verification and a fresh independent read-only validation over the complete
ticket-plus-supplemental patch, recording the paths, reason, verification,
validator result, and new patch hash in the run artifacts. A rejected or
blocked supplemental review leaves the run awaiting commit and commits nothing.

`revise` snapshots the reviewed ticket patch in the run artifacts, then asks the
workers to make the smallest correction on top of it. `reject` remains a
backward-compatible alias for `revise`. `restart` also snapshots the patch, but
then restores only ticket-owned files to `HEAD` before a fresh strict RED→GREEN
attempt. Use restart only when the existing approach should be discarded.

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
