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
Plug 'ap/vim-css-color'
Plug 'honza/vim-snippets'
Plug 'itchyny/lightline.vim'
Plug 'itchyny/vim-gitbranch'
Plug 'jesseleite/vim-agriculture'
Plug 'jiangmiao/auto-pairs'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all && source ~/.zshrc' }
Plug 'junegunn/fzf.vim'
Plug 'machakann/vim-sandwich'
Plug 'mcchrish/nnn.vim'
Plug 'mengelbrecht/lightline-bufferline'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'nelstrom/vim-visual-star-search'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'niklaas/lightline-gitdiff'
Plug 'ntpeters/vim-better-whitespace'
Plug 'plasticboy/vim-markdown'
Plug 'sheerun/vim-polyglot'
Plug 'suan/vim-instant-markdown', {'for': 'markdown'}
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-eunuch'
Plug 'udalov/kotlin-vim'
Plug 'xolox/vim-misc'
Plug 'xolox/vim-session'
Plug 'zivyangll/git-blame.vim'
Plug 'RRethy/vim-illuminate'
Plug 'APZelos/blamer.nvim'
Plug 'easymotion/vim-easymotion'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

call plug#end()

packadd cfilter

" Automatically install missing plugins on startup
autocmd VimEnter *
  \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall --sync | q
  \| endif
