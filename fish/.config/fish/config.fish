export BAT_THEME="tokyonight"

export ALTERNATE_EDITOR="nvim"
export VISUAL="nvr -cc split --remote-wait"
export EDITOR="nvr -cc split --remote-wait"
export TERM="xterm-kitty"
export KITTY_CACHE_DIRECTORY="/tmp/"
export FISH_CONFIG="$HOME/.config/fish/config.fish"
export TERMINFO="~/.terminfo"
export LANG="en_US.UTF-8"
export NNN_OPTS="da"
export NNN_FIFO="/tmp/nnn.fifo"
export NNN_PLUG='t:preview-tui;'
ssh-add -A &> /dev/null

export GNUPGHOME="$HOME/.asdf/keyrings/nodejs" && mkdir -p "$GNUPGHOME" && chmod 0700 "$GNUPGHOME"
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME/sdk"
export GOPATH="$HOME/go"

# setp yarn prefix first with this `yarn config set prefix "~/.yarn/"`
export PATH="$GOPATH/bin:$ANDROID_SDK_ROOT:/usr/local/opt/gnu-sed/libexec/gnubin:$HOME/.asdf/shims:$HOME/.asdf/bin:$HOME/google-cloud-sdk/bin:$HOME/.yarn/bin:$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

source ~/.env

source ~/.asdf/asdf.fish
zoxide init fish | source

export FZF_DEFAULT_COMMAND='rg --files --hidden --follow -S'
export FZF_CTRL_R_OPTS='--sort --exact'
export FZF_TMUX=1
export FZF_DEFAULT_OPTS='--bind=ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all'

export LDFLAGS="-L/usr/local/opt/zlib/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include"

defaults write -g ApplePressAndHoldEnabled -bool false
# defaults write -g InitialKeyRepeat -int 15
# defaults write -g KeyRepeat -int 2

set $fish_term24bit to "1"
set fish_color_command blue
set -U fish_greeting

alias brup='brew update && brew upgrade && brew upgrade --cask && brew cleanup && brew doctor'
alias cat=bat
alias bcb='bat cache --build'
alias dc='docker compose'
alias dcu='docker compose up'
alias dcd='docker compose down'
alias dcs='docker compose start'
alias dcx='docker compose stop'
alias g=git
alias ga='git add'
alias gb='git branch'
alias gc='git checkout'
alias gca='git commit --amend'
alias gco='git commit -m'
alias gd='git diff'
alias gds='git diff --staged'
alias gfm='git pull'
alias gfmc='git pull origin (git branch --show-current)'
alias gmt="git mergetool"
alias gp='git push'
alias groot='cd $(git rev-parse --show-cdup)'
alias gs='git status'
alias gtr='git log --oneline --graph --decorate --all'
alias gx='git clean -fxd'
alias h='cd ~/.dotfiles'
alias icat="kitty +kitten icat"
# alias k="/Library/Application\ Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli  --select-profile "
alias k=kubectl
alias kgp="kubectl get pods"
alias kl="kubectl logs"
alias mk='mkdir -p'
alias n=npm
alias ni='npm install'
alias nn='nnn -d -e -H'
alias rf=trash
alias sf='source $FISH_CONFIG'
alias st=speedtest-cli
alias t=zellij
alias ta='zellij attach || zellij --layout custom'
alias tg=tig
alias top=btm
alias upa='brew update && brew upgrade && brew upgrade --cask && brew cleanup && brew doctor; nvim +PackerSync +PackerCompile +qall > /dev/null'
alias v=nvim
alias vim=nvim
alias vimdiff='nvim -d'
alias vimup='nvim +PackerSync +PackerCompile +qall > /dev/null'
alias vst='vim-startuptime -vimpath nvim'
alias y=yarn
alias ya='yarn add'
alias yr='yarn run'
alias ys='yarn start'
alias yt='yarn test'
alias zz=zi
alias zellij="zellij --layout custom"

# Changing "ls" to "exa"
# alias ls='exa --color=always --group-directories-first'  # all files and dirs
alias la='exa -a --color=always --group-directories-first'  # all files and dirs
alias ll='exa -lah --color=always --group-directories-first'  # long format
alias lt='exa -aT --git-ignore --color=always --group-directories-first' # tree listing
alias l.='exa -a | egrep "^\."'
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias ......='cd ../../../../../'
alias .......='cd ../../../../../../'
alias please=sudo

alias python3=python
alias p=python

# asdf erlang fails without this in fish
set CFLAGS "-O2 -g" $CFLAGS

