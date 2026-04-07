---
name: dotfiles
description: Use when working in the dotfiles repo — enforces stow conventions, prevents editing symlink targets, guides adding new packages
when_to_use: When the user asks to add, edit, or restructure any dotfile or stow package
---

# Dotfiles Skill

## Core Rule

NEVER edit stow target files directly — `~/.config/`, `~/.hammerspoon/`, and `~/.claude/` are all symlink destinations.
Always edit the source files in `~/.dotfiles/<package>/` (e.g. `~/.dotfiles/claude/.claude/` for Claude configs).
Referencing `~/.claude/` as a path is fine; the rule is about editing via the symlink instead of the source.

## Before Stowing — Always Dry-Run First

```bash
stow -n <package>
```

If conflicts are shown (existing non-symlink files): back up, remove, then stow.

## Adding a New Package

1. Create the directory mirroring the target path relative to $HOME:
   - File at `~/.config/foo/bar.toml` → package structure: `~/.dotfiles/foo/.config/foo/bar.toml`
2. Dry-run: `stow -n foo`
3. Stow: `stow foo`
4. Verify: `ls -la ~/.config/foo/bar.toml`

## Adding Files to an Existing Package

```bash
stow -R <package>
```

## Removing a Package

```bash
stow -D <package>
```

Removes symlinks only — source files are preserved.

## Common Mistakes to Avoid

- Editing `~/.config/fish/config.fish` instead of `~/.dotfiles/fish/.config/fish/config.fish`
- Running `stow` without `-n` dry-run first
- Forgetting `stow -R` after adding new files
- Committing secrets or tokens in any config file
