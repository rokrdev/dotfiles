# Plugin & Built-in Skills (Reference)

Load on demand — not auto-loaded every session. See `rules/skills.md` for always-active custom skills.

## Plugin Skills (via `enabledPlugins` in settings.json)

### context-mode (`context-mode@context-mode`)
| Skill | Trigger | Purpose |
|-------|---------|---------|
| `context-mode:context-mode` | Use ctx_execute/ctx_execute_file instead of Bash/cat for large output | Context window protection via sandbox routing |
| `context-mode:ctx-upgrade` | `/ctx-upgrade` | Update context-mode from GitHub, fix hooks/settings |
| `context-mode:ctx-doctor` | `/ctx-doctor` | Run context-mode diagnostics |
| `context-mode:ctx-stats` | `/ctx-stats` | Show token savings for current session |
| `context-mode:ctx-purge` | `/ctx-purge` | Permanently purge the knowledge base |
| `context-mode:context-mode-ops` | Managing context-mode GitHub issues/PRs/releases | Parallel subagent ops for plugin maintenance |

### caveman (`caveman@caveman`)
| Skill | Trigger | Purpose |
|-------|---------|---------|
| `caveman:caveman` | Ultra-compressed communication needed | Cuts token usage ~75% via caveman speak |
| `caveman:compress` | `/caveman:compress <filepath>` | Compress CLAUDE.md/memory files into caveman format |
| `caveman:caveman-review` | Code review comments needed | Ultra-compressed PR review feedback |
| `caveman:caveman-commit` | Commit message generation | Ultra-compressed conventional commit messages |
| `caveman:caveman-help` | `/caveman-help` or "what caveman commands" | Quick-reference card for all caveman modes |

### pr-review-toolkit (`pr-review-toolkit@claude-plugins-official`)
| Skill | Trigger | Purpose |
|-------|---------|---------|
| `pr-review-toolkit:review-pr` | PR review requested | Comprehensive PR review using specialized agents |

### claude-md-management (`claude-md-management@claude-plugins-official`)
| Skill | Trigger | Purpose |
|-------|---------|---------|
| `claude-md-management:revise-claude-md` | After a session with learnings to capture | Update CLAUDE.md with session learnings |
| `claude-md-management:claude-md-improver` | Auditing/improving CLAUDE.md files | Structured CLAUDE.md audit and improvement |

### ralph-loop (`ralph-loop@claude-plugins-official`)
| Skill | Trigger | Purpose |
|-------|---------|---------|
| `ralph-loop:ralph-loop` | Start recurring loop in current session | Kick off Ralph Loop |
| `ralph-loop:cancel-ralph` | Cancel active loop | Stop Ralph Loop |
| `ralph-loop:help` | "how does ralph loop work" | Explain Ralph Loop plugin and commands |

### skill-creator (`skill-creator@claude-plugins-official`)
| Skill | Trigger | Purpose |
|-------|---------|---------|
| `skill-creator:skill-creator` | Creating, modifying, or measuring skills | Skill creation and improvement workflow |

### claude-code-setup (`claude-code-setup@claude-plugins-official`)
| Skill | Trigger | Purpose |
|-------|---------|---------|
| `claude-code-setup:claude-automation-recommender` | Analyzing a codebase for automation opportunities | Recommend hooks, subagents, skills, and workflows |

### swift-lsp (`swift-lsp@claude-plugins-official`)
| Skill | Trigger | Purpose |
|-------|---------|---------|
| `swift-lsp` | Swift/iOS/macOS projects needing symbol navigation, type resolution, or diagnostics | LSP-backed Swift language intelligence (manual invocation only) |

### code-simplifier (`code-simplifier@claude-plugins-official`)
| Skill | Trigger | Purpose |
|-------|---------|---------|
| `code-simplifier` | After completing a feature or refactor — reviewing changed code for complexity | Simplifies code for clarity and maintainability (manual invocation only) |

### security-guidance (`security-guidance@claude-plugins-official`)
| Skill | Trigger | Purpose |
|-------|---------|---------|
| `security-guidance` | When reviewing code for security issues or planning security-sensitive features | Structured security analysis and remediation recommendations (manual invocation only) |

## Built-in / Native Skills (always available)
| Skill | Purpose |
|-------|---------|
| `simplify` | Review changed code for reuse, quality, efficiency; fix issues |
| `init` | Initialize a new CLAUDE.md for a repo |
| `review` | Review a pull request |
| `security-review` | Security review of pending branch changes |
| `audit-instructions` | Audit and tune agent instruction files; output proposed changes for review — never auto-edits |
