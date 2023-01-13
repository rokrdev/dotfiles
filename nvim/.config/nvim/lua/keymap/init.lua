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

wk.register({
  b = {
    name = "buffer",
    c = { map_cr("nohl"), "Clear search" },
    d = { map_cr("bd"), "delete buffer" },
    D = { map_cr("bd!"), "Force delete buffer" },
    -- l = { map_args("ls<CR>:b"), "list buffers"},
    l = { "<cmd>HopLine<CR>", "Hop Line"},
    o = { map_cr("b#"), "alternate buffer"},
    r = { "<Plug>(Scalpel)", "Replace in file"},
    s = { map_lua("require('telescope.builtin').current_buffer_fuzzy_find()"), "Search in buffer"},
    t = { map_lua("require('Trailspace').trim()"), "Trim trailing whitespace" },
    ['-'] = { map_cr("Scratch"), "Scratch buffer" },
  },
  d = {
    name = "dotfiles",
    f = { map_cr("Dff"), "Find file in dotfiles" },
    k = { map_cr("Dfc"), "close dotfile buffers" },
    r = { map_cr("Reload"), "Reload nvim" },
    s = { map_cr("Dfs"), "Search in dotfiles" },
    w = { map_cr("Dfg"), "Search word in dotfiles" },
  },
  f = {
    name = "file",
    f = { map_lua("require('telescope.builtin').find_files({hidden=true})"), "Find file"},
    n = { map_lua("require('keymap.utils').nnnPicker()"), "Open file picker"},
    p = { map_cr("MarkdownPreviewToggle"), "Preview" },
    s = { map_lua("require('telescope.builtin').live_grep()"), "Search in file"},
    t = { map_cr("NvimTreeToggle"), "Open file tree"},
    w = { map_lua("require('telescope.builtin').grep_string()"), "Search string"},
    y = { map_cr("let @+ = expand('%')"), "Yank current file path" }, -- yank current file path
  },
  g = {
    name = "git",
    b = { map_lua("require('telescope.builtin').git_branches()"), "Branches" },
    c = { map_lua("require('telescope.builtin').git_commits()"), "Commits" },
    C = { map_lua("require('keymap.custom').git_conflicts({})"), "Conflict files" },
    f = { map_lua("require('keymap.utils').openTerm('tig ' .. vim.fn.expand('%'))"), "Tig file history" },
    g = { map_cr("Neogit"), "Neogit" },
    l = { map_lua("require('gitsigns').blame_line()"), "Blame line" },
    L = { map_lua("require('keymap.utils').openTerm('tig')"), "Tig log" },
    t = { map_lua("require('keymap.utils').openTerm('tig status')"), "Tig status" },
  },
  l = {
    name = "Lsp",
    i = { map_cr("LspInfo"), "Lsp info"},
    k = { map_cr("LspStop"), "Kill lsp"},
    r = { map_cr("LspRestart"), "Restart lsp"},
    s = { map_cr("LspStart"), "Start lsp"},
  },
  s = {
    name = "session",
    d = { map_wait("SD " .. require('keymap.utils').getSessionFilePath()), "Delete session" },
    r = { map_wait("SR " .. require('keymap.utils').getSessionFilePath()), "Reload session" },
    s = { map_args("SS"), "Save session" },
  },
  o = {
    name = "others",
    n = { map_lua("require('keymap.utils').toggleNumbers()"), "Cycle number" },
  },
  ["<space>"] = { map_lua("require('telescope.builtin').buffers()"), "list buffers" },
}, { prefix = "<leader>" })

wk.register({
  f = {
    name = "file",
    r = { "<Plug>(ScalpelVisual)", "Replace in file"},
    w = { map_lua("require('telescope.builtin').grep_string({search = require('keymap.utils').getVisualSelection()})"), "Search visual selection"},
  },
}, { mode = "v", prefix = "<leader>" })

wk.register({
  ["<M-o>"] = { map_cr("wincmd w"), "Other window" },
  ["<C-h>"] = { map_cr("BufferLineCyclePrev"), "Previous buffer" },
  ["<C-l>"] = { map_cr("BufferLineCycleNext"), "Next buffer" },
  ["!"] = { map_cmd("f cl<CR><ESC>l"), "Split lines" },
  ["<C-S-j>"] = { ":m .+1<CR>==", "Move down line" },
  ["<C-S-k>"] = { ":m .-2<CR>==", "Move up line" },
  ["f"] = { "<cmd>lua require('keymap.utils').custom_f()<CR>", "f"},
  ["F"] = { "<cmd>lua require('keymap.utils').custom_F()<CR>", "F"},
  ["t"] = { "<cmd>lua require('keymap.utils').custom_t()<CR>", "t"},
  ["T"] = { "<cmd>lua require('keymap.utils').custom_T()<CR>", "T"},
  ["s"] = { "<cmd>lua require('hop').hint_words()<CR>", "Hop Word"},
  n = { [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]], "Next" },
  N = { [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]], "Previous" },
  ["*"] = { [[*<Cmd>lua require('hlslens').start()<CR>]], "Search word under cursor" },
  ["#"] = { [[#<Cmd>lua require('hlslens').start()<CR>]], "Search word under cursor" },
  ["g*"] = { [[g*<Cmd>lua require('hlslens').start()<CR>]], "Search word under cursor" },
  ["g#"] = { [[g#<Cmd>lua require('hlslens').start()<CR>]], "Search word under cursor" },
}, { mode = "n" })

wk.register({
  ["<C-S-j>"] = { ":m '>+1<CR>gv=gv", "Move down selection" },
  ["<C-S-k>"] = { ":m '<-2<CR>gv=gv", "Move up selection" },
  ["f"] = { "<cmd>lua require('keymap.utils').custom_f()<CR>", "f"},
  ["F"] = { "<cmd>lua require('keymap.utils').custom_F()<CR>", "F"},
  ["t"] = { "<cmd>lua require('keymap.utils').custom_t()<CR>", "t"},
  ["T"] = { "<cmd>lua require('keymap.utils').custom_T()<CR>", "T"},
  ["s"] = { "<cmd>lua require('hop').hint_words()<CR>", "Hop Word"},
}, { mode = "v" })

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
