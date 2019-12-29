#!/bin/zsh


brewConfig () {
  echo "install brew packages ---------------------------------------------------------------------"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  brew tap homebrew/bundle
  brew tap homebrew/cask
  brew tap homebrew/cask-fonts
  brew tap homebrew/cask-versions
  brew tap homebrew/core
  brew tap homebrew/services
  brew tap koekeishiya/formulae
  brew tap adoptopenjdk/openjdk

  brew install git asdf aspell bash bat bluetoothconnector boost carthage coreutils curl curl-openssl editorconfig fasd fd ffmpeg fontconfig fzf fzy gcc gd gdbm git git-crypt gnu-sed gnu-tar gnu-time gnupg gpg graphicsmagick graphviz grep htop httpie imagemagick ispell jq kpcli mps-youtube nmap nnn openssl pandoc python python3 qt ranger readline ren rename ripgrep screenfetch screenresolution skhd speedtest-cli sqlite ssh-copy-id swiftlint telnet tesseract tmux tree unbound wget yabai youtube-dl zsh zsh-autosuggestions zsh-completions zsh-syntax-highlighting

  brew cask install 1password adoptopenjdk8 aerial alacritty alfred anaconda android-file-transfer android-platform-tools bartender brave-browser calibre db-browser-for-sqlite docker dropbox evernote firefox folx font-hasklig-nerd-font-mono font-meslo-nerd-font-mono font-sourcecodepro-nerd-font-mono gimp google-backup-and-sync google-chrome graphiql intellij-idea-ce iterm2 kap karabiner-elements kindle macmediakeyforwarder now qbittorrent slack sourcetree spotify spotmenu the-unarchiver visual-studio-code vlc whatsapp xmind

  brew install neovim
  echo "BREW CONFIG COMPLETE *************************************************"
}


preztoConfig () {
  echo "install prezto ---------------------------------------------------------------------"
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
  setopt EXTENDED_GLOB
  for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
  done
  echo "PREZTO CONFIG COMPLETE *************************************************"
}

asdfTermConfremove {
  echo "asdf config ---------------------------------------------------------------------"
  asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
  asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
  asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
  bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring

  touch ~/.tool-versions
  echo "elixir 1.9.4-otp-22\nerlang 22.2.1\nnodejs 13.5.0\n" >> ~/.tool-versions

  asdf install

  asdf global erlang 22.2.1
  asdf global elixir 1.9.4-otp-22
  asdf global nodejs 13.5.0
  echo "ASDF CONFIG COMPLETE *************************************************"
}

pythonConf () {
  echo "python conf ---------------------------------------------------------------------"
  echo "changeps1: False" > ~/.condarc
  python3.7 -m venv global
  pip3 install --user neovim
  echo "PYTHON CONFIG COMPLETE *************************************************"
}


loadDotfiles () {
  echo "load dotfiles ---------------------------------------------------------------------"
  mkdir ~/.config
  mkdir ~/projects

  touch ~/.env

  git clone https://github.com/jbharat/dotfiles.git ~/projects/dotfiles

  git clone https://github.com/jbharat/keyboard.git ~/projects/keyboard

  # setup links ---------------------------------------------------------------------------------------------------------------------------------------------------------
  ln -s ~/projects/dotfiles/alacritty/ ~/.config/alacritty
  ln -s ~/projects/dotfiles/nvim/ ~/.config/nvim
  ln -s ~/projects/keyboard/karabiner/ ~/.config/karabiner

  ln ~/projects/dotfiles/tmux.conf ~/.tmux.conf

  ln ~/projects/keyboard/.skhdrc ~/.skhdrc
  ln ~/projects/keyboard/.yabairc ~/.yabairc

  cp ~/projects/dotfiles/xterm-24bit.terminfo ~/

  echo "term config  ---------------------------------------------------------------------"
  tic -x xterm-24bit.terminfo

  echo "override zsh files ---------------------------------------------------------------------"
  rm ~/.zshrc
  rm ~/.zshenv
  rm ~/.fzf.zsh

  ln ~/projects/dotfiles/zshenv ~/.zshenv
  ln ~/projects/dotfiles/zshrc ~/.zshrc
  ln ~/projects/dotfiles/fzf.zsh ~/.fzf.zsh

  source ~/.zshrc
  echo "DOTFILES LOADED *************************************************"
}

vimAndNpmConfig () {
  echo "Vim pluging install ---------------------------------------------------------------------"
  curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  nvim +PlugInstall +UpdateRemotePlugins +qa > /dev/null
  npm i -g bash-language-server
  echo "VIM AND NPM CONFIG COMPLETE *************************************************"
}


brewConfig; preztoConfig; asdfTermConfig; pythonConf; loadDotfiles; vimAndNpmConfig;
echo "-------------------------------------------Installation Complete----------------------------------------------"
