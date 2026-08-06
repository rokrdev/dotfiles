export BAT_THEME="tokyonight"

export ALTERNATE_EDITOR="hx"
export EDITOR="hx"
export VISUAL="hx"
export FISH_CONFIG="$HOME/.config/fish/config.fish"
export LANG="en_US.UTF-8"
export COLORTERM=truecolor
ssh-add -l &>/dev/null || ssh-add -A &>/dev/null

export GOPATH="$HOME/.go"
export GOBIN="$GOPATH/bin"
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow -S'
export FZF_CTRL_R_OPTS='--sort --exact'
export FZF_DEFAULT_OPTS="\
--layout=reverse \
--height=75% \
--bind=ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all \
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"
export _ZO_FZF_OPTS=$FZF_DEFAULT_OPTS

# setp yarn prefix first with this `yarn config set prefix "~/.yarn/"`
export PATH="$HOME/.cargo/bin:$HOME/.docker/bin:$HOME/bin:$HOME/.bun/bin:$GOPATH/bin:$ANDROID_SDK_ROOT:$HOME/.yarn/bin:$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

if test (uname) = Linux
    set -g PATH "/home/linuxbrew/.linuxbrew/bin" $PATH
end

export XDG_CONFIG_HOME="$HOME/.config"
