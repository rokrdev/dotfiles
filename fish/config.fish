export ALTERNATE_EDITOR="nvim"
export VISUAL="nvim"
export EDITOR="$VISUAL"

export PATH="/usr/local/anaconda3/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="/usr/local/bin:/usr/local/sbin/:$PATH"
export GNUPGHOME="$HOME/.asdf/keyrings/nodejs" && mkdir -p "$GNUPGHOME" && chmod 0700 "$GNUPGHOME"
# set yarn prefix first with this `yarn config set prefix "~/.yarn/"`
export PATH="$HOME/.yarn/bin:$PATH"

source ~/.env

export FZF_DEFAULT_COMMAND='rg --files --hidden --follow -S'
export FZF_CTRL_R_OPTS='--sort --exact'
export FZF_TMUX=1
export FZF_DEFAULT_OPTS='--no-reverse --bind=ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all --color=fg:#d6deeb,bg:#011627,hl:#addb67 --color=fg+:#82aaff,bg+:#011627,hl+:#82aaff --color=info:#7fdbca,prompt:#c792ea,pointer:#c792ea --color=marker:#82aaff,spinner:#c792ea,header:#7fdbca'

defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# defaults write NSGlobalDomain KeyRepeat -float 1.5
# defaults write NSGlobalDomain InitialKeyRepeat -int 23

set $fish_term24bit to "1"
set fish_color_command blue

alias b=bat
alias br="broot --sizes -dp"
alias brup='brew update; brew upgrade; brew cask upgrade; brew cleanup; brew doctor'
alias dc='docker-compose'
alias fg='fg 2>/dev/null'
alias fk="fkill"
alias g=git
alias ga='git add'
alias gb='git branch'
alias gc='git checkout'
alias gca='git commit --amend'
alias gco='git commit -m'
alias gd='git diff'
alias gfm='git pull'
alias gp='git push'
alias gs='git status'
alias gtr='git log --oneline --graph --decorate --all'
alias k="/Library/Application\ Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli  --select-profile "
alias lg=lazygit
alias m=make
alias mi='make install'
alias mu='make update'
alias n=npm
alias ni='npm install'
alias nn='nnn -d -e -H'
alias nq=notion
alias nr='npm run'
alias nt='npm test'
alias nv="~/.npm-packages/bin/n"
alias p=python
alias python3=python
alias rf=rimraf
alias sar="brew services restart skhd"
alias ssh="TERM=xterm-256color ssh"
alias st=speedtest-cli
alias sudo='sudo '       # to use sudo with alias
alias t=tmux
alias ta='tmux attach || tmux new'
alias v=nvim
alias vim=nvim
alias vimup='vim +PlugUpgrade +PlugUpdate +PlugClean! +qall > /dev/null'
alias y=yarn
alias ya='yarn add'
alias yar='brew services restart yabai'
alias yas='brew services stop yabai'
alias yast='brew services start yabai'
alias yr='yarn run'
alias ys='yarn start'
alias yt='yarn test'

# The next line updates PATH for the Google Cloud SDK.
if [ -f '~/google-cloud-sdk/path.zsh.inc' ]; then . '~/google-cloud-sdk/path.zsh.inc'; end

# The next line enables shell command completion for gcloud.
if [ -f '~/google-cloud-sdk/completion.zsh.inc' ]; then . '~/google-cloud-sdk/completion.zsh.inc'; end

# asdf erlang fails without this in fish
set CFLAGS "-O2 -g" $CFLAGS

asdf current java 2>&1 > /dev/null

if test $status -eq 0
  export JAVA_HOME=(asdf where java)
end

export NNN_PLUG='o:fzopen;d:diffs;g:_git diff;l:_git log;v:imgviu;t:treeview'
export NNN_BMS='d:~/Downloads;p:~/projects;D:~/Documents'

# for shell error
set -x SHELL /bin/zsh

# asdf
source /usr/local/opt/asdf/asdf.fish

for f in ~/.config/fish/custom/*
  source $f
end
