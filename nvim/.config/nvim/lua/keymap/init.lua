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
set({'n'}, '<leader>ds', map_cr("Scratch"), sil)
set({'n'}, '<leader>dv', map_cr("FocusSplitRight"), sil)
set({'n'}, '<leader>dh', map_cr("FocusSplitDown"), sil)
set({'n'}, '<leader>du', map_cr("on"), sil)
set({'n'}, '!', map_cmd("f cl<CR><ESC>l"), sil)

------------- session ------------------
set({'n'}, '<leader>ss', map_args("SS"))
set({'n'}, '<leader>sr', map_wait("SR " .. require('utils').getSessionFilePath()))
set({'n'}, '<leader>sd', map_wait("SD " .. require('utils').getSessionFilePath()))

------------- Meta ------------------
set({'n'}, '<M-;>', map_cr("b#"), sil)
set({'n'}, '<leader>c', map_cr("nohl"), sil)
set({'n'}, '<leader>l', map_args("ls<CR>:b"))
set({'n'}, '<M-+>', map_cr(":vertical resize +5"), sil)
set({'n'}, '<M-=>', map_cr(":vertical resize -5"), sil)
set({'n'}, '<M-->', map_cr(":resize +5"), sil)
set({'n'}, '<M-_>', map_cr(":resize -5"), sil)
set({'n'}, '<M-Space>', map_cr("wincmd w"), sil)
set({'n'}, '<M-b>', map_cr("wincmd ="), sil)

------------- git ------------------
set({'n'}, '<leader>gt', map_lua("require('utils').openTerm('tig status')"), sil)
set({'n'}, '<leader>gf', map_lua("require('utils').openTerm('tig ' .. vim.fn.expand('%'))"), sil)
set({'n'}, '<leader>gL', map_lua("require('utils').openTerm('tig')"), sil)
set({'n'}, '<leader>gl', map_lua("require('gitsigns').blame_line()"))
set({'n'}, '<leader>gg', map_cr("Neogit"), sil)
set({'n'}, '<leader>gc', map_lua("require('keymap.custom').git_conflicts({})"))
set({'n'}, '<leader>gB', map_lua("require('telescope.builtin').git_branches()"))
set({'n'}, '<leader>gC', map_lua("require('telescope.builtin').bcommits()"))

------------- copy/paste ------------------
-- set({'n'}, 'Y', map_cmd("y$"))
-- set({'n', 'v'}, '<leader>ap', map_cmd("\"+p")) -- paste from clipboard
-- set({'v'}, '<leader>ay', map_cmd("\"+y")) -- copy visual selection to clipboard
set({'n'}, '<leader>fp', map_cr("let @+ = expand('%')")) -- yank current file path
-- set({'n', 'v'}, '<leader>am', map_cmd("\"mp")) -- paste from m register
-- set({'v'}, '<leader>ac', map_cmd("\"my")) -- copy visual selection to register m

------------- Dotfiles ------------------
set({'n'}, '<leader>hc', map_cr("Dfc"), sil)
set({'n'}, '<leader>hf', map_cr("Dff"), sil)
set({'n'}, '<leader>hs', map_cr("Dfs"), sil)
set({'n'}, '<leader>hw', map_cr("Dfg"), sil)
set({'n'}, '<leader>hr', map_cr("Reload"), sil)

------------- telescope ------------------
set({'n'}, '<leader>ff', map_lua("require('telescope.builtin').find_files({hidden=true})"))
set({'n'}, '<leader>fs', map_lua("require('telescope.builtin').live_grep()"))
set({'n'}, '<leader>fw', map_lua("require('telescope.builtin').grep_string()"))
set({'n'}, '<leader>fc', map_lua("require('telescope.builtin').current_buffer_fuzzy_find()"))
set({'n'}, '<leader>b', map_lua("require('telescope.builtin').buffers()"))
set({'n'}, '<leader>fn', map_lua("require('utils').nnnPicker()"))
set({'n'}, '<leader>ft', map_cr("NvimTreeToggle"), sil)
set({'n'}, '<leader>fr', "<Plug>(Scalpel)")
set({'n'}, '<leader>r', map_cr("Telescope registers"), sil)

set({'v'}, '<leader>fw', map_lua("require('telescope.builtin').grep_string({search = require('utils').getVisualSelection()})"), sil)
set({'v'}, '<leader>fr', "<Plug>(ScalpelVisual)")

------------- LSP ------------------
set({'n'}, '<leader>ls', map_cr("LspStart"), sil)
set({'n'}, '<leader>le', map_cr("LspStop"), sil)
set({'n'}, '<leader>lr', map_cr("LspRestart"), sil)
set({'n'}, '<leader>li', map_cr("LspInfo"), sil)

------------- bufferline ------------------
set({'n'}, '<M-.>', map_cr("bprev"), sil)
set({'n'}, '<M-,>', map_cr("bnext"), sil)

------------- move lines ------------------
set({'n'}, '<C-S-j>', ":m .+1<CR>==", sil)
set({'n'}, '<C-S-k>', ":m .-2<CR>==", sil)
set({'v'}, '<C-S-j>', ":m '>+1<CR>gv=gv", sil)
set({'v'}, '<C-S-k>', ":m '<-2<CR>gv=gv", sil)

------------- leap ------------------
set({'n'}, 's', map_lua("require'leap'.leap { ['target-windows'] = { vim.api.nvim_get_current_win() } }"))
set({'v'}, 'z', map_lua("require'leap'.leap { ['target-windows'] = { vim.api.nvim_get_current_win() } }"))

------------- zettelkasten ------------------
set({'n'}, '<leader>zf', map_lua("require('telekasten').find_notes()"), sil)
set({'n'}, '<leader>zd', map_lua("require('telekasten').find_daily_notes()"), sil)
set({'n'}, '<leader>zg', map_lua("require('telekasten').search_notes()"), sil)
set({'n'}, '<leader>zz', map_lua("require('telekasten').follow_link()"), sil)
set({'n'}, '<leader>zT', map_lua("require('telekasten').goto_today()"), sil)
set({'n'}, '<leader>zW', map_lua("require('telekasten').goto_thisweek()"), sil)
set({'n'}, '<leader>zw', map_lua("require('telekasten').find_weekly_notes()"), sil)
set({'n'}, '<leader>zn', map_lua("require('telekasten').new_note()"), sil)
set({'n'}, '<leader>zN', map_lua("require('telekasten').new_templated_note()"), sil)
set({'n'}, '<leader>zy', map_lua("require('telekasten').yank_notelink()"), sil)
set({'n'}, '<leader>zc', map_lua("require('telekasten').show_calendar()"), sil)
set({'n'}, '<leader>zC', ":CalendarT", sil)
set({'n'}, '<leader>zi', map_lua("require('telekasten').paste_img_and_link()"), sil)
set({'n'}, '<leader>zt', map_lua("require('telekasten').toggle_todo()"), sil)
set({'n'}, '<leader>zb', map_lua("require('telekasten').show_backlinks()"), sil)
set({'n'}, '<leader>zF', map_lua("require('telekasten').find_friends()"), sil)
set({'n'}, '<leader>zI', map_lua("require('telekasten').insert_img_link({ i=true })"), sil)
set({'n'}, '<leader>zp', map_lua("require('telekasten').preview_img()"), sil)
set({'n'}, '<leader>zm', map_lua("require('telekasten').browse_media()"), sil)
set({'n'}, '<leader>za', map_lua("require('telekasten').show_tags()"), sil)
set({'n'}, '<leader>#', map_lua("require('telekasten').show_tags()"), sil)
set({'n'}, '<leader>zr', map_lua("require('telekasten').rename_note()"), sil)


------------- vsnip/hlslens ------------------
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


  " on hesitation, bring up the panel
  nnoremap <leader>z :lua require('telekasten').panel()<CR>

  " inoremap <leader>zl <cmd>:lua require('telekasten').insert_link({ i=true })<CR>
  " inoremap <leader>zt <cmd>:lua require('telekasten').toggle_todo({ i=true })<CR>
  " inoremap <leader># <cmd>lua require('telekasten').show_tags({i = true})<cr>


  vnoremap <leader>z<enter> :call Get_visual_selection()<cr>

  function! Get_visual_selection()
    " Why is this not a built-in Vim script function?!
    let [lnum1, col1] = getpos("'<")[1:2]
    let [lnum2, col2] = getpos("'>")[1:2]
    let lines = getline(lnum1, lnum2)
    let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][col1 - 1:]
    let selection = join(lines,'\n')
    let change = "\[\[".selection."\]\]"
    execute ":s/".selection."/".change
  endfunction

]])

