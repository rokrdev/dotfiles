let g:EasyMotion_smartcase = 1

let g:EasyMotion_keys = 'abcdefghijklmnopqrstuvwxyz'

let g:EasyMotion_prompt = '{n}>>> '

"" <Leader>f{char} to move to {char}
map  <Leader>jf <Plug>(easymotion-bd-f)
nmap <Leader>jf <Plug>(easymotion-overwin-f)

" s{char}{char} to move to {char}{char}
nmap <Leader>js <Plug>(easymotion-overwin-f2)

" Move to line
map <Leader>jj <Plug>(easymotion-bd-jk)
nmap <Leader>jj <Plug>(easymotion-overwin-line)

" Move to word
map  <Leader>jw <Plug>(easymotion-bd-w)
nmap <Leader>jw <Plug>(easymotion-overwin-w)

highlight EasyMotionTarget guifg=#82aaff
