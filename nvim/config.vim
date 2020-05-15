
let mapleader=" "
set clipboard=unnamed
let $TERM="xterm-24bit"

if has("termguicolors")
  set termguicolors
end

syntax enable
colorscheme night-owl

set showtabline=2
set guicursor=
set dir=~/.vim/swap//
set foldmethod=indent
set foldlevel=2
" set foldcolumn=2
set showmatch           " Show matching brackets.
set cursorline
" set number              " Show the line numbers on the left side.
set number relativenumber
set formatoptions+=o    " Continue comment marker in new lines.
set expandtab           " Insert spaces when TAB is pressed.
set tabstop=2           " Render TABs using this many spaces.
set shiftwidth=2        " Indentation amount for < and > commands.
set softtabstop=2
set nojoinspaces        " Prevents inserting two spaces after punctuation on a join (J)
set encoding=utf-8
set autoread
set lazyredraw
" More natural splits
set splitbelow          " Horizontal split below current.
set splitright          " Vertical split to right of current.
if !&scrolloff
    set scrolloff=3       " Show next 3 lines while scrolling.
endif
if !&sidescrolloff
    set sidescrolloff=5   " Show next 5 columns while side-scrolling.
endif
set nostartofline       " Do not jump to first character with page commands.
set ignorecase
set smartcase           " ... unless the query has capital letters.
set gdefault
set mouse=nicr
set incsearch
set noshowmode
set splitbelow splitright
set hidden
set nobackup
set nowritebackup
set cmdheight=1
set updatetime=100
set shortmess+=cI
set signcolumn=yes
set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
set shell=/usr/local/bin/fish
