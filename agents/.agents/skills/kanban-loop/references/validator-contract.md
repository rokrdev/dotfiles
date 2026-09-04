# Fresh Reviewer Contract

The executable supplies this role with the schema-v3 ticket contract, accepted
HITL amendments, complete attributed patch, and exact verification evidence.
The reviewer starts in fresh read-only context and must not edit files, invoke
agents, stage, commit, or mutate workflow state.

The executable selects the review runtime independently of the implementation
model: Claude uses Opus with high effort, Codex uses `gpt-5.6-sol` with high
reasoning effort, and OpenCode retains the session model.

For both serial HITL and worktree-parallel AUTO, review the candidate once in
its isolated worktree. After AUTO acceptance or explicit HITL approval, the
executable applies the persisted patch to the advancing target branch, reruns
verification, and invokes another fresh reviewer. That integration review is
authoritative for an ordinary approval; a conflict or rejection retains the
patch and requires HITL resolution.

Review only for:

- unmet acceptance or conflicting accepted intent;
- correctness and regressions;
- meaningful missing behavioral coverage;
- security or data-loss risk;
- unrelated scope;
- behavior that the supplied evidence cannot verify.

Style, optional cleanup, and nonessential improvements are advisory. Do not
invent requirements, treat `likely-files` as an allowlist, or require TDD when
`strict-tdd` is false.

Return exactly the structured reviewer schema supplied by the executable:

- `verdict`: `accept`, `revise`, or `blocked`;
- `summary`: concise review outcome;
- `findings`: objects containing `id`, `classification`, `category`, `summary`,
  `evidence`, optional `path`, and optional `required_outcome`;
- `assumptions`: explicit assumptions made during review.

`classification` is `blocking` only for the review dimensions above. A
`maintainability` or `style` finding is advisory. Use `blocked` when reliable
review requires a material human decision or trustworthy evidence that is not
available; use `revise` for actionable implementation problems.

When structured output is unavailable, emit exactly one standalone labelled
fallback line: `Verdict: accept`, `Verdict: revise`, or `Verdict: blocked`.
Unlabelled or conflicting prose must never authorize a transition.
