#!/bin/zsh

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

brew install adns aom apr apr-util asdf aspcud aspell augeas autoconf automake bash bat bench bluetoothconnector boost brotli c-ares cairo camlp4 carthage certbot cfitsio clingo cmake composer coreutils ctags curl curl-openssl dialog editorconfig fasd fd ffmpeg fftw flac fontconfig fontforge freetds freetype frei0r fribidi fzf fzy gcc gd gdbm gdk-pixbuf gettext ghostscript giflib git git-crypt glib gmp gnu-sed gnu-tar gnu-time gnupg gnutls gobject-introspection gpg gradle graphicsmagick graphite2 graphviz grep groovy gts harfbuzz hdf5 htop httpie hwloc icu4c ilmbase imagemagick imagemagick@6 isl ispell jansson jasper jemalloc jenv jpeg jq kotlin kpcli ktlint lame leiningen leptonica libarchive libass libassuan libbluray libcroco libde265 libebml libev libevent libexif libffi libgcrypt libgpg-error libgsf libheif libidn libidn2 libksba libmagic libmatio libmatroska libmetalink libmpc libogg libomp libpng libpq librsvg libsamplerate libsndfile libsoxr libspiro libssh2 libtasn1 libtermkey libtiff libtool libuninameslist libunistring libusb libuv libvidstab libvorbis libvpx libvterm libxml2 libyaml libzip little-cms2 lua lua@5.1 luajit luarocks lzo mas maven mcrypt mhash mkvtoolnix mongodb-community mozjpeg mpfr mps-youtube mpv msgpack mujs nasm ncurses neofetch neovim netpbm nettle nghttp2 nmap nnn npth nspr nss ocaml ocamlbuild oniguruma opam open-mpi opencore-amr openexr openjpeg openldap openslide openssl openssl@1.1 opus orc p11-kit pandoc pango pcre pcre2 perl php@5.6 pinentry pinentry-mac pixman pkg-config poppler postgresql python python3 qt ranger rbenv readline ren rename ripgrep rtmpdump rubberband ruby-build screenfetch screenresolution sdl2 shared-mime-info skhd snappy speedtest-cli speex sphinx-doc sqlite ssh-copy-id swiftlint szip telnet tesseract texi2html texinfo theora tidy-html5 tmux trash tree uchardet unbound unibilium unixodbc vapoursynth vips webp wget wxmac x264 x265 xvid xz yabai youtube-dl zimg zsh zsh-autosuggestions zsh-completions zsh-syntax-highlighting

brew cask install 1password 1password-cli adobe-acrobat-reader aerial alacritty alfred anaconda android-file-transfer android-platform-tools bartender brave-browser calibre db-browser-for-sqlite docker dropbox evernote firefox folx font-hasklig-nerd-font-mono font-meslo-nerd-font-mono font-sourcecodepro-nerd-font-mono font-symbola gimp google-backup-and-sync google-chrome graphiql intellij-idea-ce iterm2 java8 kap karabiner karabiner-elements kindle macmediakeyforwarder now qbittorrent slack sourcetree spotify spotmenu superbeam the-unarchiver visual-studio-code vlc whatsapp xmind zoom

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
ln ~/projects/dotfiles/zshenv ~/.zshenv
ln ~/projects/dotfiles/zshrc ~/.zshrc
ln ~/projects/dotfiles/fzf.zsh ~/.fzf.zsh

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

source ~/.zshrc

# setup python ---------------------------------------------------------------------------------------------------------------------------------------------------------
python3.7 -m venv global
pip install --user neovim


# nvim setup ---------------------------------------------------------------------------------------------------------------------------------------------------------
curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
nvim +PlugInstall +UpdateRemotePlugins +qa > /dev/null

echo "-------------------------------------------Installation Complete----------------------------------------------"
