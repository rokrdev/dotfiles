# dotfiles

macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Prerequisites

- macOS
- [Homebrew](https://brew.sh/)
- [GNU Stow](https://formulae.brew.sh/formula/stow) — `brew install stow`
- git

## Quick Install

```bash
git clone git@github.com:rokr-dev/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Preview changes before applying (dry run)
stow -n fish

# Apply a package
stow fish
stow helix
stow claude
```

Stow creates symlinks from each package into `$HOME`. The target is `$HOME` by default when run from the repo root — no `--target` flag needed.

## Packages

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
| `claude` | Claude Code — `~/.claude/` (settings, hooks, skills) |
| `zed` | Zed editor — `~/.config/zed/` |
| `keylayout` | Custom keyboard layout files |
| `terminfo` | Terminal info entries |
| `snippets` | Code/text snippets |

## Structure

Each package mirrors the exact target path relative to `$HOME`. For example, a file at `~/.config/fish/config.fish` lives in the repo at `fish/.config/fish/config.fish`.

To add a new tool: create a top-level directory with the correct mirrored path, then `stow <package>`.

**Never edit files under `~/.config/` or `~/.hammerspoon/` directly** — those are symlinks. Always edit source files in `~/.dotfiles/<package>/`.

## Utilities

- **`clear-all`** — zsh script at repo root that unstows all packages at once (`stow -D` on each). Useful for a clean removal of all symlinks.

## Docs

See [`docs/`](docs/) for detailed workflow documentation.
