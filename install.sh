#!/bin/bash
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/rokr-dev/dotfiles/main/install.sh)"

set -e

# ─────────────────────────────────────────────
# Homebrew
# ─────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Add Homebrew to PATH (Apple Silicon: /opt/homebrew, Intel: /usr/local)
# This must run unconditionally on every invocation to ensure brew is in PATH
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# ─────────────────────────────────────────────
# Clone dotfiles repo
# ─────────────────────────────────────────────
DOTFILES="${HOME}/.dotfiles"

if [[ -d "$DOTFILES/.git" ]]; then
  echo "Dotfiles already cloned at $DOTFILES"
else
  echo "Cloning dotfiles repo..."
  # Try SSH first, fall back to HTTPS if it fails
  if ! git clone git@github.com:rokr-dev/dotfiles.git "$DOTFILES" 2>/dev/null; then
    echo "SSH clone failed, trying HTTPS..."
    git clone https://github.com/rokr-dev/dotfiles.git "$DOTFILES"
  fi
fi

cd "$DOTFILES"

# ─────────────────────────────────────────────
# Homebrew packages from Brewfile
# ─────────────────────────────────────────────
if [[ ! -f "$DOTFILES/Brewfile" ]]; then
  echo "ERROR: Brewfile not found at $DOTFILES/Brewfile"
  exit 1
fi

echo "Installing dependencies from Brewfile..."
brew bundle --file="$DOTFILES/Brewfile"

# ─────────────────────────────────────────────
# GNU Stow
# ─────────────────────────────────────────────
if ! command -v stow &>/dev/null; then
  echo "ERROR: GNU Stow not found after brew bundle. Check Brewfile."
  exit 1
fi

echo "Stowing packages..."
for d in "$DOTFILES"/*/ ; do
  # Get the directory name (strip trailing slash and path)
  dirname="$(basename "$d")"

  # Skip non-package directories and files
  case "$dirname" in
    install|.git|docs|node_modules|.claude) continue ;;
  esac

  # Dry-run check for conflicts
  conflicts=$(stow -v --no-folding -n -d "$DOTFILES" "$dirname" 2>&1 | grep "conflict" || true)

  if [ -n "$conflicts" ]; then
    echo "ERROR: stow conflicts detected in $dirname — cannot proceed"
    echo "Run 'stow -n $dirname' to see details:"
    echo "$conflicts"
    exit 1
  else
    echo "Restowing $dirname..."
    stow -R -v --no-folding -d "$DOTFILES" "$dirname"
  fi
done

# ─────────────────────────────────────────────
# asdf — plugins and tool versions
# ─────────────────────────────────────────────
echo "Installing asdf plugins..."
asdf plugin add bun || true
asdf plugin add java || true
asdf plugin add lua-language-server || true
asdf plugin add nodejs || true
asdf plugin add python || true
asdf plugin add ruby || true
asdf plugin add rust || true

echo "Installing tool versions from ~/.tool-versions..."
asdf install

# ─────────────────────────────────────────────
# Language servers
# ─────────────────────────────────────────────

# npm: typescript-language-server, prettier, basedpyright
if command -v npm &>/dev/null; then
  echo "Installing npm language servers..."
  command -v typescript-language-server &>/dev/null || npm install -g typescript typescript-language-server
  command -v prettier &>/dev/null || npm install -g prettier
  command -v basedpyright &>/dev/null || npm install -g basedpyright
else
  echo "WARNING: npm not found — skipping typescript-language-server, prettier, and basedpyright. Run after asdf nodejs setup."
fi

# cargo: simple-completion-language-server (scls)
if command -v cargo &>/dev/null; then
  if ! command -v simple-completion-language-server &>/dev/null; then
    echo "Installing simple-completion-language-server..."
    cargo install simple-completion-language-server || echo "WARNING: cargo install failed — run manually after Rust is set up."
  fi
else
  echo "WARNING: cargo not found — skipping simple-completion-language-server. Run after asdf rust setup."
fi

# Python LSP: basedpyright (npm, above) + ruff (brew, Brewfile)
# pylsp is no longer used — replaced by basedpyright for type checking and ruff for linting/formatting.

# ─────────────────────────────────────────────
# Claude Code
# ─────────────────────────────────────────────
if ! command -v claude &>/dev/null; then
  echo "Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
  # Refresh PATH — Claude Code installs to ~/.local/bin
  export PATH="$HOME/.local/bin:$PATH"
fi

# if command -v claude &>/dev/null; then
#   echo "Installing Claude Code plugins..."
#   claude plugin install superpowers@claude-plugins-official || true
#   claude plugin install context7@claude-plugins-official || true
#   claude plugin install context-mode@context-mode || true
#   claude plugin install pr-review-toolkit@claude-plugins-official || true
# else
#   echo "WARNING: claude not found in PATH — skipping plugin installation. Run manually after setup."
# fi

# ─────────────────────────────────────────────
# Manual setup required
# ─────────────────────────────────────────────
echo ""
echo "Bootstrap complete! Dotfiles installed to $HOME"
echo ""
echo "Manual setup steps:"
echo "1. Things 3 app (macOS task manager, required by capture-to-things skill)"
echo "   → Install from Mac App Store"
echo ""
echo "2. Set Fish as default shell"
echo "   → chsh -s /opt/homebrew/bin/fish"
echo ""
echo "NOTE: Do NOT stow ~/.claude/settings.local.json — it contains personal"
echo "      paths, email, and API references specific to this machine."
