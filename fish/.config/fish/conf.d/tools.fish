# Docker initialization
if test -e ~/.docker/init-fish.sh
    source $HOME/.docker/init-fish.sh || true # Added by Docker Desktop
end

# Set color scheme
setscheme tokyonight_night

fish_add_path $HOME/.fzf/bin $HOME/.cargo/bin /snap/bin

# FZF initialization
fzf --fish | source

# Zoxide initialization
zoxide init fish | source

# Direnv
direnv hook fish | source
