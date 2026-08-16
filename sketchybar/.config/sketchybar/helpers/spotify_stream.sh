#!/usr/bin/env bash
# helpers/spotify_stream.sh
# Bridge media-control (event-driven now-playing via privileged /usr/bin/perl)
# into a sketchybar event. Works on macOS 15.4+/26 where sketchybar's own
# media_change event is deprecated/blocked.
#
# media-control stream emits JSON *diffs*: {payload:{...changed fields}}.
# This script accumulates state (playing/app/title/artist), seeding from the
# first full snapshot, and only overwrites fields present in each diff. Each
# line then fires:
#   sketchybar --trigger spotify_change playing=.. app=.. title=.. artist=..
#
# NOTE: use jq's `has()` to detect field presence. A bare `.X // empty` drops
# literal `false` values (playing=false), which would leave the pill stuck on.
set -u

PLAYING=false
APP=""
TITLE=""
ARTIST=""

media-control stream 2>/dev/null | while IFS= read -r line; do
  # Presence-aware extraction: only overwrite accumulated state when the field
  # is actually present in this diff, preserving literal false values.
  if printf '%s' "$line" | jq -e '.payload | has("playing")' >/dev/null 2>&1; then
    PLAYING=$(printf '%s' "$line" | jq -r '.payload.playing' 2>/dev/null)
  fi
  if printf '%s' "$line" | jq -e '.payload | has("bundleIdentifier")' >/dev/null 2>&1; then
    APP=$(printf '%s' "$line" | jq -r '.payload.bundleIdentifier' 2>/dev/null)
  fi
  if printf '%s' "$line" | jq -e '.payload | has("title")' >/dev/null 2>&1; then
    TITLE=$(printf '%s' "$line" | jq -r '.payload.title' 2>/dev/null)
  fi
  if printf '%s' "$line" | jq -e '.payload | has("artist")' >/dev/null 2>&1; then
    ARTIST=$(printf '%s' "$line" | jq -r '.payload.artist' 2>/dev/null)
  fi

  /opt/homebrew/bin/sketchybar --trigger spotify_change \
    playing="$PLAYING" app="$APP" title="$TITLE" artist="$ARTIST"
done
