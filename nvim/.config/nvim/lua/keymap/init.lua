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

_G.vsnip_expand = function()
  if vim.fn.call("vsnip#available", {1}) == 1 then
    return t "<Plug>(vsnip-expand-or-jump)"
  else
    return t "<C-y>"
  end
end

_G.markdown_binding = function()
  print("setting up")
  local wk = require("which-key")
  wk.register({
    f = {
      p = { map_cr("Glow"), "Preview" }
    }
  }, { prefix = "<leader>" })
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
  f = {
    name = "file",
    f = { map_lua("require('telescope.builtin').find_files({hidden=true})"), "Find file"},
    s = { map_lua("require('telescope.builtin').live_grep()"), "Search in file"},
    w = { map_lua("require('telescope.builtin').grep_string()"), "Search string"},
    n = { map_lua("require('utils').nnnPicker()"), "Open file picker"},
    t = { map_cr("NvimTreeToggle"), "Open file tree"},
    r = { "<Plug>(Scalpel)", "Replace in file"},
    y = { map_cr("let @+ = expand('%')"), "Yank current file path" } -- yank current file path
  },
  b = {
    name = "buffer",
    b = { map_lua("require('telescope.builtin').buffers()"), "list buffers"},
    c = { map_cr("nohl"), "Clear search" },
    l = { map_args("ls<CR>:b"), "list buffers"},
    s = { map_lua("require('telescope.builtin').current_buffer_fuzzy_find()"), "Search in buffer"},
    k = { map_cr("bd"), "kill buffer" },
    x = { map_cr("bd!"), "Force kill buffer" },
    o = { map_cr("b#"), "alternate buffer"},
  },
  d = {
    name = "dotfiles",
    f = { map_cr("Dff"), "Find file in dotfiles" },
    s = { map_cr("Dfs"), "Search in dotfiles" },
    w = { map_cr("Dfg"), "Search word in dotfiles" },
    k = { map_cr("Dfc"), "close dotfile buffers" },
    r = { map_cr("Reload"), "Reload nvim" },
  },
  g = {
    name = "git",
    t = { map_lua("require('utils').openTerm('tig status')"), "Tig status" },
    f = { map_lua("require('utils').openTerm('tig ' .. vim.fn.expand('%'))"), "Tig file history" },
    L = { map_lua("require('utils').openTerm('tig')"), "Tig log" },
    l = { map_lua("require('gitsigns').blame_line()"), "Blame line" },
    g = { map_cr("Neogit"), "Neogit" },
    C = { map_lua("require('keymap.custom').git_conflicts({})"), "Conflict files" },
    b = { map_lua("require('telescope.builtin').git_branches()"), "Branches" },
    c = { map_lua("require('telescope.builtin').git_commits()"), "Commits" },
  },
  l = {
    name = "Lsp",
    s = { map_cr("LspStart"), "Start lsp"},
    k = { map_cr("LspStop"), "Kill lsp"},
    r = { map_cr("LspRestart"), "Restart lsp"},
    i = { map_cr("LspInfo"), "Lsp info"},
  },
  s = {
    name = "session",
    s = { map_args("SS"), "Save session" },
    r = { map_wait("SR " .. require('utils').getSessionFilePath()), "Reload session" },
    d = { map_wait("SD " .. require('utils').getSessionFilePath()), "Delete session" },
  },
  o = {
    name = "others",
    n = { map_lua("require('utils').toggleNumbers()"), "Cycle number" },
    s = { map_cr("Scratch"), "Scratch buffer" },
    t = { map_lua("require('Trailspace').trim()"), "Trim trailing whitespace" }
  },
  z = {
    name = "zettelkasten",
    f = { map_lua("require('telekasten').find_notes()"), "Find notes"},
    D = { map_lua("require('telekasten').find_daily_notes()"), "Find daily notes"},
    s = { map_lua("require('telekasten').search_notes()"), "Search notes"},
    z = { map_lua("require('telekasten').follow_link()"), "Follow link"},
    ["gt"] = { map_lua("require('telekasten').goto_today()"), "Go to today"},
    ["gw"] = { map_lua("require('telekasten').goto_thisweek()"), "Go to this week"},
    W = { map_lua("require('telekasten').find_weekly_notes()"), "Find weekly notes"},
    n = { map_lua("require('telekasten').new_note()"), "New note"},
    N = { map_lua("require('telekasten').new_templated_note()"), "New templated note"},
    y = { map_lua("require('telekasten').yank_notelink()"), "Yank note link"},
    c = { map_lua("require('telekasten').show_calendar()"), "Show Calendar"},
    -- set({'n'}, '<leader>zC', ":CalendarT", sil)
    i = { map_lua("require('telekasten').paste_img_and_link()"), "Paste image link"},
    t = { map_lua("require('telekasten').toggle_todo()"), "Toggle todo"},
    b = { map_lua("require('telekasten').show_backlinks()"), "Show backlinks"},
    F = { map_lua("require('telekasten').find_friends()"), "Find friends"},
    I = { map_lua("require('telekasten').insert_img_link({i=true})"), "Insert image link"},
    p = { map_lua("require('telekasten').preview_img()"), "Preview image"},
    m = { map_lua("require('telekasten').browse_media()"), "Browse media"},
    a = { map_lua("require('telekasten').show_tags()"), "Show tags"},
    r = { map_lua("require('telekasten').rename_note()"), "Rename note"},
  }
}, { prefix = "<leader>" })

wk.register({
  f = {
    name = "file",
    w = { map_lua("require('telescope.builtin').grep_string({search = require('utils').getVisualSelection()})"), "Search visual selection"},
    r = { "<Plug>(ScalpelVisual)", "Replace in file"},
  }
}, { mode = "v", prefix = "<leader>" })

wk.register({
  ["<M-o>"] = { map_cr("wincmd w"), "Other window" },
  ["<M-.>"] = { map_cr("bprev"), "Previous buffer" },
  ["<M-,>"] = { map_cr("bnext"), "Next buffer" },
  ["!"] = { map_cmd("f cl<CR><ESC>l"), "Split lines" },
  ["<C-S-j>"] = { ":m .+1<CR>==", "Move down line" },
  ["<C-S-k>"] = { ":m .-2<CR>==", "Move up line" },
  s = { map_lua("require'leap'.leap { ['target-windows'] = { vim.api.nvim_get_current_win() } }"), "Leap" },
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
  z = { map_lua("require'leap'.leap { ['target-windows'] = { vim.api.nvim_get_current_win() } }"), "Leap Visual" }
}, { mode = "v" })


------------- vsnip ------------------
vim.cmd([[
  " on hesitation, bring up the panel
  nnoremap <leader>z :lua require('telekasten').panel()<CR>

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

