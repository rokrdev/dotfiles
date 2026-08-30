#!/usr/bin/env bash

# Create Claude worktrees from the triggering Agent tool call's description.
# WorktreeCreate hooks must print the resulting absolute path as the final
# non-empty stdout line. Keep all diagnostics on stderr.

set -u
set -o pipefail

printed_path=0
initial_dir="$(pwd -P 2>/dev/null || pwd)"
output_path="$initial_dir/.claude/worktrees/isolated-worktree"

print_path_on_exit() {
  status=$?
  trap - EXIT
  if [ "$printed_path" -eq 0 ]; then
    printf '%s\n' "$output_path"
  fi
  exit "$status"
}
trap print_path_on_exit EXIT

slugify() {
  printf '%s' "$1" \
    | LC_ALL=C tr '[:upper:]' '[:lower:]' \
    | LC_ALL=C sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//' \
    | cut -c 1-64 \
    | LC_ALL=C sed -E 's/-+$//'
}

payload="$(command cat 2>/dev/null)"
input_cwd=""
input_name=""
transcript_path=""
description=""

if command -v jq >/dev/null 2>&1; then
  input_cwd="$(printf '%s' "$payload" | jq -r '.cwd // empty' 2>/dev/null)"
  input_name="$(printf '%s' "$payload" | jq -r '.name // empty' 2>/dev/null)"
  transcript_path="$(printf '%s' "$payload" | jq -r '.transcript_path // empty' 2>/dev/null)"

  if [ -n "$transcript_path" ] && [ -r "$transcript_path" ]; then
    # The triggering tool call is near the end of the JSONL transcript. Bound
    # the scan so a very large or malformed transcript cannot stall creation.
    description="$(
      tail -n 400 "$transcript_path" 2>/dev/null \
        | jq -rs '
            [
              .[]
              | ..
              | objects
              | select(
                  .type? == "tool_use"
                  and (.name? == "Agent" or .name? == "Task")
                  and .input?.isolation? == "worktree"
                )
              | .input.description?
              | select(type == "string" and length > 0)
            ]
            | last // empty
          ' 2>/dev/null
    )"
  fi
fi

if [ -n "$input_cwd" ] && [ -d "$input_cwd" ]; then
  start_dir="$input_cwd"
else
  start_dir="$initial_dir"
fi

if [ -z "$description" ]; then
  case "$input_name" in
    "" | agent-*) description="isolated-worktree" ;;
    *) description="$input_name" ;;
  esac
fi

base_slug="$(slugify "$description")"
if [ -z "$base_slug" ]; then
  base_slug="isolated-worktree"
fi

output_path="$start_dir/.claude/worktrees/$base_slug"

repo_root="$(git -C "$start_dir" rev-parse --show-toplevel 2>/dev/null)"
if [ -z "$repo_root" ] || [ ! -d "$repo_root" ]; then
  printf 'WorktreeCreate: not inside a Git repository: %s\n' "$start_dir" >&2
  exit 1
fi

repo_root="$(cd "$repo_root" 2>/dev/null && pwd -P)"
if [ -z "$repo_root" ]; then
  printf 'WorktreeCreate: cannot resolve repository root\n' >&2
  exit 1
fi

worktree_root="$repo_root/.claude/worktrees"
candidate="$base_slug"
attempt=1

while [ "$attempt" -le 100 ]; do
  branch="worktree-$candidate"
  output_path="$worktree_root/$candidate"

  if [ ! -e "$output_path" ] \
    && [ ! -L "$output_path" ] \
    && ! git -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch"; then
    break
  fi

  attempt=$((attempt + 1))
  suffix="-$attempt"
  prefix_limit=$((64 - ${#suffix}))
  candidate="$(printf '%s' "$base_slug" | cut -c "1-$prefix_limit" | sed -E 's/-+$//')$suffix"
done

if [ "$attempt" -gt 100 ]; then
  printf 'WorktreeCreate: no free name available for slug %s\n' "$base_slug" >&2
  exit 1
fi

if ! mkdir -p "$worktree_root"; then
  printf 'WorktreeCreate: cannot create worktree directory: %s\n' "$worktree_root" >&2
  exit 1
fi

if ! git -C "$repo_root" worktree add -b "$branch" "$output_path" HEAD >&2; then
  printf 'WorktreeCreate: git worktree add failed for %s\n' "$output_path" >&2
  exit 1
fi

printf '%s\n' "$output_path"
printed_path=1
