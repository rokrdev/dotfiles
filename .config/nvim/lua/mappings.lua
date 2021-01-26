local api = vim.api
local cmd = vim.cmd
local g = vim.g

local function t(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end


api.nvim_set_keymap('n', '<C-down>', ':m .+1<CR>==', { noremap = true })
api.nvim_set_keymap('n', '<C-up>', ':m .-2<CR>==', { noremap = true })
api.nvim_set_keymap('v', '<C-down>', ':m .+1<CR>==', { noremap = true })
api.nvim_set_keymap('v', '<C-up>', ':m .-2<CR>==', { noremap = true })
api.nvim_set_keymap('n', '<Leader>C', ':e %:p:h/', { noremap = true })
api.nvim_set_keymap('n', 's-', ':bd<CR>', { noremap = true })
api.nvim_set_keymap('n', 's_', ':bd!<CR>', { noremap = true })
api.nvim_set_keymap('n', 'sy', '"+y', { noremap = true })
api.nvim_set_keymap('n', 'sp', '"+p', { noremap = true })
api.nvim_set_keymap('n', 'gh', ':b#<CR>', { noremap = true })
api.nvim_set_keymap('n', 'ss', ':Buffers<CR>', { noremap = true })

api.nvim_set_keymap('n', 's', '<Nop>', {})
api.nvim_set_keymap('x', 's', '<Nop>', {})

api.nvim_set_keymap('n', '<ESC><ESC>', ':nohl<CR>', { noremap = true, silent = true })

api.nvim_set_keymap('n', '<A-a>', ':vertical resize +5<CR>', { noremap = true, silent = true })
api.nvim_set_keymap('n', '<A-d>', ':vertical resize -5<CR>', { noremap = true, silent = true })
api.nvim_set_keymap('n', '<A-w>', ':resize +5<CR>', { noremap = true, silent = true })
api.nvim_set_keymap('n', '<A-s>', ':resize -5<CR>', { noremap = true, silent = true })

api.nvim_set_keymap('n', '<Leader>r', ':%s///g<Left><Left><Left>', { noremap = true })
api.nvim_set_keymap('n', '<Leader>rc', ':%s///gc<Left><Left><Left><Left>', { noremap = true })
api.nvim_set_keymap('n', 's#', ":let @/='\\<'.expand('<cword>').'\\>'<CR>cgN", { noremap = true, silent = true })
api.nvim_set_keymap('x', 's#', '"sy:let @/=@s<CR>cgN', { noremap = true, silent = true })
api.nvim_set_keymap('n', 's*', ":let @/='\\<'.expand('<cword>').'\\>'<CR>cgn", { noremap = true, silent = true })
api.nvim_set_keymap('x', 's*', '"sy:let @/=@s<CR>cgn', { noremap = true, silent = true })

g["@z"] = "f cl<CR><ESC>l"

api.nvim_set_keymap('n', '!', g["@z"], { noremap = true })

function _G.smart_tab()
    return vim.fn.pumvisible() == 1 and t'<C-n>' or t'<Tab>'
end

function _G.smart_shift_tab()
    return vim.fn.pumvisible() == 1 and t'<C-p>' or t'<Tab>'
end

api.nvim_set_keymap('n', '<Leader>0', 'custom#ToggleNumberDisplay', { noremap = true, expr = true })
api.nvim_set_keymap('i', '<TAB>', 'v:lua.smart_tab()', { noremap = true, expr = true })
api.nvim_set_keymap('i', '<S-TAB>', 'v:lua.smart_shift_tab()', { noremap = true, expr = true })

api.nvim_set_keymap('n', '#', ":let @/='\\V\\<'.custom#EscapeSlashes(expand('<cword>')).'\\>'<CR>:let v:searchforward=0<CR>n", { noremap = true, silent = true })
api.nvim_set_keymap('n', '*', ":let @/='\\V\\<'.custom#EscapeSlashes(expand('<cword>')).'\\>'<CR>:let v:searchforward=1<CR>n", { noremap = true, silent = true })
api.nvim_set_keymap('n', 'g#', ":let @/='\\V'.custom#EscapeSlashes(expand('<cword>'))<CR>:let v:searchforward=0<CR>n", { noremap = true, silent = true })
api.nvim_set_keymap('n', 'g*', ":let @/='\\V'.custom#EscapeSlashes(expand('<cword>'))<CR>:let v:searchforward=1<CR>n", { noremap = true, silent = true })
api.nvim_set_keymap('x', '*', ":<C-u>call custom#VSetSearch('/')<CR>/<C-R>=@/<CR><CR>", { noremap = true })
api.nvim_set_keymap('x', '*', ":<C-u>call custom#VSetSearch('?')<CR>?<C-R>=@/<CR><CR>", { noremap = true })

api.nvim_set_keymap('n', '<Leader>*', ":call custom#RgWordUnderCursor()<CR>", { noremap = true })
api.nvim_set_keymap('v', '<Leader>*', ":call custom#RgRawVisualSelection()<CR>", { noremap = true })

api.nvim_set_keymap('n', '<Leader>o', ":Files<CR>", { noremap = true })
api.nvim_set_keymap('n', '<Leader>f', ":RG<CR>", { noremap = true })
api.nvim_set_keymap('n', '<Leader>F', ":RGRaw<CR>", { noremap = true })
api.nvim_set_keymap('n', '<Leader>/', ":LinesWithPreview<CR>", { noremap = true })
api.nvim_set_keymap('n', '<Leader>G', ":GF?<CR>", { noremap = true })
api.nvim_set_keymap('n', '<Leader>co', ":Commands<CR>", { noremap = true })
api.nvim_set_keymap('n', '<Leader>cc', ":BCommits<CR>", { noremap = true })
api.nvim_set_keymap('n', '<Leader>n', ":Vifm<CR>", { noremap = true })

api.nvim_set_keymap('n', 'f', "<Plug>Sneak_f", {})
api.nvim_set_keymap('n', 'F', "<Plug>Sneak_F", {})
api.nvim_set_keymap('n', 't', "<Plug>Sneak_t", {})
api.nvim_set_keymap('n', 'T', "<Plug>Sneak_T", {})
api.nvim_set_keymap('v', 'f', "<Plug>Sneak_f", {})
api.nvim_set_keymap('v', 'F', "<Plug>Sneak_F", {})
api.nvim_set_keymap('v', 't', "<Plug>Sneak_t", {})
api.nvim_set_keymap('v', 'T', "<Plug>Sneak_T", {})
api.nvim_set_keymap('n', 'sj', "<Plug>SneakLabel_s", {})
api.nvim_set_keymap('n', 'sk', "<Plug>SneakLabel_S", {})

api.nvim_set_keymap('n', '<Leader>S', ":Scratch<CR>", { noremap = true })
api.nvim_set_keymap('n', '<Leader>gg', ":call custom#OpenTerm('tig status')<CR>", { noremap = true })
-- tig a file
api.nvim_set_keymap('n', '<Leader>gb', ":call custom#OpenTerm('tig ' . expand('%'))<CR>", { noremap = true })
-- tig show unpushed commits
api.nvim_set_keymap('n', '<Leader>gu', ":call custom#OpenTerm('tig log @{u}.. -p')<CR>", { noremap = true })

api.nvim_set_keymap('n', 'gb', ":GitMessenger<CR>", { noremap = true })

api.nvim_set_keymap('n', '<Leader>ck', "<Plug>(coc-diagnostic-prev)", {})
api.nvim_set_keymap('n', '<Leader>cj', "<Plug>(coc-diagnostic-next)", {})
api.nvim_set_keymap('n', '<Leader>cd', "<Plug>(coc-definition)", {})
api.nvim_set_keymap('n', '<Leader>cy', "<Plug>(coc-type-definition)", {})
api.nvim_set_keymap('n', '<Leader>ci', "<Plug>(coc-implementation)", {})
api.nvim_set_keymap('n', '<Leader>cr', "<Plug>(coc-references)", {})

api.nvim_set_keymap('n', '<Leader>cs', ":CocSearch<Space>", { noremap = true })
api.nvim_set_keymap('n', '<Leader>cw', ":CocSearch <C-R>=expand('<cword>')<CR><CR>", { noremap = true })

api.nvim_set_keymap('i', '<C-f>', "<Plug>(coc-snippets-expand-jump)", {})
api.nvim_set_keymap('n', '<Leader>ct', ":CocCommand explorer<CR>", {})
api.nvim_set_keymap('n', '<Leader>cT', ":call coc#float#close_all()<CR>", {})

api.nvim_set_keymap('n', 'K', ":call custom#show_documentation()<CR>", { noremap = true, silent = true })
api.nvim_set_keymap('n', '<Leader>;', "o<ESC>", { noremap = true })
api.nvim_set_keymap('n', '<Leader>:', "O<ESC>", { noremap = true })

g.VM_maps = {
    -- replace C-n
    ['Find Under'] = '<C-n>',
     -- replace visual C-n
    ['Find Subword Under'] = '<C-n>',
    ["Add Cursor Down"] = '<M-Down>',
    ["Add Cursor Up"] = '<M-Up>',
    --  start selecting down
    ["Select Cursor Down"] = '<M-C-Down>',
    -- start selecting up
    ["Select Cursor Up"] = '<M-C-Up>'
}

