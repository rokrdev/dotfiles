export ALTERNATE_EDITOR="nvim"
export VISUAL="nvim"
export EDITOR="nvim"
export TERM="alacritty"
export FISH_CONFIG="$HOME/.config/fish/config.fish"
set TERMINFO ~/.terminfo/
export LANG="en_US.UTF-8"

source /usr/local/opt/asdf/asdf.fish

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

abbr -a -g br "broot --sizes -dp"
abbr -a -g brup 'brew update && brew upgrade && brew upgrade --cask && brew cleanup && brew doctor'
abbr -a -g cat bat
abbr -a -g dc 'docker-compose'
abbr -a -g dcu 'docker-compose up'
abbr -a -g dcd 'docker-compose down'
abbr -a -g dc 'docker-compose'
abbr -a -g fm vifm
abbr -a -g g git
abbr -a -g ga 'git add'
abbr -a -g gb 'git branch'
abbr -a -g gc 'git checkout'
abbr -a -g gca 'git commit --amend'
abbr -a -g gco 'git commit -m'
abbr -a -g gd 'git diff'
abbr -a -g gds 'git diff --staged'
abbr -a -g gfm 'git pull'
abbr -a -g gfmc 'git pull origin (git branch --show-current)'
abbr -a -g gmt "git mergetool"
abbr -a -g gp 'git push'
abbr -a -g gs 'git status'
abbr -a -g gtr 'git log --oneline --graph --decorate --all'
abbr -a -g h 'z dot'
abbr -a -g k "/Library/Application\ Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli  --select-profile "
abbr -a -g mk 'mkdir -p'
abbr -a -g n npm
abbr -a -g nb newsboat
abbr -a -g ni 'npm install'
abbr -a -g nn 'nnn -d -e -H'
abbr -a -g nv "~/.npm-packages/bin/n"
abbr -a -g rf trash
abbr -a -g sar "brew services restart skhd"
abbr -a -g sd "pushd ~/.dotfiles && rsync -r --exclude-from \"exclude_from_sync.txt\" . ~ && popd"
abbr -a -g sf 'source $FISH_CONFIG'
abbr -a -g st speedtest-cli
abbr -a -g t tmux
abbr -a -g ta 'tmux attach || tmux new'
abbr -a -g tg tig
abbr -a -g top btm
abbr -a -g upa 'brew update && brew upgrade && brew upgrade --cask && brew cleanup && brew doctor; nvim +PackerSync +PackerCompile +qall > /dev/null'
abbr -a -g v nvim
abbr -a -g vim nvim
abbr -a -g vimdiff 'nvim -d'
abbr -a -g vimup 'nvim +PackerSync +PackerCompile +qall > /dev/null'
abbr -a -g vst 'vim-startuptime -vimpath nvim'
abbr -a -g y yarn
abbr -a -g ya 'yarn add'
abbr -a -g yar 'brew services restart yabai'
abbr -a -g yas 'brew services stop yabai'
abbr -a -g yast 'brew services start yabai'
abbr -a -g yr 'yarn run'
abbr -a -g ys 'yarn start'
abbr -a -g yt 'yarn test'

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

