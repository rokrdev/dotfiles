
function! custom#SingleToMulti() abort
    normal! 0f{
    execute "normal! ci{\<CR>\<CR>\<Up>\<C-r>\""
    s/ *$/,
    s/, /,\r
    normal =i{
endfunction

function! custom#ToggleNumberDisplay()
    if(&rnu == 1)
        set nu rnu!
    elseif(&nu == 1)
        set nu!
    else
        set nu rnu
    endif
endfunction

function! custom#GoToRoot()
    exec 'cd' fnameescape(fnamemodify(finddir('.git', escape(expand('%:p:h'), ' ') . ';'), ':h'))
endfunction



" https://github.com/wincent/loupe/blob/cf2d75a4b32a639e1b0a477c2ebdaebb1b70bf27/autoload/loupe/private.vim
" E486: Pattern not found: \<foo\bar\>
function! custom#EscapeSlashes(cword) abort
  return substitute(a:cword, '\\', '\\\\', 'g')
endfunction

" makes * and # work on visual mode too.
function! custom#VSetSearch(cmdtype, ...)
    let l:temp = @s
    norm! gv"sy
    let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
    let @s = temp
endfunction

function! custom#OpenMergetool()
    let g:mergetool_layout = 'mr'
    let g:mergetool_prefer_revision = 'local'
    nmap <Leader>gmt <Plug>(MergetoolToggle)
    exe "MergetoolStart"
endfunction

function! custom#show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    else
        call CocAction('doHover')
    endif
endfunction

function! custom#check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! custom#hijack_directory() abort
    let path = expand('%:p')
    if !isdirectory(path)
        return
    endif
    bwipeout %
    execute printf('Fern %s', fnameescape(path))
endfunction


function! custom#OnTermExit(id, status, event)
    exe 'bw!'
endfunction

function! custom#OpenTerm(cmd)
    exe 'tabnew'
    call termopen(a:cmd, { 'on_exit': 'custom#OnTermExit' })
endfunction

function! custom#fzf_statusline()
    " Override statusline as you like
    highlight fzf1 guifg=#ecc48d guibg=#011627
    setlocal statusline=%#fzf1#\ >\ %#fzf1#fzf
endfunction

function! custom#FernInit() abort
    setlocal nonumber norelativenumber
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
    nmap <buffer> <Tab> <Plug>(fern-action-mark:toggle)
    nmap <buffer> k <Up>
    nmap <buffer> j <Down>
    nmap <buffer> gq :bd<CR>
    nmap <buffer> h <Plug>(fern-action-collapse)
    nmap <buffer> l <Plug>(fern-action-open-or-expand)
    nmap <buffer> < <Plug>(fern-action-leave)
    nmap <buffer> > <Plug>(fern-action-enter)
endfunction


function custom#Rand()
    return str2nr(matchstr(reltimestr(reltime()), '\v\.@<=\d+')[1:])
endfunction

function! custom#ScratchGenerator()
    exe "e!" . "__Scratchy__" . custom#Rand() | setlocal buftype=nofile bufhidden=hide noswapfile
endfunction

function! custom#RgWordUnderCursor()
    exe 'Rg '.expand('<cword>')
endfunction

function! custom#RgRawVisualSelection()
    exe 'Rg '.custom#EscapeSlashes(expand('<cword>'))
endfunction
