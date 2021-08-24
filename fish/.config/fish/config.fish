 # TokyoNight Color Palette
set -l foreground c0caf5
set -l selection 33467C
set -l comment 565f89
set -l red f7768e
set -l orange ff9e64
set -l yellow e0af68
set -l green 9ece6a
set -l purple 9d7cd8
set -l cyan 7dcfff
set -l pink bb9af7

# Syntax Highlighting Colors
set -g fish_color_normal $foreground
set -g fish_color_command $cyan
set -g fish_color_keyword $pink
set -g fish_color_quote $yellow
set -g fish_color_redirection $foreground
set -g fish_color_end $orange
set -g fish_color_error $red
set -g fish_color_param $purple
set -g fish_color_comment $comment
set -g fish_color_selection --background=$selection
set -g fish_color_search_match --background=$selection
set -g fish_color_operator $green
set -g fish_color_escape $pink
set -g fish_color_autosuggestion $comment

# Completion Pager Colors
set -g fish_pager_color_progress $comment
set -g fish_pager_color_prefix $cyan
set -g fish_pager_color_completion $foreground
set -g fish_pager_color_description $comment

export ALTERNATE_EDITOR="nvim"
export VISUAL="nvr -cc split --remote-wait"
export EDITOR="nvr -cc split --remote-wait"
export TERM="alacritty"
export FISH_CONFIG="$HOME/.config/fish/config.fish"
set TERMINFO ~/.terminfo/
export LANG="en_US.UTF-8"

ssh-add -A &> /dev/null

source ~/.asdf/asdf.fish

zoxide init fish | source

export GNUPGHOME="$HOME/.asdf/keyrings/nodejs" && mkdir -p "$GNUPGHOME" && chmod 0700 "$GNUPGHOME"

# setp yarn prefix first with this `yarn config set prefix "~/.yarn/"`
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$HOME/.asdf/shims:$HOME/.asdf/bin:$HOME/google-cloud-sdk/bin:$HOME/.yarn/bin:$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

source ~/.env

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

alias br="broot --sizes -dp"
alias brup='brew update && brew upgrade && brew upgrade --cask && brew cleanup && brew doctor'
alias cat=bat
alias dc='docker compose'
alias dcu='docker compose up'
alias dcd='docker compose down'
alias dcs='docker compose start'
alias dcx='docker compose stop'
alias fm=vifm
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
alias gs='git status'
alias gtr='git log --oneline --graph --decorate --all'
alias h='cd ~/.dotfiles'
alias k="/Library/Application\ Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli  --select-profile "
alias mk='mkdir -p'
alias n=npm
alias nb=newsboat
alias ni='npm install'
alias nn='nnn -d -e -H'
alias nv="~/.npm-packages/bin/n"
alias rf=trash
alias sar="brew services restart skhd"
alias sf='source $FISH_CONFIG'
alias st=speedtest-cli
alias t=tmux
alias ta='tmux attach || tmux new'
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
alias yar='brew services restart yabai'
alias yas='brew services stop yabai'
alias yast='brew services start yabai'
alias yr='yarn run'
alias ys='yarn start'
alias yt='yarn test'
alias zz=zi

# Changing "ls" to "exa"
alias ls='exa --color=always --group-directories-first'  # all files and dirs
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

