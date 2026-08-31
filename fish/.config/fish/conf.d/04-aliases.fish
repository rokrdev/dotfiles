alias brup='brew update && brew upgrade && brew upgrade --cask && brew cleanup && brew doctor'
alias cat=bat
alias bcb='bat cache --build'

# Changing "ls" to "eza"
alias ls='eza --icons=always --color=always --group-directories-first' # all files and dirs

alias python3=python

alias ll='eza --icons=always -lah --group-directories-first'
alias la='eza --icons=always -a --group-directories-first'
alias lt='eza --icons=always -aT --git-ignore --group-directories-first'
alias l.='eza --icons=always -a | egrep "^\."'
