set showtabline=0
set guicursor=
set number relativenumber
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
set termguicolors
set scrolloff=8
set noshowmode
set completeopt=menuone,noinsert,noselect
set cmdheight=1
set updatetime=50       " Having longer updatetime leads to noticeable delays and poor user experience.
set shortmess+=cI
set colorcolumn=100
set termguicolors
set list
set listchars=tab:>-,eol:¬
set dir=~/.vim/swap//
set showmatch           " Show matching brackets.
set nocursorline
set lazyredraw
set splitbelow          " Horizontal split below current.
set splitright          " Vertical split to right of current.
set nowritebackup
set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
set shell=/bin/zsh



call plug#begin('~/.config/nvim/autoload')

Plug 'honza/vim-snippets'
Plug 'itchyny/lightline.vim'
Plug 'itchyny/vim-gitbranch'
Plug 'ap/vim-css-color'
Plug 'jesseleite/vim-agriculture'
Plug 'jiangmiao/auto-pairs'
Plug 'junegunn/fzf',
Plug 'junegunn/fzf.vim'
Plug 'machakann/vim-sandwich'
Plug 'nelstrom/vim-visual-star-search'
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-commentary'
Plug 'mhinz/vim-signify'
Plug 'samoshkin/vim-mergetool', {
            \'on': [
            \  'MergetoolStart',
            \  'MergetoolToggle',
            \  '<Plug>(MergetoolToggle)'
            \]}
Plug 'antoinemadec/FixCursorHold.nvim' "cursor hold issue with neovim
Plug 'lambdalisue/fern.vim', { 'on': 'Fern' }
Plug 'rhysd/git-messenger.vim', { 'on': '<Plug>(git-messenger)' }
Plug 'styled-components/vim-styled-components', {
            \'branch': 'main',
            \'for': ['javascript', 'typescript', 'javascriptreact']
            \}
Plug 'svermeulen/vim-extended-ft'

call plug#end()

packadd cfilter



function! SingleToMulti() abort
    normal! 0f{
    execute "normal! ci{\<CR>\<CR>\<Up>\<C-r>\""
    s/ *$/,
    s/, /,\r
    normal =i{
endfunction

function! ToggleNumberDisplay()
    if(&rnu == 1)
        set nu rnu!
    elseif(&nu == 1)
        set nu!
    else
        set nu rnu
    endif
endfunction

function! GoToRoot()
    exec 'cd' fnameescape(fnamemodify(finddir('.git', escape(expand('%:p:h'), ' ') . ';'), ':h'))
endfunction



let mapleader=" "
let $TERM="alacritty"
syntax enable
filetype plugin indent on



nnoremap <C-n> :m .+1<CR>==
nnoremap <C-p> :m .-2<CR>==
nnoremap <Leader>c :e %:h/
nnoremap <Leader>! :bd!<CR>
nnoremap <Leader>y "+y
nnoremap <Leader>p "+p
nnoremap gh :b#<CR>
nnoremap <Leader>b :ls<cr>:b<space>
nnoremap Q q
nnoremap q <Nop>
nnoremap \| @@
" for vim-sandwich
nmap s <Nop>
xmap s <Nop>
nnoremap <esc><esc> :silent! nohl<CR>
vnoremap <C-n> :m '>+1<CR>gv=gv
vnoremap <C-p> :m '<-2<CR>gv=gv
nnoremap <silent> <A-=> :vertical resize +10<CR>
nnoremap <silent> <A--> :vertical resize -10<CR>
nnoremap <silent> <A-+> :resize +10<CR>
nnoremap <silent> <A-_> :resize -10<CR>
nnoremap <Leader>r :%s///g<Left><Left><Left>
nnoremap <Leader>rc :%s///gc<Left><Left><Left><Left>
nnoremap <silent>s# :let @/='\<'.expand('<cword>').'\>'<CR>cgN
xnoremap <silent>s# "sy:let @/=@s<CR>cgN
nnoremap <silent>s* :let @/='\<'.expand('<cword>').'\>'<CR>cgn
xnoremap <silent>s* "sy:let @/=@s<CR>cgn
" saved macro to replace next space to newline in a line
let @s = "f cl\<CR>\<ESC>l"
nnoremap ! @s
command! FJ %!jq .
noremap <expr> <Leader>0 ToggleNumberDisplay()
nnoremap <Leader>qr :cfdo %s///g \| update<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>
nnoremap [<Space> O<Esc>
nnoremap ]<Space> o<Esc>
nnoremap [q :cprevious<CR>
nnoremap ]q :cnext<CR>


let g:cursorhold_updatetime = 100

nmap gb <Plug>(git-messenger)



let g:mergetool_layout = 'mr'
let g:mergetool_prefer_revision = 'local'
nmap <Leader>gM <Plug>(MergetoolToggle)



command! Gcd call GoToRoot()



colorscheme night-owl

highlight FoldColumn guifg=#806e6f
highlight Folded guifg=#806e6f
highlight LineNr guifg=#4b6479
highlight CursorLineNr guifg=#C5E4FD guibg=#011627
" highlight CursorLine guibg=#263147



function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    else
        call CocAction('doHover')
    endif
endfunction

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
    inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
    inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent><Leader>gd <Plug>(coc-definition)
nmap <silent><Leader>gy <Plug>(coc-type-definition)
nmap <silent><Leader>gi <Plug>(coc-implementation)
nmap <silent><Leader>gr <Plug>(coc-references)

nmap <Leader>ss :CocSearch<Space>
nmap <Leader>sw :CocSearch <C-R>=expand("<cword>")<CR><CR>

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

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

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
            \ pumvisible() ? coc#_select_confirm() :
            \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
            \ <SID>check_back_space() ? "\<TAB>" :
            \ coc#refresh()

let g:coc_snippet_next = '<tab>'
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" imap <C-f> <Plug>(coc-snippets-expand)

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()



" .............................................................................
" lambdalisue/fern.vim
" .............................................................................

" Disable netrw.
let g:loaded_netrw  = 1
let g:loaded_netrwPlugin = 1
let g:loaded_netrwSettings = 1
let g:loaded_netrwFileHandlers = 1
let g:fern#disable_viewer_hide_cursor=1

augroup my-fern-hijack
    autocmd!
    autocmd BufEnter * ++nested call s:hijack_directory()
augroup END

function! s:hijack_directory() abort
    let path = expand('%:p')
    if !isdirectory(path)
        return
    endif
    bwipeout %
    execute printf('Fern %s', fnameescape(path))
endfunction

" Custom settings and mappings.
let g:fern#disable_default_mappings = 1

function! OpenFern()
    if bufname("%") == ""
        exe "Fern . -drawer -toggle"
    else
        exe "Fern . -reveal=% -drawer -toggle"
    endif
endfunction

noremap <silent> - :call OpenFern()<CR>

function! FernInit() abort
    nmap <buffer><expr>
                \ <Plug>(fern-my-open-expand-collapse)
                \ fern#smart#leaf(
                \   "\<Plug>(fern-action-open:select)",
                \   "\<Plug>(fern-action-expand)",
                \   "\<Plug>(fern-action-collapse)",
                \ )
    nmap <buffer> <CR> <Plug>(fern-my-open-expand-collapse)
    nmap <buffer> <2-LeftMouse> <Plug>(fern-my-open-expand-collapse)
    nmap <buffer> n <Plug>(fern-action-new-path)
    nmap <buffer> d <Plug>(fern-action-remove)
    nmap <buffer> m <Plug>(fern-action-move)
    nmap <buffer> c <Plug>(fern-action-copy)
    nmap <buffer> r <Plug>(fern-action-rename)
    nmap <buffer> ! <Plug>(fern-action-hidden:toggle)
    nmap <buffer> R <Plug>(fern-action-reload)
    nmap <buffer> b <Plug>(fern-action-open:split)
    nmap <buffer> v <Plug>(fern-action-open:vsplit)
    nmap <buffer> ! <Plug>(fern-action-mark:toggle)
    nmap <buffer> k <Up>
    nmap <buffer> j <Down>
    nmap <buffer> q :bd<CR>
    nmap <buffer> h <Plug>(fern-action-collapse)
    nmap <buffer> l <Plug>(fern-action-open-or-expand)
    nmap <buffer> < <Plug>(fern-action-leave)
    nmap <buffer> > <Plug>(fern-action-enter)
endfunction

augroup FernGroup
    autocmd!
    autocmd FileType fern call FernInit()
augroup END



" run pip install neovim-remote for nvr
if has('nvim')
    let $GIT_EDITOR = 'nvr -cc split --remote-wait'
endif
" :wq saves commit message and close the split
autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete

function! OnTermExit(id, status, event)
    exe 'bw!'
endfunction

function! OpenTerm(cmd)
    exe 'tabnew'
    call termopen(a:cmd, { 'on_exit': 'OnTermExit' })
endfunction


nmap <Leader>gg :call OpenTerm('tig status')<CR>
nmap <Leader>gb :call OpenTerm('tig ' . expand('%'))<CR>
nmap <Leader>gu :call OpenTerm('tig log @{u}.. -p')<CR>



" let g:fzf_layout = { 'window': 'split enew'  }
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.9, 'border': 'rounded', 'highlight': 'Directory' }}

" [Buffers] Jump to the existing window if possible
let g:fzf_buffers_jump = 1

" [[B]Commits] Customize the options used by 'git log':
let g:fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'

" [Tags] Command to generate tags file
let g:fzf_tags_command = 'ctags &'

" [Commands] --expect expression for directly executing the command
let g:fzf_commands_expect = 'alt-enter,ctrl-x'

let g:fzf_action = {
            \ 'ctrl-x': 'split',
            \ 'ctrl-v': 'vsplit' }

let g:fzf_preview_window = 'right:50%'

au FileType fzf tunmap <buffer> <Esc>

command! -bang -nargs=* Rg
            \call fzf#vim#grep(
            \  "rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1,
            \  fzf#vim#with_preview(), <bang>0)

nnoremap <Leader>B :Buffers<CR>
nmap <Leader>* <Plug>RgRawWordUnderCursor<CR>
vmap <Leader>* <Plug>RgRawVisualSelection<CR>
nnoremap <Leader>o :Files<CR>
nnoremap <Leader>f :Rg<CR>
nmap <Leader>F <Plug>RgRawSearch

function! s:fzf_statusline()
    " Override statusline as you like
    highlight fzf1 guifg=#ecc48d guibg=#011627
    setlocal statusline=%#fzf1#\ >\ %#fzf1#fzf
endfunction

autocmd! User FzfStatusLine call <SID>fzf_statusline()



highlight SignifySignAdd    ctermbg=233 ctermfg=149 guifg=#addb67 guibg=#011627 cterm=NONE gui=NONE
highlight SignifySignDelete ctermbg=233 ctermfg=204 guifg=#ff5874 guibg=#011627 cterm=NONE gui=NONE
highlight SignifySignChange ctermbg=233 ctermfg=222 guifg=#ecc48d guibg=#011627 cterm=NONE gui=NONE



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

" ============================================================
" nightowl
" ============================================================

let s:p = {"normal": {}, "inactive": {}, "insert": {}, "replace": {}, "visual": {}, "tabline": {} }

let s:p.normal.left = [[["#263147", 235], ["#82aaff", 111]], [["#d6deeb", 253], ["#263147", 235]]]
let s:p.normal.middle = [[["#d6deeb", 253], ["#263147", 235]]]
let s:p.normal.right = [[["#d6deeb", 253], ["#263147", 235]], [["#263147", 235], ["#82aaff", 111]]]
let s:p.normal.error = [[["#263147", 235], ["#82aaff", 111]]]
let s:p.normal.warning = [[["#263147", 235], ["#82aaff", 111]]]

let s:p.inactive.left = [[["#d6deeb", 253], ["#112630", 235]], [["#d6deeb", 253], ["#112630", 235]]]
let s:p.inactive.middle = [[["#d6deeb", 253], ["#112630", 235]]]
let s:p.inactive.right = [[["#d6deeb", 253], ["#112630", 235]], [["#d6deeb", 253], ["#112630", 235]]]

let s:p.insert.left = [[["#263147", 235], ["#addb67", 149]], [["#d6deeb", 253], ["#263147", 235]]]
let s:p.insert.middle = [[["#d6deeb", 253], ["#263147", 235]]]
let s:p.insert.right = [[["#d6deeb", 253], ["#263147", 235]], [["#263147", 235], ["#addb67", 149]]]

let s:p.replace.left = [[["#263147", 235], ["#ff5874", 204]], [["#d6deeb", 253], ["#263147", 235]]]
let s:p.replace.middle = [[["#d6deeb", 253], ["#263147", 235]]]
let s:p.replace.right = [[["#d6deeb", 253], ["#263147", 235]], [["#263147", 235], ["#ff5874", 204]]]

let s:p.visual.left = [[["#263147", 235], ["#c792ea", 176]], [["#d6deeb", 253], ["#263147", 235]]]
let s:p.visual.middle = [[["#d6deeb", 253], ["#263147", 235]]]
let s:p.visual.right = [[["#d6deeb", 253], ["#263147", 235]], [["#263147", 235], ["#c792ea", 176]]]

let s:p.tabline.left = [[["#d6deeb", 253], ["#263147", 235]]]
let s:p.tabline.tabsel = [[["#263147", 235], ["#82aaff", 111]]]
let s:p.tabline.middle = [[["#d6deeb", 253], ["#263147", 235]]]
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
            \     'right': [ [ 'lineinfo', 'filetype', 'fileencoding' ],
            \              [ 'percent' ] ],
            \   },
            \   'inactive': {
            \     'left': [ [ 'mode', 'paste' ],
            \               [ 'fugitive', 'filename', 'readonly', 'modified' ],
            \              [ 'gitdiff' ] ],
            \     'right': [ [ 'lineinfo' ],
            \              [ 'percent' ] ],
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



let g:vim_markdown_conceal = 0



let g:mergetool_layout = 'mr'
let g:mergetool_prefer_revision = 'local'



function Rand()
    return str2nr(matchstr(reltimestr(reltime()), '\v\.@<=\d+')[1:])
endfunction

function! ScratchGenerator()
    exe "e!" . "__Scratchy__" . Rand() | setlocal buftype=nofile bufhidden=hide noswapfile
endfunction

command! Scratch call ScratchGenerator()

nnoremap <Leader>S :Scratch<CR>



autocmd TermOpen * startinsert
autocmd TermOpen * setlocal listchars= nonumber norelativenumber
autocmd TermOpen * tnoremap <buffer> <Esc> <c-\><c-n>

command! -bang Term terminal<bang> /usr/local/bin/fish
command! -nargs=* T split | Term <args>
command! -nargs=* VT vsplit | Term <args>

nnoremap <Leader>ts :T<CR>
nnoremap <Leader>tv :VT<CR>


highlight default link EndOfLineSpace ErrorMsg
match EndOfLineSpace / \+$/
autocmd InsertEnter * hi link EndOfLineSpace Normal
autocmd InsertLeave * hi link EndOfLineSpace ErrorMsg

command! DisableTrailingWhitespace hi link EndOfLineSpace Normal
command! EnableTrailingWhitespace hi link EndOfLineSpace ErrorMsg

augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=250, on_visual=false}
augroup END
