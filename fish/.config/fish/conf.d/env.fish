export BAT_THEME="tokyonight"

export ALTERNATE_EDITOR="hx"
export EDITOR="hx"
export VISUAL="hx"
export FISH_CONFIG="$HOME/.config/fish/config.fish"
export LANG="en_US.UTF-8"
export COLORTERM=truecolor
ssh-add -l &>/dev/null || ssh-add -A &>/dev/null

set -gx GNUPGHOME "$HOME/.asdf/keyrings/nodejs"
if not test -d "$GNUPGHOME"
    mkdir -p "$GNUPGHOME"
end
chmod 0700 "$GNUPGHOME"

export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME/sdk"
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow -S'
export FZF_CTRL_R_OPTS='--sort --exact'
export FZF_DEFAULT_OPTS='--popup 80% --bind=ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all'
export _ZO_FZF_OPTS='--popup 80%'

# setp yarn prefix first with this `yarn config set prefix "~/.yarn/"`
export PATH="$HOME/.docker/bin:$HOME/bin:$HOME/.bun/bin:$GOPATH/bin:$ANDROID_SDK_ROOT:/usr/local/opt/gnu-sed/libexec/gnubin:$HOME/google-cloud-sdk/bin:$HOME/.yarn/bin:$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

export XDG_CONFIG_HOME="$HOME/.config"

export CARGO_TARGET_DIR=~/.cargo-target

# LM Studio CLI
set -gx PATH $PATH /Users/bharat/.lmstudio/bin
