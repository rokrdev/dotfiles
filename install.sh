#!/bin/bash
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/sacredyak/dotfiles/main/install.sh)"

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
  if ! git clone git@github.com:sacredyak/dotfiles.git "$DOTFILES" 2>/dev/null; then
    echo "SSH clone failed, trying HTTPS..."
    git clone https://github.com/sacredyak/dotfiles.git "$DOTFILES"
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

echo "Bootstrap complete! Dotfiles installed to $HOME"
