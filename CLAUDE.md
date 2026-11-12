# dotfiles — Claude Context

## Repo Purpose

macOS dotfiles managed with GNU Stow. Each top-level directory is a stow package. Running `stow <package>` from the repo root symlinks that package's contents into `$HOME`, preserving the directory structure under each package.

Remote: `git@github.com:rokrdev/dotfiles.git`

## Stow Packages

| Package | Manages |
|---------|---------|
| `aerospace` | AeroSpace window manager — `~/.config/aerospace/` |
| `agents` | Global instructions and canonical Codex/DeepSeek Harness skills — `~/AGENTS.md`, `~/.agents/skills/` |
| `asdf` | asdf version manager — `~/.tool-versions` |
| `bat` | bat (cat replacement) config |
| `bin` | User scripts — `~/.local/bin/` |
| `borders` | JankyBorders — `~/.config/borders/` |
| `btop` | btop system monitor — `~/.config/btop/` |
| `ccstatusline` | ccstatusline — `~/.config/ccstatusline/` |
| `claude` | Claude Code — `~/.claude/` (settings, hooks, agents, and skill compatibility links) |
| `dprint` | dprint formatter — `~/.config/dprint/` |
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
| `sketchybar` | SketchyBar menu bar — `~/.config/sketchybar/` |
| `yazi` | yazi file manager config, installs plugins via `ya pkg install` from package.toml |

Non-package items at root: `CLAUDE.md`, `README.md`, `Brewfile`, `.editorconfig`, `install.sh`, `clear.sh`, `scripts/`, `docs/`, `tests/`

## How to Apply Configs

```bash
# From $HOME/.dotfiles — stow a single package
stow fish
stow helix
stow agents
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

- `agents/AGENTS.md` — global agent instructions for all tools (stows to `~/AGENTS.md`)
- `agents/.agents/skills/` — canonical Codex/DeepSeek Harness skills (stows to `~/.agents/skills/`)
- `fish/.config/fish/config.fish` — main fish shell config
- `fish/.config/fish/functions/` — custom fish functions (one `.fish` file per function)
- `helix/.config/helix/config.toml` — Helix editor config
- `hammerspoon/.hammerspoon/init.lua` — Hammerspoon automation entry point
- `claude/.claude/settings.json` — Claude Code settings (hooks, permissions)
- `claude/.claude/hooks/` — Claude Code hook scripts
- `claude/.claude/skills/` — per-skill compatibility symlinks to `agents/.agents/skills/`
- `claude/.claude/agents/` — agent definitions (neo, merlin, argus)

Codex and DeepSeek Harness read the canonical `~/.agents/skills/` tree directly.
DeepSeek Harness profiles based on `dsh-base`, including the persistent Web
profile, watch that tree and refresh their catalogs without a restart. Claude
Code uses the compatibility links under `~/.claude/skills/`. Invoke skills as
`$skill-name` in Codex or `/skill-name` in Claude Code and DeepSeek Harness.

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
