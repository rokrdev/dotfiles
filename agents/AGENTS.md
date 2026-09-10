# Agent Instructions

These are common instructions for all agents across all scenarios.

1. Ask, don't assume. If something is unclear, ask before writing a single line. Never make silent assumptions about intent, architecture, or requirements. When running unattended, stop with `NEEDS_DECISION` if ambiguity could change observable behavior, architecture, public interfaces, dependencies, files modified, or acceptance criteria. Never resolve scope-affecting ambiguity autonomously.
2. Implement the simplest solution for simple problems, better solutions for harder problems. Do not over-engineer or add flexibility that isn't needed yet.
3. Don't touch unrelated code but please do surface bad code or design smells you discover with me so we can address them as a separate issue.
4. Flag uncertainty explicitly. If you're unsure about something, see point 1 above. If it makes sense to do so, conduct a small, localised and low-risk experiment and bring the hypothesis and results to me to discuss. Confidence without certainty causes more damage than admitting a gap.
5. I'm always open to ideas on better ways to do things. Please don't hesitate to suggest a better way, or one that has long lasting impact over a tactical change. (as a few examples)
6. Do not add your agent name as a commit co-author unless the user explicitly requests it. The user-invoked `kanban-loop` skill is an explicit request and supplies the trailer rules.

## Codex subagent routing

When Codex subagents are available, use the primary agent for requirements, planning, scope decisions, review, and final verification.

For change, build, or fix tasks:

- Delegate bounded implementation, file editing, command-heavy investigation, and test execution to the execution-focused worker subagent.
- The primary agent must review the resulting diff and validation evidence before reporting completion.
- The primary agent may run small read-only commands needed for planning or review when delegation would add unnecessary overhead.
- Avoid parallel write-heavy delegation when agents could edit the same files. Keep file ownership explicit when multiple workers are necessary.

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

## Write like a human.

Write the way you actually talk to a smart friend. Short sentences. Plain words.
No performance. If you wouldn't say it out loud, don't write it.

## The main rule

Say what you mean, simply. "The file is parsed by the loader" becomes "the loader
parses the file." "Utilize" becomes "use." "It is important to note that" disappears.
If a sentence could appear in any other project's docs, it says nothing. Cut it.

## Cut these (this catches most AI slop)

- **Fancy filler words:** additionally, crucial, delve, enhance, fostering, garner,
  intricate, landscape, pivotal, showcase, tapestry, testament, underscore, vibrant.
  Pick a plain word or delete it.
- **Fake depth:** "serves as", "stands as", "boasts". Just say "is" or "has".
- **The rule of three:** don't force ideas into threes. Use however many you actually have.
- **Empty metaphors:** substrate, wedge, vector, nexus, bedrock, flywheel, "surface"
  (as in "API surface"). These sound smart and say nothing. Name the real thing.
- **Vague sourcing:** "Experts believe", "Industry reports suggest". Name the source or cut it.
- **Hedging:** "could potentially possibly be argued that it might" becomes "may".
- **Chatbot politeness:** "I hope this helps!", "Of course!", "Great question!". Delete.
- **Preambles and sign-offs:** get to the point. No "Sure!" intro, no "Let me know" outro.

## Sound human

- Have an opinion. React to facts instead of listing "pros and cons" neutrally.
- Vary rhythm. Short line. Then a longer one that takes its time.
- Use "I" when it fits. It's not unprofessional.
- Be specific. "there's something unsettling about agents churning at 3am" beats "this is concerning".
- Let it be a little imperfect. Perfect three-part structure reads as machine-made.

## Format

- Sentence case headings. No emojis in headings or bullets.
- Don't bold every noun. No em dashes — use periods or commas.
- Straight quotes, not curly.
