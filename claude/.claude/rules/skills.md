# Active Skills

Custom skills live in `~/.dotfiles/claude/.claude/skills/` and are stowed to `~/.claude/skills/`.

## Custom Skills (from skills/ dir)

| Skill | Trigger | Purpose |
|-------|---------|---------|
| **neo** (agent) | Loaded via `agent: neo` in settings.json | Orchestrator — enforces delegation pattern; never does work directly |
| **capture-to-things** | Invoke explicitly when tasks/action items identified | Add todos to Things 3 with correct project/area assignment |
| **obsidian** | Invoke when creating/editing markdown outside a git repo, or working in the vault | Routes markdown files to the correct Obsidian vault folder |
| **session-handoff** | Invoke when user says "session handoff", "wrap up session", "hand off", or wants end-of-session summary | Produces structured handoff summary for seamless next-session continuation |
| **humanize-text** | Invoke when user asks to humanize, de-AI, or clean up AI-sounding text | Rewrites AI-generated prose to read human via three-pass process (diagnose, rewrite, sanity check) |
| **web-fetch** | Invoke when fetching any URL to read webpage content — user provides a link, or Claude needs to look up docs/articles/pages | Tiered fetch: static → Jina AI (JS-rendered) → web-to-markdown CLI; all output stays in context-mode sandbox |
| **compound** | After code review with learnings | Extract lessons from code review and write as permanent rules into CLAUDE.md |


Full plugin and built-in skill list: see `rules/skills-plugins.md` (load on demand).
