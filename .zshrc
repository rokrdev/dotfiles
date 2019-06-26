# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

source ~/.zshenv

eval "$(fasd --init auto)"

# Customize to your needs...
function startEmacs {
   emacs "$1" &
}

alias k="/Library/Application\ Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli  --select-profile "
alias b=bat
alias br=brew
alias ed="emacs --daemon &"
alias e="emacs -nw"
# alias e="emacsclient -t -a ''"
alias eg=startEmacs
alias fk="fkill"
alias g=git
alias m=make
alias nn=nnn
alias t=tmux
alias v=nvim
alias y=yarn
alias z='fasd_cd -d'     # cd, same functionality as j in autojump
alias sudo='sudo '       # to use sudo with alias
alias brup='brew update; brew upgrade; brew cleanup; brew doctor'
alias dc='docker-compose'
alias ga='git add'
alias gc='git checkout'
alias gcb='git checkout -b'
alias gco='git commit -m'
alias gcoa='git commit --amend'
alias gd='git diff'
alias gdc='git diff --cached'
alias gpl='git pull'
alias gps='git push'
alias gs='git status'
alias gst='git stash'
alias gstp='git stash pop'
alias gsta='git stash apply'
alias gt='git log --oneline --graph --decorate --all'
alias gl='git log'
alias mi='make install'
alias mu='make update'
alias ni='npm install'
alias nr='npm run'
alias nt='npm test'
alias rf=rimraf
alias ta='tmux attach || tmux new'
alias vim=nvim
alias yr='yarn run'
alias ys='yarn start'
alias yt='yarn test'
alias ya='yarn add'
alias zz='fasd_cd -d -i' # cd with interactive selection

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

eval "$(rbenv init -)"

# source autosuggestions
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

prompt pure

defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# defaults write NSGlobalDomain KeyRepeat -float 1.5
# defaults write NSGlobalDomain InitialKeyRepeat -int 23

SPACESHIP_DIR_TRUNC_REPO="false"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '~/google-cloud-sdk/path.zsh.inc' ]; then . '~/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '~/google-cloud-sdk/completion.zsh.inc' ]; then . '~/google-cloud-sdk/completion.zsh.inc'; fi

eval "$(jenv init -)"
alias jenv_set_java_home='export JAVA_HOME="$HOME/.jenv/versions/`jenv version-name`"'

source ~/projects/shellject/bash/shellject_wrapper.sh
source ~/.rbenv/versions/2.4.1/lib/ruby/gems/2.4.0/gems/shellject-1.0.1/bash/shellject_wrapper.sh
