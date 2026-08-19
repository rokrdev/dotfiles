---
name: kanban-loop
description: Implement exactly one issue-tracker ticket in an isolated Git branch and worktree. Use only when the user explicitly invokes the skill with a ticket reference and wants test-driven implementation, full project verification, independent validation, bounded repair retries, and a local commit without pushing.
---

# Kanban Loop

Implement exactly one ticket and stop after creating a reviewed local commit. This is a user-invoked runner, not an automatic board drain.

Treat the invocation arguments as the ticket reference. Accept the repository's configured issue-tracker form: a GitHub or GitLab issue URL/number, or a local issue file.

## Non-negotiable boundaries

- Work on one ticket only.
- Create a new branch and linked worktree before editing.
- Follow TDD for changed behavior.
- Run the repository's complete build and test command lists, not targeted substitutes, before every validation.
- Use an independent, read-only validator. The implementing agent must not validate its own work.
- Allow at most three repair passes after the initial validation.
- Commit only after a `SHIP` verdict and green full verification.
- Never push, open a pull request, merge, delete the worktree, or move on to another ticket.

## 1. Resolve the ticket and execution contract

Before mutation:

1. Confirm the current directory belongs to a Git repository.
2. Read repository instructions, `CONTEXT.md`, relevant ADRs, and `docs/agents/issue-tracker.md` when present.
3. Resolve the supplied ticket and capture its identifier, title, complete body, acceptance criteria, dependencies, and target branch. Include issue comments only when the tracker treats them as part of the specification.
4. Refuse to guess if the ticket reference is missing, ambiguous, closed, blocked, or belongs to another repository.
5. Discover and record the repository's ordered full build and full test command lists from its documentation, CI configuration, package scripts, or build files. A list may contain one command. If either list cannot be identified confidently, ask the user before implementation.
6. Resolve the target branch: use the ticket's target when specified, otherwise the remote default branch. When it has a remote, fetch that target before fixing the base SHA; if freshness cannot be established, stop and report the fetch failure. A repository with no remote may use a confirmed local base. Never rebase or change the fixed base after work begins.
7. Resolve and record the co-author trailer identity now. Prefer a harness-documented identity, then repository-local `agent.coauthorName` and `agent.coauthorEmail` Git config. If neither is trustworthy, ask the user before creating the worktree.

Do not change issue status automatically. The user owns tracker state.

## 2. Create the branch and worktree

Derive a short filesystem-safe slug and use:

- Branch: `ticket/<ticket-id>-<slug>`
- Worktree: a sibling directory under `<repo-name>-worktrees/<ticket-id>-<slug>`

Check `git branch --list` and `git worktree list` first. If either target already exists, stop and report it rather than silently reusing or deleting anything.

Create the linked worktree from the fixed base ref with `git worktree add -b`. From this point onward, run every file edit, build, test, validation, staging, and commit command inside that worktree. Record the base commit SHA for the validator.

## 3. Implement with TDD

Read the sibling [TDD skill](../tdd/SKILL.md) and the references it requires, then apply those rules inside the worktree.

For each vertical slice:

1. Identify the public seam and confirm that the ticket already makes the expected behavior unambiguous. If it does not, stop and ask the user.
2. Add one behavior-level test.
3. Run it and append the command plus meaningful RED failure to a compact TDD evidence log.
4. Make the smallest production change that makes it GREEN.
5. Run the test again and append the GREEN result to the evidence log.
6. Repeat until the ticket's acceptance criteria are covered.

Do not broaden scope, perform unrelated cleanup, or create speculative abstractions.

## 4. Run complete verification

Run every command in the recorded full build list, then every command in the full test list, in order. Every command must exit successfully.

If any command fails, diagnose and fix it inside ticket scope, then rerun both complete lists from the start. If green verification requires an out-of-scope change or cannot be achieved, stop without committing and report the failing command and relevant output.

## 5. Invoke an independent validator

Read [the validator contract](references/validator-contract.md). Select the first available adapter:

1. A configured named read-only implementation validator. In Claude Code, prefer the `argus` agent.
2. A fresh isolated subagent instructed with the complete validator contract.
3. If the harness cannot provide an independent context, stop before commit and tell the user that validation could not run. Do not replace independence with self-review.

Give the validator the ticket text, fixed base ref and SHA, current branch and worktree, verification command lists and results, compact TDD evidence log, and any findings from the previous validation. Supply the complete committed, staged, and unstaged diff. Enumerate `git status --porcelain` and provide or direct the validator to inspect the full contents of every untracked file; ordinary `git diff` does not include them. The validator must not edit files.

Every adapter must return the exact common sections and verdict token from the contract. If a named validator uses a native format, the adapter must map it to the common contract before this skill interprets it.

## 6. Apply the verdict with a bounded loop

The initial validation does not consume a repair pass.

- `SHIP`: continue to commit.
- `RETHINK`: stop immediately without committing. Report the plan concern or fundamental approach problem to the user.
- `FIX FIRST`: pass the exact findings to the implementing agent and start repair pass 1.

For each repair pass:

1. Fix only the validator's actionable findings.
2. Add or adjust tests using the same RED-before-GREEN discipline where behavior changes.
3. Run the complete build and complete test command lists again from the start.
4. Invoke a fresh validator in re-critique mode with the previous findings.

Permit at most three repair passes total. If pass 3 still returns `FIX FIRST`, stop without committing and report the unresolved findings and verification state. A validator crash or malformed verdict may be corrected once; if it still cannot produce a valid verdict, stop without committing.

## 7. Commit locally

After `SHIP`:

1. Run `git status --short` and inspect the final diff.
2. Stage only files required by the ticket. Never use staging to hide unrelated changes.
3. Use the repository's commit-message convention; otherwise use a concise imperative summary derived from the ticket title.
4. Append exactly one `Co-authored-by: Name <email>` trailer using the identity recorded during preflight.
5. Commit. Do not push.

Finish by reporting the ticket, branch, worktree path, commit SHA, build and test command lists, compact TDD RED/GREEN evidence, final validator verdict, repair-pass count, and that the branch remains local for the user to push.
