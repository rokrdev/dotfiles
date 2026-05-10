#!/usr/bin/env bash
# Human-in-the-loop reproduction loop.
# Copy this file, edit the steps below, and run it.
# The agent runs the script; the user follows prompts in their terminal.
#
# Usage:
#   bash hitl-loop.template.sh
#
# Two helpers:
#   step "<instruction>"          → show instruction, wait for Enter
#   capture VAR "<question>"      → show question, read response into VAR
#
# At the end, captured values are printed as KEY=VALUE for the agent to parse.

set -euo pipefail

ERRORED=""
ERROR_MSG=""

step() {
  printf '\n>>> %s\n' "$1" >&2
  read -r -p "    [Enter when done] " _ || true
}

capture() {
  local var="$1" question="$2" answer
  printf '\n>>> %s\n' "$question" >&2
  if ! read -r -p "    > " answer; then
    printf '[hitl-loop] ERROR: stdin is not interactive — cannot capture user input\n' >&2
    exit 1
  fi
  printf -v "$var" '%s' "$answer"
}

# --- edit below ---------------------------------------------------------

step "Open the app at http://localhost:3000 and sign in."

capture ERRORED "Click the 'Export' button. Did it throw an error? (y/n)"

capture ERROR_MSG "Paste the error message (or 'none'):"

# --- edit above ---------------------------------------------------------

printf '\n--- Captured ---\n' >&2
printf 'ERRORED=%s\n' "$ERRORED"
printf 'ERROR_MSG=%s\n' "$ERROR_MSG"
