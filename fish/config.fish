export ALTERNATE_EDITOR="nvim"
export VISUAL="nvim"
export EDITOR="nvim"
export TERM="alacritty"
export FISH_CONFIG="$HOME/.config/fish/config.fish"
set TERMINFO ~/.terminfo/

export GNUPGHOME="$HOME/.asdf/keyrings/nodejs" && mkdir -p "$GNUPGHOME" && chmod 0700 "$GNUPGHOME"
export GEM_HOME="$HOME/.gem"

# using ruby from brew
# setp yarn prefix first with this `yarn config set prefix "~/.yarn/"`
export PATH="$HOME/opt/miniconda3/bin:/usr/local/opt/ruby/bin:$HOME/.gem/bin:$HOME/.asdf/shims:/usr/local/opt/asdf/shims:/usr/local/opt/asdf/bin:$HOME/google-cloud-sdk/bin:$HOME/.yarn/bin:$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

source ~/.env

export FZF_DEFAULT_COMMAND='rg --files --hidden --follow -S'
export FZF_CTRL_R_OPTS='--sort --exact'
export FZF_TMUX=1
export FZF_DEFAULT_OPTS='--bind=ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all --color=fg:#d6deeb,bg:#011627,hl:#addb67 --color=fg+:#82aaff,bg+:#1d3c69,hl+:#82aaff --color=info:#7fdbca,gutter:#011627,prompt:#c792ea,pointer:#c792ea --color=marker:#82aaff,spinner:#c792ea,header:#7fdbca'

# defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# defaults write NSGlobalDomain KeyRepeat -float 1.5
# defaults write NSGlobalDomain InitialKeyRepeat -int 23

set $fish_term24bit to "1"
set fish_color_command blue

alias br="broot --sizes -dp"
alias brup='brew update; brew upgrade; brew upgrade --cask; brew cleanup; brew doctor'
alias cat=bat
alias dc='docker-compose'
alias dcu='docker-compose up'
alias dcd='docker-compose down'
alias fg='fg 2>/dev/null'
alias fr='source $FISH_CONFIG'
alias fk="fkill"
alias g=git
alias ga='git add'
alias gb='git branch'
alias gc='git checkout'
alias gca='git commit --amend'
alias gco='git commit -m'
alias gd='git diff'
alias gds='git diff --staged'
alias gfm='git pull'
alias gmt="git mergetool"
alias gp='git push'
alias gs='git status'
alias gtr='git log --oneline --graph --decorate --all'
alias k="/Library/Application\ Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli  --select-profile "
alias lg=lazygit
alias m=make
alias mi='make install'
alias mu='make update'
alias n=npm
alias nb=newsboat
alias ni='npm install'
alias nn='nnn -d -e -H'
alias nq=notion
alias nr='npm run'
alias nt='npm test'
alias nv="~/.npm-packages/bin/n"
alias python=~/opt/miniconda3/bin/python
alias pip=~/opt/miniconda3/bin/pip
alias p=~/opt/miniconda3/bin/python
alias rf=trash
alias sar="brew services restart skhd"
# alias ssh="bash ~/start_ssh.sh"
alias st=speedtest-cli
alias sudo='sudo '       # to use sudo with alias
alias t=tmux
alias ta='tmux attach || tmux new'
alias tg=tig
alias top=btm
alias v=nvim
alias vim=nvim
alias vimdiff='nvim -d'
alias vimup='vim +PlugUpgrade +PlugUpdate +PlugClean! +qall > /dev/null'
alias y=yarn
alias ya='yarn add'
alias yar='brew services restart yabai'
alias yas='brew services stop yabai'
alias yast='brew services start yabai'
alias yr='yarn run'
alias ys='yarn start'
alias yt='yarn test'

# Changing "ls" to "exa"
alias ls='exa -a --color=always --group-directories-first'  # all files and dirs
alias ll='exa -al --color=always --group-directories-first'  # long format
alias lt='exa -aT --color=always --group-directories-first' # tree listing
alias l.='exa -a | egrep "^\."'
alias ..='cd ..'
alias ...='cd ../../'
alias .3='cd ../../../'
alias .4='cd ../../../'
alias .5='cd ../../../../'
alias .6='cd ../../../../../'

# asdf erlang fails without this in fish
set CFLAGS "-O2 -g" $CFLAGS

# asdf current java 2>&1 > /dev/null

# if test $status -eq 0
#   export JAVA_HOME=(asdf where java)
# end

fish_vi_key_bindings
set __fish_git_prompt_show_informative_status
set __fish_git_prompt_showcolorhints 'yes'
set __fish_git_prompt_showupstream 'informative'
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_char_cleanstate '✔'
set __fish_git_prompt_char_dirtystate '◆'
set __fish_git_prompt_char_upstream_ahead '↑'
set __fish_git_prompt_char_upstream_behind '↓'
set __fish_git_prompt_char_upstream_diverged '<>'
set __fish_git_prompt_color_upstream cyan
set fish_color_cwd blue
set __fish_git_prompt_color_branch magenta

function fish_mode_prompt --description 'Displays the current mode'
    # Do nothing if not in vi mode
    if test "$fish_key_bindings" = "fish_vi_key_bindings"
        switch $fish_bind_mode
            case default
                set_color --bold blue
                echo ▲
            case insert
                set_color --bold green
                echo ▲
            case replace-one
                set_color --bold yellow
                echo ▲
            case visual
                set_color --bold brmagenta
                echo ▲
        end
        set_color normal
        printf " "
    end
end

function fish_prompt --description 'Write out the prompt'
    set -l prompt ' ~>> '

    set -l prompt_color blue
    if test $status -ne 0
        set prompt_color red
    end

    set -l pwd (prompt_pwd)
    if test $pwd = '~'
        set pwd ''
        # remove extra space from at the beginning of prompt
        set prompt '~>> '
    end

    set -l vcs (fish_vcs_prompt)

    echo -n -s (set_color $fish_color_cwd) $pwd $vcs (set_color $prompt_color) $prompt
end

function fzf_history_search
    history merge
    history -z | fzf --read0 --print0 --tiebreak=index | read -lz result
    and commandline -- $result
    commandline -f repaint
end

function fish_user_key_bindings
    bind -M insert -m default \cr fzf_history_search
    bind -M insert -m default \cf forward-char
end

set fish_greeting

function f --description 'Fuzzy find file and open in vim'
    set files (echo (eval "$FZF_DEFAULT_COMMAND | fzf --multi --exit-0 --preview 'bat --style=plain --color=always --line-range :100 {}'"))
    if test -n $files
      v (echo $files | string split ' ')
    end
end

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


