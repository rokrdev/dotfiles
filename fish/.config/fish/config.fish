set --global fish_key_bindings fish_helix_key_bindings

test -f ~/.custom.fish && source ~/.custom.fish
test -f ~/.env && source ~/.env

set $fish_term24bit to 1
# set fish_color_command blue
set -U fish_greeting

# asdf erlang fails without this in fish
set CFLAGS "-O2 -g" $CFLAGS

if test (uname) = Darwin
    # One-time macOS setting; only touch it when it isn't already as desired.
    # Avoids running `defaults write -g` on every shell/pane spawn — that is a
    # no-op when already correct, but prints "Could not write domain Apple
    # Global Domain" when the shell lacks defaults authorization (e.g. herdr
    # panes launched from an agent/SSH context). 2>/dev/null also silences any
    # residual denial without affecting normal interactive terminals.
    set -l k "ApplePressAndHoldEnabled"
    if not defaults read -g $k >/dev/null 2>&1
        defaults write -g $k -bool false 2>/dev/null
    end
    # defaults write -g InitialKeyRepeat -int 15
    # defaults write -g KeyRepeat -int 2
end
