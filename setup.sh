!/bin/zsh

# install brew packages ---------------------------------------------------------------------------------------------------------------------------------------------------------
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew tap homebrew/bundle
brew tap homebrew/cask
brew tap homebrew/cask-fonts
brew tap homebrew/cask-versions
brew tap homebrew/core
brew tap homebrew/services
brew tap koekeishiya/formulae
brew tap neovim/neovim

brew install git
brew install adns
brew install aom
brew install apr
brew install apr-util
brew install asdf
brew install aspcud
brew install aspell
brew install augeas
brew install autoconf
brew install automake
brew install bash
brew install bat
brew install bench
brew install bluetoothconnector
brew install boost
brew install brotli
brew install c-ares
brew install cairo
brew install camlp4
brew install carthage
brew install certbot
brew install cfitsio
brew install clingo
brew install cmake
brew install composer
brew install coreutils
brew install ctags
brew install curl
brew install curl-openssl
brew install dialog
brew install editorconfig
brew install fasd
brew install fd
brew install ffmpeg
brew install fftw
brew install flac
brew install fontconfig
brew install fontforge
brew install freetds
brew install freetype
brew install frei0r
brew install fribidi
brew install fzf
brew install fzy
brew install gcc
brew install gd
brew install gdbm
brew install gdk-pixbuf
brew install gettext
brew install ghostscript
brew install giflib
brew install git
brew install git-crypt
brew install glib
brew install gmp
brew install gnu-sed
brew install gnu-tar
brew install gnu-time
brew install gnupg
brew install gnutls
brew install gobject-introspection
brew install gpg
brew install gradle
brew install graphicsmagick
brew install graphite2
brew install graphviz
brew install grep
brew install groovy
brew install gts
brew install harfbuzz
brew install hdf5
brew install htop
brew install httpie
brew install hwloc
brew install icu4c
brew install ilmbase
brew install imagemagick
brew install imagemagick@6
brew install isl
brew install ispell
brew install jansson
brew install jasper
brew install jemalloc
brew install jpeg
brew install jq
brew install kotlin
brew install kpcli
brew install ktlint
brew install lame
brew install leiningen
brew install leptonica
brew install libarchive
brew install libass
brew install libassuan
brew install libbluray
brew install libcroco
brew install libde265
brew install libebml
brew install libev
brew install libevent
brew install libexif
brew install libffi
brew install libgcrypt
brew install libgpg-error
brew install libgsf
brew install libheif
brew install libidn
brew install libidn2
brew install libksba
brew install libmagic
brew install libmatio
brew install libmatroska
brew install libmetalink
brew install libmpc
brew install libogg
brew install libomp
brew install libpng
brew install libpq
brew install librsvg
brew install libsamplerate
brew install libsndfile
brew install libsoxr
brew install libspiro
brew install libssh2
brew install libtasn1
brew install libtermkey
brew install libtiff
brew install libtool
brew install libuninameslist
brew install libunistring
brew install libusb
brew install libuv
brew install libvidstab
brew install libvorbis
brew install libvpx
brew install libvterm
brew install libxml2
brew install libyaml
brew install libzip
brew install little-cms2
brew install lua
brew install lua@5.1
brew install luajit
brew install luarocks
brew install lzo
brew install mas
brew install maven
brew install mcrypt
brew install mhash
brew install mkvtoolnix
brew install mozjpeg
brew install mpfr
brew install mps-youtube
brew install mpv
brew install msgpack
brew install mujs
brew install nasm
brew install ncurses
brew install neofetch
brew install neovim
brew install netpbm
brew install nettle
brew install nghttp2
brew install nmap
brew install nnn
brew install npth
brew install nspr
brew install nss
brew install ocaml
brew install ocamlbuild
brew install oniguruma
brew install opam
brew install open-mpi
brew install opencore-amr
brew install openexr
brew install openjpeg
brew install openldap
brew install openslide
brew install openssl
brew install openssl@1.1
brew install opus
brew install orc
brew install p11-kit
brew install pandoc
brew install pango
brew install pcre
brew install pcre2
brew install perl
brew install pinentry
brew install pinentry-mac
brew install pixman
brew install pkg-config
brew install poppler
brew install postgresql
brew install python
brew install python3
brew install qt
brew install ranger
brew install readline
brew install ren
brew install rename
brew install ripgrep
brew install rtmpdump
brew install rubberband
brew install ruby-build
brew install screenfetch
brew install screenresolution
brew install sdl2
brew install shared-mime-info
brew install skhd
brew install snappy
brew install speedtest-cli
brew install speex
brew install sphinx-doc
brew install sqlite
brew install ssh-copy-id
brew install swiftlint
brew install szip
brew install telnet
brew install tesseract
brew install texi2html
brew install texinfo
brew install theora
brew install tidy-html5
brew install tmux
brew install trash
brew install tree
brew install uchardet
brew install unbound
brew install unibilium
brew install unixodbc
brew install vapoursynth
brew install vips
brew install webp
brew install wget
brew install wxmac
brew install x264
brew install x265
brew install xvid
brew install xz
brew install yabai
brew install youtube-dl
brew install zimg
brew install zsh
brew install zsh-autosuggestions
brew install zsh-completions
brew install zsh-syntax-highlighting

brew cask install 1password
brew cask install 1password-cli
brew cask install adobe-acrobat-reader
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
brew cask install evernote
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
brew cask install now
brew cask install qbittorrent
brew cask install slack
brew cask install sourcetree
brew cask install spotify
brew cask install spotmenu
brew cask install superbeam
brew cask install the-unarchiver
brew cask install visual-studio-code
brew cask install vlc
brew cask install whatsapp
brew cask install xmind
brew cask install zoom

mkdir ~/projects

# install prezto modules ---------------------------------------------------------------------------------------------------------------------------------------------------------
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

mkdir ~/.config

# clone required projects ---------------------------------------------------------------------------------------------------------------------------------------------------------
git clone https://github.com/jbharat/dotfiles ~/projects/dotfiles

git clone https://github.com/jbharat/keyboard.git ~/projects/keyboard

# setup links ---------------------------------------------------------------------------------------------------------------------------------------------------------
ln -s ~/projects/dotfiles/alacritty/ ~/.config/alacritty
ln -s ~/projects/dotfiles/nvim/ ~/.config/nvim
ln -s ~/projects/keyboard/karabiner/ ~/.config/karabiner

ln ~/projects/dotfiles/tmux.conf ~/.tmux.conf

ln ~/projects/keyboard/.skhdrc ~/.skhdrc
ln ~/projects/keyboard/.yabairc ~/.yabairc

cp ~/projects/dotfiles/xterm-24bit.terminfo ~/

# add terminfo ---------------------------------------------------------------------------------------------------------------------------------------------------------
tic -x xterm-24bit.terminfo

# setup asdf plugins ---------------------------------------------------------------------------------------------------------------------------------------------------------
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
npm i -g bash-language-server

# setup python ---------------------------------------------------------------------------------------------------------------------------------------------------------
python3.7 -m venv global
pip install --user neovim


# nvim setup ---------------------------------------------------------------------------------------------------------------------------------------------------------
curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
nvim +PlugInstall +UpdateRemotePlugins +qa > /dev/null


# override zshrc  ---------------------------------------------------------------------------------------------------------------------------------------------------------
ln ~/projects/dotfiles/zshenv ~/.zshenv
ln ~/projects/dotfiles/zshrc ~/.zshrc
ln ~/projects/dotfiles/fzf.zsh ~/.fzf.zsh

source ~/.zshrc

echo "-------------------------------------------Installation Complete----------------------------------------------"
