
source ~/.config/nvim/plug.vim
source ~/.config/nvim/functions.vim
source ~/.config/nvim/config.vim

for rcfile in split(globpath("~/.config/nvim/plugins", "*.vim"), '\n')
    execute('source '.rcfile)
endfor

autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

autocmd StdinReadPre * let s:std_in=1

let g:loaded_matchit = 1

" set file > 10MB has huge file
let g:hugefile_trigger_size = 10

let g:UltiSnipsExpandTrigger="<C-f>"
let g:UltiSnipsEditSplit="vertical"

autocmd FileType javascript setlocal foldmethod=expr
autocmd FileType javascript setlocal foldexpr=JSFolds()

filetype plugin indent on

let g:matchup_matchparen_deferred = 1
let g:matchup_matchparen_deferred_show_delay = 50
let g:matchup_matchparen_deferred_hide_delay = 700

au TermOpen * startinsert
au TermOpen * setlocal listchars= nonumber norelativenumber

au BufRead *.md setlocal spell
au BufRead *.markdown setlocal spell

let g:better_whitespace_enabled=1
let g:strip_whitespace_on_save=1

" auto show quickfix window
autocmd QuickFixCmdPost [^l]* nested cwindow
autocmd QuickFixCmdPost    l* nested lwindow

command! Scratch call ScratchGenerator()

inoremap <silent> <expr> <C-]> utils#manualTagComplete()
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
au TermOpen * tnoremap <buffer> <Esc> <c-\><c-n>

command! -nargs=* T split | terminal <args>
command! -nargs=* VT vsplit | terminal <args>

nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==
nnoremap <Leader>S :Scratch<CR>
nnoremap <Leader>l :BLines<space>
nnoremap <Leader><Space> :Buffers<CR>
nnoremap <Leader>/ :Rg<CR>
nmap <Leader>\ <Plug>RgRawSearch
nmap <Leader>* <Plug>RgRawWordUnderCursor<CR>
vmap <Leader>* <Plug>RgRawVisualSelection<CR>
nnoremap <Leader>c :e %:h/
nnoremap <Leader>mc :nohl<CR>
nnoremap <Leader>f :Files<CR>
nnoremap <Leader>! :bd!<CR>
noremap <Leader>y "+y
noremap <Leader>p "+p
nnoremap <S-Tab> :bp<CR>
nnoremap <Tab> :bn<CR>
nnoremap gh :b#<CR>
nnoremap go o<Esc>
nnoremap gO O<Esc>
nnoremap <Leader>n :NnnPicker (%:p:h)<CR>
nnoremap <Leader>T :T<CR>
nnoremap <Leader>\| :stop<CR>
nnoremap Q @@
nnoremap [w :PrevTrailingWhitespace<CR>
nnoremap ]w :NextTrailingWhitespace<CR>
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

" vnoremap Q :norm @q<CR>
" vnoremap <Leader>ms :s/\(^\s*\)\@<!\s/\r/<CR> :nohl<CR>
nnoremap <silent> <A-=> :vertical resize +10<CR>
nnoremap <silent> <A--> :vertical resize -10<CR>
nnoremap <silent> <A-+> :resize +10<CR>
nnoremap <silent> <A-_> :resize -10<CR>

nnoremap <Leader>gb :<C-u>call gitblame#echo()<CR>

nnoremap <Leader>r :%s///g<Left><Left>
nnoremap <Leader>rc :%s///gc<Left><Left><Left>
xnoremap <Leader>r :s///g<Left><Left>
xnoremap <Leader>rc :s///gc<Left><Left><Left>
nnoremap <silent> s* :let @/='\<'.expand('<cword>').'\>'<CR>cgn
xnoremap <silent> s* "sy:let @/=@s<CR>cgn

" saved macro to replace next space to newline in a line
let @s = "f cl\<CR>\<ESC>l"
nnoremap ! @s

autocmd FileType javascript nnoremap <buffer> s# :<C-u>silent call SingleToMulti()<CR>
" nnoremap s# ci{<CR><C-R>=split(@@)<CR><ESC>=`[f}gea,<ESC>
com! FJ %!jq .
highlight NormalFloat cterm=NONE ctermfg=14 ctermbg=0 gui=NONE guifg=#93a1a1 guibg=#002931
highlight Comment cterm=italic gui=italic guifg=#8187A2
highlight Function cterm=italic gui=italic
highlight FoldColumn guifg=#806e6f
highlight Folded guifg=#806e6f
highlight LineNr guifg=#8187A2
highlight Sneak guifg=black guibg=#00C7DF ctermfg=black ctermbg=cyan

" reload file on change
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI *
      \ if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif

autocmd FileChangedShellPost *
      \ echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None

