" set commands {{{

set showtabline=0
" set guicursor=
set number
set hidden
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set ignorecase
set smartcase
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set scrolloff=8
set noshowmode
set completeopt=menuone,noinsert,noselect
set cmdheight=1
set updatetime=250       " Having longer updatetime leads to noticeable delays and poor user experience.
set shortmess+=cI
set colorcolumn=0
set termguicolors
set list
set listchars=tab:>-,eol:¬,extends:»,precedes:«
set dir=~/.vim/swap//
set showmatch           " Show matching brackets.
set cursorline
set lazyredraw
set redrawtime=10000    " Some php files takes long to redraw else syntax gets disabled
set splitbelow          " Horizontal split below current.
set splitright          " Vertical split to right of current.
set nowritebackup
set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
set shell=/bin/zsh
set nowrap
set foldmethod=manual
set foldnestmax=10
set foldlevel=2
set inccommand=split
set signcolumn=yes
set wildignorecase
" }}}


" Plug {{{

call plug#begin('~/.config/nvim/autoload')

Plug 'itchyny/lightline.vim'
Plug 'itchyny/vim-gitbranch'
Plug 'norcalli/nvim-colorizer.lua'
Plug 'jiangmiao/auto-pairs'
Plug 'junegunn/fzf.vim'
Plug 'machakann/vim-sandwich'
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'tpope/vim-commentary'
Plug 'mhinz/vim-signify'
Plug 'antoinemadec/FixCursorHold.nvim' "cursor hold issue with neovim
Plug 'rhysd/git-messenger.vim', { 'on': '<Plug>(git-messenger)' }
Plug 'styled-components/vim-styled-components', {
            \'branch': 'main',
            \'for': ['javascript', 'typescript', 'javascriptreact']
            \}
Plug 'justinmk/vim-sneak'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-obsession', { 'on': ['Obsession', 'Obsess'] }
Plug 'vifm/vifm.vim', { 'on': 'Vifm' }
Plug 'rrethy/vim-illuminate'
Plug 'Yggdroot/indentLine'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}

call plug#end()

packadd cfilter

" }}}

" other {{{

set rtp+=/usr/local/opt/fzf
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI *
      \ if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif
autocmd FileChangedShellPost *
      \ echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None

let mapleader=" "
let $TERM="alacritty"
syntax enable
filetype plugin indent on
let g:cursorhold_updatetime = 100
let g:Illuminate_delay = 500
let g:Illuminate_highlightUnderCursor = 1

let g:indentLine_char = 'c'
let g:indentLine_char_list = ['│']
let g:indentLine_fileTypeExclude = ['coc-explorer']
let g:indentLine_bufTypeExclude = ['help', 'terminal']
let g:indentLine_bufNameExclude = ['vifm']

autocmd FileType * setlocal formatoptions-=cro

" setup colorizer
lua require'colorizer'.setup()

command! Gcd call custom#GoToRoot()
command! Config :e $MYVIMRC
command! Reload :so $MYVIMRC
command! Tcc call custom#Togglecolorcolumn()

colorscheme night-owl
let g:vim_markdown_conceal = 0
command! Scratch call custom#ScratchGenerator()
" run pip install neovim-remote for nvr
if has('nvim')
    let $GIT_EDITOR = 'nvr -cc split --remote-wait'
endif

" fix for slow movement in large php files
let g:php_syntax_extensions_enabled=[]
let php_var_selector_is_identifier=1
let php_sql_query=0
let php_sql_heredoc=0
let php_sql_nowdoc=0
let php_html_load=0
let php_html_in_heredoc=0
let php_html_in_nowdoc=0

" :wq saves commit message and close the split
autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete
" }}}

" COC {{{

" Highlight symbol under cursor on CursorHold
" autocmd CursorHold * silent call CocActionAsync('highlight')

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" use `:OR` for organize import of current buffer
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')

" Add status line support, for integration with other plugin, checkout `:h coc-status`
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
let g:coc_global_extensions = [
            \ 'coc-css',
            \ 'coc-docker',
            \ 'coc-elixir',
            \ 'coc-explorer',
            \ 'coc-emmet',
            \ 'coc-eslint',
            \ 'coc-html',
            \ 'coc-json',
            \ 'coc-markdownlint',
            \ 'coc-prettier',
            \ 'coc-python',
            \ 'coc-sh',
            \ 'coc-snippets',
            \ 'coc-tsserver',
            \ 'coc-yaml',
            \ ]

" inoremap <silent><expr> <TAB>
"       \ pumvisible() ? coc#_select_confirm() :
"       \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
"       \ <SID>check_back_space() ? "\<TAB>" :
"       \ coc#refresh()

" inoremap <silent><expr> <c-space> coc#refresh()

" }}}

" Fzf {{{

" let g:fzf_layout = { 'window': 'split enew'  }
let g:fzf_layout = { 'window': { 'width': 1, 'height': 1, 'border': 'rounded', 'highlight': 'Directory' }}

" [Buffers] Jump to the existing window if possible
let g:fzf_buffers_jump = 1

" [[B]Commits] Customize the options used by 'git log':
let g:fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'

" [Commands] --expect expression for directly executing the command
let g:fzf_commands_expect = 'alt-enter,ctrl-x'

let g:fzf_action = {
            \ 'ctrl-x': 'split',
            \ 'ctrl-v': 'vsplit' }

let g:fzf_preview_window = 'right:50%'
autocmd! FileType fzf tunmap <buffer> <Esc>

command! -bang -nargs=* Rg
            \call fzf#vim#grep(
            \  "rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1,
            \  fzf#vim#with_preview(), <bang>0)

command! -bang -nargs=* RgRaw
            \ call fzf#vim#grep(
            \   'rg --column --line-number --no-heading --color=always --smart-case '.(<q-args>), 1,
            \   fzf#vim#with_preview(),  <bang>0)

command! -bang -nargs=* GConflicts
            \ call fzf#run(
            \    fzf#wrap({'source': 'git diff --name-only --diff-filter=U',
            \      'options': ['--multi', '--prompt', 'Conflicts?> ', '--preview', 'cat {}']
            \    }, <bang>0))

" }}}

" Lightline  {{{

function! LightlineReadonly()
    return &readonly ? '' : ''
endfunction

function! LightlineFugitive()
    let branch = gitbranch#name()
    return branch !=# '' ? ' '.branch : ''
endfunction

function! LightlineSignify()
    let [added, modified, removed] = sy#repo#get_stats()
    let l:sy = ''
    for [flag, flagcount] in [
                \   [exists("g:signify_sign_add")?g:signify_sign_add:'+', added],
                \   [exists("g:signify_sign_delete")?g:signify_sign_delete:'-', removed],
                \   [exists("g:signify_sign_change")?g:signify_sign_change:'!', modified]
                \ ]
        if flagcount> 0
            let l:sy .= printf('%s%d', flag, flagcount)
        endif
    endfor
    if !empty(l:sy)
        let l:sy = printf('[%s]', l:sy)
        return printf('%s', l:sy)
    else
        return ''
    endif
endfunction

" show signify status in statusline without delay
autocmd User Signify call lightline#update()


let s:p = {"normal": {}, "inactive": {}, "insert": {}, "replace": {}, "visual": {}, "tabline": {} }

let s:p.normal.left = [[["#1a2b4a", 235], ["#82aaff", 111]], [["#d6deeb", 253], ["#1a2b4a", 235]]]
let s:p.normal.middle = [[["#d6deeb", 253], ["#1a2b4a", 235]]]
let s:p.normal.right = [[["#1a2b4a", 235], ["#82aaff", 111]], [["#d6deeb", 253], ["#1a2b4a", 235]]]
let s:p.normal.error = [[["#1a2b4a", 235], ["#82aaff", 111]]]
let s:p.normal.warning = [[["#1a2b4a", 235], ["#82aaff", 111]]]

let s:p.inactive.left = [[["#d6deeb", 253], ["#112630", 235]], [["#d6deeb", 253], ["#112630", 235]]]
let s:p.inactive.middle = [[["#d6deeb", 253], ["#112630", 235]]]
let s:p.inactive.right = [[["#d6deeb", 253], ["#112630", 235]], [["#d6deeb", 253], ["#112630", 235]]]

let s:p.insert.left = [[["#1a2b4a", 235], ["#addb67", 149]], [["#d6deeb", 253], ["#1a2b4a", 235]]]
let s:p.insert.middle = [[["#d6deeb", 253], ["#1a2b4a", 235]]]
let s:p.insert.right = [[["#1a2b4a", 235], ["#addb67", 149]], [["#d6deeb", 253], ["#1a2b4a", 235]]]

let s:p.replace.left = [[["#1a2b4a", 235], ["#ff5874", 204]], [["#d6deeb", 253], ["#1a2b4a", 235]]]
let s:p.replace.middle = [[["#d6deeb", 253], ["#1a2b4a", 235]]]
let s:p.replace.right = [[["#1a2b4a", 235], ["#ff5874", 204]], [["#d6deeb", 253], ["#1a2b4a", 235]]]

let s:p.visual.left = [[["#1a2b4a", 235], ["#c792ea", 176]], [["#d6deeb", 253], ["#1a2b4a", 235]]]
let s:p.visual.middle = [[["#d6deeb", 253], ["#1a2b4a", 235]]]
let s:p.visual.right = [[["#1a2b4a", 235], ["#c792ea", 176]], [["#d6deeb", 253], ["#1a2b4a", 235]]]

let s:p.tabline.left = [[["#d6deeb", 253], ["#1a2b4a", 235]]]
let s:p.tabline.tabsel = [[["#1a2b4a", 235], ["#82aaff", 111]]]
let s:p.tabline.middle = [[["#d6deeb", 253], ["#1a2b4a", 235]]]
let s:p.tabline.right = [[["#d6deeb", 253], ["#ff5874", 204]]]

let g:lightline#colorscheme#nightowl#palette = lightline#colorscheme#flatten(s:p)

let g:lightline = {
            \   'colorscheme': 'nightowl',
            \   'mode_map': {
            \     'n' : 'N',
            \     'i' : 'I',
            \     'R' : 'R',
            \     'v' : 'V',
            \     'V' : 'VL',
            \     "\<C-v>": 'VB',
            \     'c' : 'C',
            \     's' : 'S',
            \     'S' : 'SL',
            \     "\<C-s>": 'SB',
            \     't': 'T',
            \   },
            \   'active': {
            \     'left': [ [ 'mode', 'paste' ],
            \               [ 'fugitive', 'filename', 'readonly', 'modified' ],
            \              [ 'gitdiff', 'cocstatus' ] ],
            \     'right': [ [ 'percent' ], [ 'filetype', 'fileencoding', 'lineinfo' ] ],
            \   },
            \   'inactive': {
            \     'left': [ [ 'mode', 'paste' ],
            \               [ 'fugitive', 'filename', 'readonly', 'modified' ],
            \              [ 'gitdiff' ] ],
            \     'right': [ [ 'percent' ], [ 'lineinfo'] ],
            \   },
            \   'component_function': {
            \     'readonly': 'LightlineReadonly',
            \     'fugitive': 'LightlineFugitive',
            \     'gitdiff': 'LightlineSignify',
            \     'cocstatus': 'coc#status',
            \   },
            \   'component_expand': {
            \     'gitdiff': 'LightlineSignify'
            \   },
            \   'component_type': {
            \     'gitdiff': 'middle',
            \   },
            \ }

autocmd BufWritePost,TextChanged,TextChangedI,TermLeave * call lightline#update()
" }}}

" Term {{{

function OnTermOpen()
    startinsert
    setlocal listchars= nonumber norelativenumber
    tnoremap <buffer> <Esc> <Nop>
endfunction

autocmd TermOpen * call OnTermOpen()

command! -bang Term terminal<bang> /usr/local/bin/fish
command! -nargs=* T split | Term <args>
command! -nargs=* VT vsplit | Term <args>

command! SS Obsess! | Obsess | wq
" }}}

" whitepace {{{

highlight default link EndOfLineSpace ErrorMsg
match EndOfLineSpace / \+$/
autocmd InsertEnter * hi link EndOfLineSpace Normal
autocmd InsertLeave * hi link EndOfLineSpace ErrorMsg

command! DisableTrailingWhitespace hi link EndOfLineSpace Normal
command! EnableTrailingWhitespace hi link EndOfLineSpace ErrorMsg
" }}}

augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=250, on_visual=false}
augroup END

" sneak {{{

let g:sneak#use_ic_scs = 1
let g:sneak#target_labels = "asdfjkl;ghqweruioptyzxcvnmb"

" }}}

" mappings {{{
nnoremap <C-down> :m .+1<CR>==
nnoremap <C-up> :m .-2<CR>==
nnoremap <Leader>C :e %:p:h/
nnoremap s_ :bd!<CR>
nnoremap s- :bd<CR>
nnoremap sp "+p
vnoremap sy "+y
vnoremap sp "+p
nnoremap gh :b#<CR>
nnoremap ss :Buffers<CR>
nnoremap \| @@
" for vim-sandwich
nmap s <Nop>
xmap s <Nop>
nnoremap <esc><esc> :silent! nohl<CR>
vnoremap <C-down> :m '>+1<CR>gv=gv
vnoremap <C-up> :m '<-2<CR>gv=gv
nnoremap <silent> <A-a> :vertical resize +5<CR>
nnoremap <silent> <A-d> :vertical resize -5<CR>
nnoremap <silent> <A-w> :resize +5<CR>
nnoremap <silent> <A-s> :resize -5<CR>
nnoremap <Leader>r :%s///g<Left><Left><Left>
nnoremap <Leader>rc :%s///gc<Left><Left><Left><Left>
nnoremap <silent>s# :let @/='\<'.expand('<cword>').'\>'<CR>cgN
xnoremap <silent>s# "sy:let @/=@s<CR>cgN
nnoremap <silent>s* :let @/='\<'.expand('<cword>').'\>'<CR>cgn
xnoremap <silent>s* "sy:let @/=@s<CR>cgn
" saved macro to replace next space to newline in a line
let @z = "f cl\<CR>\<ESC>l"
nnoremap ! @z
command! FJ %!jq .
nnoremap <expr> <Leader>0 custom#ToggleNumberDisplay()
nnoremap <Leader>qr :cfdo %s///g \| update<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>
inoremap <expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"
" */#/g*/g# mapping that obeys smartcase and  ignorecase
nnoremap <silent># :let @/='\V\<'.custom#EscapeSlashes(expand('<cword>')).'\>'<CR>:let v:searchforward=0<CR>n
nnoremap <silent>* :let @/='\V\<'.custom#EscapeSlashes(expand('<cword>')).'\>'<CR>:let v:searchforward=1<CR>n
nnoremap <silent>g# :let @/='\V'.custom#EscapeSlashes(expand('<cword>'))<CR>:let v:searchforward=0<CR>n
nnoremap <silent>g* :let @/='\V'.custom#EscapeSlashes(expand('<cword>'))<CR>:let v:searchforward=1<CR>n
xnoremap * :<C-u>call custom#VSetSearch('/')<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call custom#VSetSearch('?')<CR>?<C-R>=@/<CR><CR>
" nnoremap <Leader>* :call custom#RgWordUnderCursor()<CR>
" vnoremap <Leader>* :call custom#RgRawVisualSelection()<CR>
nnoremap <Leader>o :Files<CR>
nnoremap <Leader>f :Rg<CR>
nnoremap <Leader>F :RgRaw<Space>
nnoremap <Leader>/ :BLines<CR>
nnoremap <Leader>G :GF?<CR>
nnoremap <Leader>co :Commands<CR>
nnoremap <Leader>cc :BCommits<CR>
nnoremap <Leader>n :Vifm<CR>
nmap f <Plug>Sneak_f
nmap F <Plug>Sneak_F
nmap t <Plug>Sneak_t
nmap T <Plug>Sneak_T
vmap f <Plug>Sneak_f
vmap F <Plug>Sneak_F
vmap t <Plug>Sneak_t
vmap T <Plug>Sneak_T
nmap sj <Plug>SneakLabel_s
nmap sk <Plug>SneakLabel_S
nnoremap <Leader>S :Scratch<CR>
nnoremap <Leader>gg :call custom#OpenTerm('tig status')<CR>
nnoremap <Leader>gb :call custom#OpenTerm('tig ' . expand('%'))<CR>
nnoremap <Leader>gu :call custom#OpenTerm('tig log @{u}.. -p')<CR>
nmap gb <Plug>(git-messenger)
nmap <Leader>ck <Plug>(coc-diagnostic-prev)
nmap <Leader>cj <Plug>(coc-diagnostic-next)
nmap <Leader>cd <Plug>(coc-definition)
nmap <Leader>cy <Plug>(coc-type-definition)
nmap <Leader>ci <Plug>(coc-implementation)
nmap <Leader>cr <Plug>(coc-references)
nnoremap <Leader>cs :CocSearch<Space>
nnoremap <Leader>cw :CocSearch <C-R>=expand("<cword>")<CR><CR>
imap <C-f> <Plug>(coc-snippets-expand-jump)
nmap <Leader>ct :CocCommand explorer<CR>
nmap <Leader>cT :call coc#float#close_all()<CR>
nnoremap <silent> K :call custom#show_documentation()<CR>
nnoremap <Leader>; o<ESC>
nnoremap <Leader>: O<ESC>
let g:VM_maps = {}
let g:VM_maps['Find Under']         = '<C-n>'           " replace C-n
let g:VM_maps['Find Subword Under'] = '<C-n>'           " replace visual C-n
let g:VM_maps["Add Cursor Down"] = '<M-Down>'
let g:VM_maps["Add Cursor Up"] = '<M-Up>'
let g:VM_maps["Select Cursor Down"] = '<M-C-Down>'      " start selecting down
let g:VM_maps["Select Cursor Up"]   = '<M-C-Up>'        " start selecting up
" nnoremap <Leader>\> :cnext<CR>
" nnoremap <Leader>\< :cprevious<CR>
" }}}

