" - For Neovim: ~/.local/share/nvim/pluggedf
" - Avoid using standard Vim directory names like 'plugin'
"
call plug#begin('~/.config/nvim/autoload')

" Make sure you use single quotes

" Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
Plug 'junegunn/vim-easy-align'

" Any valid git URL is allowed
Plug 'https://github.com/junegunn/vim-github-dashboard.git'

Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
let g:deoplete#enable_at_startup = 1
" On-demand loading
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
" Specify a directory for plugins
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-repeat'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'haishanh/night-owl.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'sheerun/vim-polyglot'
Plug 'matthewbdaly/vim-filetype-settings'
" Comments
Plug 'Yggdroot/indentLine'
Plug 'mattn/emmet-vim'
Plug 'ap/vim-css-color'
Plug 'airblade/vim-gitgutter'
Plug 'pangloss/vim-javascript'
Plug 'jiangmiao/auto-pairs'

Plug 'tbodt/deoplete-tabnine', { 'do': './install.sh' }

Plug 'cloudhead/neovim-fuzzy'
Plug 'ternjs/tern_for_vim', { 'do': 'npm install' }
Plug 'shougo/context_filetype.vim'
Plug 'joshdick/onedark.vim'
Plug 'terryma/vim-expand-region'
Plug 'andymass/vim-matchup'
" Plug 'skwp/vim-easymotion'
" Plug 'justinmk/vim-sneak'
Plug 'arcticicestudio/nord-vim'
Plug 'prettier/vim-prettier'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'terryma/vim-multiple-cursors'
Plug 'ntpeters/vim-better-whitespace'
Plug 'udalov/kotlin-vim'
Plug 'ayu-theme/ayu-vim'
Plug 'francoiscabrol/ranger.vim'
Plug 'rbgrouleff/bclose.vim'
Plug 'w0rp/ale'
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': './install.sh',
    \ }
Plug 'elixir-editors/vim-elixir'
Plug 'RRethy/vim-illuminate'

call plug#end()

let g:deoplete#auto_completion_start_length=2
let g:deoplete#sources={}
let g:deoplete#sources._    = ['buffer', 'file', 'ultisnips']
let g:deoplete#sources.ruby = ['buffer', 'member', 'file', 'ultisnips']
let g:deoplete#sources.vim  = ['buffer', 'member', 'file', 'ultisnips']
let g:deoplete#sources.css  = ['buffer', 'member', 'file', 'omni', 'ultisnips']
let g:deoplete#sources.scss = ['buffer', 'member', 'file', 'omni', 'ultisnips']
" Insert <TAB> or select next match

" Manually trigger tag autocomplete
inoremap <silent> <expr> <C-]> utils#manualTagComplete()
" let g:deoplete#disable_auto_complete = 1
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
"

" let g:sneak#label = 1
" map f <Plug>Sneak_f
" map F <Plug>Sneak_F
" map t <Plug>Sneak_t
" map T <Plug>Sneak_T

" tern
if exists('g:plugs["tern_for_vim"]')
  let g:tern_show_argument_hints = 'on_hold'
  let g:tern_show_signature_in_pum = 1
  autocmd FileType javascript setlocal omnifunc=tern#Complete
endif

let g:loaded_matchit = 1

let g:EasyMotion_leader_key = '<Leader>'

" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<C-f>"
let g:UltiSnipsJumpForwardTrigger="<C-b>"
let g:UltiSnipsJumpBackwardTrigger="<C-z>"


" augroup javascript_folding
"     au!
"     au FileType javascript setlocal foldmethod=syntax
" augroup END

set clipboard=unnamed
let NERDTreeMapOpen='<ENTER>'
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

" If you have vim >=8.0 or Neovim >= 0.1.5
if (has("termguicolors"))
  " set termguicolors
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

" For Neovim 0.1.3 and 0.1.4
let $NVIM_TUI_ENABLE_TRUE_COLOR=1

""""" enable the theme
syntax enable
set background=dark
let ayucolor="mirage"
let g:nord_bold=1
let g:nord_italic=1
colorscheme nord
let g:airline_theme='nord'

" let g:airline#extensions#tabline#fnamemod = ':t'

let mapleader=" "

set foldmethod=syntax
set foldlevel=20
set showmatch           " Show matching brackets.
set number              " Show the line numbers on the left side.
set formatoptions+=o    " Continue comment marker in new lines.
set expandtab           " Insert spaces when TAB is pressed.
set tabstop=2           " Render TABs using this many spaces.
set shiftwidth=2        " Indentation amount for < and > commands.
set softtabstop=2
set cursorline
set nojoinspaces        " Prevents inserting two spaces after punctuation on a join (J)
set hidden
set encoding=utf-8

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

set ignorecase          " Make searching case insensitive
set smartcase           " ... unless the query has capital letters.
set gdefault
set mouse=a
set incsearch
set noshowmode

" autosave on bufferleave
" au BufLeave * silent! wall

filetype plugin indent on

func! Multiple_cursors_before()
  if deoplete#is_enabled()
    call deoplete#disable()
    let g:deoplete_is_enable_before_multi_cursors = 1
  else
    let g:deoplete_is_enable_before_multi_cursors = 0
  endif
endfunc
func! Multiple_cursors_after()
  if g:deoplete_is_enable_before_multi_cursors
    call deoplete#enable()
  endif
endfunc
highlight multiple_cursors_cursor term=reverse cterm=reverse gui=reverse
highlight link multiple_cursors_visual Visual

let g:multi_cursor_use_default_mapping=0

" Default mapping
let g:multi_cursor_start_word_key      = '<C-n>'
let g:multi_cursor_select_all_word_key = '<leader>aa'
let g:multi_cursor_start_key           = 'g<C-n>'
let g:multi_cursor_select_all_key      = 'g<leader>ak'
let g:multi_cursor_next_key            = '<C-n>'
let g:multi_cursor_prev_key            = '<C-p>'
let g:multi_cursor_skip_key            = '<C-x>'
let g:multi_cursor_quit_key            = '<Esc>'

" Search and Replace
nmap <Leader>S :%s!!!g<Left><Left><Left>
nnoremap <leader>c :nohlsearch<CR>
nnoremap Q @q
vnoremap Q :norm @q<cr>
nnoremap L :bnext<CR>
nnoremap H :bprevious<CR>
nnoremap <leader>s :w<cr>
let g:ranger_map_keys = 0
nnoremap <leader>p :FuzzyOpen<CR>
nnoremap <leader>F :Ranger<cr>
nnoremap <leader>f :Rg<cr>
nnoremap <leader>n :NERDTreeToggle<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv
nnoremap ]w :NextTrailingWhitespace<CR>
nnoremap [w :PrevTrailingWhitespace<CR>
nnoremap \ :Find<SPACE>

let g:indentLine_enabled = 0
let g:indentLine_char = '│'
let g:indentLine_leadingSpaceEnabled = 1
let g:indentLine_leadingSpaceChar = "·"

" let g:fuzzy_opencmd = 'tab drop'

let g:matchup_matchparen_status_offscreen = 0

let g:airline#extensions#default#section_truncate_width = {
      \ 'b': 79,
      \ 'x': 60,
      \ 'y': 88,
      \ 'z': 45,
      \ }
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let b:airline_whitespace_checks = [ 'indent', 'mixed-indent-file' ]
let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
" unicode symbols
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.whitespace = 'Ξ'

" airline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
" let g:airline_left_sep = ''
" let g:airline_left_alt_sep = ''
" let g:airline_right_sep = ''
" let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''

" --column: Show column number
" --line-number: Show line number
" --no-heading: Do not show file headings in results
" --fixed-strings: Search term as a literal string
" --ignore-case: Case insensitive search
" --no-ignore: Do not respect .gitignore, etc...
" --hidden: Search hidden files and folders
" --follow: Follow symlinks
" --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)
" --color: Search color options
command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --glob "!{.git,node_modules}/*" --color "always" '.shellescape(<q-args>), 1, <bang>0)

set guicursor=

let g:prettier#autoformat = 1
autocmd BufWritePre *.js,*.jsx,*.css,*.scss,*.less Prettier

let g:ale_fixers = {
 \ 'javascript': ['eslint'],
 \ 'elixir': ['elixir-ls']
 \ }

let g:ale_fixers = {
\   'elixir': ['mix_format'],
\}

let g:ale_sign_error = '❌'
let g:ale_sign_warning = '⚠️'

let g:ale_fix_on_save = 1
let g:ale_elixir_elixir_ls_release = '~/.local/bin'

nnoremap ]r :ALENextWrap<CR>     " move to the next ALE warning / error
nnoremap [r :ALEPreviousWrap<CR> " move to the previous ALE warning / error

" Required for operations modifying multiple buffers like rename.
set hidden

let g:LanguageClient_serverCommands = {
    \ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
    \ 'javascript': ['javascript-typescript-langserver'],
    \ 'javascript.jsx': ['tcp://127.0.0.1:2089'],
    \ 'python': ['/usr/local/bin/pyls'],
    \ 'ruby': ['~/.rbenv/shims/solargraph', 'stdio'],
    \ 'elixir': ['~/.local/bin/language_server.sh']
    \ }

nnoremap <leader>l :call LanguageClient_contextMenu()<CR>
" Or map each action separately
nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <leader>r :call LanguageClient#textDocument_rename()<CR>

let g:Illuminate_ftblacklist = ['nerdtree']
let g:indentLine_fileTypeExclude = ["nerdtree"]

let g:better_whitespace_enabled=1
let g:strip_whitespace_on_save=1

highlight Comment cterm=italic gui=italic
highlight Function cterm=italic gui=italic
let g:nord_comment_brightness = 20
