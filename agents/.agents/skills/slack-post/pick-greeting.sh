#!/usr/bin/env bash
set -eu

# Follow symlinks so greetings.txt resolves from the real skill dir.
src="${BASH_SOURCE[0]}"
while [ -L "$src" ]; do
  dir="$(cd "$(dirname "$src")" && pwd -P)"
  src="$(readlink "$src")"
  case "$src" in /*) ;; *) src="$dir/$src" ;; esac
done
here="$(cd "$(dirname "$src")" && pwd -P)"
greetings="$here/greetings.txt"

# State lives outside the skill dir so it never dirties the dotfiles repo.
state_dir="${SLACK_POST_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/slack-post}"
used="$state_dir/used-greetings.txt"
mkdir -p "$state_dir"
touch "$used"

all_greetings() { cut -d'|' -f1 "$greetings" | grep -v '^[[:space:]]*$'; }

pick() {
  local last avail
  last="$(tail -n 1 "$used")"
  avail="$(all_greetings | grep -vxFf "$used" || true)"
  if [ -z "$avail" ]; then
    # Reset the cycle, but skip the last greeting so it does not repeat back to back.
    : > "$used"
    avail="$(all_greetings | grep -vxF -- "$last" || true)"
  fi
  [ -n "$avail" ] || { echo "no greetings available in $greetings" >&2; exit 1; }
  # sed instead of head avoids a SIGPIPE on sort.
  printf '%s\n' "$avail" | sort -R | sed -n 1p
}

record() {
  [ -n "${1:-}" ] || { echo "record needs a greeting" >&2; exit 2; }
  printf '%s\n' "$1" >> "$used"
}

case "${1:-}" in
  pick) pick ;;
  record) shift; record "${1:-}" ;;
  *) echo "usage: ${0##*/} pick | record \"<Greeting>\"" >&2; exit 2 ;;
esac
