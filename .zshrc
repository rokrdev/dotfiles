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
alias ed="emacs --daemon &"
alias e="emacs -nw"
# alias e="emacsclient -t -a ''"
alias eg=startEmacs
alias fk="fkill"
alias m=make
alias nn=nnn
alias n=npm
alias t=tmux
alias v=nvim
alias y=yarn
alias zl='fasd_cd -d'     # cd, same functionality as j in autojump
alias rg="rg --hidden -g '!.git/*'"
alias sudo='sudo '       # to use sudo with alias
alias brup='brew update; brew upgrade; brew cleanup; brew doctor'
alias dc='docker-compose'
alias gtr='git log --oneline --graph --decorate --all'
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

jenv_set_java_home

unalias f
f() {
    local files
    local olIFS=IFS  # save old IFS to reset later
    IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
    IFS=$olIFS   # reset IFS else git info breaks in terminal prompt
    [[ -n "$files" ]] && emacs -nw "${files[@]}"
}

ffLogic() {
    local files
    local olIFS=IFS  # save old IFS to reset later
    if [ ! "$#" -ge 1 ]; then echo "Need a string to search for!"; return 1; fi
    IFS=$'\n' files=($(rg --files-with-matches --no-messages "$1" | fzf --multi --select-1 --exit-0 --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}"))
    IFS=$olIFS   #reset IFS else git info breaks in terminal prompt
    if [ "$2" = 'open' ]; then
        [[ -n "$files" ]] && emacs -nw "${files[@]}"
    else
        [[ -n "$files" ]] && echo "${files[@]}"
    fi
}

ffo() {
    ffLogic "$1" "open"
}

ff() {
    ffLogic "$1" "search"
}

function z() {
    [ $# -gt 0 ] && fasd_cd -d "$*" && return
    local dir
    dir="$(fasd -Rdl "$1" | fzf -1 -0 --no-sort +m)" && cd "${dir}" || return 1
}
alias z=z

kp() {
    ### PROCESS
    # mnemonic: [K]ill [P]rocess
    # show output of "ps -ef", use [tab] to select one or multiple entries
    # press [enter] to kill selected processes and go back to the process list.
    # or press [escape] to go back to the process list. Press [escape] twice to exit completely.

    local pid=$(ps aux | sed 1d | eval "fzf ${FZF_DEFAULT_OPTS} -m --header='[kill:process]'" | awk '{print $2}')

    if [ "x$pid" != "x" ]
    then
        echo $pid | xargs kill -${1:-9}
        kp
    fi
}
