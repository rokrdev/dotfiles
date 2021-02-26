local api = vim.api
local g = vim.g

local function t(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

api.nvim_set_keymap('n', 's', '<Nop>', {})
api.nvim_set_keymap('x', 's', '<Nop>', {})
api.nvim_set_keymap('v', 's', '<Nop>', {})

api.nvim_set_keymap('n', '<M-d>', ':m .+1<CR>==', { noremap = true })
api.nvim_set_keymap('n', '<M-u>', ':m .-2<CR>==', { noremap = true })
api.nvim_set_keymap('v', '<M-d>', ":m '>+1<CR>gv=gv", { noremap = true })
api.nvim_set_keymap('v', '<M-u>', ":m '<-2<CR>gv=gv", { noremap = true })
api.nvim_set_keymap('n', '<Leader>C', ':e %:p:h/', { noremap = true })

api.nvim_set_keymap('n', 's-', ':bd<CR>', { noremap = true })
api.nvim_set_keymap('n', 's_', ':bd!<CR>', { noremap = true })
api.nvim_set_keymap('n', 'sp', '"+p', { noremap = true })
api.nvim_set_keymap('v', 'sy', '"+y', { noremap = true })
api.nvim_set_keymap('v', 'sp', '"+p', { noremap = true })
api.nvim_set_keymap('n', 'sh', ':b#<CR>', { noremap = true })
api.nvim_set_keymap('n', 'sc', ':nohl<CR>', { noremap = true, silent = true })
api.nvim_set_keymap('n', 's#', ":let @/='\\<'.expand('<cword>').'\\>'<CR>cgN", { noremap = true, silent = true })
api.nvim_set_keymap('x', 's#', '"sy:let @/=@s<CR>cgN', { noremap = true, silent = true })
api.nvim_set_keymap('n', 's*', ":let @/='\\<'.expand('<cword>').'\\>'<CR>cgn", { noremap = true, silent = true })
api.nvim_set_keymap('x', 's*', '"sy:let @/=@s<CR>cgn', { noremap = true, silent = true })
-- api.nvim_set_keymap('n', 'ss', ':ls<CR>:b<Space>', { noremap = true })

api.nvim_set_keymap('n', '<M-+>', ':vertical resize +5<CR>', { noremap = true, silent = true })
api.nvim_set_keymap('n', '<M-=>', ':vertical resize -5<CR>', { noremap = true, silent = true })
api.nvim_set_keymap('n', '<M-->', ':resize -5<CR>', { noremap = true, silent = true })
api.nvim_set_keymap('n', '<M-_>', ':resize +5<CR>', { noremap = true, silent = true })

api.nvim_set_keymap('n', '<Leader>r', ':%s///g<Left><Left><Left>', { noremap = true })
api.nvim_set_keymap('n', '<Leader>rc', ':%s///gc<Left><Left><Left><Left>', { noremap = true })

g["@z"] = "f cl<CR><ESC>l"

api.nvim_set_keymap('n', '!', g["@z"], { noremap = true })

function _G.smart_tab()
  return vim.fn.pumvisible() == 1 and t'<C-n>' or t'<Tab>'
end

function _G.smart_shift_tab()
  return vim.fn.pumvisible() == 1 and t'<C-p>' or t'<Tab>'
end

api.nvim_set_keymap('n', '<Leader>0', '<cmd>lua require("helpers").toggleNumbers()<CR>', { noremap = true })
api.nvim_set_keymap('n', '<C-e>', ':wincmd w<CR>', { noremap = true })
api.nvim_set_keymap('n', '<M-h>', '<C-w>h', { noremap = true })
api.nvim_set_keymap('n', '<M-j>', '<C-w>j', { noremap = true })
api.nvim_set_keymap('n', '<M-k>', '<C-w>k', { noremap = true })
api.nvim_set_keymap('n', '<M-l>', '<C-w>l', { noremap = true })
api.nvim_set_keymap('i', '<TAB>', 'v:lua.smart_tab()', { noremap = true, expr = true })
api.nvim_set_keymap('i', '<S-TAB>', 'v:lua.smart_shift_tab()', { noremap = true, expr = true })

api.nvim_set_keymap('x', '*', "<cmd>lua require('helpers').VSetSearch('/')<CR>/<C-R>=@/<CR><CR>", { noremap = true })
api.nvim_set_keymap('x', '#', "<cmd>lua require('helpers').VSetSearch('?')<CR>?<C-R>=@/<CR><CR>", { noremap = true })

api.nvim_set_keymap('n', '<Leader>*', "<cmd>lua require('helpers').rgWordUnderCursor()<CR>", { noremap = true })
api.nvim_set_keymap('v', '<Leader>*', "<cmd>lua require('helpers').rgVisualSelection()<CR>", { noremap = true })

api.nvim_set_keymap('n', '<Leader>b', ':Buffers<CR>', { noremap = true })
api.nvim_set_keymap('n', '<Leader>o', ":Files<CR>", { noremap = true })
api.nvim_set_keymap('n', '<Leader>f', ":RG<CR>", { noremap = true })
api.nvim_set_keymap('n', '<Leader>F', ":RGRaw ", { noremap = true })
api.nvim_set_keymap('n', '<Leader>/', ":LinesWithPreview<CR>", { noremap = true })
api.nvim_set_keymap('n', '<Leader>G', ":GF?<CR>", { noremap = true })
api.nvim_set_keymap('n', '<Leader>n', "<cmd>lua require('helpers').nnnPicker()<CR>", { noremap = true })

api.nvim_set_keymap('n', 'f', ":<C-U>call sneak#wrap('', 1, 0, 1, 1)<CR>", {})
api.nvim_set_keymap('n', 'F', ":<C-U>call sneak#wrap('', 1, 1, 1, 1)<CR>", {})
api.nvim_set_keymap('n', 't', ":<C-U>call sneak#wrap('', 1, 0, 0, 1)<CR>", {})
api.nvim_set_keymap('n', 'T', ":<C-U>call sneak#wrap('', 1, 1, 0, 1)<CR>", {})
api.nvim_set_keymap('n', 'sj', "<Plug>SneakLabel_s", {})
api.nvim_set_keymap('n', 'sk', "<Plug>SneakLabel_S", {})

api.nvim_set_keymap('n', '<Leader>gg', "<cmd>lua require('helpers').openTerm('tig status')<CR>", { noremap = true })
-- tig a file
api.nvim_set_keymap('n', '<Leader>gb', "<cmd>lua require('helpers').openTerm('tig ' .. vim.fn.expand('%'))<CR>", { noremap = true })
-- tig show unpushed commits
api.nvim_set_keymap('n', '<Leader>gl', "<cmd>lua require('helpers').openTerm('tig')<CR>", { noremap = true })

api.nvim_set_keymap('n', 'gb', ":GitMessenger<CR>", { noremap = true })

api.nvim_set_keymap('n', '<Leader>ck', "<Plug>(coc-diagnostic-prev)", {})
api.nvim_set_keymap('n', '<Leader>cj', "<Plug>(coc-diagnostic-next)", {})
api.nvim_set_keymap('n', '<Leader>cd', "<Plug>(coc-definition)", {})
api.nvim_set_keymap('n', '<Leader>cy', "<Plug>(coc-type-definition)", {})
api.nvim_set_keymap('n', '<Leader>ci', "<Plug>(coc-implementation)", {})
api.nvim_set_keymap('n', '<Leader>cr', "<Plug>(coc-references)", {})
api.nvim_set_keymap('n', '<Leader>cs', ":CocSearch<Space>", { noremap = true })
api.nvim_set_keymap('n', '<Leader>cw', ":CocSearch <C-R>=expand('<cword>')<CR><CR>", { noremap = true })
api.nvim_set_keymap('n', '<Leader>cT', ":call coc#float#close_all()<CR>", {})
api.nvim_set_keymap('i', '<C-j>', "<Plug>(coc-snippets-expand-jump)", {})
api.nvim_set_keymap('n', '<C-f>', "coc#float#has_scroll() ? coc#float#scroll(1) : '<C-f>'", { silent = true, noremap = true, expr = true, nowait = true })
api.nvim_set_keymap('n', '<C-b>', "coc#float#has_scroll() ? coc#float#scroll(0) : '<C-b>'", { silent = true, noremap = true, expr = true, nowait = true })

api.nvim_set_keymap('n', '<M-i>', "<cmd>lua require('helpers').show_documentation()<CR>", { noremap = true, silent = true })

api.nvim_set_keymap('n', '<Leader>;', "o<ESC>", { noremap = true })
api.nvim_set_keymap('n', '<Leader>:', "O<ESC>", { noremap = true })

api.nvim_set_keymap('n', '<Leader>t', ":NvimTreeToggle<CR>", { noremap = true })

api.nvim_set_keymap('n', '<Leader>ss', ":SS ", { noremap = true })
api.nvim_set_keymap('n', '<Leader>sr', ":SR " .. require('helpers').getSessionFilePath(), { noremap = true })
api.nvim_set_keymap('n', '<Leader>sd', ":!rm " .. require('helpers').getSessionFilePath(), { noremap = true })
api.nvim_set_keymap('n', '<Leader>sc', ":Scratch<CR>", { noremap = true })

g.VM_leader = '\\'
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

g["nvim_tree_bindings"] = {
  ["preview"] = '<C-TAB>',
  ["edit_tab"] = '<C-TAB>',
}
