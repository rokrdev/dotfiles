local M = {}

local navic = require "nvim-navic"

M.winbar_filetype_exclude = {
  "help",
  "startify",
  "dashboard",
  "packer",
  "neogitstatus",
  "NvimTree",
  "Trouble",
  "alpha",
  "lir",
  "Outline",
  "spectre_panel",
  "toggleterm",
}

local excludes = function()
  if vim.tbl_contains(M.winbar_filetype_exclude, vim.bo.filetype) then
    vim.opt_local.winbar = nil
    return true
  end
  return false
end

local disable_winbar = function()
  vim.cmd[[highlight link WinBar EndOfBuffer]]
end

function M.get_winbar()
  if excludes() then
    disable_winbar()
    return ""
  end

  if navic.is_available() then
    vim.cmd[[highlight link WinBar StatusLine]]
    return "%{%v:lua.require'nvim-navic'.get_location()%}"
  else
    disable_winbar()
    return ""
  end
end

return M
