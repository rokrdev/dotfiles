---
name: kanban-loop
description: Run and control the local schema-v3 Kanban workflow through its executable. Use for ticket, feature, or board execution, review, pause/resume, migration, archival, and recovery.
---

# Kanban Loop

Act as a thin conversational adapter for the provider-neutral `kanban-loop`
executable. The executable owns board state, provider dispatch, verification,
fresh review, Git isolation, commits, recovery, and diagnostics.

Read `~/.dotfiles/docs/kanban-workflow.md` when explaining, diagnosing, or
migrating the workflow. Never reproduce the runner inline or move board files
manually.

## Route the Request

HITL is the default. AUTO must be explicit.

```text
/kanban-loop --dry-run
  -> kanban-loop plan

/kanban-loop [--hitl] [--ticket KEY | --feature SLUG | --all]
  -> kanban-loop run --mode hitl <scope>

/kanban-loop --auto [--ticket KEY | --feature SLUG | --all] [--jobs N]
  -> kanban-loop run --mode auto <scope> [--jobs N]

/kanban-loop status
  -> kanban-loop status

/kanban-loop pause <ticket>
  -> kanban-loop pause <ticket>

/kanban-loop pause --feature <slug>
  -> kanban-loop pause --feature <slug>

/kanban-loop resume <ticket> [feedback]
  -> kanban-loop resume <ticket> [--feedback <feedback>]

/kanban-loop resume --feature <slug>
  -> kanban-loop resume --feature <slug>

/kanban-loop migrate
  -> kanban-loop migrate

/kanban-loop migrate --apply
  -> kanban-loop migrate --apply

/kanban-loop migrate --restore <backup>
  -> kanban-loop migrate --restore <backup>

/kanban-loop archive <feature>
  -> kanban-loop archive <feature>

/kanban-loop restore <feature>
  -> kanban-loop restore <feature>
```

Use `--ticket`, `--feature`, or `--all` exactly as the user requests. If no scope
was supplied, run the next eligible ticket. Pass a requested provider through;
otherwise let the executable detect the current host or local configuration.

Pause and resume preserve ticket and feature origin. A feature pause pauses all
unfinished tickets; resume removes only that feature-origin pause, preserving
ticket-level pauses and dependency blocks. Surface the executable's blocked
dependency explanation rather than altering dependencies.

## HITL Review

Present the review packet faithfully: diff, verification evidence, reviewer
findings, scope changes, and failures. Map the user's natural-language decision
to one review action:

- `approve` — commit the verified session patch with a Conventional Commit
  subject (`<type>[optional scope][!]: <description>`);
- `revise --feedback ...` — preserve useful work and revise it, including a
  justified change of files, tests, or approach;
- `ask --feedback ...` — investigate or answer without committing;
- `override --reason ...` — explicit human verification override with its reason;
- `pause` — shelve the session for later resumption;
- `abandon` or `cancel --reason ...` — use only when the user clearly requests
  that outcome; cancellation always preserves its reason;
- `incorporate`, `defer`, or `restart` — use only for the matching runner-defined
  recovery path.

Do not reduce feedback to an old file allowlist. A revision is allowed to change
the implementation scope while remaining within feature intent and hard safety
boundaries. Never invent approval or a verification override.

HITL implementation and review use one persistent managed worktree. Keep the
coordinator checkout untouched while waiting for human action, and never start
a second HITL ticket while one is active or awaiting review. Approval causes
the executable to integrate the persisted candidate, rerun verification and a
fresh review in the coordinator checkout, and commit only if that gate passes.

## AUTO Boundary

AUTO may retry ordinary implementation or review failures within the configured
limit. Material scope, architecture, security, destructive behavior, ambiguous
intent, verification override, or exhausted retry decisions must become HITL.
Report the escalation and retained session state; do not bypass it.

Feature and board AUTO scopes may fan out dependency-ready AUTO tickets through
managed Git worktrees. `--jobs` overrides the local `auto-concurrency` value;
`--jobs 1` is serial. Tickets whose effective mode is HITL never join the fan-out.
The executable persists each worktree patch, integrates candidates in selection
order, and reruns verification plus fresh review on the advancing target branch
before each commit. HITL uses the same worktree isolation and integration gate,
but always remains sequential.

## Safety and Failure Handling

Do not implement directly, stage paths, commit, invoke another implementation
agent, edit tickets during a run, or perform remote Git operations. Do not parse
agent prose as authorization when the executable rejects it.

If the executable fails, report its persisted diagnostic path and the concrete
missing, malformed, unsafe, or conflicting data. Failure records are part of the
workflow: never replace them with only a generic exception message.
