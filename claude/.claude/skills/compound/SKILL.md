---
name: compound
description: Extract lessons from code review and write them as permanent rules into the project CLAUDE.md, so every future session inherits the learning.
when_to_use: After completing a code review, after superpowers:requesting-code-review output is visible, or after receiving PR review feedback. Invoke to turn review findings into durable project rules.
---

# Compound Engineering

## Purpose

Every code review contains pattern-level knowledge. This skill captures that knowledge as actionable rules in the project CLAUDE.md so future agent sessions — and future engineers — automatically inherit it. One compound step per review compounds into a progressively smarter project context.

## Workflow

### Step 1 — Identify the review source

Look for feedback in this order:
1. Conversation context from a recent code review, `superpowers:requesting-code-review` output, or `pr-review-toolkit:review-pr` output
2. Run `gh pr view --comments` if on a branch with an open PR
3. Explicit user-provided feedback or pasted review

If no review feedback is found, return: "No review feedback found. Please provide the review output or paste the feedback, then re-invoke." Do NOT interactively prompt the user — subagents report back rather than asking questions directly.

### Step 2 — Locate the project CLAUDE.md

Run: `git rev-parse --show-toplevel`

- If not in a git repo → abort with: "Compound learnings require a project CLAUDE.md. Not in a git repo."
- If repo found but no CLAUDE.md at root → create a minimal one:

```markdown
# <repo-name> — Claude Context

## Compound Learnings
```

- If CLAUDE.md exists → read it before proceeding (needed for deduplication and placement).

### Step 3 — Synthesize lessons

Extract **2–5 actionable rules** from the review. Every rule must pass all four checks:

| Check | Requirement |
|-------|-------------|
| **Imperative** | Starts with "Always", "Never", "When … do …", or "Prefer … over …" |
| **Pattern-level** | Describes a reusable pattern, not a one-off fix |
| **Non-duplicate** | Does not already exist (even in different wording) in the current CLAUDE.md |
| **Survives cleanup** | Clearly valuable — a future "clean up CLAUDE.md" pass should keep it |

If uncertain whether something rises to a pattern, do NOT include it.

Examples of what to include vs. exclude:

- Include: "Always validate user input at service boundaries before passing to domain logic"
- Exclude: "Fix null check in UserService.findById" (one-off fix, not a pattern)
- Include: "Never call external APIs inside a transaction — extract to a post-commit hook"
- Exclude: "Add missing await in fetchUser" (specific bug, not a pattern)

### Step 4 — Determine placement

Scan the existing CLAUDE.md sections:

- If a section clearly matches the lesson topic (e.g. "## Error Handling", "## API Conventions") → append the rule there
- If no matching section exists → append under `## Compound Learnings` (create the section at the end of the file if missing)

### Step 5 — Write the lessons

Append each rule as a bullet under the chosen section. Format:

```
- <Imperative rule statement> (<brief rationale — one clause explaining why>)
```

Example:
```
- Always validate pagination parameters before hitting the database (prevents unbounded queries that cause timeouts under load)
```

Use the Edit tool to write to the project CLAUDE.md. Never use Bash or ctx_execute for file writes.

### Step 6 — Report to user

Show exactly what was added:

```
Added to <section name> in <path/to/CLAUDE.md>:

• <rule 1>
• <rule 2>
• ...

These rules will apply to all future agent sessions in this project.
```

## Constraints

- **Max 5 lessons per invocation** — prevents noise accumulation; if more than 5 patterns emerge, pick the 5 highest-signal ones
- **Project CLAUDE.md only** — never write to `~/.claude/CLAUDE.md` (global user config); always write to the project CLAUDE.md identified by `git rev-parse --show-toplevel`. The dotfiles repo's `~/.dotfiles/CLAUDE.md` IS a valid project CLAUDE.md and is writable.
- **No one-off fixes** — only reusable patterns that apply beyond the specific code reviewed
- **Err on the side of fewer rules** — a CLAUDE.md with 10 sharp rules beats one with 40 diluted ones
- **Rationale required** — every rule must include a parenthetical explaining why it matters; rules without rationale are not written

## Related Skills

Typically invoked after code review (via `superpowers:requesting-code-review` or `pr-review-toolkit:review-pr`) and merging to capture lessons into the project.
