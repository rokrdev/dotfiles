# Claude Code Setup Hardening — Round 2

> **For agentic workers:** Use `superpowers:subagent-driven-development` to implement this plan task-by-task.

**Goal:** Wire up the orchestrator guard hook, fix documentation drift, constrain specialist agent scope, and clarify Merlin invocation patterns.

**Architecture:** settings.json registration, CLAUDE.md patches, agent .md scope additions.

**Tech Stack:** JSON, Markdown, Bash

---

## Task 1: Register orchestrator-guard.sh in settings.json + Update Hook Order Docs

### Files to Modify
- `/Users/bharat/.dotfiles/claude/.claude/settings.json` (Create/Modify)
- `/Users/bharat/.dotfiles/claude/.claude/CLAUDE.md` (Modify Hook Execution Order section)

### Current State
- `orchestrator-guard.sh` exists at `/Users/bharat/.dotfiles/claude/.claude/hooks/orchestrator-guard.sh` but is **NOT registered** in settings.json
- Hook Execution Order section in CLAUDE.md lists only `rtk-rewrite.sh` and `superpowers-redirect.sh` — missing orchestrator-guard.sh

### Steps

**1.1: Update settings.json — Add orchestrator-guard.sh to PreToolUse hooks (FIRST position)**

Current PreToolUse hooks in settings.json:
```json
"preToolUseHooks": [
  {"matcher": "Bash", "hooks": [{"type": "command", "command": "bash $HOME/.claude/hooks/rtk-rewrite.sh"}]},
  {"matcher": "Write|Edit", "hooks": [{"type": "command", "command": "bash $HOME/.claude/hooks/superpowers-redirect.sh"}]}
]
```

Replace with:
```json
"preToolUseHooks": [
  {"matcher": "Bash", "hooks": [
    {"type": "command", "command": "bash $HOME/.dotfiles/claude/.claude/hooks/orchestrator-guard.sh"},
    {"type": "command", "command": "bash $HOME/.claude/hooks/rtk-rewrite.sh"}
  ]},
  {"matcher": "Write|Edit", "hooks": [{"type": "command", "command": "bash $HOME/.claude/hooks/superpowers-redirect.sh"}]}
]
```

**Rationale:** Orchestrator guard must run FIRST (before RTK) to enforce the Iron Law before any command preprocessing.

**1.2: Validate JSON**
```bash
jq empty /Users/bharat/.dotfiles/claude/.claude/settings.json
```
Expected: No output (valid JSON).

**1.3: Update Hook Execution Order section in `/Users/bharat/.dotfiles/claude/.claude/CLAUDE.md`**

Current section:
```markdown
## Hook Execution Order

**PreToolUse** hooks fire in this sequence:
1. **rtk-rewrite.sh** (Bash) — rewrites commands through RTK proxy
2. **superpowers-redirect.sh** (Write|Edit) — blocks spec/plan writes outside ~/projects/

**SessionStart** hooks fire in this sequence (after orchestrator mode loads):
1. cleanup-worktrees.sh — removes merged worktrees
```

Replace with:
```markdown
## Hook Execution Order

**PreToolUse** hooks fire in this sequence:
1. **orchestrator-guard.sh** (Bash) — enforces Iron Law: only allowlisted commands run directly; non-allowlisted commands are denied
2. **rtk-rewrite.sh** (Bash) — rewrites commands through RTK proxy
3. **superpowers-redirect.sh** (Write|Edit) — blocks spec/plan writes outside ~/projects/

**SessionStart** hooks fire in this sequence (after orchestrator mode loads):
1. cleanup-worktrees.sh — removes merged worktrees
```

### Verification
- [ ] `jq empty` passes (no JSON errors)
- [ ] Hook order matches settings.json registration
- [ ] orchestrator-guard.sh path uses `~/.dotfiles/claude/.claude/hooks/` (stow-managed)
- [ ] Next Bash command in session triggers guard hook (should see denial message if command is non-allowlisted)

### Commit
```
chore(claude): register orchestrator-guard.sh and update hook execution order

- Add orchestrator-guard.sh as FIRST PreToolUse hook for Bash in settings.json
- Enforce Iron Law before RTK preprocessing
- Update CLAUDE.md Hook Execution Order section with orchestrator-guard.sh entry
- Validates JSON; no functional changes to existing hooks

Closes #[issue-number-if-any]
```

---

## Task 2: Fix RTK Documentation Claim

### Files to Modify
- `/Users/bharat/.dotfiles/claude/.claude/CLAUDE.md` (Modify RTK mention)
- `/Users/bharat/.claude/CLAUDE.md` (Modify RTK mention — global, NOT stow-managed)

### Current State
- Both CLAUDE.md files claim RTK version is "confirmed in SessionStart hook" — **FALSE**
- RTK is guaranteed by system bootstrap (always installed); no hook validates it
- False claim creates confusion about RTK availability and maintenance model

### Steps

**2.1: Fix `/Users/bharat/.dotfiles/claude/.claude/CLAUDE.md`**

Find section mentioning RTK (under "Maintenance Notes" or "MCP Servers & RTK Plugins"):

Current text (if present):
```
RTK (Rust Token Killer) — version confirmed in SessionStart hook
```

Replace with:
```
RTK (Rust Token Killer) — guaranteed by system bootstrap; always installed; never flag as missing
```

**2.2: Fix `/Users/bharat/.claude/CLAUDE.md` (global, NOT stow-managed)**

Find section: "Maintenance Notes" or "MCP Servers & RTK Plugins"

Current text:
```
RTK (Rust Token Killer) — version confirmed in SessionStart hook
```

Or in the memory/feedback file:
```
**RTK (Rust Token Killer)** — always installed via bootstrap; version confirmed in SessionStart hook; never flag as missing
```

Replace with:
```
**RTK (Rust Token Killer)** — guaranteed by system bootstrap (always installed); no validation hook needed; never flag as missing
```

### Verification
- [ ] Both files no longer mention "SessionStart hook" for RTK validation
- [ ] Both files clarify RTK is bootstrap-guaranteed, not hook-validated
- [ ] No false claims about hook-based version checking

### Commit (only for dotfiles)
```
chore(claude): fix RTK documentation — remove false SessionStart hook claim

RTK is guaranteed by system bootstrap, not by a SessionStart hook.
Remove misleading "version confirmed in SessionStart hook" claim.

Global ~/.claude/CLAUDE.md updated directly (not stow-managed).
```

---

## Task 3: Remove context-mode Duplication from Global CLAUDE.md

### Files to Modify
- `/Users/bharat/.claude/CLAUDE.md` (global, NOT stow-managed — edit directly)

### Current State
- Full context-mode routing rules section exists in `/Users/bharat/.claude/CLAUDE.md`
- Canonical version lives in `/Users/bharat/.dotfiles/claude/.claude/rules/context-mode.md`
- Duplication creates maintenance risk: changes to canonical are not synced to global

### Steps

**3.1: Locate section in `/Users/bharat/.claude/CLAUDE.md`**

Find:
```markdown
# context-mode — MANDATORY routing rules
```

This section spans multiple paragraphs (GATHER, FOLLOW-UP, PROCESSING, WEB, Bash, Read, ctx commands tables, etc.) — **entire section to be replaced**.

**3.2: Replace full section with TL;DR pointer**

Replace entire "context-mode — MANDATORY routing rules" section with:

```markdown
# context-mode — MANDATORY routing rules

See `~/.dotfiles/claude/.claude/rules/context-mode.md` for the full routing guide.

**TL;DR:**
- Use `ctx_batch_execute(commands, queries)` for 2+ commands or >20 lines output
- Use `ctx_search(queries: [...])` for follow-up queries on previously indexed content
- Use `ctx_execute(language, code)` or `ctx_execute_file(path, language, code)` for sandbox execution
- Use `ctx_fetch_and_index(url, source)` then `ctx_search` for web content
- **Blocked:** curl, wget, WebFetch, inline HTTP — use sandbox or ctx_fetch_and_index instead
- **Bash:** only for git, mkdir, rm, mv, cd, ls, npm install, pip install, and short-output commands
- **Read:** only when you plan to Edit the file afterward

For exact tool signatures and comprehensive routing rules, see the canonical rules file.
```

### Verification
- [ ] Old "context-mode — MANDATORY routing rules" section fully removed
- [ ] New TL;DR section replaces it with pointer to canonical location
- [ ] Reference path is correct: `~/.dotfiles/claude/.claude/rules/context-mode.md`
- [ ] Global CLAUDE.md is shorter, single source of truth clarified

### Commit
**No git commit** — `/Users/bharat/.claude/CLAUDE.md` is NOT stow-managed and not tracked. Edit directly and leave.

---

## Task 4: Add Scope Constraints to Specialist Agents

### Files to Modify
- `/Users/bharat/.dotfiles/claude/.claude/agents/conan.md` (Modify)
- `/Users/bharat/.dotfiles/claude/.claude/agents/snape.md` (Modify)
- `/Users/bharat/.dotfiles/claude/.claude/agents/swifty.md` (Modify)

### Current State
- Specialist agents have full tool access and no explicit scope constraints
- No guidance on when to escalate to Merlin or report NEEDS_CONTEXT
- Risk: specialists over-read codebase, make architecture decisions autonomously, re-consult Merlin unnecessarily

### Steps

**4.1: Add "## Scope Constraints" section to conan.md**

Location: After "## Model Hierarchy" section, before or after "## Kotlin Best Practices".

Insert:
```markdown
## Scope Constraints

You operate within a bounded scope defined by Neo's dispatch prompt. Stay within it.

**Hard limits:**
- If completing the task requires understanding more than 3 files not mentioned in the brief → stop, report `NEEDS_CONTEXT` to Neo with exactly what you need
- Never make architecture decisions — if one is required, report `DONE_WITH_CONCERNS` describing the decision needed
- If Neo's brief already includes a Merlin recommendation, implement it — do NOT re-consult Merlin

**Escalate to Merlin** (via Neo) for implementation-level design decisions ONLY if Neo's brief did not specify the approach:
- Data model design choices
- Concurrency model selection
- Module boundary decisions
- Pattern selection (e.g., sealed class vs interface hierarchy)

**Red flags — stop and report:**
- "I don't know which architecture to use"
- "The codebase structure doesn't align with the task"
- "I need to read more than 3 files to understand dependencies"
```

**4.2: Add "## Scope Constraints" section to snape.md**

Location: After "## Model Hierarchy" section, before or after "## Python Best Practices".

Insert (same template, language-specific examples optional):
```markdown
## Scope Constraints

You operate within a bounded scope defined by Neo's dispatch prompt. Stay within it.

**Hard limits:**
- If completing the task requires understanding more than 3 files not mentioned in the brief → stop, report `NEEDS_CONTEXT` to Neo with exactly what you need
- Never make architecture decisions — if one is required, report `DONE_WITH_CONCERNS` describing the decision needed
- If Neo's brief already includes a Merlin recommendation, implement it — do NOT re-consult Merlin

**Escalate to Merlin** (via Neo) for implementation-level design decisions ONLY if Neo's brief did not specify the approach:
- Data model design choices (schema, class hierarchies)
- Concurrency model selection (asyncio, threading, multiprocessing)
- Module boundary decisions
- Pattern selection (e.g., inheritance vs composition, dataclass vs namedtuple)

**Red flags — stop and report:**
- "I don't know which architecture to use"
- "The codebase structure doesn't align with the task"
- "I need to read more than 3 files to understand dependencies"
```

**4.3: Add "## Scope Constraints" section to swifty.md**

Location: After "## Model Hierarchy" section, before or after "## Swift Best Practices".

Insert (same template, Swift-specific examples):
```markdown
## Scope Constraints

You operate within a bounded scope defined by Neo's dispatch prompt. Stay within it.

**Hard limits:**
- If completing the task requires understanding more than 3 files not mentioned in the brief → stop, report `NEEDS_CONTEXT` to Neo with exactly what you need
- Never make architecture decisions — if one is required, report `DONE_WITH_CONCERNS` describing the decision needed
- If Neo's brief already includes a Merlin recommendation, implement it — do NOT re-consult Merlin

**Escalate to Merlin** (via Neo) for implementation-level design decisions ONLY if Neo's brief did not specify the approach:
- Data model design choices (struct vs class, value vs reference semantics)
- Concurrency model selection (async/await, actors, GCD, Combine vs SwiftUI async)
- Module boundary decisions (separation of concerns in MVC/MVVM/VIPER)
- Pattern selection (protocol-oriented vs inheritance, property wrappers)

**Red flags — stop and report:**
- "I don't know which architecture to use"
- "The codebase structure doesn't align with the task"
- "I need to read more than 3 files to understand dependencies"
```

### Verification
- [ ] All three files have "## Scope Constraints" section
- [ ] Hard limits are identical across all three (20 LOC scoping rule)
- [ ] Escalation rules match the decision matrix (implementation-level only if not in brief)
- [ ] Red flags are clear and actionable

### Commit
```
chore(claude): add scope constraints to specialist agents (Conan, Snape, Swifty)

- Add "## Scope Constraints" section to conan.md, snape.md, swifty.md
- Establish hard limits: stop if task requires >3 unlisted files
- Clarify Merlin escalation: implementation-level design decisions only if not in brief
- Prevent over-reading, autonomous architecture decisions, and re-consultation

Closes #[issue-number-if-any]
```

---

## Task 5: Add Neo Dispatch Brief Reminder + Merlin Decision Matrix

### Files to Modify
- `/Users/bharat/.dotfiles/claude/.claude/agents/neo.md` (Modify)
- `/Users/bharat/.dotfiles/claude/.claude/agents/merlin.md` (Modify)

### Current State
- neo.md has "Crafting Good Subagent Prompts" section but no explicit reminder about dispatch brief content
- merlin.md documents "When You Are Consulted" but does NOT document who calls it and when
- No clear decision matrix: unclear when Neo calls Merlin vs. when specialists do

### Steps

**5.1: Update Merlin decision matrix in merlin.md**

Location: After "## When You Are Consulted" or as a new subsection "## When Neo Calls Merlin vs. Specialists Call Merlin".

Find current "When You Are Consulted" section:
```markdown
## When You Are Consulted

You receive a focused question with supporting context from a language expert. Answer it directly. Do not ask clarifying questions — work with what you have. If the question is underspecified, state your assumptions explicitly before advising.
```

Append after this section:
```markdown
## When Neo Calls Merlin vs. Specialists Escalate

| Decision type | Caller | When | Example |
|---|---|---|---|
| System-level architecture | Neo (before dispatch) | Before sending specialists to code | "Should auth live in middleware or service layer?" |
| Cross-cutting concerns | Neo | Multi-agent coordination needed | "How should logging span across Kotlin and Python modules?" |
| Implementation-level design | Specialist (if brief unclear) | After reading dispatch brief, if approach not specified | "Sealed class vs interface hierarchy?" |
| Already decided by Merlin | Nobody | Never re-consult | If Neo passed Merlin's recommendation in dispatch, specialist implements it — no escalation |

**Rule:** When Neo consults Merlin, include Merlin's recommendation verbatim in the specialist's dispatch prompt. Specialists NEVER re-consult Merlin on already-decided matters.
```

**5.2: Update "Crafting Good Subagent Prompts" in neo.md**

Find section in neo.md:
```markdown
## Crafting Good Subagent Prompts

[current content...]
```

Append (or replace if vague) with:
```markdown
## Crafting Good Subagent Prompts

For specialist agents (Swifty/Snape/Conan), always specify in the dispatch prompt:

**Required content:**
- **Exact files to read/modify** — not "look around the codebase"; list 2-5 specific file paths
- **Merlin recommendations already made** — include verbatim if a design decision was already made by Merlin; specialists implement, never re-consult
- **Explicit scope boundary** — what NOT to touch (adjacent modules, infrastructure, test infrastructure, etc.)
- **Task completion criteria** — what "done" looks like (tests passing, all x.ts files updated, etc.)

**Example dispatch (good):**
```
Read ARCHITECT-BRIEF.md first.

Task: Add error handler to UserService

Files to modify:
- src/services/UserService.ts
- test/services/UserService.test.ts

Do NOT touch:
- AuthService (adjacent; not your responsibility)
- DB layer (managed separately)

Merlin recommends: Wrap errors in ResultType<T, Error> (already documented in ARCH).

Done when: All user-facing errors are wrapped, tests pass, no console.error() calls in prod code.
```

**Example dispatch (bad):**
```
Add error handling to the UserService. Look around and find what needs fixing.
```

**For code explorers (Explore subagents):**
- Specify exactly what question you want answered
- Specify scope (e.g., "only read src/, ignore test/")
- Specify output format (e.g., "return top 5 candidates with file paths and line numbers")
```

### Verification
- [ ] neo.md "Crafting Good Subagent Prompts" includes required dispatch content checklist
- [ ] merlin.md has decision matrix showing who calls Merlin when
- [ ] Rule is clear: Specialists implement Merlin recommendations, never re-consult
- [ ] Example dispatch prompts show both good and bad patterns

### Commit
```
chore(claude): clarify Merlin invocation and Neo dispatch brief structure

- Add decision matrix to merlin.md: when Neo calls Merlin vs. specialists escalate
- Update neo.md "Crafting Good Subagent Prompts" with required dispatch fields
- Establish rule: specialists implement Merlin recommendations verbatim, never re-consult
- Include example good/bad dispatch prompts

Closes #[issue-number-if-any]
```

---

## Task 6: Add Cross-Language Handoff Pattern to Specialist Agents

### Files to Modify
- `/Users/bharat/.dotfiles/claude/.claude/agents/conan.md` (Modify)
- `/Users/bharat/.dotfiles/claude/.claude/agents/snape.md` (Modify)
- `/Users/bharat/.dotfiles/claude/.claude/agents/swifty.md` (Modify)

### Current State
- Specialist agents have no guidance for when they encounter work outside their language domain
- Risk: Conan asked to work on a Kotlin+Python project may attempt Python work; Snape may attempt Swift; Swifty may attempt Kotlin
- No clear escalation pattern for out-of-domain handoffs

### Steps

**6.1: Add cross-language handoff clause to conan.md Scope Constraints**

Location: In the "## Scope Constraints" section (added in Task 4), after "Red flags — stop and report:" section.

Append:
```markdown
**Cross-language handoff:**
If the task requires work outside your language domain (Python, JavaScript, Swift, etc.), stop immediately. Do NOT attempt the out-of-domain work. Report `NEEDS_CONTEXT` to Neo with:
- What out-of-domain work is needed
- Which specialist should handle it (Snape for Python, Conan for Kotlin, Swifty for Swift)
- What inputs that specialist will need
```

**6.2: Add cross-language handoff clause to snape.md Scope Constraints**

Location: In the "## Scope Constraints" section (added in Task 4), after "Red flags — stop and report:" section.

Append:
```markdown
**Cross-language handoff:**
If the task requires work outside your language domain (Kotlin, JavaScript, Swift, etc.), stop immediately. Do NOT attempt the out-of-domain work. Report `NEEDS_CONTEXT` to Neo with:
- What out-of-domain work is needed
- Which specialist should handle it (Snape for Python, Conan for Kotlin, Swifty for Swift)
- What inputs that specialist will need
```

**6.3: Add cross-language handoff clause to swifty.md Scope Constraints**

Location: In the "## Scope Constraints" section (added in Task 4), after "Red flags — stop and report:" section.

Append:
```markdown
**Cross-language handoff:**
If the task requires work outside your language domain (Python, Kotlin, JavaScript, etc.), stop immediately. Do NOT attempt the out-of-domain work. Report `NEEDS_CONTEXT` to Neo with:
- What out-of-domain work is needed
- Which specialist should handle it (Snape for Python, Conan for Kotlin, Swifty for Swift)
- What inputs that specialist will need
```

### Verification
- [ ] **Step 1:** Add cross-language handoff clause to conan.md Scope Constraints section
- [ ] **Step 2:** Add cross-language handoff clause to snape.md Scope Constraints section
- [ ] **Step 3:** Add cross-language handoff clause to swifty.md Scope Constraints section
- [ ] **Step 4:** Verify: `grep -l "Cross-language handoff" /Users/bharat/.dotfiles/claude/.claude/agents/*.md` returns all three files
- [ ] **Step 5:** Commit: `git -C /Users/bharat/.dotfiles add claude/.claude/agents/ && git -C /Users/bharat/.dotfiles commit -m "docs(agents): add cross-language handoff pattern to specialists"`

### Commit
```
docs(agents): add cross-language handoff pattern to specialists

- Add cross-language handoff clause to conan.md, snape.md, swifty.md Scope Constraints
- Specialists stop immediately if task requires out-of-domain work
- Report NEEDS_CONTEXT to Neo with clear handoff target and required inputs
- Prevent out-of-domain implementation attempts across language boundaries

Closes #[issue-number-if-any]
```

---

## Task 7: Automate Pre-Commit Skill Execution

### Files to Modify
- `/Users/bharat/.dotfiles/claude/.claude/skills/pre-commit/SKILL.md` (Modify)

### Current State
- Pre-commit skill is a manual checklist the user fills out
- Execution is not automated — user must manually run checks and decide on each step
- Risk: checks are skipped, manual steps are inconsistent, commit happens without proper validation

### Steps

**7.1: Read current SKILL.md**

Review the existing structure to understand format and frontmatter.

**7.2: Rewrite skill body to dispatch-based workflow**

Replace the manual checklist body with automated dispatch instructions. Keep the frontmatter (metadata, callout) but transform the execution model.

New body structure:
```markdown
⚠️ **MANUAL SKILL** — You invoke this skill, but the harness does the heavy lifting.

## Automated Pre-Commit Workflow

When you invoke `pre-commit`, the system:

1. **Check staged files** — Run `git diff --cached --stat` to list what's staged
2. **Dispatch code-simplifier** — Send staged files to `code-simplifier:code-simplifier` subagent for quality review
3. **Re-stage changes** — If simplifier modifies files, run `git add -u` to include them
4. **Dispatch code reviewer** — Send staged diff to `pr-review-toolkit:code-reviewer` for structural review
5. **Handle review findings** — If reviewer returns CRITICAL or IMPORTANT issues, stop and request fixes before proceeding
6. **Run project tests** — Detect and run project test suite:
   - JavaScript/Node: `npm test`
   - Python: `pytest` or `python -m unittest`
   - Java/Kotlin: `./gradlew test`
   - Other: Skip if no detectable test command
7. **Proceed to commit** — Only when all checks pass (tests, no critical review issues, simplifier approved)

## Error Handling

If any step fails (tests fail, simplifier finds major issues, reviewer flags critical problems):
- Stop the workflow
- Report the issue clearly
- Do NOT commit
- Return control to you for fixes

## What Gets Committed

Commits only proceed when:
- All staged changes have been reviewed by simplifier
- Structural review is clean (no CRITICAL/IMPORTANT issues)
- All project tests pass
- You explicitly confirm in the skill response
```

**7.3: Verify the changes**

Confirm that:
- `grep -c "Dispatch" /Users/bharat/.dotfiles/claude/.claude/skills/pre-commit/SKILL.md` returns > 0
- The file has been edited (not created)
- Frontmatter is intact
- No manual checklist remains

**7.4: Commit**

```bash
git -C /Users/bharat/.dotfiles add claude/.claude/skills/pre-commit/SKILL.md && git -C /Users/bharat/.dotfiles commit -m "refactor(pre-commit): automate dispatch workflow, remove manual checklist"
```

### Verification
- [ ] **Step 1:** Read current SKILL.md to understand existing structure
- [ ] **Step 2:** Rewrite body to dispatch-based workflow (keep frontmatter and manual callout)
- [ ] **Step 3:** Verify dispatch workflow with automated steps (1-7 as listed above)
- [ ] **Step 4:** Commit: `git -C /Users/bharat/.dotfiles add claude/.claude/skills/pre-commit/SKILL.md && git -C /Users/bharat/.dotfiles commit -m "refactor(pre-commit): automate dispatch workflow, remove manual checklist"`

### Commit
```
refactor(pre-commit): automate dispatch workflow, remove manual checklist

- Replace manual checklist with automated dispatch workflow
- Skill invokes code-simplifier → code-reviewer → test suite in sequence
- Stops on CRITICAL/IMPORTANT issues; only commits on all-clear
- Reduces user intervention, improves consistency, catches issues early
```

---

## Task 8: Define Generic Haiku Subagent Routing in neo.md

### Files to Modify
- `/Users/bharat/.dotfiles/claude/.claude/agents/neo.md` (Modify)

### Current State
- neo.md dispatches "Haiku subagents" for generic work but has no clear definition
- No decision table: unclear when to use generic Haiku vs a specialist (Swifty/Snape/Conan)
- Ambiguity leads to mis-routing or escalating simple tasks to specialists unnecessarily

### Steps

**8.1: Read neo.md and locate agent hierarchy / model selection section**

Find where Neo documents agent choices or model selection. Look for sections like:
- "## Agent Routing"
- "## Model Hierarchy"
- "## Subagent Selection"
- "## When to Escalate"

**8.2: Add or integrate Agent Routing decision table**

Insert the routing decision table in the appropriate location (after existing agent hierarchy docs). If "Agent Routing" section exists, update it; otherwise create a new section.

Add:
```markdown
### Agent Routing

| Use generic Haiku for | Use specialist (Swifty/Snape/Conan) for |
|---|---|
| File reads, codebase exploration, search | Language-specific implementation |
| Config, doc, or markdown edits | Debugging in a specific language stack |
| Single-file mechanical edits (< 50 lines) | Testing in a specific framework |
| Summarising output, research tasks | Multi-file refactors in a language |

**Rule:** Default to generic Haiku. Escalate to a specialist only when the task requires language-specific knowledge or tooling. Escalate to Merlin before dispatching any specialist if architecture decisions are involved.
```

**8.3: Verify the table is in place**

Run:
```bash
grep -A 10 "Agent Routing" /Users/bharat/.dotfiles/claude/.claude/agents/neo.md
```

Expected: Table visible with "Use generic Haiku for" and "Use specialist" columns.

**8.4: Commit**

```bash
git -C /Users/bharat/.dotfiles add claude/.claude/agents/neo.md && git -C /Users/bharat/.dotfiles commit -m "docs(neo): add agent routing table — Haiku vs specialist decision rules"
```

### Verification
- [ ] **Step 1:** Read neo.md to find agent routing section
- [ ] **Step 2:** Add or integrate Agent Routing decision table
- [ ] **Step 3:** Table shows clear criteria: generic Haiku for exploration, specialists for language work
- [ ] **Step 4:** Verify table is present with: `grep -A 10 "Agent Routing" /Users/bharat/.dotfiles/claude/.claude/agents/neo.md`
- [ ] **Step 5:** Commit: `git -C /Users/bharat/.dotfiles add claude/.claude/agents/neo.md && git -C /Users/bharat/.dotfiles commit -m "docs(neo): add agent routing table — Haiku vs specialist decision rules"`

### Commit
```
docs(neo): add agent routing table — Haiku vs specialist decision rules

- Add Agent Routing section with decision matrix: generic Haiku vs specialists
- Default to Haiku for exploration, search, config, and mechanical edits
- Escalate to specialists only for language-specific implementation
- Clarifies when architecture decisions require Merlin involvement

Closes #[issue-number-if-any]
```

---

## Summary of Changes

| Task | Files | Type | Verification |
|------|-------|------|--------------|
| 1 | settings.json, CLAUDE.md (dotfiles) | Create/Modify | JSON valid, hook order matches |
| 2 | CLAUDE.md (dotfiles), CLAUDE.md (global) | Modify | No "SessionStart hook" claims |
| 3 | CLAUDE.md (global) | Modify | Deduplication complete, TL;DR added |
| 4 | conan.md, snape.md, swifty.md | Modify | Scope Constraints section in all three |
| 5 | neo.md, merlin.md | Modify | Decision matrix clear, dispatch checklist added |
| 6 | conan.md, snape.md, swifty.md | Modify | Cross-language handoff clause in all three |
| 7 | pre-commit/SKILL.md | Modify | Automated dispatch workflow, no manual checklist |
| 8 | neo.md | Modify | Agent Routing table with Haiku vs specialist rules |

## Execution Order
1. Task 1 (settings.json + hook order) — foundation for guard enforcement
2. Task 2 (RTK docs) — quick clarification
3. Task 3 (context-mode dedup) — reduce global file bloat
4. Task 4 (specialist scope) — prevent over-reach
5. Task 5 (Merlin matrix + dispatch brief) — clarify system patterns
6. Task 6 (cross-language handoff) — enforce language domain boundaries
7. Task 7 (pre-commit automation) — replace manual workflow with dispatch
8. Task 8 (Haiku routing) — clarify generic vs specialist dispatch decision

## Git Commits
- Task 1: `chore(claude): register orchestrator-guard.sh and update hook execution order`
- Task 2: `chore(claude): fix RTK documentation — remove false SessionStart hook claim`
- Task 4: `chore(claude): add scope constraints to specialist agents (Conan, Snape, Swifty)`
- Task 5: `chore(claude): clarify Merlin invocation and Neo dispatch brief structure`
- Task 6: `docs(agents): add cross-language handoff pattern to specialists`
- Task 7: `refactor(pre-commit): automate dispatch workflow, remove manual checklist`
- Task 8: `docs(neo): add agent routing table — Haiku vs specialist decision rules`
- Task 3: No commit (global ~/.claude/CLAUDE.md is not stow-managed)
