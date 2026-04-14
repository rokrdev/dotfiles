---
name: update-memory
description: Update project memory after completing a session, PR, or significant work chunk
trigger: explicit — invoke after PR merges or at end of complex sessions
type: rigid
---

# Update Memory Skill

Run this checklist at the end of any session involving significant work, or after merging a PR.

## Checklist

### 1. Create or update `current-work.md`
- [ ] Update "Recent Work Completed" with what was just finished
- [ ] Update "Next Up" — remove completed items, add newly discovered work
- [ ] Update "Known Blockers" — add/remove as appropriate
- [ ] Update the `*Last updated*` date

### 2. Create or update `architecture-decisions.md` (if applicable)
- [ ] Was a new architectural decision made? Add it with rationale.
- [ ] Did an existing decision change? Update it.
- [ ] Only update if something actually changed — don't touch for routine work.

### 3. Capture new feedback or lessons
- [ ] Did the user correct an assumption or workflow? Create/update a topic file.
- [ ] Did a subagent dispatch pattern work well or poorly? Create or update `orchestration_lessons.md`.
- [ ] Was there a project-specific constraint discovered? Document it.

### 4. Update MEMORY.md index
- [ ] Are all topic files listed in `MEMORY.md`?
- [ ] Are the one-line descriptions still accurate?
- [ ] Is MEMORY.md under ~200 lines? (Move details to topic files if not.)

## Notes
- Memory files live in `~/.claude/projects/<project-hash>/memory/`
- `autoMemoryEnabled: true` handles routine in-session capture automatically
- This skill is for **deliberate, structured** end-of-session consolidation
- Keep topic files focused: one concern per file
- Use absolute dates, not relative ("2026-04-14", not "today")
