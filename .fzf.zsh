# Key bindings
# ------------
if [[ $- == *i* ]]; then

# CTRL-T - Paste the selected file path(s) into the command line
__fsel() {
  local cmd="${FZF_CTRL_T_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type f -print \
    -o -type d -print \
    -o -type l -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail 2> /dev/null
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) -m "$@" | while read item; do
    echo -n "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

__fzf_use_tmux__() {
  [ -n "$TMUX_PANE" ] && [ "${FZF_TMUX:-0}" != 0 ] && [ ${LINES:-40} -gt 15 ]
}

__fzfcmd() {
  __fzf_use_tmux__ &&
    echo "fzf-tmux -d${FZF_TMUX_HEIGHT:-40%}" || echo "fzf"
}

fzf-file-widget() {
  LBUFFER="${LBUFFER}$(__fsel)"
  local ret=$?
  zle reset-prompt
  return $ret
}
zle     -N   fzf-file-widget
bindkey '^T' fzf-file-widget

# Ensure precmds are run after cd
fzf-redraw-prompt() {
  local precmd
  for precmd in $precmd_functions; do
    $precmd
  done
  zle reset-prompt
}
zle -N fzf-redraw-prompt

# ALT-C - cd into the selected directory
fzf-cd-widget() {
  local cmd="${FZF_ALT_C_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type d -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail 2> /dev/null
  local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_ALT_C_OPTS" $(__fzfcmd) +m)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  cd "$dir"
  local ret=$?
  zle fzf-redraw-prompt
  return $ret
}
zle     -N    fzf-cd-widget
bindkey '\ec' fzf-cd-widget

# CTRL-R - Paste the selected command from history into the command line
fzf-history-widget() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail 2> /dev/null
  selected=( $(fc -rl 1 |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} +m" $(__fzfcmd)) )
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle reset-prompt
  return $ret
}
zle     -N   fzf-history-widget
bindkey '^R' fzf-history-widget

fi

unalias f
f() {
    local files
    local olIFS=$IFS  # save old IFS to reset later
    IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
    IFS=$olIFS   # reset IFS else git info breaks in terminal prompt
    [[ -n "$files" ]] && v "${files[@]}"
}

fe() {
    local files
    local olIFS=$IFS  # save old IFS to reset later
    IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
    IFS=$olIFS   # reset IFS else git info breaks in terminal prompt
    [[ -n "$files" ]] && v "${files[@]}" &
}

ffLogic() {
    local files
    local olIFS=$IFS  # save old IFS to reset later
    if [ -z "$2" ]; then echo "Need a string to search for!"; return 1; fi
    IFS=$'\n' files=($(rg --files-with-matches --no-messages "$2" | fzf --multi --select-1 --exit-0 --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$2' || rg --ignore-case --pretty --context 10 '$2' {}"))
    IFS=$olIFS   #reset IFS else git info breaks in terminal prompt
    if [ "$1" = 'open' ]; then
        [[ -n "$files" ]] && v "${files[@]}"
    else
        [[ -n "$files" ]] && echo "${files[@]}"
    fi
}

ffo() {
    ffLogic "open" "$1"
}

ff() {
    ffLogic "search" "$1"
}

function z() {
    local olIFS=$IFS  # save old IFS to reset later
    [ $# -gt 0 ] && fasd_cd -d "$*" && return
    local dir
    dir="$(fasd -Rdl "$1" | fzf -1 -0 --no-sort +m)" && cd "${dir}"
    IFS=$olIFS   #reset IFS else git info breaks in terminal prompt
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
