# dotfiles

macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Prerequisites

- macOS
- [Homebrew](https://brew.sh/)
- [GNU Stow](https://formulae.brew.sh/formula/stow) — `brew install stow`
- git

## Quick Install

### Bootstrap (new machine)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/rokrdev/dotfiles/main/install.sh)"
```

This installs Homebrew, clones the repo, runs `brew bundle`, stows all packages, and sets up language servers and tools automatically.

### Manual install

```bash
git clone git@github.com:rokrdev/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Preview changes before applying (dry run)
stow -n fish

# Apply a package
stow fish
stow helix
stow agents
stow claude
stow ccstatusline
```

Stow creates symlinks from each package into `$HOME`. The target is `$HOME` by default when run from the repo root — no `--target` flag needed.

## Packages

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
| `yazi` | yazi file manager config |
| `zed` | Zed editor — `~/.config/zed/` |

## Structure

Each package mirrors the exact target path relative to `$HOME`. For example, a file at `~/.config/fish/config.fish` lives in the repo at `fish/.config/fish/config.fish`.

To add a new tool: create a top-level directory with the correct mirrored path, then `stow <package>`.

## Agent skills

Skills live once under `agents/.agents/skills/`. Stow exposes them as
`~/.agents/skills/`, the user-level skill directory read by Codex and DeepSeek
Harness. DeepSeek Harness profiles built on `dsh-base`, including the persistent
Web profile, watch that directory and refresh their skill catalog after changes.

Claude Code reads `~/.claude/skills/`, so the `claude` package contains one Git
symlink per skill pointing back to the canonical copy. Edit only the canonical
files. Invoke a skill using the syntax of the active harness: `$skill-name` in
Codex or `/skill-name` in Claude Code and DeepSeek Harness.

Stow both packages after changing the skill set:

```bash
stow -R --no-folding agents claude
```

The deterministic local workflow is:

1. `grill-me` or `grill-with-docs` — resolve the product decisions.
2. `to-prd` — write an explicitly reviewed product contract.
3. `to-tickets` — create an intent-based schema-v3 feature and serial tickets under `.workflow/kanban/`.
4. `kanban-loop` — run worktree-isolated sequential HITL or worktree-parallel AUTO implementation, verification, fresh review, pause/resume, and descriptive per-ticket commits.
5. `ship-it` — optionally push the completed feature branch and open a pull request.

`tdd`, `code-review`, `diagnosing-bugs`, `to-bug-ticket`, and `handoff` remain independently invocable. The issue-tracker-oriented `setup-matt-pocock-skills`, `to-spec`, `grilling`, and domain-modeling skills are also available when a project uses that workflow.

**Never edit files under `~/.config/` or `~/.hammerspoon/` directly** — those are symlinks. Always edit source files in `~/.dotfiles/<package>/`.

## Utilities

- **`install.sh`** — full bootstrap installer (Homebrew, brew bundle, stow, asdf, language servers, Claude Code).
- **`scripts/install-intellij-server.sh`** — installs and verifies JetBrains' Java/Kotlin IntelliJ language server, records explicit EULA acceptance, and wires its Helix wrapper into `~/.local/bin`.
- **`clear.sh`** — shell script at repo root that unstows all packages at once (`stow -D` on each). Useful for a clean removal of all symlinks. Skips non-package dirs (`.git`, tool dirs, etc.).

## Java and Kotlin in Helix

Java and Kotlin use the same IntelliJ language-server process so Gradle, Maven,
and Bazel projects containing both languages share one imported project model.
The server is distributed separately from the small VS Code/Open VSX extension
and is covered by a JetBrains EULA.

Install or update it with:

```bash
scripts/install-intellij-server.sh
```

The installer fetches the current platform manifest, verifies the server
archive's published SHA-256, shows the EULA when it changes, and activates the
new build side-by-side. Run `intellij-server-helix --check` afterwards, then
restart an existing editor with `:lsp-restart`.

Useful overrides:

- `IJ_JAVA_OPTIONS="-Xmx4g"` increases the language-server heap.
- `INTELLIJ_REGION=oceania` changes the product-terms region (the wrapper's
  default for these personal dotfiles).
- `INTELLIJ_DATA_SHARING=none` controls telemetry (also the default).
- `INTELLIJ_SERVER_HOME=/path` selects a non-default installation directory.

The wrapper also translates library `jar:` and JDK `jrt:` locations into local
cached source files, because Helix only opens filesystem URIs. Project-local
Java/Kotlin navigation does not require this translation.
