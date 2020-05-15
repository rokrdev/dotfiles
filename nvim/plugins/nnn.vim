
let g:nnn#layout = { 'window': { 'width': 0.8, 'height': 0.6, 'border': 'rounder', 'highlight': 'Comment' } }

let g:nnn#command = 'nnn -d -e -H'

nnoremap <Leader>n :NnnPicker '%:p:h'<CR>
