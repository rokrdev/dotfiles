
let g:loaded_matchit = 1
let g:matchup_matchparen_deferred = 1
let g:matchup_matchparen_deferred_show_delay = 50
let g:matchup_matchparen_deferred_hide_delay = 700
let g:matchup_matchpref = {
    \ 'html': { 'tagnameonly': 1, },
    \ 'vue':  { 'tagnameonly': 1, },
    \}

highlight MatchParen guibg=#011627 guifg=#7fdbca gui=underline
