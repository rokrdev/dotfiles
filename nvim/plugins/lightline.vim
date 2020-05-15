let g:lightline = {
\   'colorscheme': 'nightowl',
\   'mode_map': {
\     'n' : 'N',
\     'i' : 'I',
\     'R' : 'R',
\     'v' : 'V',
\     'V' : 'VL',
\     "\<C-v>": 'VB',
\     'c' : 'C',
\     's' : 'S',
\     'S' : 'SL',
\     "\<C-s>": 'SB',
\     't': 'T',
\   },
\   'active': {
\     'left': [ [ 'mode', 'paste' ],
\               [ 'fugitive', 'filename', 'readonly', 'modified' ],
\              [ 'gitdiff' ] ],
\     'right': [ [ 'lineinfo' ],
\              [ 'percent' ] ],
\   },
\   'inactive': {
\     'left': [ [ 'mode', 'paste' ],
\               [ 'fugitive', 'filename', 'readonly', 'modified' ],
\              [ 'gitdiff' ] ],
\     'right': [ [ 'lineinfo' ],
\              [ 'percent' ] ],
\   },
\   'component_function': {
\     'readonly': 'LightlineReadonly',
\     'fugitive': 'LightlineFugitive',
\   },
\   'tabline': {'left': [['buffers']], 'right':[]},
\   'component_expand': {
\     'buffers': 'lightline#bufferline#buffers',
\     'gitdiff': 'lightline#gitdiff#get',
\   },
\   'component_type': {
\     'buffers': 'tabsel',
\     'gitdiff': 'middle',
\   },
\ }

autocmd BufWritePost,TextChanged,TextChangedI,TermLeave * call lightline#update()
