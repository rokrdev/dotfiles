#!/bin/zsh

brewConfig () {
  echo "install brew packages ---------------------------------------------------------------------"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  brew tap homebrew/bundle
  brew tap homebrew/cask
  brew tap homebrew/cask-fonts
  brew tap homebrew/core
  brew tap homebrew/services
  brew tap AdoptOpenJDK/openjdk
  brew tap koekeishiya/formulae

  brew install git
  brew install asdf
  brew install aspell
  brew install bash
  brew install bat
  brew install bluetoothconnector
  brew install boost
  brew install broot
  brew install carthage
  brew install coreutils
  brew install curl
  brew install curl-openssl
  brew install editorconfig
  brew install fasd
  brew install fd
  brew install ffmpeg
  brew install fontconfig
  brew install fzf
  brew install fzy
  brew install gcc
  brew install gd
  brew install gdbm
  brew install ghostscript
  brew install git
  brew install git-crypt
  brew install gnu-sed
  brew install gnu-tar
  brew install gnu-time
  brew install gnupg
  brew install gpg
  brew install graphicsmagick
  brew install graphviz
  brew install grep
  brew install htop
  brew install httpie
  brew install imagemagick
  brew install ispell
  brew install jq
  brew install kpcli
  brew install neovim
  brew install nmap
  brew install nnn
  brew install openssl
  brew install pandoc
  brew install python
  brew install python3
  brew install qt
  brew install ranger
  brew install readline
  brew install ren
  brew install rename
  brew install ripgrep
  brew install screenfetch
  brew install screenresolution
  brew install skhd
  brew install speedtest-cli
  brew install sqlite
  brew install ssh-copy-id
  brew install telnet
  brew install tesseract
  brew install tmux
  brew install tree
  brew install unbound
  brew install wget
  brew install yabai
  brew install youtube-dl
  brew install zsh
  brew install zsh-autosuggestions
  brew install zsh-completions
  brew install zsh-syntax-highlighting

  brew cask install 1password
  brew cask install adoptopenjdk8
  brew cask install aerial
  brew cask install alacritty
  brew cask install alfred
  brew cask install anaconda
  brew cask install android-file-transfer
  brew cask install android-platform-tools
  brew cask install bartender
  brew cask install brave-browser
  brew cask install calibre
  brew cask install db-browser-for-sqlite
  brew cask install docker
  brew cask install dropbox
  brew cask install firefox
  brew cask install folx
  brew cask install font-hasklig-nerd-font-mono
  brew cask install font-meslo-nerd-font-mono
  brew cask install font-sourcecodepro-nerd-font-mono
  brew cask install gimp
  brew cask install google-backup-and-sync
  brew cask install google-chrome
  brew cask install graphiql
  brew cask install intellij-idea-ce
  brew cask install iterm2
  brew cask install kap
  brew cask install karabiner-elements
  brew cask install kindle
  brew cask install macmediakeyforwarder
  brew cask install microsoft-edge
  brew cask install notion
  brew cask install now
  brew cask install qbittorrent
  brew cask install slack
  brew cask install sourcetree
  brew cask install spotify
  brew cask install spotmenu
  brew cask install the-unarchiver
  brew cask install visual-studio-code
  brew cask install vlc
  brew cask install whatsapp
  brew cask install xmind
  brew cask install xquartz

  brew install mps-youtube
  brew cask install mpv
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

asdfTermConfig () {
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

pythonConfig () {
  echo "python conf ---------------------------------------------------------------------"
  touch ~/.condarc
  echo "changeps1: False" >> ~/.condarc
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

  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

  # setup links ---------------------------------------------------------------------------------------------------------------------------------------------------------
  ln -sf ~/projects/dotfiles/alacritty/ ~/.config/alacritty
  ln -sf ~/projects/dotfiles/nvim/ ~/.config/nvim
  ln -sf ~/projects/keyboard/karabiner/ ~/.config/karabiner

  ln -f ~/projects/dotfiles/.tmux.conf ~/.tmux.conf

  ln -f ~/projects/keyboard/.skhdrc ~/.skhdrc
  ln -f ~/projects/keyboard/.yabairc ~/.yabairc

  cp ~/projects/dotfiles/xterm-24bit.terminfo ~/

  echo "term config  ---------------------------------------------------------------------"
  tic -x xterm-24bit.terminfo

  # echo "override zsh files ---------------------------------------------------------------------"
  # rm ~/.zshrc
  # rm ~/.zshenv
  # rm ~/.fzf.zsh

  ln -f ~/projects/dotfiles/.zshenv ~/.zshenv
  ln -f ~/projects/dotfiles/.zshrc ~/.zshrc
  ln -f ~/projects/dotfiles/.fzf.zsh ~/.custom_fzf.zsh

  source ~/.zshrc
  sudo yabai --install-sa

  brew services start yabai
  brew services start skhd
  echo "DOTFILES LOADED *************************************************"
}

vimAndNpmConfig () {
  echo "Vim pluging install ---------------------------------------------------------------------"
  curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  nvim +PlugInstall +UpdateRemotePlugins +qa > /dev/null
  npm i -g bash-language-server rimraf instant-markdown-d
  echo "VIM AND NPM CONFIG COMPLETE *************************************************"
}


brewConfig; preztoConfig; asdfTermConfig; pythonConfig; loadDotfiles; vimAndNpmConfig;
echo "-------------------------------------------Installation Complete----------------------------------------------"
