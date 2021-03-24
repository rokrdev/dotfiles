local api = vim.api
local map = vim.api.nvim_set_keymap
local g = vim.g

local function t(str)
  return api.nvim_replace_termcodes(str, true, true, true)
end

local opt = {}
local nOpt = { noremap = true }
local nsOpt = { noremap = true, silent = true }
local neOpt = { noremap = true, expr = true }
local nsenOpt = { noremap = true, silent = true, expr = true, nowait = true }

map('n', 's', '<Nop>', opt)
map('x', 's', '<Nop>', opt)
map('v', 's', '<Nop>', opt)

map('n', '<M-d>', ':m .+1<CR>==', nOpt)
map('n', '<M-u>', ':m .-2<CR>==', nOpt)
map('v', '<M-d>', ":m '>+1<CR>gv=gv", nOpt)
map('v', '<M-u>', ":m '<-2<CR>gv=gv", nOpt)
map('n', '<Leader>C', ':e %:p:h/', nOpt)

map('n', 's-', ':bd<CR>', nOpt)
map('n', 's_', ':bd!<CR>', nOpt)
map('n', 'sp', '"+p', nOpt)
map('v', 'sy', '"+y', nOpt)
map('v', 'sp', '"+p', nOpt)
map('n', 's;', ':b#<CR>', nOpt)
map('n', 'sc', ':nohl<CR>', nsOpt)
map('n', 's#', ":let @/='\\<'.expand('<cword>').'\\>'<CR>cgN", nsOpt)
map('x', 's#', '"sy:let @/=@s<CR>cgN', nsOpt)
map('n', 's*', ":let @/='\\<'.expand('<cword>').'\\>'<CR>cgn", nsOpt)
map('x', 's*', '"sy:let @/=@s<CR>cgn', nsOpt)
map('n', 'ss', ':ls<CR>:b<Space>', nOpt)
map('n', 's!', ':let @+=expand("%")<CR>', nOpt)

map('n', '<M-+>', ':vertical resize +5<CR>', nsOpt)
map('n', '<M-=>', ':vertical resize -5<CR>', nsOpt)
map('n', '<M-->', ':resize -5<CR>', nsOpt)
map('n', '<M-_>', ':resize +5<CR>', nsOpt)

map('n', '<Leader>r', ':%s///g<Left><Left><Left>', nOpt)
map('n', '<Leader>rc', ':%s///gc<Left><Left><Left><Left>', nOpt)

map('x', '<Leader>r', ":s///g<Left><Left><Left>", nOpt)
map('x', '<Leader>rc', ":s///gc<Left><Left><Left><Left>", nOpt)

g["@z"] = "f cl<CR><ESC>l"

map('n', '!', g["@z"], nOpt)

function _G.smart_tab()
  return vim.fn.pumvisible() == 1 and t'<C-n>' or t'<Tab>'
end

function _G.smart_shift_tab()
  return vim.fn.pumvisible() == 1 and t'<C-p>' or t'<Tab>'
end

map('n', '<Leader>0', '<cmd>lua require("helpers").toggleNumbers()<CR>', nOpt)
map('n', '<C-e>', ':wincmd w<CR>', nOpt)
map('n', '<M-h>', '<C-w>h', nOpt)
map('n', '<M-j>', '<C-w>j', nOpt)
map('n', '<M-k>', '<C-w>k', nOpt)
map('n', '<M-l>', '<C-w>l', nOpt)
map('i', '<TAB>', 'v:lua.smart_tab()', neOpt)
map('i', '<S-TAB>', 'v:lua.smart_shift_tab()', neOpt)

map('x', '*', "<cmd>lua require('helpers').VSetSearch('/')<CR>/<C-R>=@/<CR><CR>", nOpt)
map('x', '#', "<cmd>lua require('helpers').VSetSearch('?')<CR>?<C-R>=@/<CR><CR>", nOpt)

map('n', '<Leader>*', "<cmd>lua require('helpers').rgWordUnderCursor()<CR>", nOpt)
map('v', '<Leader>*', "<cmd>lua require('helpers').rgVisualSelection()<CR>", nOpt)

map('n', '<Leader><Leader>', ':Buffers<CR>', nOpt)
map('n', '<Leader>o', ":Files<CR>", nOpt)
map('n', '<Leader>f', ":RG<CR>", nOpt)
map('n', '<Leader>F', ":RGRaw ", nOpt)
map('n', '<Leader>/', ":LinesWithPreview<CR>", nOpt)
map('n', '<Leader>G', ":GF?<CR>", nOpt)
map('n', '<Leader>n', "<cmd>lua require('helpers').nnnPicker()<CR>", nOpt)

map('n', 'sh', ":<C-U>call sneak#wrap('', 1, 0, 1, 2)<CR>", opt)
map('n', 'sl', ":<C-U>call sneak#wrap('', 1, 1, 1, 2)<CR>", opt)
map('n', 'sH', ":<C-U>call sneak#wrap('', 1, 0, 0, 2)<CR>", opt)
map('n', 'sL', ":<C-U>call sneak#wrap('', 1, 1, 0, 2)<CR>", opt)
map('n', 'sj', "<Plug>SneakLabel_s", opt)
map('n', 'sk', "<Plug>SneakLabel_S", opt)

map('n', '<Leader>gn', ":Neogit<CR>", nOpt)
-- tig status
map('n', '<Leader>gg', "<cmd>lua require('helpers').openTerm('tig status')<CR>", nOpt)
-- tig a file
map('n', '<Leader>gb', "<cmd>lua require('helpers').openTerm('tig ' .. vim.fn.expand('%'))<CR>", nOpt)
-- tig show unpushed commits
map('n', '<Leader>gl', "<cmd>lua require('helpers').openTerm('tig')<CR>", nOpt)

map('n', 'gb', ":GitMessenger<CR>", nOpt)

map('n', '<Leader>ck', "<Plug>(coc-diagnostic-prev)", opt)
map('n', '<Leader>cj', "<Plug>(coc-diagnostic-next)", opt)
map('n', '<Leader>cd', "<Plug>(coc-definition)", opt)
map('n', '<Leader>cy', "<Plug>(coc-type-definition)", opt)
map('n', '<Leader>ci', "<Plug>(coc-implementation)", opt)
map('n', '<Leader>cr', "<Plug>(coc-references)", opt)
map('n', '<Leader>cs', ":CocSearch<Space>", nOpt)
map('n', '<Leader>cw', ":CocSearch <C-R>=expand('<cword>')<CR><CR>", nOpt)
map('n', '<Leader>cT', ":call coc#float#close_all()<CR>", opt)
map('i', '<C-j>', "<Plug>(coc-snippets-expand-jump)", opt)
map('n', '<C-f>', "coc#float#has_scroll() ? coc#float#scroll(1) : '<C-f>'", nsenOpt)
map('n', '<C-b>', "coc#float#has_scroll() ? coc#float#scroll(0) : '<C-b>'", nsenOpt)

map('n', '<C-k>', ":lprevious<CR>", opt)
map('n', '<C-j>', ":lnext<CR>", opt)
map('n', '<Leader>q-', ":lclose<CR>", opt)
map('n', '<Leader>ql', ":lopen<CR>", opt)

map('n', '<Leader>k', ":cprevious<CR>", opt)
map('n', '<Leader>j', ":cnext<CR>", opt)
map('n', '<Leader>q_', ":cclose<CR>", opt)
map('n', '<Leader>qq', ":copen<CR>", opt)

map('n', '<M-i>', "<cmd>lua require('helpers').show_documentation()<CR>", nsOpt)

map('n', '<Leader>;', "o<ESC>", nOpt)
map('n', '<Leader>:', "O<ESC>", nOpt)

map('n', '<Leader>t', ":NvimTreeToggle<CR>", nOpt)

map('n', '<Leader>ss', ":SS ", nOpt)
map('n', '<Leader>sr', ":SR " .. require('helpers').getSessionFilePath(), nOpt)
map('n', '<Leader>sd', ":!rm " .. require('helpers').getSessionFilePath(), nOpt)
map('n', '<Leader>sc', ":Scratch<CR>", nOpt)

map('n', '<Leader>mp', ":MarkdownPreview<CR>", nOpt)
map('n', '<C-h>', ":BufferLineCyclePrev<CR>", nOpt)
map('n', '<C-l>', ":BufferLineCycleNext<CR>", nOpt)

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
