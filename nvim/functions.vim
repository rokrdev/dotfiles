function Rand()
    return str2nr(matchstr(reltimestr(reltime()), '\v\.@<=\d+')[1:])
endfunction

function! ScratchGenerator()
  exe "e!" . "__Scratchy__" . Rand() | setlocal buftype=nofile bufhidden=hide noswapfile
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
