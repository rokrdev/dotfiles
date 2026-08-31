# Migrating Schema-v2 Kanban Boards to Schema v3

Schema v3 replaces immutable file-scoped execution contracts with intent-based
tickets, feature definitions, richer lifecycle state, resumable sessions, and
complete failure diagnostics. Migration is local, explicit, previewable, and
recoverable.

## What Is Preserved

- feature slug and ticket prefix;
- full ticket key, number, slug, title, and body;
- dependency relationships, converted from legacy slugs to stable full keys;
- backlog, pause, active, and completion meaning;
- human-review requirements;
- acceptance intent and verification commands;
- old exact file lists as non-binding `likely-files` hints;
- the untouched complete schema-v2 board in a dated backup.
- legacy `.git/kanban-loop/runs/` evidence, preserved in place and reported by
  migration/status for manual recovery or audit.

Legacy `doing/` tickets become paused HITL tickets. Schema v2 has no trustworthy
resumable provider session, so explicit resume returns them to `ready` for a
fresh attributed run. Existing project changes remain user-owned.

## New Layout

```text
.workflow/kanban/
├── features/
├── tickets/
│   ├── ready/
│   ├── active/
│   ├── review/
│   ├── paused/
│   ├── blocked/
│   ├── done/
│   └── cancelled/
├── archive/
└── .state/
```

The original board backup is written under:

```text
.workflow/kanban-backups/<UTC timestamp>/
```

Both locations are local-only and must remain excluded from Git.

## Preconditions

1. Stop any running legacy Kanban process.
2. Inspect project work with `git status --short --branch`.
3. Do not stage Kanban files.
4. Preserve or commit any unrelated project work normally.
5. Install/restow the updated `bin`, `agents`, and `claude` packages.

Preview Stow first:

```bash
stow -n -v -R --no-folding bin agents claude
stow -v -R --no-folding bin agents claude
```

Confirm the executable:

```bash
kanban-loop --version
kanban-loop providers
```

## Preview Migration

```bash
kanban-loop migrate
```

Preview performs no mutation. Review:

- source and target schema;
- every feature and prefix;
- every ticket, source column, and target identity;
- dependency conversions;
- all reported ambiguities or invalid legacy data.

Migration refuses tickets without schema-v2 feature/prefix identity, conflicting
prefixes, unknown dependencies, or invalid frontmatter. Correct the legacy
intent or preserve it separately; do not make the migrator guess.

## Apply Migration

```bash
kanban-loop migrate --apply
```

Apply performs these ordered operations:

1. Re-run the complete preview and stop on any error.
2. Copy the full legacy board to the timestamped backup.
3. Build a complete schema-v3 board in a temporary local directory.
4. Validate the converted board, identities, dependencies, and columns.
5. Atomically replace the active board.
6. Leave the backup intact for recovery.

Normal `run`, `status`, and `validate` never migrate automatically.

## Validate the Result

```bash
kanban-loop validate
kanban-loop status
kanban-loop plan
```

Confirm:

- unfinished backlog tickets appear as `ready`;
- legacy paused tickets remain paused;
- legacy `doing` tickets are paused and resume to `ready` in HITL mode;
- done tickets remain done and satisfy dependencies;
- dependencies use full `PREFIX-NN-slug` keys;
- file lists are hints rather than permissions;
- HITL is required for imported active work;
- no project source file or Git index entry changed.

## Resuming Imported Work

Inspect imported paused work before resuming:

```bash
kanban-loop status
kanban-loop resume <ticket-key>
```

If partial implementation existed outside the local board, kanban-loop treats
it as pre-existing user work. It will not absorb or overwrite it silently.
Reconcile or preserve that patch deliberately before asking an agent to
continue.

## Recovery

If conversion succeeded but the result is not acceptable, stop before running
any ticket. Restore the exact backup path reported by migration:

```bash
kanban-loop migrate --restore .workflow/kanban-backups/<UTC timestamp>
```

Restore validates the schema-v2 backup, first backs up the current schema-v3
board, and then reinstates the legacy board. Ordinary execution will again
require an explicit migration.

Do not delete the only backup, use `git reset --hard`, or stage `.workflow`.

## Ticket Generation After Migration

New work should be generated with the updated `/to-tickets` skill. Schema-v3
tickets define outcomes, examples, constraints, exclusions, stable dependencies,
verification expectations, AUTO eligibility, and optional hints. They do not
contain exact file allowlists or predetermined commit messages.

Read [kanban-workflow.md](kanban-workflow.md) for the complete schema and
runtime contract.
