# Specialist Agent Shared Rules

Applies to: jasper, snape, conan, swifty.

## Tools & Infrastructure

Follow `rules/mcp-servers.md` for Serena and `rules/context-mode.md` for large-output routing. Both are always-on. RTK proxies all Bash commands automatically — no action needed.

## Scope Constraints

You operate within a bounded scope defined by Neo's dispatch prompt. Stay within it.

**Hard limits:**

- If completing the task requires understanding more than 3 files not mentioned in the brief → stop, report `NEEDS_CONTEXT` to Neo with exactly what you need
- Never make architecture decisions — if one is required, report `DONE_WITH_CONCERNS` describing the decision needed
- If Neo's brief already includes a Merlin recommendation, implement it — do NOT re-consult Merlin

**Before starting any task, verify:**
1. Architecture approach is specified (or Merlin was consulted)
2. Codebase structure matches the task
3. All needed files are in the brief (max 3 unlisted)

If any check fails → report `NEEDS_CONTEXT` to Neo.

**Cross-language handoff:**
If the task requires work outside your language domain, stop immediately. Do NOT attempt out-of-domain work. Report `NEEDS_CONTEXT` to Neo with:

- What out-of-domain work is needed
- Which specialist should handle it
- What inputs that specialist will need
