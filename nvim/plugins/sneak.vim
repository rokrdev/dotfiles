" let g:sneak#label = 1

" case insensitive sneak
let g:sneak#use_ic_scs = 1

" immediately move to the next instance of search, if you move the cursor sneak is back to default behavior
let g:sneak#s_next = 1

" remap so I can use , and ; with f and t
map f <Plug>Sneak_f
map F <Plug>Sneak_F
map t <Plug>Sneak_t
map T <Plug>Sneak_T
map s <Plug>Sneak_s
map S <Plug>Sneak_S
map gS <Plug>Sneak_,
map gs <Plug>Sneak_;

highlight Sneak guifg=black guibg=#ffd494
