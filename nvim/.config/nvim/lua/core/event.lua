local create_autocmd = vim.api.nvim_create_autocmd
local create_autogroup = vim.api.nvim_create_augroup
local autocmd = {}

function autocmd.nvim_create_augroups(definitions)
  for group_name, definition in pairs(definitions) do
    create_autogroup(group_name, {clear = true})
    for _, def in ipairs(definition) do
      create_autocmd(def[1], {
        group = group_name,
        pattern = def[2],
        command = def[3]
      })
    end
  end
end

function autocmd.load_autocmds()
  local definitions = {
    bufs = {
      {{"BufRead","BufNewFile"}, "*", "setlocal formatoptions-=cro"},
      {{"BufRead","BufNewFile"}, "*.fish", "set filetype=fish"},
      {{"BufRead","BufNewFile"}, "*.ex,*.exs", "set filetype=elixir"},
      {{"BufRead","BufNewFile"}, "mix.lock", "set filetype=elixir"},
      {{"BufRead","BufNewFile"}, "*.eex,*.leex", "set filetype=eelixir"},
      -- {"BufDelete", "*", "lua nvim_feedkeys('<esc>', 'i', v:true)"},
    },

    wins = {
      {{"FocusGained","BufEnter","CursorHold","CursorHoldI"}, "*", "if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif"},
    },

    ft = {
      {"FileChangedShellPost", "*", "echohl WarningMsg | echo 'File changed on disk. Buffer reloaded.' | echohl None"},
      {"FileType", "gitcommit,gitrebase,gitconfig", "set bufhidden=delete"},
      {"FileType", "json", "set conceallevel=0"},
      {"FileType", "alpha", "setlocal nofoldenable"},
      {"FileType", "markdown", "set conceallevel=0"},
    },

    yank = {
      {"TextYankPost", "*", [[lua vim.highlight.on_yank({higroup='IncSearch', timeout=100})]]};
    },
  }

  autocmd.nvim_create_augroups(definitions)
end

autocmd.load_autocmds()
