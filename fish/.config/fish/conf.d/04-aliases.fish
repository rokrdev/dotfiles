alias brup='brew update && brew upgrade && brew upgrade --cask && brew cleanup && brew doctor'
alias cat=bat
alias bcb='bat cache --build'
alias d='cd ~/.dotfiles'
alias dkc='docker compose'
alias dkcu='docker compose up'
alias dkcd='docker compose down'
alias dkcs='docker compose start'
alias dlcx='docker compose stop'
alias gfmc='git pull origin (git branch --show-current)'
alias gtmt="git mergetool"
alias gg="gitui"
alias gtr='git log --oneline --graph --decorate --all'
alias gtx='git clean -fxd'
alias hup='brew uninstall helix && brew install helix --HEAD'
alias kbgp="kubectl get pods"
alias kbl="kubectl logs"
alias kblf="kubectl logs -f"
alias lg=lazygit
alias rf=trash
alias sf='source $FISH_CONFIG'
alias st=speedtest-cli
alias top=btop

# Changing "ls" to "eza"
# alias ls='eza --color=always --group-directories-first'  # all files and dirs

alias python3=python

alias clb="claude --model $CLAUDE_MODEL_SONNET --effort high"
alias cld="claude --model $CLAUDE_MODEL_OPUS --effort high"

#provider/model
alias ocs="opencode -m openrouter/xiaomi/mimo-v2.5"
alias oco="opencode -m neuralwatt/glm-5.2-flex"

alias ll='eza -lah --group-directories-first'
alias la='eza -a --group-directories-first'
alias lt='eza -aT --git-ignore --group-directories-first'
alias l.='eza -a | egrep "^\."'
