#!/usr/bin/env bash
# Install the language server behind "Java and Kotlin by IntelliJ IDEA" for Helix.
set -euo pipefail

export PYTHONUTF8=1

DEST="${INTELLIJ_SERVER_HOME:-$HOME/.local/share/jetbrains-intellij-server}"
ACCEPT_EULA=false

usage() {
  cat <<'EOF'
Usage: install-intellij-server.sh [--accept-eula] [--dest PATH]

Downloads the latest platform-specific JetBrains IntelliJ language server,
verifies its published SHA-256, installs it side-by-side, and activates it for
the Helix wrapper.

The server has a JetBrains EULA. Without --accept-eula the script shows the
agreement and asks for explicit acceptance on an interactive terminal.
EOF
}

while (($#)); do
  case "$1" in
    --accept-eula)
      ACCEPT_EULA=true
      shift
      ;;
    --dest)
      [[ $# -ge 2 ]] || { echo "ERROR: --dest requires a path" >&2; exit 2; }
      DEST="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

for command in curl python3 tar unzip; do
  command -v "$command" >/dev/null 2>&1 || {
    echo "ERROR: required command not found: $command" >&2
    exit 1
  }
done

case "$(uname -s):$(uname -m)" in
  Darwin:arm64) PLATFORM="darwin-arm64" ;;
  Darwin:x86_64) PLATFORM="darwin-x64" ;;
  *)
    echo "ERROR: this dotfiles installer currently supports macOS arm64/x64 only" >&2
    exit 1
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WRAPPER_SOURCE="$REPO_ROOT/bin/.local/bin/intellij-server-helix"
TMP_DIR="$(mktemp -d)"
INSTALL_TMP=""

cleanup() {
  rm -rf "$TMP_DIR"
  if [[ -n "$INSTALL_TMP" && -d "$INSTALL_TMP" ]]; then
    rm -rf "$INSTALL_TMP"
  fi
}
trap cleanup EXIT

echo "==> Discovering the latest JetBrains extension for $PLATFORM"
curl -fsSL "https://open-vsx.org/api/JetBrains/intellij-server/latest" \
  -o "$TMP_DIR/open-vsx.json"

read -r EXTENSION_VERSION VSIX_URL < <(python3 - "$PLATFORM" "$TMP_DIR/open-vsx.json" <<'PY'
import json
import sys

platform, path = sys.argv[1:]
with open(path, encoding="utf-8") as source:
    metadata = json.load(source)
version = metadata.get("version")
url = metadata.get("downloads", {}).get(platform)
if not isinstance(version, str) or not version:
    raise SystemExit("ERROR: Open VSX metadata has no extension version")
if not isinstance(url, str) or not url.startswith("https://open-vsx.org/"):
    raise SystemExit(f"ERROR: Open VSX metadata has no safe download for {platform}")
print(version, url)
PY
)

echo "==> Downloading extension shim $EXTENSION_VERSION"
curl -fsSL "$VSIX_URL" -o "$TMP_DIR/intellij-server.vsix"
unzip -p "$TMP_DIR/intellij-server.vsix" extension/server-bundle.json \
  > "$TMP_DIR/server-bundle.json"

read -r SERVER_VERSION ARCHIVE_NAME ARCHIVE_URL ARCHIVE_SHA < <(python3 - "$TMP_DIR/server-bundle.json" <<'PY'
import json
import re
import sys
from urllib.parse import urlparse

with open(sys.argv[1], encoding="utf-8") as source:
    bundle = json.load(source)
version = bundle.get("version")
name = bundle.get("archiveName")
url = bundle.get("url")
sha = bundle.get("sha256")
if not isinstance(version, str) or not re.fullmatch(r"[0-9A-Za-z][0-9A-Za-z._-]*", version):
    raise SystemExit("ERROR: invalid server version in bundle metadata")
if not isinstance(name, str) or name != name.rsplit("/", 1)[-1] or not name:
    raise SystemExit("ERROR: invalid archive name in bundle metadata")
parsed = urlparse(url) if isinstance(url, str) else None
if parsed is None or parsed.scheme != "https" or parsed.hostname != "download.jetbrains.com":
    raise SystemExit("ERROR: unexpected server download URL in bundle metadata")
if not isinstance(sha, str) or not re.fullmatch(r"[0-9a-fA-F]{64}", sha):
    raise SystemExit("ERROR: invalid server checksum in bundle metadata")
print(version, name, url, sha.lower())
PY
)

SERVERS_DIR="$DEST/servers"
DOWNLOADS_DIR="$DEST/downloads"
SERVER_DIR="$SERVERS_DIR/$SERVER_VERSION"
ARCHIVE="$DOWNLOADS_DIR/$ARCHIVE_NAME"
LAUNCHER="$SERVER_DIR/bin/intellij-server"

mkdir -p "$SERVERS_DIR" "$DOWNLOADS_DIR"
if [[ ! -x "$LAUNCHER" ]]; then
  echo "==> Downloading IntelliJ language server $SERVER_VERSION"
  if [[ -f "$ARCHIVE" ]]; then
    if ! curl -fL --continue-at - "$ARCHIVE_URL" -o "$ARCHIVE"; then
      echo "==> Cached download cannot be resumed; restarting it"
      rm -f "$ARCHIVE"
      curl -fL "$ARCHIVE_URL" -o "$ARCHIVE"
    fi
  else
    curl -fL "$ARCHIVE_URL" -o "$ARCHIVE"
  fi

  ACTUAL_SHA="$(python3 - "$ARCHIVE" <<'PY'
import hashlib
import sys

digest = hashlib.sha256()
with open(sys.argv[1], "rb") as source:
    for chunk in iter(lambda: source.read(1024 * 1024), b""):
        digest.update(chunk)
print(digest.hexdigest())
PY
)"
  if [[ "$ACTUAL_SHA" != "$ARCHIVE_SHA" ]]; then
    rm -f "$ARCHIVE"
    echo "ERROR: server checksum mismatch" >&2
    echo "  expected: $ARCHIVE_SHA" >&2
    echo "  actual:   $ACTUAL_SHA" >&2
    exit 1
  fi

  echo "==> Checksum verified; extracting server"
  INSTALL_TMP="$SERVERS_DIR/.install-$SERVER_VERSION-$$"
  UNPACK_DIR="$TMP_DIR/unpacked"
  case "$ARCHIVE_NAME" in
    *.sit)
      mkdir -p "$UNPACK_DIR"
      tar -xf "$ARCHIVE" -C "$UNPACK_DIR"
      shopt -s dotglob nullglob
      entries=("$UNPACK_DIR"/*)
      shopt -u dotglob nullglob
      if [[ ${#entries[@]} -eq 1 && -d "${entries[0]}" ]]; then
        mv "${entries[0]}" "$INSTALL_TMP"
      else
        mkdir -p "$INSTALL_TMP"
        for entry in "${entries[@]}"; do
          mv "$entry" "$INSTALL_TMP/"
        done
      fi
      ;;
    *.tar.gz|*.tgz)
      mkdir -p "$INSTALL_TMP"
      tar -xzf "$ARCHIVE" --strip-components=1 -C "$INSTALL_TMP"
      ;;
    *.zip)
      mkdir -p "$INSTALL_TMP"
      tar -xf "$ARCHIVE" -C "$INSTALL_TMP"
      ;;
    *)
      echo "ERROR: unsupported server archive: $ARCHIVE_NAME" >&2
      exit 1
      ;;
  esac

  [[ -d "$INSTALL_TMP/lib" && -x "$INSTALL_TMP/bin/intellij-server" ]] || {
    echo "ERROR: extracted server is incomplete" >&2
    exit 1
  }
  if [[ -e "$SERVER_DIR" ]]; then
    mv "$SERVER_DIR" "$SERVERS_DIR/.incomplete-$SERVER_VERSION-$(date +%s)"
  fi
  mv "$INSTALL_TMP" "$SERVER_DIR"
  INSTALL_TMP=""
  rm -f "$ARCHIVE"
else
  echo "==> IntelliJ language server $SERVER_VERSION is already installed"
fi

EULA="$SERVER_DIR/EULA.txt"
[[ -f "$EULA" ]] || { echo "ERROR: installed server has no EULA.txt" >&2; exit 1; }
EULA_HASH="$(python3 - "$EULA" <<'PY'
import hashlib
import sys
print(hashlib.sha256(open(sys.argv[1], "rb").read()).hexdigest()[:16])
PY
)"

CURRENT_ACCEPTED=""
if [[ -f "$DEST/accepted-eula" ]]; then
  CURRENT_ACCEPTED="$(tr -d '[:space:]' < "$DEST/accepted-eula")"
fi

if [[ "$CURRENT_ACCEPTED" != "$EULA_HASH" && "$ACCEPT_EULA" != true ]]; then
  if [[ ! -t 0 ]]; then
    echo "==> Server installed, but its EULA has not been accepted."
    echo "    Review: $EULA"
    echo "    Then rerun interactively, or rerun with --accept-eula."
    exit 3
  fi
  echo
  echo "===== JetBrains IntelliJ language server EULA ====="
  cat "$EULA"
  echo "===== End EULA ====="
  echo
  read -r -p "Type 'accept' to accept this EULA for server $SERVER_VERSION: " answer
  if [[ "$answer" != "accept" ]]; then
    echo "EULA not accepted; the server remains installed but will not be launched."
    exit 3
  fi
fi

printf '%s\n' "$EULA_HASH" > "$DEST/accepted-eula"
ln -sfn "servers/$SERVER_VERSION" "$DEST/current"

mkdir -p "$HOME/.local/bin"
chmod +x "$WRAPPER_SOURCE"
ln -sfn "$WRAPPER_SOURCE" "$HOME/.local/bin/intellij-server-helix"

echo
echo "==> Installed IntelliJ language server $SERVER_VERSION"
echo "==> Activated: $DEST/current"
echo "==> Wrapper:   $HOME/.local/bin/intellij-server-helix"
echo "==> Verify:    intellij-server-helix --check"
echo "==> Restart existing Helix sessions with :lsp-restart"
