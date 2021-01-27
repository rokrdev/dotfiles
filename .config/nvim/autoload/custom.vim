
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
    exec 'cd' finddir('.git/..', expand('%:p:h').';')
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

function! custom#OnTermExit(id, status, event)
    exe 'bw!'
endfunction

function! custom#OpenTerm(cmd)
    exe 'tabnew'
    call termopen(a:cmd, { 'on_exit': 'custom#OnTermExit' })
endfunction

function! custom#VisualSelection()
    if mode()=="v"
        let [line_start, column_start] = getpos("v")[1:2]
        let [line_end, column_end] = getpos(".")[1:2]
    else
        let [line_start, column_start] = getpos("'<")[1:2]
        let [line_end, column_end] = getpos("'>")[1:2]
    end
    if (line2byte(line_start)+column_start) > (line2byte(line_end)+column_end)
        let [line_start, column_start, line_end, column_end] =
        \   [line_end, column_end, line_start, column_start]
    end
    let lines = getline(line_start, line_end)
    if len(lines) == 0
            return ''
    endif
    let lines[-1] = lines[-1][: column_end - 1]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction

function custom#Rand()
    return str2nr(matchstr(reltimestr(reltime()), '\v\.@<=\d+')[1:])
endfunction

function! custom#ScratchGenerator()
    exe "e!" . "__Scratchy__" . custom#Rand() | setlocal buftype=nofile bufhidden=hide noswapfile
endfunction

function! custom#RgWordUnderCursor()
    exe 'RG '.expand('<cword>')
endfunction

function! custom#RgRawVisualSelection()
    let str = custom#VisualSelection()
    exe 'RG '.str
endfunction

function! custom#Togglecolorcolumn()
    if &colorcolumn
        set colorcolumn=0
    else
        set colorcolumn=100
    endif
endfunction

function! custom#OnTermOpen()
    startinsert
    setlocal listchars= nonumber norelativenumber
    tnoremap <buffer> <Esc> <Nop>
endfunction

function! custom#LightlineReadonly()
    return &readonly ? '' : ''
endfunction

function! custom#LightlineFugitive()
    let branch = gitbranch#name()
    return branch !=# '' ? ' '.branch : ''
endfunction

function! custom#LightlineSignify()
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

