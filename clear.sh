#!/bin/zsh

setopt PIPE_FAIL

SKIP=(.git graphify-out docs .claude)
FAILED=0

for d in */ ; do
  pkg="${d%/}"

  # Check SKIP list
  local_skip=0
  for s in "${SKIP[@]}"; do
    if [[ "$pkg" == "$s" ]]; then
      local_skip=1
      break
    fi
  done

  if (( local_skip )); then
    print -u2 "[clear] skipping: $pkg"
    continue
  fi

  print -u2 "[clear] de-stowing: $pkg"
  stow -D "$pkg" || {
    print -u2 "[clear] ERROR: stow -D failed for $pkg"
    FAILED=1
  }
done

(( FAILED )) && exit 1 || exit 0
