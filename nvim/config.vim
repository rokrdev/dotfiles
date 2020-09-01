
let mapleader=" "
set clipboard=unnamed
let $TERM="alacritty"

syntax enable

set showtabline=2
set dir=~/.vim/swap//
set foldmethod=manual
set foldlevel=2
" set foldcolumn=2
set nofoldenable
set showmatch           " Show matching brackets.
set cursorline
set number              " Show the line numbers on the left side.
" set number relativenumber
set formatoptions+=o    " Continue comment marker in new lines.
set expandtab           " Insert spaces when TAB is pressed.
" set tabstop=2           " Render TABs using this many spaces.
set shiftwidth=2        " Indentation amount for < and > commands.
set softtabstop=2
set nojoinspaces        " Prevents inserting two spaces after punctuation on a join (J)
set encoding=utf-8
set autoread
set redrawtime=10000
set lazyredraw
" More natural splits
set splitbelow          " Horizontal split below current.
set splitright          " Vertical split to right of current.
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
set shell=/bin/zsh
set guifont=MonoLisa:h12

set list
set listchars=tab:>-,eol:¬

filetype plugin indent on
let g:large_file = 1024 * 1024 * 5  "5MB as large file
autocmd BufReadPre * let curFile=expand("<afile>") | if getfsize(curFile)
            \ > g:large_file | set noswapfile | syntax off | setlocal nu! rnu! | endif

autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
autocmd StdinReadPre * let s:std_in=1
autocmd FileType javascript setlocal foldmethod=expr
autocmd FileType javascript setlocal foldexpr=JSFolds()
autocmd BufRead *.md setlocal spell
autocmd BufRead *.markdown setlocal spell
autocmd QuickFixCmdPost [^l]* nested cwindow
autocmd QuickFixCmdPost    l* nested lwindow
autocmd FileType javascript nnoremap <buffer> s# :<C-u>silent call SingleToMulti()<CR>
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
" reload file on change
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI *
      \ if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif
autocmd FileChangedShellPost *
      \ echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None

nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==
nnoremap <Leader>c :e %:h/
nnoremap <Leader>mc :nohl<CR>
nnoremap <Leader>! :bd!<CR>
noremap <Leader>y "+y
noremap <Leader>p "+p
nnoremap <C-h> :bp<CR>
nnoremap <C-l> :bn<CR>
nnoremap gh :b#<CR>
nnoremap <Leader>\| :stop<CR>
nnoremap Q @@
nnoremap gq q
nnoremap q <Nop>
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

nnoremap <silent> <A-=> :vertical resize +10<CR>
nnoremap <silent> <A--> :vertical resize -10<CR>
nnoremap <silent> <A-+> :resize +10<CR>
nnoremap <silent> <A-_> :resize -10<CR>

nnoremap <Leader>r :%s///g<Left><Left>
nnoremap <Leader>rc :%s///gc<Left><Left><Left>
xnoremap <Leader>r :s///g<Left><Left>
xnoremap <Leader>rc :s/\<'.expand('<cword>').'\>'//gc<Left><Left><Left>
nnoremap <silent> s* :let @/='\<'.expand('<cword>').'\>'<CR>cgn
xnoremap <silent> s* "sy:let @/=@s<CR>cgn

" saved macro to replace next space to newline in a line
let @s = "f cl\<CR>\<ESC>l"
nnoremap ! @s

" nnoremap s# ci{<CR><C-R>=split(@@)<CR><ESC>=`[f}gea,<ESC>
command! FJ %!jq .

noremap <expr> <Leader>0 ToggleNumberDisplay()
nnoremap <Leader>qr :cfdo %s///g \| update<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>
nnoremap <silent> <leader>qq :cclose<CR>

let g:Illuminate_delay = 500

nnoremap ][q :copen<CR>
nnoremap []q :cclose<CR>
nnoremap ][l :lopen<CR>
nnoremap []l :lclose<CR>

let g:cursorhold_updatetime = 100

" fix for <CR> in vim-visual-multiedit when coc-completion is visible
autocmd User visual_multi_mappings  imap <buffer><expr> <CR> pumvisible() ? "\<C-Y>" : "\<Plug>(VM-I-Return)"

nnoremap <Leader>b :<C-u>call gitblame#echo()<CR>
