
function nvim_create_augroups(definitions)
  for group_name, definition in pairs(definitions) do
    vim.cmd('augroup '..group_name)
    vim.cmd('autocmd!')
    for _, def in ipairs(definition) do
      local command = table.concat(vim.tbl_flatten{'autocmd', def}, ' ')
      vim.cmd(command)
    end
    vim.cmd('augroup END')
  end
end

local autocmds = {
  MY_AUTOCMDS = {
    {"FocusGained,BufEnter,CursorHold,CursorHoldI", "*", "if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif"},
    {"FileChangedShellPost", "*", "echohl WarningMsg | echo 'File changed on disk. Buffer reloaded.' | echohl None"},
    {"BufRead,BufNewFile", "*", "setlocal formatoptions-=cro"},
    {"FileType", "gitcommit,gitrebase,gitconfig", "set bufhidden=delete"},
    {"FileType", "fzf", "tunmap <buffer> <Esc>"},
    {"TermOpen", "*", "call custom#OnTermOpen()"},
    {"InsertEnter", "*", "hi link EndOfLineSpace Normal"},
    {"InsertLeave", "*", "hi link EndOfLineSpace diffRemoved"},
    {"TextYankPost", "*", "silent! lua vim.highlight.on_yank {higroup='IncSearch', timeout=250, on_visual=false}"},
  }
}

nvim_create_augroups(autocmds)
