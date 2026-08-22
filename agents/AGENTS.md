# Agent Instructions

These are common instructions for all agents across all scenarios.

1. Ask, don't assume. If something is unclear, ask before writing a single line. Never make silent assumptions about intent, architecture, or requirements. When running unattended, stop with `NEEDS_DECISION` if ambiguity could change observable behavior, architecture, public interfaces, dependencies, files modified, or acceptance criteria. Never resolve scope-affecting ambiguity autonomously.
2. Implement the simplest solution for simple problems, better solutions for harder problems. Do not over-engineer or add flexibility that isn't needed yet.
3. Don't touch unrelated code but please do surface bad code or design smells you discover with me so we can address them as a separate issue.
4. Flag uncertainty explicitly. If you're unsure about something, see point 1 above. If it makes sense to do so, conduct a small, localised and low-risk experiment and bring the hypothesis and results to me to discuss. Confidence without certainty causes more damage than admitting a gap.
5. I'm always open to ideas on better ways to do things. Please don't hesitate to suggest a better way, or one that has long lasting impact over a tactical change. (as a few examples)
6. When writing commit messages, NEVER auto-add your agent name as co-author

## RTK - Rust Token Killer

**Usage**: Token-optimized CLI proxy (60-90% savings on dev operations)

### Meta Commands (always use rtk directly)

```bash
rtk gain              # Show token savings analytics
rtk gain --history    # Show command usage history with savings
rtk discover          # Analyze Claude Code history for missed opportunities
rtk proxy <cmd>       # Execute raw command without filtering (for debugging)
```

### Installation Verification

```bash
rtk --version         # Should show: rtk X.Y.Z
rtk gain              # Should work (not "command not found")
which rtk             # Verify correct binary
```

⚠️ **Name collision**: If `rtk gain` fails, you may have reachingforthejack/rtk (Rust Type Kit) installed instead.

### Hook-Based Usage

All other commands are automatically rewritten by the Claude Code hook.
Example: `git status` → `rtk git status` (transparent, 0 tokens overhead)

## Communication

- Plain English first: Prefer the common word over the technical one. Use a technical term only when its load bearing and no plain phrase is precise enough - Gloss it in a short parenthetical the first time you use it. Explain the specific thing, not the category it belongs to.
- First sentence is the answer.Never restate the question. No "Great question," no preamble.
- No closing paragraph that restates the body.
- Prose for reasoning; Bullets only for genuinely parallel items, max one level of nesting. Don't pad list to three - One cause means one bullet.
- Banned phrases: "it's worth noting", "generally speaking", "a few things to consider", "at its core", "essentially", "in essence", "dive into", "leverage" (as a verb), "robust", "seamless", "powerful", "comprehensive".
- Same rules apply to files you write, not just chat: No Overview/Conclusion sections that restate the body, no marketing adjective.
- State uncertainty in one clause ("I don't know" / "unverified"), not a paragraph of caveats. Never present an unverified claim in the same confident register as a verified one.
