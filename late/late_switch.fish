#!/usr/bin/env fish

set CONFIG_PATH "$HOME/Library/Application Support/late/config.json"
set PATCH_DIR "$HOME/.dotfiles/late"

if [ (count $argv) -ne 1 ]
    echo "Error: expected one argument (deep or lite)"
    exit 1
end

if [ "$argv[1]" != "deep" -a "$argv[1]" != "lite" ]
    echo "Error: argument must be 'deep' or 'lite'"
    exit 1
end

jq -s '.[0] * .[1]' "$CONFIG_PATH" "$PATCH_DIR/$argv[1].json" > "$CONFIG_PATH.tmp" && mv "$CONFIG_PATH.tmp" "$CONFIG_PATH"

late
