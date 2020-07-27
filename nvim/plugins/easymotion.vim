let g:EasyMotion_smartcase = 1

let g:EasyMotion_keys = 'abcdefghijklmnopqrstuvwxyz'

let g:EasyMotion_prompt = '{n}>>> '

map <Leader>e <Plug>(easymotion-prefix)

"" <Leader>f{char} to move to {char}
nmap sf <Plug>(easymotion-overwin-f)

" s{char}{char} to move to {char}{char}
nmap ss <Plug>(easymotion-overwin-f2)

" Move to line
nmap sj <Plug>(easymotion-overwin-line)

" Move to word
nmap sw <Plug>(easymotion-overwin-w)

highlight EasyMotionTarget guifg=#82aaff
