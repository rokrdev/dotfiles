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
| `dotfiles` | Invoke when adding, editing, or restructuring dotfiles | Enforces stow conventions — never edit symlink targets, always dry-run before stowing |

