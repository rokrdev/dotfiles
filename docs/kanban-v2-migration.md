# Migrating an Existing Claude Kanban Board to Schema v2

This runbook explains how to start using the deterministic schema-v2 Kanban
workflow on another system without deleting or losing legacy backlog, doing, or
done tickets.

## What Changed

The new workflow treats each ticket as an immutable authorization contract. A
ticket now has strict YAML frontmatter containing the exact files, operations,
tests, verification commands, and commit message that the runner is allowed to
use.

The `kanban-loop` executable, rather than Claude itself, now owns:

- Ticket selection and board transitions.
- Test and implementation worker dispatch.
- RED/GREEN and verification gates.
- Independent read-only validation.
- Staging and per-ticket commits.
- HITL approval state and automatic continuation.

The runner requires schema-v2 tickets and deliberately rejects legacy tickets.
It validates Markdown files in all three active columns:

```text
.workflow/kanban/
├── backlog/
├── doing/
└── done/
```

Consequently, converting only `backlog/` is not sufficient when old-format
tickets remain in `done/` or `doing/`.

There is intentionally no blind, mechanical migration. Fields such as exact
allowed paths, file operations, test commands, and full verification commands
must be derived from the current codebase. The safe approach is to preserve the
legacy board intact and regenerate only the unfinished work.

## Migration Outcome

After migration, the project will have:

```text
.workflow/
├── docs/
│   └── <remaining-work-prd>.md
├── kanban/
│   ├── backlog/       # New schema-v2 tickets
│   ├── doing/
│   └── done/
└── kanban-legacy-<date>/
    ├── backlog/       # Original tickets, unchanged
    ├── doing/
    └── done/
```

The legacy tickets remain available for history and auditing, but only the new
board is executable. `.workflow/` is local-only tracking: do not stage or
commit either the archive or the active board.

## 1. Publish the Dotfiles Branch

The branch must be available from the remote before the other system can pull
it. On the system containing the changes:

```bash
cd ~/.dotfiles
git status --short --branch
git push origin codex/helix-intellij-lsp
```

If a different branch contains the workflow changes, substitute that branch
name in this runbook.

## 2. Install the New Workflow on the Other System

On the other system:

```bash
cd ~/.dotfiles
git fetch origin
git switch codex/helix-intellij-lsp
git pull --ff-only
```

Preview the Stow changes first:

```bash
stow -n -R --no-folding bin agents claude
```

If the preview is correct, apply them:

```bash
stow -R --no-folding bin agents claude
```

These packages provide:

- `bin`: the `kanban-loop` executable under `~/.local/bin/`.
- `agents`: the canonical skills under `~/.agents/skills/`.
- `claude`: Claude settings and compatibility links under `~/.claude/skills/`.

Confirm that the executable and its dependencies are available:

```bash
command -v uv
command -v claude
command -v kanban-loop
kanban-loop --help
```

The executable requires `uv` and at least one supported provider CLI. The
Claude skill explicitly selects the Claude provider.

Close and restart Claude Code after restowing so it reloads the new skills and
global instructions.

## 3. Stabilize Existing Work Before Migrating

Do not change workflows while an agent is actively editing a ticket.

Before migrating the project:

1. Stop the existing Claude session.
2. Inspect `git status` and the existing board.
3. Ensure no worker or legacy Kanban loop is still running.
4. Ensure completed implementation is committed or otherwise safely backed up,
   and copy the local board somewhere safe if it is not already backed up.
5. Resolve anything in `doing/` before archiving the board.

Use:

```bash
git status --short --branch
find .workflow/kanban -maxdepth 2 -type f -name '*.md' -print | sort
```

If the old board lives at `.kanban/`, inspect that path instead.

### Handling an Existing `doing/` Ticket

Choose the applicable case:

- If implementation is complete, finish and commit it using the old workflow
  before migration.
- If no implementation started, treat it as unfinished product intent when
  constructing the new PRD.
- If partial code exists, preserve it on a separate commit or stash before
  migration. Do not let the new runner inherit an unexplained dirty patch.
- If it is unclear whether the acceptance criterion is complete, require Claude
  to compare it with the current code and tests and surface a decision.

The new runner requires a clean checkout outside `.workflow/` before it starts.
Its Git index must be entirely clean; untracked or unstaged local board files
are intentionally ignored.

## 4. Archive the Legacy Board Intact

Create a migration branch in the project if the work is not already on a
dedicated feature branch:

```bash
git switch -c chore/kanban-v2-migration
```

Archive a legacy `.workflow/kanban/` board with an ordinary, recoverable local
filesystem move:

```bash
mv .workflow/kanban .workflow/kanban-legacy-YYYY-MM-DD
```

For a board still using the older `.kanban/` location:

```bash
mkdir -p .workflow
mv .kanban .workflow/kanban-legacy-YYYY-MM-DD
```

Replace `YYYY-MM-DD` with the migration date. Do not delete the old board and
do not rewrite its tickets merely to satisfy the new schema.

The new runner only scans the active `.workflow/kanban/backlog`, `doing`, and
`done` directories, so the archived board will not interfere with validation.

Do not start `kanban-loop` yet. The new active board does not exist until the
remaining work has been reviewed and regenerated.

## 5. Reconstruct the Remaining Product Contract with Claude

Start a fresh Claude Code session in the project and explicitly invoke
`/to-prd`. Paste the following request:

```text
/to-prd

We are migrating from the legacy Kanban board archived at
.workflow/kanban-legacy-YYYY-MM-DD/.

Treat:
- backlog/ tickets as unresolved product intent;
- done/ tickets as historical evidence, not work to repeat;
- doing/ tickets as unresolved unless the current code proves their acceptance
  criteria are already complete.

Inspect the current code and tests before drafting the PRD. Preserve the intent
of every unfinished ticket, but consolidate duplicates and omit behavior already
implemented. A dependency on an archived completed ticket should be treated as
already satisfied only when the current code and tests confirm that behavior.
Do not create new dependencies on slugs that exist only in the archived board.

Surface inconsistencies, missing acceptance criteria, and scope decisions
instead of guessing.

Create a draft PRD for only the remaining work. Do not create tickets, move board
files, run kanban-loop, or implement anything. Stop for my review and explicit
approval.
```

Review the generated PRD carefully. In particular, verify:

- Every unfinished legacy acceptance criterion is represented.
- Already completed behavior is not scheduled again.
- Partial or uncertain `doing/` work is called out explicitly.
- Constraints and out-of-scope behavior survived the migration.
- There are no unresolved scope-affecting decisions.

Approve the PRD explicitly only when it accurately describes the remaining
work. Approval changes it from a draft into the product contract used to create
new tickets.

## 6. Generate Schema-v2 Tickets

After approving the PRD, explicitly invoke:

```text
/to-tickets .workflow/docs/<approved-prd>.md
```

The `to-tickets` skill must inspect the current codebase before proposing the
ticket set. It will identify real entry points, existing tests, exact files,
targeted test commands, full-suite commands, and repository vocabulary.

Before writing any files, Claude must present the complete proposed ticket set.
For every ticket, review:

- ID, slug, title, and dependency slugs.
- One externally observable acceptance criterion.
- Every exact allowed file and its `create`, `modify`, or `delete` operation.
- Exact tests to write during the RED phase.
- The targeted RED/GREEN command.
- All verification commands and expected exit codes.
- The exact Conventional Commit message.
- Whether `human-required` should force review during an AUTO run.

Ask Claude to merge, split, reorder, or correct tickets as needed. The skill is
required to show the complete revised set after changes and must not write the
ticket files until approval is explicit.

### Schema-v2 Frontmatter

Every active ticket follows this shape:

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

Important schema rules:

- `schema-version` must be the integer `2`.
- The numeric ID and slug must match the filename.
- `parallel-safe` is currently always `false`; the runner is serial.
- `allowed-changes` must contain exact repository-relative files, never
  directories, globs, optional paths, or `.workflow` paths.
- Every allowed path must declare `create`, `modify`, or `delete`.
- Every test named in `failing-tests` must use `path::test-name` and its file
  must also be present in `allowed-changes`.
- `tdd-test-command` must be a targeted command that fails after test authoring
  and passes after the implementation phase.
- `verification` must include deterministic expected exit codes and the full
  relevant suite.
- `commit-message` must be an exact Conventional Commit subject.
- Machine-critical information belongs in frontmatter, not only in prose.

When the ticket set is approved, Claude creates:

```text
.workflow/kanban/
├── backlog/
├── doing/
└── done/
```

It writes the approved schema-v2 tickets into `backlog/`, runs validation, and
then stops without implementing them.

## 7. Validate and Review the Migration

Run validation directly if necessary:

```bash
kanban-loop validate
```

Expected output resembles:

```text
Valid board: <count> tickets, schema-version 2
```

Also review implementation changes separately from the local board:

```bash
git status --short -- . ':(exclude).workflow'
find .workflow -maxdepth 3 -type f -print | sort
```

Confirm that:

- The archived legacy board still contains every original ticket.
- The new PRD describes only remaining work.
- The new active board contains only schema-v2 tickets.
- No new ticket depends on a slug that exists only in the archive.
- Every required source and test file is within the appropriate ticket's exact
  authorization boundary.
- Validation passes without warnings or errors.

## 8. Keep the Planning Migration Local

The runner ignores unstaged and untracked `.workflow/` files, but refuses any
staged index content. Review the migration locally and do not run
`git add .workflow` or commit the board. Do not include unrelated source changes
in a later implementation commit.

## 9. Preview the New Execution Plan

In Claude Code, run:

```text
/kanban-loop --dry-run
```

This maps to:

```bash
kanban-loop plan --provider claude
```

It validates the board and reports the currently eligible ticket without moving
tickets, modifying implementation files, running tests, or committing.

Check the selected ticket, acceptance criterion, and allowed paths before
starting execution.

## 10. Start in Human-in-the-Loop Mode

Begin with the default mode:

```text
/kanban-loop
```

This maps to:

```bash
kanban-loop run --provider claude --mode hitl
```

If currently on `main`, `master`, or `develop`, supply the new implementation
branch explicitly:

```text
/kanban-loop --branch feat/<feature-name>
```

For each ticket, the runner:

1. Moves the ticket from backlog to doing.
2. Launches a test-only worker.
3. Confirms that only declared test files changed.
4. Runs the targeted test command and requires RED.
5. Launches a production-only worker.
6. Confirms that only declared production files changed.
7. Runs every declared verification command.
8. Hashes the complete patch.
9. Launches a fresh read-only validator.
10. Pauses for approval when running in HITL mode.
11. Commits only the accepted implementation; the doing-to-done move remains local.

When Claude reports `KANBAN_AWAITING_COMMIT`, review the exact diff,
verification results, and validator report. Approve, reject with a concise
reason, or abort. Approval authorizes only the corresponding runner decision.

After a ticket commit, HITL mode may report `KANBAN_AWAITING_NEXT`. Choose
whether to continue to the next eligible ticket or abort the run.

## 11. Enable AUTO Only After Establishing Trust

AUTO mode must be explicitly requested:

```text
/kanban-loop --auto
```

Use it only after the regenerated tickets and initial HITL runs demonstrate that
the authorization boundaries and verification commands are correct.

A ticket with `human-required: true` still upgrades itself to HITL during an
AUTO run. This should be used for architecture, UX or API judgment, security,
ambiguous scope, or risky cross-cutting changes.

## Operational Rules After Migration

- Do not ask Claude to manually pick or move active board tickets.
- Do not ask Claude to reproduce the loop with inline TDD or ad hoc subagents.
- Do not manually stage or commit an in-progress runner patch, including any
  `.workflow` file.
- Do not edit a ticket after it enters `doing/`.
- Do not create runtime state under `.workflow`; the runner stores it under
  `.git/kanban-loop/runs/`.
- Do not use the legacy `--parallel` behavior. The deterministic runner is
  intentionally serial.
- Continue using `/to-prd` and `/to-tickets` as separate, explicitly approved
  planning steps for future features.
- Use `/to-bug-ticket` for a diagnosed defect that needs a schema-v2 regression
  ticket.
- Use `/ship-it` only after implementation is complete; `kanban-loop` already
  creates the per-ticket commits.

## Troubleshooting

### `schema-version must be 2; legacy tickets must be regenerated`

At least one Markdown ticket in the active `backlog/`, `doing/`, or `done/`
directory is still legacy format. Move it into the preserved legacy archive or
regenerate it through the approved PRD and `to-tickets` workflow.

Do not add only `schema-version: 2`; the remaining required fields must also be
derived and validated.

### `Board missing ...`

The active board must contain all three directories:

```bash
mkdir -p .workflow/kanban/backlog
mkdir -p .workflow/kanban/doing
mkdir -p .workflow/kanban/done
```

Normally, the approved `/to-tickets` flow creates these directories.

### `Working tree must be clean before starting kanban-loop`

Review `git status --short -- . ':(exclude).workflow'` and ensure
`git diff --cached --name-only` is empty. Preserve unrelated work outside the
local board. Never start the runner on top of an unexplained implementation
patch.

### `Deadlock; unmet dependencies`

A backlog ticket depends on a slug that is not present in the active `done/`
column. During migration this commonly means a new ticket still references an
archived legacy slug. Revisit the PRD and ticket graph rather than copying a fake
completion marker into `done/`.

### Claude does not recognize the new skills

Confirm the Stow links and restart Claude Code:

```bash
ls -l ~/.claude/skills/to-prd
ls -l ~/.claude/skills/to-tickets
ls -l ~/.claude/skills/kanban-loop
```

The links should resolve to the canonical copies under `~/.agents/skills/`.

### The runner cannot find a provider

Check:

```bash
command -v claude
command -v uv
```

The Claude skill passes `--provider claude`. Direct provider-neutral invocations
can use automatic provider discovery.

## Reference

- `docs/kanban-workflow.md` contains the deterministic runner design and state
  machine.
- `agents/.agents/skills/to-prd/SKILL.md` defines the PRD contract and approval
  boundary.
- `agents/.agents/skills/to-tickets/SKILL.md` defines schema-v2 ticket creation
  and validation.
- `agents/.agents/skills/kanban-loop/SKILL.md` defines the Claude adapter and
  HITL commands.
- `bin/.local/bin/kanban-loop` is the provider-neutral executable.
