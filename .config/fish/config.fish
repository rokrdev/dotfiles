export ALTERNATE_EDITOR="nvim"
export VISUAL="nvr -cc split --remote-wait"
export EDITOR="nvr -cc split --remote-wait"
export TERM="alacritty"
export FISH_CONFIG="$HOME/.config/fish/config.fish"
set TERMINFO ~/.terminfo/
export LANG="en_US.UTF-8"

ssh-add &> /dev/null

source /usr/local/opt/asdf/asdf.fish

zoxide init fish | source

export GNUPGHOME="$HOME/.asdf/keyrings/nodejs" && mkdir -p "$GNUPGHOME" && chmod 0700 "$GNUPGHOME"

# setp yarn prefix first with this `yarn config set prefix "~/.yarn/"`
export PATH="$HOME/.asdf/shims:/usr/local/opt/asdf/shims:/usr/local/opt/asdf/bin:$HOME/google-cloud-sdk/bin:$HOME/.yarn/bin:$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

source ~/.env

export FZF_DEFAULT_COMMAND='rg --files --hidden --follow -S'
export FZF_CTRL_R_OPTS='--sort --exact'
export FZF_TMUX=1
export FZF_DEFAULT_OPTS='--bind=ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all --color=fg:#d6deeb,bg:#011627,hl:#addb67 --color=fg+:#82aaff,bg+:#00111F,hl+:#82aaff --color=info:#7fdbca,gutter:#011627,prompt:#c792ea,pointer:#c792ea --color=marker:#82aaff,spinner:#c792ea,header:#7fdbca'

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
alias dc='docker-compose'
alias dcu='docker-compose up'
alias dcd='docker-compose down'
alias dc='docker-compose'
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
alias h='z dot'
alias k="/Library/Application\ Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli  --select-profile "
alias mk='mkdir -p'
alias n=npm
alias nb=newsboat
alias ni='npm install'
alias nn='nnn -d -e -H'
alias nv="~/.npm-packages/bin/n"
alias rf=trash
alias sar="brew services restart skhd"
alias sd="pushd ~/.dotfiles && rsync -r --exclude-from \"exclude_from_sync.txt\" . ~ && popd"
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
alias .....='cd ../../../'
alias ......='cd ../../../../'
alias .......='cd ../../../../../'
alias please=sudo

alias python3=python
alias p=python

# asdf erlang fails without this in fish
set CFLAGS "-O2 -g" $CFLAGS

