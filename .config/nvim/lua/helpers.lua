local M = {}

M.getopt = vim.api.nvim_get_option

function M.setopt(k, v)
  vim.o[k] = v
end

function M.setBopt(k, v)
  vim.o[k] = v
  vim.bo[k] = v
end

function M.setWopt(k, v)
  vim.o[k] = v
  vim.wo[k] = v
end

return M

