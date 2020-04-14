# zmodload zsh/zprof

source ~/.zshenv

autoload -Uz compinit
compinit
# enable bash complete compatibility in zsh
autoload bashcompinit
bashcompinit

# Customize to your needs...

alias k="/Library/Application\ Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli  --select-profile "
alias b=bat
alias fk="fkill"
alias m=make
alias n=npm
alias nn='nnn -d -e -H'
alias nv="~/.npm-packages/bin/n"
alias ssh="TERM=xterm-256color ssh"
alias t=tmux
alias v=nvim
alias y=yarn
alias zl='fasd_cd -d'     # cd, same functionality as j in autojump
alias sudo='sudo '       # to use sudo with alias
alias br="br --sizes -dp"
alias brup='brew update; brew upgrade; brew cask upgrade; brew cleanup; brew doctor'
alias dc='docker-compose'
alias g=git
alias ga='git add'
alias gs='git status'
alias gd='git diff'
alias gb='git branch'
alias gc='git checkout'
alias gco='git commit -m'
alias gca='git commit --amend'
alias gtr='git log --oneline --graph --decorate --all'
alias gp='git push'
alias gfm='git pull'
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
alias vimup='vim +PlugUpgrade +PlugUpdate +PlugClean! +qall > /dev/null'
alias st=speedtest-cli

# exclude="priv,.config,.git,node_modules,vendor,build,package-lock.json,yarn.lock,mix.lock,dist"
# alias rg='rg --hidden -g "!{'$exclude'}/*"'

# source autosuggestions
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

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
source ~/.custom_fzf.zsh

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

# asdf
. /usr/local/opt/asdf/asdf.sh
. /usr/local/opt/asdf/etc/bash_completion.d/asdf.bash

# zprof

source /Users/bharat/Library/Preferences/org.dystroy.broot/launcher/bash/br
asdf current java 2>&1 > /dev/null

if [[ "$?" -eq 0 ]]
then
    export JAVA_HOME=$(asdf where java)
fi

export NNN_PLUG='o:fzopen;d:diffs;g:_git diff;l:_git log;v:imgviu;t:treeview'
export NNN_BMS='d:~/Downloads;p:~/projects;D:~/Documents'
