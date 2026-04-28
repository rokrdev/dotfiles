# Coding Behavior

**Think Before Coding** — Surface assumptions explicitly before writing. List all interpretations if the request is ambiguous — don't pick one silently. Push back when a simpler approach exists.

**Simplicity First** — Write the minimum code that solves the problem. No speculative features, no abstractions for single-use code, no unrequested flexibility. Self-test: "Would a senior engineer say this is overcomplicated?"

**Surgical Changes** — Touch only what the request requires. Don't improve adjacent code, formatting, or comments. Match existing style. Mention unrelated dead code — don't silently delete it. DO remove imports/variables your changes made unused. Test: "Every changed line should trace directly to the user's request."

## When to Skip TDD

TDD is the default. Skip it only for:

- Pure config changes (no logic path added or changed)
- Documentation-only changes
- One-liner fixes where the test suite already covers the changed line
- Scaffolding / boilerplate where zero logic is introduced

When skipping, confirm the existing test suite still passes before marking the task complete.

## System Boundaries — What Counts

Mocks are only acceptable at system boundaries. A system boundary is any point where the code leaves the process:

- **Network** — HTTP calls, gRPC, WebSockets, message queues
- **Filesystem** — reading or writing files outside the test's own temp directory
- **Clock / time** — `Date.now()`, `datetime.now()`, `Instant.now()`, etc.
- **Random / UUID** — any non-deterministic source
- **External APIs and services** — third-party SDKs, auth providers, payment processors
- **Hardware / OS** — camera, GPS, push notifications, keychain

Everything else uses real dependencies: in-memory implementations, real parsers, real business logic.
