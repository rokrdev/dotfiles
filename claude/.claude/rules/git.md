# Git & Commit Standards

## Conventional Commits Format

All commits must follow the conventional commits specification:

```
type(scope): description

body

footer
```

### Type
Required. Describes the kind of change:
- **feat**: A new feature
- **fix**: A bug fix
- **chore**: Build, tooling, dependency updates, version bumps
- **refactor**: Code restructuring without changing functionality
- **docs**: Documentation changes only
- **test**: Test additions or fixes; no production code changes
- **perf**: Performance improvements
- **ci**: CI/CD pipeline changes
- **style**: Code style (whitespace, semicolons, etc.) — never use for formatting (use **refactor**)

### Scope
Optional but recommended. Names the part of the codebase affected: `fish`, `nvim`, `settings`, `hooks`, etc.

### Description
Concise, present tense, no period. Examples:
- ✓ `add obsidian skill symlink`
- ✓ `fix buddy-reroll hook removal`
- ✗ `added` (past tense)
- ✗ `Add obsidian skill symlink.` (period)

## Body

Explain **WHY**, not WHAT. The code shows WHAT; the body explains motivation, context, or implications.

```
refactor(settings): consolidate hook definitions

Reduces duplication and makes SessionStart hooks easier to maintain.
Future: consider moving all hooks to separate config file.
```

## Footer

Optional. Use for:
- Breaking changes: `BREAKING CHANGE: ...`
- Issue references: `Closes #123`, `Fixes #456`
- Collaborators: `Co-Authored-By: Name <email>`

## Pull Request Guidelines

**Title**: Under 70 characters, use conventional commit format
- ✓ `feat(fish): add git aliases for common workflows`
- ✗ `fix: stuff` (too vague)
- ✗ `feat(everything): major refactor affecting many systems` (too long)

**Body**: Summary of changes, testing performed, rationale

**Co-Authored-By**: Include when Claude has contributed:
```
Co-Authored-By: Claude Sonnet <noreply@anthropic.com>
```

## Pre-Commit Workflow (MANDATORY)

Before every `git commit`, you MUST run these three steps in strict sequential order:

1. **`/simplify`** — simplify and refine changed code
2. **`/pr-review-toolkit:review-pr`** — run full PR review (code, errors, comments)
3. **Run tests** — execute the project's test suite; only skip if there are genuinely no tests applicable to the change

**Hard Rule**: Commits MUST NOT happen until all three steps pass with no critical issues. Steps cannot be skipped or reordered — sequential execution is non-negotiable. This applies to all commits, not just PRs.

## Commit Practices

- **Never use `--no-verify`** unless explicitly requested by user
- **Never use `--no-gpg-sign`** unless signing is broken
- **Never use `-f` (force push)** to main/master — use rebase or new commits
- **One logical change per commit** — avoid "fix all the things" commits
- **Write imperative subjects**: "add feature", not "adds feature" or "added feature"
- **Reference issues** when applicable: `Closes #123`

## Examples

### Feature
```
feat(claude): add obsidian skill symlink deployment

The obsidian skill now deploys via symlink to ~/.claude/skills/
instead of being left as a source-only file. Fixes broken markdown
file routing when creating files outside git repos.

Closes #42
```

### Fix
```
fix(settings): remove buddy-reroll hook from SessionStart

The npx buddy-reroll command was running on every session start
but is no longer needed. Removes hook entry entirely to reduce
session startup latency.
```

### Chore
```
chore(model): update main model ID to claude-sonnet-4-6

Unifies model naming convention: main model now uses full ID
(claude-sonnet-4-6) instead of short name (sonnet), matching
subagent convention (claude-haiku-4-5-20251001).
```
