function fish_user_key_bindings
    fzf_key_bindings
    fish_default_key_bindings
    bind \cf 'fg 2>/dev/null; commandline -f repaint'
end
