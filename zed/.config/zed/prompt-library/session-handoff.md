---
name: session-handoff
description: Produce a structured end-of-session summary so context can be cleared and a fresh agent picks up seamlessly. Invoke with @session-handoff when wrapping up a session or about to clear context.
---

# Session Handoff

Produce a repeatable end-of-session summary so the user can clear context and start a fresh agent without losing continuity. The audience is a future instance of you, not a stakeholder — this is a context-handoff artifact, not a status report. The next agent should be able to pick up by reading this summary alone.

Also invoke proactively if the user says they're about to clear context without having run it yet.

## How to produce the summary

1. **Review the full conversation**, not just the last few turns. Handoffs miss things when they only summarize recent context.
2. **Pull state from these sources:**
   - Plan files referenced this session.
   - Any in-progress or pending tasks noted during the session.
   - Files created or modified this session — you know what you touched; don't scan the filesystem to re-discover.
   - Unresolved questions — things you asked the user that never got a clear answer, or things the user asked that got deflected.
3. **Do NOT audit the filesystem.** This is synthesis of what happened in THIS session. No broad file sweeps. If you didn't touch it this session, it doesn't belong here.
4. **Produce the output in chat.** Do not write a file.

## Output template — use exactly this structure, every time

```
# Session Handoff — <one-line title of what this session was about>

## Where it started
<2-3 sentences: what the user asked for, key framing or constraints that emerged>

## Decisions locked + what shipped
- <decision or change> — <why, and where it lives (absolute path if a file)>
- ...

## Key files for next session
- `<absolute path>` — <why the next agent should read this first>
- Plan file: `<path>` (if a plan drove the session)

## Running state
- Background processes: <what they are + how to stop> — or "none"
- Dev servers / ports: <url + port> — or "none"
- Open branches: <names> — or "none"

## Verification — how to confirm things still work
- `<command>` — <expected outcome>
- ...

## Deferred + open questions
- Deferred: <item> — <why pushed to later>
- Open: <question needing the user's input> — <context>

## Pick up here
<1-2 sentences: the single most likely next action for a fresh agent>
```

## Hard rules

1. **Chat output only.** Never write the handoff to a file.
2. **Never invent state.** If a section has nothing to report, write "none" — do not omit the section. Structure stability is the whole point.
3. **Absolute paths always.** The next agent may have a different working directory.
4. **If a plan file drove the session, name it first** in "Key files" so the next agent reads it before anything else.
5. **No emojis, no hype, no retrospectives.** Terse and concrete — paths, commands, decisions. This is not a "what went well / what went poorly" retro. Match the tone of a seasoned engineer handing off at end-of-shift.
6. **No recommendations beyond the single "Pick up here" line.** The next agent decides; you just hand off.
