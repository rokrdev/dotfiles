local vim = vim
local autocmd = {}

function autocmd.nvim_create_augroups(definitions)
  for group_name, definition in pairs(definitions) do
    vim.api.nvim_command('augroup '..group_name)
    vim.api.nvim_command('autocmd!')
    for _, def in ipairs(definition) do
      local command = table.concat(vim.tbl_flatten{'autocmd', def}, ' ')
      vim.api.nvim_command(command)
    end
    vim.api.nvim_command('augroup END')
  end
end

function autocmd.load_autocmds()
  local definitions = {
    packer = {
      {"BufWritePost","*.lua","lua require('core.pack').auto_compile()"};
    },
    bufs = {
      {"BufRead,BufNewFile", "*", "setlocal formatoptions-=cro"},
      {"BufRead,BufNewFile", "*.fish", "set filetype=fish"},
      {"BufRead,BufNewFile", "*.ex,*.exs", "set filetype=elixir"},
      {"BufRead,BufNewFile", "mix.lock", "set filetype=elixir"},
      {"BufRead,BufNewFile", "*.eex,*.leex", "set filetype=eelixir"},
    };

    wins = {
      {"FocusGained,BufEnter,CursorHold,CursorHoldI", "*", "if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif"},
    };

    ft = {
      {"FileChangedShellPost", "*", "echohl WarningMsg | echo 'File changed on disk. Buffer reloaded.' | echohl None"},
      {"FileType", "gitcommit,gitrebase,gitconfig", "set bufhidden=delete"},
      {"FileType", "json", "set conceallevel=0"},
    };

    term = {
      {"TermOpen", "*", "lua require('utils').onTermOpen()"},
    };

    yank = {
      {"TextYankPost", [[* silent! lua vim.highlight.on_yank({higroup="IncSearch", timeout=400})]]};
    };
  }

  autocmd.nvim_create_augroups(definitions)
end

autocmd.load_autocmds()
