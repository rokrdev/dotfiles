# dotfiles — Claude Context

## Repo Purpose

macOS dotfiles managed with GNU Stow. Each top-level directory is a stow package. Running `stow <package>` from the repo root symlinks that package's contents into `$HOME`, preserving the directory structure under each package.

Remote: `git@github.com:sacredyak/dotfiles.git`

## Stow Packages

| Package | Manages |
|---------|---------|
| `fish` | Fish shell — `~/.config/fish/` (config, functions, completions, conf.d) |
| `helix` | Helix editor — `~/.config/helix/` |
| `hammerspoon` | Hammerspoon macOS automation — `~/.hammerspoon/` |
| `git` | Git config — `~/.gitconfig` and related |
| `nvim` | Neovim — `~/.config/nvim/` |
| `tmux` | tmux config |
| `yabai` | yabai tiling window manager config |
| `skhd` | skhd hotkey daemon config |
| `karabiner` | Karabiner-Elements key remapping — `~/.config/karabiner/` |
| `ghostty` | Ghostty terminal config |
| `kitty` | Kitty terminal config |
| `wezterm` | WezTerm config |
| `alacritty` | Alacritty terminal config |
| `zellij` | Zellij terminal multiplexer config |
| `lazygit` | lazygit config |
| `gitui` | gitui config |
| `tig` | tig config |
| `bat` | bat (cat replacement) config |
| `yazi` | yazi file manager config |
| `ideavim` | IdeaVim (IntelliJ) — `~/.ideavimrc` |
| `claude` | Claude Code — `~/.claude/` (settings.json, hooks, MCP, skills) |
| `keylayout` | Custom keyboard layout files |
| `terminfo` | Terminal info entries |
| `snippets` | Code/text snippets |

Non-package items at root: `install/`, `CLAUDE.md`, `webp_convertor.sh`, `xterm-24bit.terminfo`, `clear-all`

## How to Apply Configs

```bash
# From /Users/bharat/.dotfiles — stow a single package
stow fish
stow helix
stow claude

# Restow (update symlinks after adding files to a package)
stow -R fish

# Remove symlinks for a package
stow -D fish

# Dry run to preview what would change
stow -n fish
```

Stow target is `$HOME` by default when running from the repo root. No `--target` flag needed.

## Key Files

- `fish/.config/fish/config.fish` — main fish shell config
- `fish/.config/fish/functions/` — custom fish functions (one `.fish` file per function)
- `helix/.config/helix/config.toml` — Helix editor config
- `hammerspoon/.hammerspoon/init.lua` — Hammerspoon automation entry point
- `claude/.claude/settings.json` — Claude Code settings (hooks, permissions)
- `claude/.claude/hooks/` — Claude Code hook scripts
- `claude/.claude/skills/` — custom Claude Code skills
- `claude/.claude/mcp.json` — MCP server registrations

## Conventions

- Each stow package mirrors the exact target path relative to `$HOME`. If a file lives at `~/.config/foo/bar.toml`, the package structure is `foo/.config/foo/bar.toml`.
- Package names are lowercase and match the tool name.
- To add a new tool: create a top-level directory with the correct mirrored path inside, then `stow <package>`.
- Fish functions go in `fish/.config/fish/functions/` — one function per `.fish` file, filename must match the function name.
- Keep secrets (tokens, API keys) out of the repo — use env vars or the OS keychain.

## What NOT To Do

- Do NOT edit files under `~/.config/`, `~/.hammerspoon/`, etc. directly — those are symlinks. Always edit source files in `~/.dotfiles/<package>/`.
- Do NOT run `stow` without checking for conflicts first (`stow -n <pkg>`) — stow refuses to overwrite existing non-symlink files.
- Do NOT delete the `.dotfiles` directory without first running `stow -D <pkg>` for each package, or you will leave broken symlinks across `$HOME`.
- Do NOT commit machine-specific secrets, tokens, or large binaries.

## Skills Reference

| Skill | Trigger | Purpose |
|-------|---------|---------|
| `main-agent-is-orchestrator` | Auto-loaded at SessionStart | Enforces delegation pattern — main agent never does work directly, dispatches subagents for everything |
| `capture-to-things` | Invoke explicitly when tasks/action items identified | Adds todos to Things 3 with correct project/area assignment |
| `dotfiles` | Auto when working in this repo | Enforces stow conventions — never edit symlink targets, always dry-run before stowing |

# context-mode — MANDATORY routing rules

You have context-mode MCP tools available. These rules are NOT optional — they protect your context window from flooding. A single unrouted command can dump 56 KB into context and waste the entire session.

## BLOCKED commands — do NOT attempt these

### curl / wget — BLOCKED
Any Bash command containing `curl` or `wget` is intercepted and replaced with an error message. Do NOT retry.
Instead use:
- `ctx_fetch_and_index(url, source)` to fetch and index web pages
- `ctx_execute(language: "javascript", code: "const r = await fetch(...)")` to run HTTP calls in sandbox

### Inline HTTP — BLOCKED
Any Bash command containing `fetch('http`, `requests.get(`, `requests.post(`, `http.get(`, or `http.request(` is intercepted and replaced with an error message. Do NOT retry with Bash.
Instead use:
- `ctx_execute(language, code)` to run HTTP calls in sandbox — only stdout enters context

### WebFetch — BLOCKED
WebFetch calls are denied entirely. The URL is extracted and you are told to use `ctx_fetch_and_index` instead.
Instead use:
- `ctx_fetch_and_index(url, source)` then `ctx_search(queries)` to query the indexed content

## REDIRECTED tools — use sandbox equivalents

### Bash (>20 lines output)
Bash is ONLY for: `git`, `mkdir`, `rm`, `mv`, `cd`, `ls`, `npm install`, `pip install`, and other short-output commands.
For everything else, use:
- `ctx_batch_execute(commands, queries)` — run multiple commands + search in ONE call
- `ctx_execute(language: "shell", code: "...")` — run in sandbox, only stdout enters context

### Read (for analysis)
If you are reading a file to **Edit** it → Read is correct (Edit needs content in context).
If you are reading to **analyze, explore, or summarize** → use `ctx_execute_file(path, language, code)` instead. Only your printed summary enters context. The raw file content stays in the sandbox.

### Grep (large results)
Grep results can flood context. Use `ctx_execute(language: "shell", code: "grep ...")` to run searches in sandbox. Only your printed summary enters context.

## Tool selection hierarchy

1. **GATHER**: `ctx_batch_execute(commands, queries)` — Primary tool. Runs all commands, auto-indexes output, returns search results. ONE call replaces 30+ individual calls.
2. **FOLLOW-UP**: `ctx_search(queries: ["q1", "q2", ...])` — Query indexed content. Pass ALL questions as array in ONE call.
3. **PROCESSING**: `ctx_execute(language, code)` | `ctx_execute_file(path, language, code)` — Sandbox execution. Only stdout enters context.
4. **WEB**: `ctx_fetch_and_index(url, source)` then `ctx_search(queries)` — Fetch, chunk, index, query. Raw HTML never enters context.
5. **INDEX**: `ctx_index(content, source)` — Store content in FTS5 knowledge base for later search.

## Subagent routing

When spawning subagents (Agent/Task tool), the routing block is automatically injected into their prompt. Bash-type subagents are upgraded to general-purpose so they have access to MCP tools. You do NOT need to manually instruct subagents about context-mode.

## Output constraints

- Keep responses under 500 words.
- Write artifacts (code, configs, PRDs) to FILES — never return them as inline text. Return only: file path + 1-line description.
- When indexing content, use descriptive source labels so others can `ctx_search(source: "label")` later.

## ctx commands

| Command | Action |
|---------|--------|
| `ctx stats` | Call the `ctx_stats` MCP tool and display the full output verbatim |
| `ctx doctor` | Call the `ctx_doctor` MCP tool, run the returned shell command, display as checklist |
| `ctx upgrade` | Call the `ctx_upgrade` MCP tool, run the returned shell command, display as checklist |
