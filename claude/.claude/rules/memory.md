## Memory Management

Maintain a structured memory system rooted at .claude/memory/

### Structure

- memory.md — index of all memory files, updated whenever you create or modify one
- general.md — cross-project facts, preferences, environment setup
- domain/{topic}.md — domain-specific knowledge (one file per topic)
- tools/{tool}.md — tool configs, CLI patterns, workarounds

### Rules

1. When you learn something worth remembering, write it to the right file immediately
2. Keep memory.md as a current index with one-line descriptions
3. Entries: date, what, why — nothing more
4. Read memory.md at session start. Load other files only when relevant
5. If a file doesn't exist yet, create it
6. Before removing or modifying any existing memory entry, use AskUserQuestion to confirm
   with the user — show the current content and the proposed change

### Maintenance

When I say "reorganize memory":
1. Read all memory files
2. Remove duplicates and outdated entries
3. Merge entries that belong together
4. Split files that cover too many topics
5. Re-sort entries by date within each file
6. Update memory.md index
7. Show me a summary of what changed

## Global Memory

Read ~/.claude/memory/memory.md at session start. Load specific topic files only when relevant.

## Global Memory Reference Rule

Whenever you work in a project and read (or create) its MEMORY.md, check that it contains a `## Global Memory` section. If it does not, add it near the top, after the H1.

The section must be a SHORT POINTER only. Do NOT duplicate the topic file list into project
MEMORY.md. The list lives in ~/.claude/memory/memory.md (single source of truth). Project
MEMORY.md has a 200-line budget — use it for project knowledge, not boilerplate.

Canonical template for project MEMORY.md:

```markdown
## Global Memory

Read ~/.claude/memory/memory.md for memory rules and topic files.

When a new file is added to ~/.claude/memory/:
- Add it to the ## Global Memory topic file list in ~/.claude/memory/memory.md only
- Do NOT update individual project MEMORY.md files
```

## Repo Memory Auto-Init

At session start in any project, check for MEMORY.md in the project memory directory
(~/.claude/projects/{mapped-path}/memory/). If it does not exist, create it:

```markdown
# {Project Name} - Project Memory

## Global Memory

Read ~/.claude/memory/memory.md for memory rules and topic files.

## Project Notes

(Populated as you work in this project)
```

## Domain Knowledge Lifecycle

1. Staging — knowledge accumulates in ~/.claude/memory/domain/{name}/
2. Promotion — enough knowledge exists to package as a plugin/skill
3. Pointer — after promotion, the memory file becomes a pointer to the plugin;
   content lives in the plugin

When an update is needed to a promoted domain, note it in the memory file so an issue
can be created on the plugin repo.
