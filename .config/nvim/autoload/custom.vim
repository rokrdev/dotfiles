
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

function! custom#show_documentation()
    if (index(['vim','help'], &fileype) >= 0)
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
    exe 'Rg '.expand('<cword>')
endfunction

function! custom#RgRawVisualSelection()
    let str = custom#VisualSelection()
    exe 'Rg '.str
endfunction

function! custom#Togglecolorcolumn()
    if &colorcolumn
        set colorcolumn=0
    else
        set colorcolumn=100
    endif
endfunction

