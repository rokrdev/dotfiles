export ALTERNATE_EDITOR="nvim"
export VISUAL="nvim"
export EDITOR="$VISUAL"

export PATH="/usr/local/anaconda3/bin:$PATH"
export PATH="$HOME/.jenv/bin:$PATH"
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
alias python3=python
alias vimup='vim +PlugUpgrade +PlugUpdate +PlugClean! +qall > /dev/null'
alias st=speedtest-cli
alias lg=lazygit

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

function kp --description 'Fuzzy search and kill process'
    ### PROCESS
    # mnemonic: [K]ill [P]rocess
    # show output of "ps -ef", use [tab] to select one or multiple entries
    # press [enter] to kill selected processes and go back to the process list.
    # or press [escape] to go back to the process list. Press [escape] twice to exit completely.

    set pid (ps aux | sed 1d | eval "fzf $FZF_DEFAULT_OPTS -m --header='[kill:process]'" | awk '{print $2}')

    if test "x$pid" != "x"
        echo $pid | xargs kill -9
        kp
    end
end

function f --description 'Fuzzy find file and open in vim'
    set files (echo (eval "$FZF_DEFAULT_COMMAND | fzf --multi --exit-0"))
    if test -n $files
      v (echo $files | string split ' ')
    end
end

# for shell error
set -x SHELL /bin/zsh

bind \ch 'fg'

# asdf
source /usr/local/opt/asdf/asdf.fish

# fortune -s 10% art 10% law 10% science 10% ascii-art 10% wisdom 10% startrek 10% work 10% humorists 10% fortunes 10% computers
