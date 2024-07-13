require('keymap.commands').setup()

local set = vim.keymap.set

local map_cmd = function(cmd_string)
  return cmd_string
end

local map_cr = function(cmd_string)
  return (":%s<CR>"):format(cmd_string)
end

local map_args = function(cmd_string)
  return (":%s<Space>"):format(cmd_string)
end

local map_lua = function(cmd_string)
  return ("<cmd>lua %s<CR>"):format(cmd_string)
end

local map_wait = function(cmd_string)
  return (":%s"):format(cmd_string)
end

local map_cu = function(cmd_string)
  return (":<C-u>%s<CR>"):format(cmd_string)
end

local sil = { silent = true }

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

vim.g.mapleader = " "

_G.completion_confirm = function()
  local npairs = require('nvim-autopairs')

  if vim.fn.pumvisible() ~= 0  then
    if vim.fn.complete_info()["selected"] ~= -1 then
      vim.fn["compe#confirm"]()
      return npairs.esc("<c-y>")
    else
      vim.defer_fn(function()
        vim.fn["compe#confirm"]("<cr>")
      end, 20)
      return npairs.esc("<c-n>")
    end
  else
    return npairs.check_break_line_char()
  end
end

_G.vsnip_expand = function()
  if vim.fn.call("vsnip#available", {1}) == 1 then
    return t "<Plug>(vsnip-expand-or-jump)"
  else
    return t "<C-y>"
  end
end

------------- copy/paste ------------------
-- set({'n'}, 'Y', map_cmd("y$"))
-- set({'n', 'v'}, '<leader>ap', map_cmd("\"+p")) -- paste from clipboard
-- set({'v'}, '<leader>ay', map_cmd("\"+y")) -- copy visual selection to clipboard
-- set({'n', 'v'}, '<leader>am', map_cmd("\"mp")) -- paste from m register
-- set({'v'}, '<leader>ac', map_cmd("\"my")) -- copy visual selection to register m

set({'i','s'}, "<C-y>", "v:lua.vsnip_expand()", { expr = true })

local wk = require("which-key")

wk.add({
  { "<leader>b", group = "buffer" },
  { "<leader>b-", ":Scratch<CR>", desc = "Scratch buffer" },
  { "<leader>bD", ":bd!<CR>", desc = "Force delete buffer" },
  { "<leader>bb", "<cmd>lua require('telescope.builtin').buffers()<CR>", desc = "list buffers" },
  { "<leader>bc", ":nohl<CR>", desc = "Clear search" },
  { "<leader>bd", ":bd<CR>", desc = "delete buffer" },
  { "<leader>bl", "<cmd>HopLine<CR>", desc = "Hop Line" },
  { "<leader>bo", ":b#<CR>", desc = "alternate buffer" },
  { "<leader>bs", "<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>", desc = "Search in buffer" },
  { "<leader>bt", "<cmd>lua require('Trailspace').trim()<CR>", desc = "Trim trailing whitespace" },
  { "<leader>d", group = "dotfiles" },
  { "<leader>df", ":Dff<CR>", desc = "Find file in dotfiles" },
  { "<leader>dk", ":Dfc<CR>", desc = "close dotfile buffers" },
  { "<leader>dr", ":Reload<CR>", desc = "Reload nvim" },
  { "<leader>ds", ":Dfs<CR>", desc = "Search in dotfiles" },
  { "<leader>dw", ":Dfg<CR>", desc = "Search word in dotfiles" },
  { "<leader>f", group = "file" },
  { "<leader>ff", "<cmd>lua require('telescope.builtin').find_files({hidden=true})<CR>", desc = "Find file" },
  { "<leader>fn", "<cmd>lua require('keymap.utils').nnnPicker()<CR>", desc = "Open file picker" },
  { "<leader>fp", ":MarkdownPreviewToggle<CR>", desc = "Preview" },
  { "<leader>fs", "<cmd>lua require('telescope.builtin').live_grep()<CR>", desc = "Search in file" },
  { "<leader>ft", ":NvimTreeToggle<CR>", desc = "Open file tree" },
  { "<leader>fw", "<cmd>lua require('telescope.builtin').grep_string()<CR>", desc = "Search string" },
  { "<leader>fy", ":let @+ = expand('%')<CR>", desc = "Yank current file path" },
  { "<leader>g", group = "git" },
  { "<leader>gC", "<cmd>lua require('keymap.custom').git_conflicts({})<CR>", desc = "Conflict files" },
  { "<leader>gL", "<cmd>lua require('keymap.utils').openTerm('tig')<CR>", desc = "Tig log" },
  { "<leader>gb", "<cmd>lua require('telescope.builtin').git_branches()<CR>", desc = "Branches" },
  { "<leader>gc", "<cmd>lua require('telescope.builtin').git_commits()<CR>", desc = "Commits" },
  { "<leader>gf", "<cmd>lua require('keymap.utils').openTerm('tig ' .. vim.fn.expand('%'))<CR>", desc = "Tig file history" },
  { "<leader>gg", "<cmd>lua require('neogit').open()<CR>", desc = "Neogit" },
  { "<leader>gl", "<cmd>lua require('gitsigns').blame_line()<CR>", desc = "Blame line" },
  { "<leader>gt", "<cmd>lua require('keymap.utils').openTerm('tig status')<CR>", desc = "Tig status" },
  { "<leader>l", group = "Lsp" },
  { "<leader>li", ":LspInfo<CR>", desc = "Lsp info" },
  { "<leader>lk", ":LspStop<CR>", desc = "Kill lsp" },
  { "<leader>lr", ":LspRestart<CR>", desc = "Restart lsp" },
  { "<leader>ls", ":LspStart<CR>", desc = "Start lsp" },
  { "<leader>o", group = "others" },
  { "<leader>on", "<cmd>lua require('keymap.utils').toggleNumbers()<CR>", desc = "Cycle number" },
  { "<leader>s", group = "session" },
  { "<leader>sd", ":SD ~/.vim/sessions/_Users_bharat_.dotfiles-", desc = "Delete session" },
  { "<leader>sr", ":SR ~/.vim/sessions/_Users_bharat_.dotfiles-", desc = "Reload session" },
  { "<leader>ss", ":SS<Space>", desc = "Save session" },
  { "<leader>z", group = "lazy" },
  { "<leader>zc", "<cmd>lua require('lazy').health()<CR>", desc = "Check health" },
  { "<leader>zh", "<cmd>lua require('lazy').home()<CR>", desc = "Home" },
  { "<leader>zp", "<cmd>lua require('lazy').profile()<CR>", desc = "Profile" },
  { "<leader>zs", "<cmd>lua require('lazy').sync()<CR>", desc = "Sync" },
  { "<leader>zz", "<cmd>lua require('lazy').sync()<CR>", desc = "Sync" },
})

wk.add({
  { "<leader>f", group = "file", mode = "v" },
  { "<leader>fw", "<cmd>lua require('telescope.builtin').grep_string({search = require('keymap.utils').getVisualSelection()})<CR>", desc = "Search visual selection", mode = "v" },
})

wk.add({
  { "!", "f cl<CR><ESC>l", desc = "Split lines" },
  { "#", "#<Cmd>lua require('hlslens').start()<CR>", desc = "Search word under cursor" },
  { "*", "*<Cmd>lua require('hlslens').start()<CR>", desc = "Search word under cursor" },
  { "<C-S-j>", ":m .+1<CR>==", desc = "Move down line" },
  { "<C-S-k>", ":m .-2<CR>==", desc = "Move up line" },
  { "<C-h>", ":BufferLineCyclePrev<CR>", desc = "Previous buffer" },
  { "<C-l>", ":BufferLineCycleNext<CR>", desc = "Next buffer" },
  { "<M-o>", ":wincmd w<CR>", desc = "Other window" },
  { "F", "<cmd>lua require('keymap.utils').custom_F()<CR>", desc = "F" },
  { "N", "<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>", desc = "Previous" },
  { "T", "<cmd>lua require('keymap.utils').custom_T()<CR>", desc = "T" },
  { "f", "<cmd>lua require('keymap.utils').custom_f()<CR>", desc = "f" },
  { "g#", "g#<Cmd>lua require('hlslens').start()<CR>", desc = "Search word under cursor" },
  { "g*", "g*<Cmd>lua require('hlslens').start()<CR>", desc = "Search word under cursor" },
  { "n", "<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>", desc = "Next" },
  { "s", "<cmd>lua require('hop').hint_words()<CR>", desc = "Hop Word" },
  { "t", "<cmd>lua require('keymap.utils').custom_t()<CR>", desc = "t" },
})

wk.add({
  {
    mode = { "v" },
    { "<C-S-j>", ":m '>+1<CR>gv=gv", desc = "Move down selection" },
    { "<C-S-k>", ":m '<-2<CR>gv=gv", desc = "Move up selection" },
    { "F", "<cmd>lua require('keymap.utils').custom_F()<CR>", desc = "F" },
    { "T", "<cmd>lua require('keymap.utils').custom_T()<CR>", desc = "T" },
    { "f", "<cmd>lua require('keymap.utils').custom_f()<CR>", desc = "f" },
    { "s", "<cmd>lua require('hop').hint_words()<CR>", desc = "Hop Word" },
    { "t", "<cmd>lua require('keymap.utils').custom_t()<CR>", desc = "t" },
  },
})

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- multi-cursor-implementation
vim.cmd([[
let g:mc = "y/\\V\<C-r>=escape(@\", '/')\<CR>\<CR>"

nnoremap cn *``cgn
nnoremap cN *``cgN

vnoremap <expr> cn g:mc . "``cgn"
vnoremap <expr> cN g:mc . "``cgN"

let g:mc = "y/\\V\<C-r>=escape(@\", '/')\<CR>\<CR>"
function! SetupCR()
  nnoremap <Enter> :nnoremap <lt>Enter> n@z<CR>q:<C-u>let @z=strpart(@z,0,strlen(@z)-1)<CR>n@z
endfunction

nnoremap cq :call SetupCR()<CR>*``qz
vnoremap <expr> cq ":\<C-u>call SetupCR()\<CR>" . "gv" . g:mc . "``qz"
]])
