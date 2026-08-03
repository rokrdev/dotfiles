# dotfiles — Claude Context

## Repo Purpose

macOS dotfiles managed with GNU Stow. Each top-level directory is a stow package. Running `stow <package>` from the repo root symlinks that package's contents into `$HOME`, preserving the directory structure under each package.

Remote: `git@github.com:rokr-dev/dotfiles.git`

## Stow Packages

| Package | Manages |
|---------|---------|
| `asdf` | asdf version manager — `~/.tool-versions` |
| `bat` | bat (cat replacement) config |
| `btop` | btop system monitor — `~/.config/btop/` |
| `claude` | Claude Code — `~/.claude/` (settings.json, hooks, MCP, skills) |
| `fish` | Fish shell — `~/.config/fish/` (config, functions, completions, conf.d) |
| `ghostty` | Ghostty terminal config |
| `git` | Git config — `~/.gitconfig` and related |
| `gitui` | gitui config |
| `hammerspoon` | Hammerspoon macOS automation — `~/.hammerspoon/` |
| `helix` | Helix editor — `~/.config/helix/` |
| `herdr` | herdr config — `~/.config/herdr/` |
| `ideavim` | IdeaVim (IntelliJ) — `~/.ideavimrc` |
| `karabiner` | Karabiner-Elements key remapping — `~/.config/karabiner/` |
| `keylayout` | Custom keyboard layout files |
| `lazygit` | lazygit config |
| `marksman` | Marksman (markdown LSP) — `~/.config/marksman/` |
| `moxide` | Moxide config — `~/.config/moxide/` |
| `yazi` | yazi file manager config |
| `zed` | Zed editor — `~/.config/zed/` (keymap, settings, tasks) |

Non-package items at root: `CLAUDE.md`, `README.md`, `Brewfile`, `.editorconfig`, `install.sh`, `clear.sh`

## How to Apply Configs

```bash
# From $HOME/.dotfiles — stow a single package
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
- `claude/.claude/agents/neo.md` — neo orchestrator agent definition

## Fish Claude Aliases

Defined in `fish/.config/fish/config.fish`:

| Alias | Model | Effort | Auto-approve |
|-------|-------|--------|--------------|
| `clb` | claude-sonnet-4-6 | high | no |
| `cld` | claude-opus (high) | high | no |

## Conventions

- Each stow package mirrors the exact target path relative to `$HOME`. If a file lives at `~/.config/foo/bar.toml`, the package structure is `foo/.config/foo/bar.toml`.
- Package names are lowercase and match the tool name.
- To add a new tool: create a top-level directory with the correct mirrored path inside, then `stow <package>`.
- Fish functions go in `fish/.config/fish/functions/` — one function per `.fish` file, filename must match the function name.
- Keep secrets (tokens, API keys) out of the repo — use env vars or the OS keychain.

## Stow Cautions

- Always edit source in `~/.dotfiles/<package>/` — files under `~/.config/`, `~/.hammerspoon/`, etc. are symlinks.
- Always dry-run first (`stow -n <pkg>`) — stow refuses to overwrite existing non-symlink files.
- Run `stow -D <pkg>` for each package before deleting the `.dotfiles` directory, or you will leave broken symlinks across `$HOME`.
- Never commit machine-specific secrets, tokens, or large binaries.
