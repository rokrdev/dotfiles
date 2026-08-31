# @kanban-loop

> Invoke: type @kanban-loop in the Zed agent panel.

Use the provider-neutral `kanban-loop` executable as the sole lifecycle, agent,
verification, Git, and board authority. Do not reproduce its state machine
inside Zed or move `.workflow` files manually.

HITL is the default. AUTO must be explicit.

## Command Mapping

```text
@kanban-loop --dry-run
  -> kanban-loop plan

@kanban-loop [--hitl] [--ticket KEY | --feature SLUG | --all]
  -> kanban-loop run --provider opencode --mode hitl <scope>

@kanban-loop --auto [--ticket KEY | --feature SLUG | --all]
  -> kanban-loop run --provider opencode --mode auto <scope>

@kanban-loop status
  -> kanban-loop status

@kanban-loop pause <ticket>
  -> kanban-loop pause <ticket>

@kanban-loop pause --feature <slug>
  -> kanban-loop pause --feature <slug>

@kanban-loop resume <ticket> [feedback]
  -> kanban-loop resume <ticket> [--feedback <feedback>]

@kanban-loop resume --feature <slug>
  -> kanban-loop resume --feature <slug>

@kanban-loop migrate [--apply]
  -> kanban-loop migrate [--apply]

@kanban-loop migrate --restore <backup>
  -> kanban-loop migrate --restore <backup>

@kanban-loop archive <feature>
  -> kanban-loop archive <feature>

@kanban-loop restore <feature>
  -> kanban-loop restore <feature>
```

Use the provider available in the Zed environment; if `opencode` is unavailable,
report `kanban-loop providers` and ask the user to choose an available adapter.

## HITL Review

Present the executable's complete review packet and translate the user's choice
to `kanban-loop review <run-id>`:

- `approve` for the verified descriptive commit;
- `revise --feedback ...` for any requested change, including a justified
  change of files, tests, or approach;
- `ask --feedback ...` for read-only investigation;
- `override --reason ...` only after explicit human verification override;
- `pause`, `abandon`, or `cancel --reason ...` only when clearly requested;
- `incorporate`, `defer`, or `restart` for the matching ticket-edit recovery.

There is no arbitrary HITL revision limit. Likely files are hints, not an
allowlist. Do not invent approval or treat prose rejected by the executable as
authorization.

AUTO may retry bounded ordinary failures. Material product, architecture,
dependency, schema, security, destructive, verification, or ambiguity decisions
must be retained and escalated to HITL.

Pause and resume are origin-aware. Feature resume removes only its own pause;
independent ticket pauses and dependency blocks remain. Feature archive uses the
executable and is reversible.

On failure, surface the persisted diagnostic path plus the concrete missing,
malformed, unsafe, or conflicting data. Never replace it with only a generic
exception.
