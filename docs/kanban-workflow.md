# Intent-Based Kanban Workflow

Kanban-loop is a provider-neutral local delivery engine for a solo developer
working with coding agents. Human-readable Markdown records intent. The
executable owns durable sessions, dependency eligibility, provider dispatch,
verification evidence, independent review, Git commits, and board transitions.

## Pipeline

```text
grill-me
  → approved Discovery Contract
  → to-prd
  → approved PRD
  → to-tickets
  → schema-v3 intent tickets
  → kanban-loop (HITL by default, AUTO explicitly)
  → one descriptive project commit per completed ticket
  → archive completed feature when desired
```

Skills are thin interfaces. No skill or agent may reproduce the executable's
state machine or directly move machine-managed workflow state.

## Local Storage

All Kanban data is local-only and excluded from project commits:

```text
.workflow/kanban/
├── config.yaml                 # optional local policy
├── features/
│   └── <feature>.md
├── tickets/
│   ├── ready/
│   ├── active/
│   ├── review/
│   ├── paused/
│   ├── blocked/
│   ├── done/
│   └── cancelled/
├── archive/
│   └── <feature>/
│       ├── feature.md
│       └── tickets/
└── .state/                     # machine-managed pause origins/control state
```

Session state, event logs, patches, raw provider output, diagnostics, and commit
mappings live under the coordinator checkout's Git metadata at
`.git/kanban-loop/`. Managed HITL and AUTO worktrees keep their own Git indexes
while their workflow authority and durable evidence remain centralized there.

Human intent is Markdown. Machine state must not be edited manually.
`kanban-loop init` creates the board and adds `/.workflow/` to the checkout's
local Git exclude when needed; it does not edit the project's tracked
`.gitignore`.

## Feature Contract

```yaml
---
schema-version: 3
kind: feature
feature: json-output
ticket-prefix: JO
title: JSON output
priority: 0
---
```

Feature slugs are stable kebab-case identities. Prefixes are unique, start with
a letter, contain 1-8 uppercase letters or digits, and remain stable after
tickets exist.

## Ticket Contract

```yaml
---
schema-version: 3
kind: ticket
feature: json-output
ticket-prefix: JO
id: 1
slug: print-requested-record
title: Print requested record as JSON
depends-on: []
priority: 0
mode: inherit
acceptance:
  - Running `app show --json` prints the requested record as valid JSON.
constraints:
  - Preserve the existing text output when `--json` is absent.
out-of-scope:
  - Streaming multiple records.
verification:
  - command: npm test -- test/show.test.ts
    expected-exit: 0
    required: true
  - command: npm test
    expected-exit: 0
    required: true
strict-tdd: false
implementation-hints:
  - Reuse the existing record serializer if appropriate.
likely-files:
  - src/commands/show.ts
  - test/show.test.ts
---
```

Tickets are named `PREFIX-NN-kebab-slug.md`. The number is readable ordering,
not an implicit dependency. `depends-on` contains stable full ticket keys and
may cross feature boundaries.

Tickets define outcomes, examples, constraints, exclusions, dependencies,
verification expectations, and AUTO eligibility. `likely-files` and
`implementation-hints` are optional context, never permissions. Tickets do not
contain exact commit messages or exhaustive file allowlists.

`mode` is `inherit`, `hitl`, or `auto`. HITL always overrides AUTO. Strict
RED→GREEN is opt-in with `strict-tdd: true` and then requires an exact,
non-destructive `tdd-test-command`. Other tickets use verification appropriate
to their change type.

## Lifecycle

- **ready** — eligible after dependencies complete.
- **active** — implementation or revision is running.
- **review** — a complete candidate awaits a human decision.
- **paused** — deliberately suspended by ticket or feature action.
- **blocked** — cannot proceed; state records the cause and recovery action.
- **done** — the implementation commit succeeded.
- **cancelled** — explicitly terminated and does not satisfy dependencies.

Dependency blocking is computed. A ready ticket whose direct or transitive
dependency is unfinished remains stored in `ready/` but is reported as blocked
with its dependency chain.

A feature is completed only when all its tickets are done. Done plus cancelled
tickets produce `closed-with-cancellations`, not completed. Adding unfinished
work reopens a completed feature.

## Selection and Execution

HITL runs exactly one ticket pipeline at a time in a managed Git worktree.
Broad AUTO scopes run dependency-ready AUTO tickets concurrently in separate
managed Git worktrees, up to the configured concurrency limit. A run targets:

```bash
kanban-loop run --ticket JO-01-print-requested-record --mode hitl
kanban-loop run --feature json-output --mode hitl
kanban-loop run --all --mode auto
kanban-loop run --all --mode auto --jobs 4
```

Dependencies always override scope. Cross-feature prerequisites are reported;
the runner never silently broadens a selected scope. Among eligible tickets,
higher explicit priority wins, followed by ticket number and key.

Ticket scope ends after its commit. Feature and board scope continue after a
commit without a redundant confirmation. HITL still stops at each candidate's
review gate.

`--jobs` applies only to AUTO and defaults to `auto-concurrency` (built-in: 4).
`--jobs 1` retains serial AUTO execution. HITL rejects parallelism and remains
sequential for ticket, feature, and board scopes.

## HITL

HITL is the default. The ticket is a starting brief. Current explicit human
feedback outranks stale ticket details and may change implementation, tests,
approach, or file scope.

Implementation, verification, and review happen in one persistent managed
worktree. The coordinator checkout remains untouched while the candidate waits
for approval, is investigated, paused and resumed, or revised. Only one HITL
ticket may be active, including at the review gate. Approval persists the
reviewed patch, removes the clean worker checkout, applies the patch to the
coordinator checkout, and reruns verification plus a fresh independent review
against that integrated context before committing. Failed integration is
shelved and returned to HITL rather than overwriting checkout changes.

At review, use:

```bash
kanban-loop review <run-id> approve [--message "fix(scope): descriptive subject"]
kanban-loop review <run-id> revise --feedback "Use peek instead of map"
kanban-loop review <run-id> ask --feedback "Is traversal still lazy?"
kanban-loop review <run-id> override --reason "Known CI-only failure"
kanban-loop review <run-id> pause
kanban-loop review <run-id> abandon [--reason "..."]
kanban-loop review <run-id> cancel --reason "Requirement withdrawn"
```

`revise` preserves useful work and re-runs verification plus a fresh review.
There is no arbitrary HITL revision limit. `ask` invokes a read-only
investigation without changing the candidate. `override` records failed or
unavailable evidence without relabelling it as passed; AUTO cannot override.

If a ticket is edited during an active HITL session, kanban-loop offers:

```bash
kanban-loop review <run-id> incorporate
kanban-loop review <run-id> defer
kanban-loop review <run-id> restart
```

AUTO blocks for the same reconciliation rather than guessing.

## AUTO

AUTO is explicit. It may discover and modify all files reasonably required by
settled intent. For feature and board scopes, the coordinator selects only
currently dependency-ready AUTO tickets, creates a unique branch and worktree
for each, and runs up to `auto-concurrency` ticket pipelines at once. A ticket
marked `mode: hitl` is never included in that fan-out.

Implementation, verification, and the first fresh review happen inside the
ticket worktree. Accepted patches return to the coordinator in deterministic
ticket order. Before each commit, the coordinator applies the patch to the
advancing target branch, reruns verification, and invokes another fresh
read-only reviewer against the integrated context. Only then does it commit and
move the ticket to `done`. This means a dependent ticket is not started until
its prerequisite commit exists on the target branch.

Managed worktrees are discoverable with `git worktree list --porcelain`. AUTO
worktrees are removed after their patch is safely persisted; HITL worktrees
remain registered across review, revision, pause, and resume, then are removed
after approval queues integration or the session is terminated. The default
root is a hidden sibling named `.<repo>-kanban-worktrees`; local configuration
may set an absolute or repository-parent-relative `worktree-root`. Conflicting
patches, failed integration evidence, or cleanup failures are retained and
escalated to HITL rather than overwriting another candidate.

AUTO stops and shelves work when it encounters:

- materially ambiguous or conflicting requirements;
- an unsettled user-visible choice;
- destructive, credential, privacy, security, or data-loss risk;
- an unimplied dependency, schema, public API, or architecture change;
- conflicting repository policy;
- overlap with pre-existing user work;
- unavailable or untrustworthy verification.

Transient provider/result failures and actionable review findings use a bounded
retry budget. Exhaustion or a material decision escalates the saved session to
HITL. Resuming with human feedback continues from the saved patch.

## Pause, Block, and Resume

```bash
kanban-loop pause JO-01-print-requested-record
kanban-loop resume JO-01-print-requested-record
kanban-loop resume JO-01-print-requested-record --feedback "Use compatibility mode"
kanban-loop pause --feature json-output
kanban-loop resume --feature json-output
```

Pausing an active candidate writes its complete patch and session evidence,
restores a safe checkout, and releases the workflow lock. Resumption checks the
current base and refuses to overwrite conflicting work.

Feature pause applies an origin-aware pause to every unfinished ticket.
Feature resume removes only the feature-origin pause; independently paused
tickets remain paused. Completed tickets never move. External dependents are
reported as dependency-blocked without being moved.

## Verification and Review

The implementer may report focused non-destructive test/build/lint commands.
The runner combines those with ticket verification, rejects obviously
destructive or integration commands, executes the accepted commands, and
records exact exit status, output, timeout, expectation, and source.

Every candidate receives a fresh read-only reviewer context with the accepted
intent, amendments, complete patch, and verification evidence. Blocking
findings are limited to acceptance, correctness, regression, meaningful
coverage, security, data loss, unrelated scope, or unverifiable behavior.
Style and optional improvements are advisory.

Reviewer quality is provider-specific and independent of the implementation
model selection: Claude reviewers run Opus with high effort, and Codex reviewers
run `gpt-5.6-sol` with high reasoning effort. OpenCode reviewers continue to use
the session's configured model. The selected reviewer provider, model, and effort
are recorded in the review packet.

The review packet contains outcome summary, every changed file, scope notes,
assumptions, exact verification, review findings, patch hash/path, amendments,
and a proposed commit subject following
[Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/):
`<type>[optional scope][!]: <description>`. Invalid or missing agent proposals
fall back to a valid `chore:` subject; invalid human `--message` overrides are
rejected before staging or committing.

## Git Ownership

- A dirty working tree is allowed when changes are unrelated.
- The Git index must be clean.
- A session records its baseline and attributes only changes made afterward.
- Modifying a path already dirty at baseline is an overlap blocker.
- Only attributed reviewed paths are staged and committed.
- HITL requires explicit commit approval.
- Commit messages follow Conventional Commits 1.0.0, describe repository
  changes, and never mention local tickets.
- Protected branches require an explicit new topic branch.
- The runner never pushes, pulls, merges, rebases, force-updates, opens PRs, or
  publishes releases.
- Board state moves to done only after the project commit succeeds.

## Diagnostics and Recovery

Before surfacing a failure, kanban-loop records applicable session, phase,
attempt, provider/model, commands, patch hash, exit/timeout/interruption,
stdout, stderr, complete raw provider output, every parsed candidate, exact
schema failures, failed invariant, traceback, causal error, and recovery
context. Known secrets are redacted.

State transitions are written atomically. After interruption, `status` exposes
the last safe phase. Re-running a specific active ticket resumes it; paused or
blocked work can be restored explicitly. No failed attempt silently discards a
patch.

```bash
kanban-loop status
kanban-loop plan
kanban-loop validate
```

## Migration

Schema-v2 boards migrate only through an explicit preview and apply:

```bash
kanban-loop migrate
kanban-loop migrate --apply
kanban-loop migrate --restore .workflow/kanban-backups/<timestamp>
```

Preview is read-only. Apply refuses ambiguity, backs up the full old board under
`.workflow/kanban-backups/`, preserves feature/ticket identities and completed
history, converts file lists to non-binding hints, and imports old `doing/`
work as paused review-required intent. Normal `run` never migrates.

## Archival and Pruning

```bash
kanban-loop archive json-output
kanban-loop restore json-output
kanban-loop prune
kanban-loop prune --apply
```

Only completed features archive. Archived done tickets continue satisfying
dependencies. Archive is reversible and never deletes diagnostics. Prune is a
separate previewable action for bulky raw completed-session output and patches;
durable summaries and commit mappings remain.

## Providers and Configuration

Claude Code, Codex, and OpenCode adapters declare writable execution,
read-only review, structured result, cancellation, and resume capabilities.
Missing capabilities are reported instead of weakening policy.

Optional `.workflow/kanban/config.yaml` supplies local defaults such as
provider, implementation model policy, retry budgets, `auto-concurrency`,
`worktree-root`, protected branches, and retention. Use
`status` to inspect effective local configuration plus the project, feature,
ticket, and run source of each applicable policy. Configured protected branches
extend the built-in safety set; they cannot remove `main`, `master`, or
`develop`. Configuration contains no secrets and is never committed.

## Hard Invariants

The executable never:

- stages or commits work outside the active attributed patch;
- commits in HITL without explicit approval;
- marks a ticket done before commit success;
- runs a dependent ticket before dependencies complete;
- silently overwrites, merges, or discards user work;
- lets an agent own workflow state, Git staging, commits, or integration;
- persists known credentials without redaction;
- infers authority for destructive repository, filesystem, data, or remote
  operations.
