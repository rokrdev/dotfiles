function fish_user_key_bindings
    fish_default_key_bindings
    bind \cz 'fg 2>/dev/null; commandline -f repaint'
end
