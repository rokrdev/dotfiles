# Source Prezto.
# zmodload zsh/zprof

if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

source ~/.zshenv

# Customize to your needs...
function startEmacs {
   emacs  "$1" &
}

function notion {
  cd $NOTION
  ssh git@github.com
  if [ $? -eq 0 ]; then
    git pull
  fi
  emacs -nw $NOTION/clip.org
}

alias k="/Library/Application\ Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli  --select-profile "
alias b=bat
alias ed="emacs --daemon &"
alias e="emacs -nw -nl -nsl --no-site-file"
# alias e="emacsclient -t -a ''"
alias eg=startEmacs
alias fk="fkill"
alias m=make
alias n=npm
alias nn=nnn
alias nv="~/.npm-packages/bin/n"
alias ssh="TERM=xterm-256color ssh"
alias t=tmux
alias v=nvim
alias y=yarn
alias zl='fasd_cd -d'     # cd, same functionality as j in autojump
alias sudo='sudo '       # to use sudo with alias
alias brup='brew update; brew upgrade; brew cask upgrade; brew cleanup; brew doctor'
alias dc='docker-compose'
alias gtr='git log --oneline --graph --decorate --all'
alias mi='make install'
alias mu='make update'
alias ni='npm install'
alias nq=notion
alias nr='npm run'
alias nt='npm test'
alias p=python
alias rf=rimraf
alias ta='tmux attach || tmux new'
alias vim=nvim
alias yr='yarn run'
alias ys='yarn start'
alias yt='yarn test'
alias ya='yarn add'
alias zz='fasd_cd -d -i' # cd with interactive selection
alias python3=python

# exclude="priv,.config,.git,node_modules,vendor,build,package-lock.json,yarn.lock,mix.lock,dist"
# alias rg='rg --hidden -g "!{'$exclude'}/*"'

# source autosuggestions
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

prompt pure

# The next line updates PATH for the Google Cloud SDK.
if [ -f '~/google-cloud-sdk/path.zsh.inc' ]; then . '~/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '~/google-cloud-sdk/completion.zsh.inc' ]; then . '~/google-cloud-sdk/completion.zsh.inc'; fi

setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_BEEP

source ~/.fzf.zsh

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/usr/local/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/usr/local/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/usr/local/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/usr/local/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# zprof
