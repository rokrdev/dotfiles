alias brup='brew update && brew upgrade && brew upgrade --cask && brew cleanup && brew doctor'
alias cat=bat
alias bcb='bat cache --build'
alias d='cd ~/.dotfiles'
alias dc='docker compose'
alias dcu='docker compose up'
alias dcd='docker compose down'
alias dcs='docker compose start'
alias dcx='docker compose stop'
alias gfmc='git pull origin (git branch --show-current)'
alias gmt="git mergetool"
alias gg="gitui"
alias groot='cd $(git rev-parse --show-cdup)'
alias gtr='git log --oneline --graph --decorate --all'
alias gx='git clean -fxd'
alias hup='brew uninstall helix && brew install helix --HEAD'
alias k=kubectl
alias kgp="kubectl get pods"
alias kl="kubectl logs"
alias klf="kubectl logs -f"
alias lg=lazygit
alias n=npm
alias ni='npm install'
alias rf=trash
alias sf='source $FISH_CONFIG'
alias st=speedtest-cli
alias top=btop
alias upa='brew update && brew upgrade && brew upgrade --cask && brew cleanup && brew doctor; nvim +PackerSync +PackerCompile +qall > /dev/null'
alias ya='yarn add'
alias yr='yarn run'
alias ys='yarn start'
alias yt='yarn test'

# Changing "ls" to "eza"
# alias ls='eza --color=always --group-directories-first'  # all files and dirs

alias please=sudo

alias python3=python
alias p=python

alias x86="env /usr/bin/arch -x86_64 /bin/zsh --login"

alias clb="claude --model $CLAUDE_MODEL_SONNET --effort high"
alias cld="claude --model $CLAUDE_MODEL_OPUS --effort high"

#provider/model
alias ocq="opencode -m lmstudio/qwen3.6-27b-mlx"
alias ocg="opencode -m lmstudio/gemma-4-31b"

alias ldeep='fish $HOME/.dotfiles/late/late_switch.fish deep'
alias llite='fish $HOME/.dotfiles/late/late_switch.fish lite'
