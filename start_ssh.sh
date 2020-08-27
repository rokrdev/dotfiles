#!/bin/sh

# this script runs ssh with a different TERM
# this is required as my term is custom term
# sometimes backspace stops working on ssh'd system with this custom term

TERM=xterm-256color ssh "$@"
