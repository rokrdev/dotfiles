set --global fish_key_bindings fish_default_key_bindings

test -f ~/.env && source ~/.env

set $fish_term24bit to 1
set fish_color_command blue
set -U fish_greeting

# asdf erlang fails without this in fish
set CFLAGS "-O2 -g" $CFLAGS

if test (uname) = Darwin
    defaults write -g ApplePressAndHoldEnabled -bool false
    # defaults write -g InitialKeyRepeat -int 15
    # defaults write -g KeyRepeat -int 2
end
