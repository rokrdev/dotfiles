require('keymap.commands').setup()

local set = vim.keymap.set

local map_cmd = function(cmd_string)
  return cmd_string
end

local map_cr = function(cmd_string)
  return (":%s<CR>"):format(cmd_string)
end

local map_args1 = function(cmd_string)
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

------------- general ------------------
set({'n'}, '<leader>d-', map_cr("bd"), sil)
set({'n'}, '<leader>d_', map_cr("bd!"), sil)
set({'n'}, '<leader>dn', map_lua("require('utils').toggleNumbers()"), sil)
set({'n'}, '<leader>dt', map_cr("Scratch"), sil)
set({'n'}, '!', map_cmd("f cl<CR><ESC>l"), sil)

------------- session ------------------
set({'n'}, '<leader>ds', map_args1("SS"))
set({'n'}, '<leader>dr', map_wait("SR " .. require('utils').getSessionFilePath()))
set({'n'}, '<leader>dd', map_wait("SD " .. require('utils').getSessionFilePath()))

------------- Meta ------------------
set({'n'}, '<M-h>', map_cr("b#"), sil)
set({'n'}, '<M-l>', map_cr("nohl"), sil)
set({'n'}, '<M-Space>', map_args1("ls<CR>:b"))
set({'n'}, '<M-+>', map_cr(":vertical resize +5"), sil)
set({'n'}, '<M-=>', map_cr(":vertical resize -5"), sil)
set({'n'}, '<M-->', map_cr(":resize +5"), sil)
set({'n'}, '<M-_>', map_cr(":resize -5"), sil)
set({'n'}, '<M-y>', map_cr("wincmd w"), sil)
set({'n'}, '<M-b>', map_cr("wincmd ="), sil)

------------- git ------------------
set({'n'}, '<leader>gt', map_lua("require('utils').openTerm('tig status')"), sil)
set({'n'}, '<leader>gf', map_lua("require('utils').openTerm('tig ' .. vim.fn.expand('%'))"), sil)
set({'n'}, '<leader>gL', map_lua("require('utils').openTerm('tig')"), sil)
set({'n'}, '<leader>gl', map_lua("require('gitsigns').blame_line()"))
set({'n'}, '<leader>gg', map_cr("Neogit"), sil)
set({'n'}, '<leader>gc', map_lua("require('keymap.custom').git_conflicts({})"))

------------- copy/paste ------------------
set({'n'}, '<leader>gt', map_lua("require('utils').openTerm('tig status')"), sil)
set({'n'}, 'Y', map_cmd("y$"))
set({'n', 'v'}, '<leader>ap', map_cmd("\"+p")) -- paste from clipboard
set({'v'}, '<leader>ay', map_cmd("\"+y")) -- copy visual selection to clipboard
set({'n'}, '<leader>af', map_cr("let @+ = expand('%')")) -- yank current file path
set({'n', 'v'}, '<leader>am', map_cmd("\"mp")) -- paste from m register
set({'v'}, '<leader>ac', map_cmd("\"my")) -- copy visual selection to register m

------------- Vimwiki ------------------
set({'n'}, '<leader>wc', map_cr("bufdo if expand('%:p') =~ '/vimwiki/' | bd | endif"), sil)
set({'n'}, '<leader>ww', map_cr("VimwikiIndex"), sil)
set({'n'}, '<leader>wf', map_cr("Vwf"), sil)
set({'n'}, '<leader>wl', map_cr("Vws"), sil)
set({'n'}, '<leader>wg', map_cr("Vwg"), sil)

------------- Dotfiles ------------------
set({'n'}, '<leader>hf', map_cr("Dff"), sil)
set({'n'}, '<leader>hs', map_cr("Dfs"), sil)
set({'n'}, '<leader>hw', map_cr("Dfg"), sil)
set({'n'}, '<leader>hr', map_cr("so $MYVIMRC"), sil)

------------- telescope ------------------
set({'n'}, '<leader>ff', map_lua("require('telescope.builtin').find_files({hidden=true})"))
set({'n'}, '<leader>fs', map_lua("require('telescope.builtin').live_grep()"))
set({'n'}, '<leader>fw', map_lua("require('telescope.builtin').grep_string()"))
set({'n'}, '<leader>fc', map_lua("require('telescope.builtin').current_buffer_fuzzy_find()"))
set({'n'}, '<leader>b', map_lua("require('telescope.builtin').buffers()"))
set({'n'}, '<leader>fn', map_lua("require('utils').nnnPicker()"))
set({'n'}, '<leader>ft', map_cr("NvimTreeToggle"), sil)
set({'n'}, '<leader>fr', "<Plug>(Scalpel)")

set({'v'}, '<leader>fw', map_lua("require('telescope.builtin').grep_string({search = require('utils').getVisualSelection()})"), sil)
set({'v'}, '<leader>fr', "<Plug>(ScalpelVisual)")

------------- LSP ------------------
set({'n'}, '<leader>ls', map_cr("LspStart"), sil)
set({'n'}, '<leader>le', map_cr("LspStop"), sil)
set({'n'}, '<leader>lr', map_cr("LspRestart"), sil)
set({'n'}, '<leader>li', map_cr("LspInfo"), sil)

------------- bufferline ------------------
set({'n'}, '<C-k>', map_cr("BufferLineCyclePrev"), sil)
set({'n'}, '<C-j>', map_cr("BufferLineCycleNext"), sil)


vim.cmd([[
  imap <expr> <C-y>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-y>'
  smap <expr> <C-y>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-y>'

  noremap <silent> n <Cmd>execute('normal! ' . v:count1 . 'n')<CR>
            \<Cmd>lua require('hlslens').start()<CR>

  noremap <silent> N <Cmd>execute('normal! ' . v:count1 . 'N')<CR>
              \<Cmd>lua require('hlslens').start()<CR>

  noremap * *<Cmd>lua require('hlslens').start()<CR>
  noremap # #<Cmd>lua require('hlslens').start()<CR>
  noremap g* g*<Cmd>lua require('hlslens').start()<CR>
  noremap g# g#<Cmd>lua require('hlslens').start()<CR>
]])

