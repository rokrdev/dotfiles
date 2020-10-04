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
export FZF_DEFAULT_OPTS='--bind=ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all --color=fg:#d6deeb,bg:#011627,hl:#addb67 --color=fg+:#82aaff,bg+:#00111F,hl+:#82aaff --color=info:#7fdbca,gutter:#011627,prompt:#c792ea,pointer:#c792ea --color=marker:#82aaff,spinner:#c792ea,header:#7fdbca'

# defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# defaults write NSGlobalDomain KeyRepeat -float 1.5
# defaults write NSGlobalDomain InitialKeyRepeat -int 23

set $fish_term24bit to "1"
set fish_color_command blue

abbr -a -g br "broot --sizes -dp"
abbr -a -g brup 'brew update && brew upgrade && brew upgrade --cask && brew cleanup && brew doctor'
abbr -a -g cat bat
abbr -a -g dc 'docker-compose'
abbr -a -g dcu 'docker-compose up'
abbr -a -g dcd 'docker-compose down'
abbr -a -g dc 'docker-compose'
abbr -a -g fm vifm
abbr -a -g fr 'source $FISH_CONFIG'
abbr -a -g g git
abbr -a -g ga 'git add'
abbr -a -g gb 'git branch'
abbr -a -g gc 'git checkout'
abbr -a -g gca 'git commit --amend'
abbr -a -g gco 'git commit -m'
abbr -a -g gd 'git diff'
abbr -a -g gds 'git diff --staged'
abbr -a -g gfm 'git pull'
abbr -a -g gmt "git mergetool"
abbr -a -g gp 'git push'
abbr -a -g gs 'git status'
abbr -a -g gtr 'git log --oneline --graph --decorate --all'
abbr -a -g k "/Library/Application\ Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli  --select-profile "
abbr -a -g lg lazygit
abbr -a -g m make
abbr -a -g mi 'make install'
abbr -a -g mu 'make update'
abbr -a -g n npm
abbr -a -g nb newsboat
abbr -a -g ni 'npm install'
abbr -a -g nn 'nnn -d -e -H'
abbr -a -g nq notion
abbr -a -g nr 'npm run'
abbr -a -g nt 'npm test'
abbr -a -g nv "~/.npm-packages/bin/n"
abbr -a -g python ~/opt/miniconda3/bin/python
abbr -a -g pip ~/opt/miniconda3/bin/pip
abbr -a -g p ~/opt/miniconda3/bin/python
abbr -a -g rf trash
abbr -a -g sar "brew services restart skhd"
abbr -a -g sd "pushd ~/.dotfiles && rsync -r --exclude-from \"exclude_from_sync.txt\" . ~ && popd"
# abbr ssh="bash ~/start_ssh.sh"
abbr -a -g st speedtest-cli
abbr -a -g sudo 'sudo '       # to use sudo with abbr
abbr -a -g t tmux
abbr -a -g ta 'tmux attach || tmux new'
abbr -a -g tg tig
abbr -a -g top btm
abbr -a -g upa 'brew update && brew upgrade && brew upgrade --cask && brew cleanup && brew doctor && vim +PlugUpgrade +PlugUpdate +PlugClean! +qall > /dev/null'
abbr -a -g v nvim
abbr -a -g vim nvim
abbr -a -g vimdiff 'nvim -d'
abbr -a -g vimup 'vim +PlugUpgrade +PlugUpdate +PlugClean! +qall > /dev/null'
abbr -a -g y yarn
abbr -a -g ya 'yarn add'
abbr -a -g yar 'brew services restart yabai'
abbr -a -g yas 'brew services stop yabai'
abbr -a -g yast 'brew services start yabai'
abbr -a -g yr 'yarn run'
abbr -a -g ys 'yarn start'
abbr -a -g yt 'yarn test'

# Changing "ls" to "exa"
abbr -a -g ls 'exa -a --color=always --group-directories-first'  # all files and dirs
abbr -a -g ll 'exa -al --color=always --group-directories-first'  # long format
abbr -a -g lt 'exa -aT --color=always --group-directories-first' # tree listing
abbr -a -g l. 'exa -a | egrep "^\."'
abbr -a -g .. 'cd ..'
abbr -a -g ... 'cd ../../'
abbr -a -g .3 'cd ../../../'
abbr -a -g .4 'cd ../../../'
abbr -a -g .5 'cd ../../../../'
abbr -a -g .6 'cd ../../../../../'

# asdf erlang fails without this in fish
set CFLAGS "-O2 -g" $CFLAGS

# asdf current java 2>&1 > /dev/null

# if test $status -eq 0
#   export JAVA_HOME=(asdf where java)
# end
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

function fish_prompt --description 'Write out the prompt'
    set -l prompt ' ~>> '

    set -l prompt_color magenta
    if test $status -ne 0
        set prompt_color red
    end

    set -l path (prompt_pwd)
    if test $path = '~'
        set pwd ''
        set prompt '~>> '
    else
        set pwd $path
    end

    set vcs (fish_vcs_prompt)
    echo -n -s (set_color $fish_color_cwd) $pwd $vcs (set_color $prompt_color) $prompt
end

function fzf_history_search
    history merge
    history -z | fzf --read0 --print0 --tiebreak=index | read -lz result
    and commandline -- $result
    commandline -f repaint
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


