#!/bin/bash
# One-shot installer for the JetBrains IntelliJ LSP engine ("Java and Kotlin by
# IntelliJ IDEA" VSIX, JetBrains.intellij-server) + kmp-lsp diagnostics server.
#
# Designed to reproduce the same Helix setup on a fresh system:
#   1. git pull the dotfiles repo (this script lives in it)
#   2. stow helix
#   3. run:  scripts/install-intellij-server.sh
#   4. open hx (or :lsp-restart existing sessions)
#
# What it does:
#   - downloads the latest darwin-arm64/darwin-x64 VSIX from the marketplace
#   - extracts the engine to $HOME/.local/share/jetbrains-intellij-server
#   - rewrites [language-server.intellij] in languages.toml with this machine's
#     absolute paths + fresh eulaHash (preview builds expire ~30 days, so re-run
#     this script when the engine stops answering)
#   - installs kmp-lsp via cargo if missing (it supplies diagnostics, which the
#     IntelliJ engine doesn't push)
#
# Usage: scripts/install-intellij-server.sh [DEST] [LANG_FILE]
set -euo pipefail
# Force UTF-8 for all python3 invocations regardless of locale (C/POSIX locale
# on fresh systems makes sys.stdin/open() default to ASCII -> UnicodeDecodeError)
export PYTHONUTF8=1

DEST="${1:-$HOME/.local/share/jetbrains-intellij-server}"
EXT="$DEST/extension"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

for cmd in curl unzip python3; do
    command -v "$cmd" >/dev/null 2>&1 || { echo "ERROR: $cmd not found" >&2; exit 1; }
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LANG_FILE="${2:-$REPO_ROOT/helix/.config/helix/languages.toml}"
if [ ! -f "$LANG_FILE" ]; then
    LANG_FILE="$(python3 -c "import os;print(os.path.realpath('$HOME/.config/helix/languages.toml'))" 2>/dev/null || echo "$HOME/.config/helix/languages.toml")"
fi

case "$(uname -m)" in
    arm64)  PLATFORM="darwin-arm64" ;;
    x86_64) PLATFORM="darwin-x64" ;;
    *) echo "ERROR: unsupported arch $(uname -m)" >&2; exit 1 ;;
esac

echo "==> Querying marketplace for $PLATFORM..."
URL=$(curl -s "https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery" \
  -H "Content-Type: application/json" -H "Accept: application/json;api-version=3.0-preview.1" \
  -d '{"filters":[{"criteria":[{"filterType":7,"value":"JetBrains.intellij-server"}],"assetTypes":[],"pageNumber":1,"pageSize":1,"sortBy":0}],"flags":950}' \
  | python3 - "$PLATFORM" <<'PY'
import json, sys
d = json.loads(sys.stdin.buffer.read().decode('utf-8'))
platform = sys.argv[1]
ext = d['results'][0]['extensions'][0]
for v in ext['versions']:
    if v['targetPlatform'] == platform:
        for f in v['files']:
            if 'VSIXPackage' in f['assetType']:
                print(f['source'])
                sys.exit(0)
print(f'ERROR: no {platform} VSIX found (preview may be arm64-only)', file=sys.stderr)
sys.exit(1)
PY
)

echo "==> Downloading $URL"
curl -sL -o "$TMP/server.vsix" "$URL"
echo "==> Extracting..."
unzip -q -o "$TMP/server.vsix" -d "$TMP/x"
rm -rf "$EXT"
mkdir -p "$EXT"
mv "$TMP/x/extension" "$EXT/extension"

EULA="$EXT/extension/server/EULA.txt"
JBR="$EXT/extension/server/jbr/Contents/Home"
LAUNCHER="$EXT/extension/server/bin/intellij-server"
HASH=$(python3 -c "import hashlib;print(hashlib.sha256(open('$EULA','rb').read()).hexdigest()[:16])")

# Rewrite the [language-server.intellij] block with this machine's absolute
# paths + fresh eulaHash. Helix does NOT expand ~ in command/args, hence abs.
python3 - "$LANG_FILE" "$LAUNCHER" "$HOME/.cache/intellij-server" "$JBR" "$HASH" <<'PY'
import re, sys
path, launcher, syspath, jbr, hash_ = sys.argv[1:]
src = open(path, encoding='utf-8').read()
start = src.index('[language-server.intellij]')
# next section boundary at line start; \n[ avoids matching '[' inside the args line
end = src.index('\n[', start + 1)
block = src[start:end]
block = re.sub(r'command = ".*"', f'command = "{launcher}"', block)
block = re.sub(r'--system-path", "[^"]*"', f'--system-path", "{syspath}"', block)
block = re.sub(r'defaultSdk = "[^"]*"', f'defaultSdk = "{jbr}"', block)
block = re.sub(r'eulaHash = "[0-9a-f]+"', f'eulaHash = "{hash_}"', block)
open(path, 'w', encoding='utf-8').write(src[:start] + block + src[end:])
print(f'patched {path}')
PY

if ! command -v kmp-lsp >/dev/null 2>&1; then
    if command -v cargo >/dev/null 2>&1; then
        echo "==> kmp-lsp not found, installing via cargo (this can take a few minutes)..."
        cargo install kmp-lsp
    else
        echo "!! kmp-lsp not found and cargo missing — install it manually (cargo install kmp-lsp)" >&2
    fi
fi

echo ""
echo "==> Done. Engine version: $(cat "$EXT/extension/server/build.txt" 2>/dev/null || echo unknown)"
echo "==> eulaHash: $HASH (written to $LANG_FILE)"
echo "==> Restart Helix sessions with :lsp-restart, or just open hx fresh."
