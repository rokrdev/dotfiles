" REQUIRED FOR LAZYGIT
" Creates a floating window with a most recent buffer to be used
function! CreateCenteredFloatingWindow(opts)
    let width = float2nr(&columns * a:opts.width)
    let height = float2nr(&lines * a:opts.height)
    let row = ((&lines - height) / 2) - 1
    let col = (&columns - width) / 2
    let opts = {'relative': 'editor', 'row': row, 'col': col, 'width': width, 'height': height, 'style': 'minimal'}

    let top = "╭" . repeat("─", width - 2) . "╮"
    let mid = "│" . repeat(" ", width - 2) . "│"
    let bot = "╰" . repeat("─", width - 2) . "╯"
    let lines = [top] + repeat([mid], height - 2) + [bot]
    let s:buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(s:buf, 0, -1, v:true, lines)
    call nvim_open_win(s:buf, v:true, opts)
    set winhl=Normal:Floating
    let opts.row += 1
    let opts.height -= 2
    let opts.col += 2
    let opts.width -= 4
    call nvim_open_win(nvim_create_buf(v:false, v:true), v:true, opts)
    autocmd BufWipeout <buffer> exe 'bwipeout '.s:buf
endfunction

" When term starts, auto go into insert mode
autocmd TermOpen * startinsert

" Turn off line numbers etc
autocmd TermOpen * setlocal listchars= nonumber norelativenumber

function! ToggleTerm(cmd, opts)
    if empty(bufname(a:cmd))
        call CreateCenteredFloatingWindow(a:opts)
        call termopen(a:cmd, { 'on_exit': function('OnTermExit') })
    else
        bwipeout!
    endif
endfunction

function! ToggleScratchTerm()
    call ToggleTerm('fish', {'height': 0.6, 'width': 0.8})
endfunction

function! ToggleLazyGit()
    call ToggleTerm('lazygit', {'height': 0.9, 'width': 0.9})
endfunction

function! OnTermExit(job_id, code, event) dict
    if a:code == 0
        bwipeout!
    endif
endfunction

function Rand()
    return str2nr(matchstr(reltimestr(reltime()), '\v\.@<=\d+')[1:])
endfunction

function! s:ScratchGenerator()
  exe "e!" . "__Scratchy__" . Rand()
endfunction

function! s:ScratchMarkBuffer()
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
endfunction

function! LightlineReadonly()
  return &readonly ? '' : ''
endfunction
function! LightlineFugitive()
   let branch = gitbranch#name()
   return branch !=# '' ? ' '.branch : ''
endfunction

function! JSFolds()
  let thisline = getline(v:lnum)
  if thisline =~? '\v^\s*$'
    return '-1'
  endif

  if thisline =~ '^import.*$'
    return 1
  else
    return indent(v:lnum) / &shiftwidth
  endif
endfunction

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

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

function! SingleToMulti() abort
    normal! 0f{
    execute "normal! ci{\<CR>\<CR>\<Up>\<C-r>\""
    s/ *$/,
    s/, /,\r
    normal =i{
endfunction

