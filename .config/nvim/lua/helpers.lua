local M = {}

local o = vim.o
local bo = vim.bo
local wo = vim.wo
local api = vim.api
local fn = vim.fn

local SESSIONS_DIR = '~/.vim/sessions/'

M.getopt = api.nvim_get_option

function M.setopt(k, v)
  o[k] = v
end

function M.setBopt(k, v)
  o[k] = v
  bo[k] = v
end

function M.setWopt(k, v)
  o[k] = v
  wo[k] = v
end

function M.toggleNumbers()
  if wo.rnu then
    wo.rnu = false
  elseif wo.nu then
    wo.nu = false
  else
    wo.nu = true
    wo.rnu = true
  end
end

function M.goToRoot()
  api.nvim_exec(
  [[
    exec 'cd' finddir('.git/..', expand('%:p:h').';')
  ]],
  false
  )
end

local function on_exit(job_id, code, event_type)
  if code == 0 then
    api.nvim_command("silent bwipeout! ")
  end
end

function M.openTerm(cmd)
  api.nvim_exec([[tabnew]], false)
  fn.termopen(cmd, {on_exit = on_exit})
end

function M.toggleColorColumn()
  if wo.colorcolumn == "100" then
    wo.colorcolumn = "0"
  else
    wo.colorcolumn = "100"
  end
end

function M.onTermOpen()
  api.nvim_exec(
  [[
   startinsert
   setlocal listchars= nonumber norelativenumber
   tnoremap <buffer> <Esc> <Nop>
  ]],
  false
  )
end

function M.rgWordUnderCursor()
  local val = 'RG ' .. vim.fn.expand('<cword>')
  api.nvim_exec(val, false)
end

local function getRandom()
  return math.ceil(math.random() * 10000)
end

function M.scratchGenerator()
  local str = "e! __Scratchy__" .. getRandom()
  api.nvim_exec(str, false)
end

function M.show_documentation()
  if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
    api.nvim_exec('h ' .. vim.fn.expand('<cword>'))
  else
    vim.fn.call('CocAction', {'doHover'})
  end
end

function M.getVisualSelection()
  local temp = vim.fn.getreg('s')
  vim.cmd('noau normal! "sy')
  local val = vim.fn.getreg('s')
  vim.fn.setreg('s', temp)
  return val
end

function M.escape(str)
  return vim.fn.escape(str, '\\/.*$^~[]()<>')
end

function M.rgVisualSelection()
  local val = M.getVisualSelection()
  local str = "RG " .. M.escape(val)
  api.nvim_exec(str, false)
end

function M.VSetSearch(cmdtype)
  local temp = vim.fn.getreg('s')
  vim.cmd('noau normal! gv"sy')
  local escapeS = vim.fn.escape(vim.fn.getreg('s'), cmdtype .. '\\')
  local val = '\\V' .. vim.fn.substitute(escapeS, '\\n', '\\\\n', 'g')
  vim.fn.setreg('/', val)
  vim.fn.setreg('s', temp)
end

function M.getSessionNameFromCwd()
  local pwd = api.nvim_exec("pwd", true)
  return pwd, pwd:gsub("/", "_").."-"
end

function M.getSessionFilePath()
  local currentFolder, folderText = M.getSessionNameFromCwd()
  return SESSIONS_DIR .. folderText
end

function M.saveSession(name)
  local sessionName
  local currentFolder, folderText = M.getSessionNameFromCwd()
  api.nvim_exec("lcd "..SESSIONS_DIR, false)
  if name == nil or name == '' then
    sessionName = folderText .. 'default.vim'
  else
    sessionName = folderText .. name .. '.vim'
  end
  local fullPath = SESSIONS_DIR .. sessionName
  local cmd = 'mks! '..fullPath
  vim.cmd(cmd)
  api.nvim_exec("cd "..currentFolder, false)
end

function M.nnnPicker()
  local currentPath = vim.fn.expand('%:p:h')
  local cmd = 'NnnPicker '..currentPath
  vim.cmd(cmd)
end

return M

