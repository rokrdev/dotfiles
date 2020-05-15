
let g:UltiSnipsExpandTrigger="<C-f>"
let g:UltiSnipsEditSplit="vertical"

inoremap <silent> <expr> <C-]> utils#manualTagComplete()
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
