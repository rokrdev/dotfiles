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
export FZF_DEFAULT_OPTS='--popup 80% --bind=ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all'
export _ZO_FZF_OPTS='--popup 80%'

# setp yarn prefix first with this `yarn config set prefix "~/.yarn/"`
export PATH="$HOME/.cargo/bin:$HOME/.docker/bin:$HOME/bin:$HOME/.bun/bin:$GOPATH/bin:$ANDROID_SDK_ROOT:$HOME/.yarn/bin:$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

if test (uname) = "Linux"
    set -g PATH "/home/linuxbrew/.linuxbrew/bin" $PATH
end

export XDG_CONFIG_HOME="$HOME/.config"
