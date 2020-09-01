"" auto-install vim-plug
"if empty(glob('~/.config/nvim/autoload/plug.vim'))
"  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
"    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"  "autocmd VimEnter * PlugInstall
"  autocmd VimEnter * PlugInstall | source $MYVIMRC
"endif

call plug#begin('~/.config/nvim/autoload')

Plug 'SirVer/ultisnips'
Plug 'Yggdroot/indentLine'
Plug 'andymass/vim-matchup'
Plug 'ap/vim-css-color', { 'for': ['css', 'scss'] }
Plug 'honza/vim-snippets'
Plug 'itchyny/lightline.vim'
Plug 'jesseleite/vim-agriculture'
Plug 'jiangmiao/auto-pairs'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all && source ~/.zshrc' }
Plug 'junegunn/fzf.vim'
Plug 'machakann/vim-sandwich'
Plug 'mcchrish/nnn.vim', { 'on': 'NnnPicker' }
Plug 'mengelbrecht/lightline-bufferline'
Plug 'mg979/vim-visual-multi', { 'branch': 'master' }
Plug 'nelstrom/vim-visual-star-search'
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'ntpeters/vim-better-whitespace'
Plug 'sheerun/vim-polyglot'
Plug 'suan/vim-instant-markdown', { 'for': 'markdown' }
Plug 'tpope/vim-commentary'
Plug 'RRethy/vim-illuminate'
Plug 'zivyangll/git-blame.vim'
Plug 'easymotion/vim-easymotion'
Plug 'airblade/vim-gitgutter'
Plug 'itchyny/vim-gitbranch'
Plug 'samoshkin/vim-mergetool'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-repeat'
Plug 'antoinemadec/FixCursorHold.nvim' "cursor hold issue with neovim
Plug 'lambdalisue/fern.vim', { 'on': 'Fern' }
Plug 'voldikss/vim-floaterm'

call plug#end()

packadd cfilter

" Automatically install missing plugins on startup
autocmd VimEnter *
  \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall --sync | q
  \| endif
