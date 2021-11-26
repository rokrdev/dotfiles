local M = {}

local o = vim.o
local bo = vim.bo
local wo = vim.wo
local api = vim.api
local fn = vim.fn

local SESSIONS_DIR = '~/.vim/sessions/'

M.getopt = api.nvim_get_option

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
  if wo.colorcolumn == "120" then
    wo.colorcolumn = "0"
  else
    wo.colorcolumn = "120"
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

function M.getWordUnderCursor()
  return fn.expand('<cword>')
end

function M.rgWordUnderCursor()
  local val = 'RG ' .. fn.expand('<cword>')
  api.nvim_exec(val, false)
end

local function getRandom()
  return math.ceil(math.random() * 10000)
end

function M.scratchGenerator()
  local str = "e! __Scratchy__" .. getRandom()
  api.nvim_exec(str, false)
end

function M.getVisualSelection()
  local temp = fn.getreg('s')
  vim.cmd('noau normal! "sy')
  local val = fn.getreg('s')
  fn.setreg('s', temp)
  return val
end

function M.escape(str)
  return fn.escape(str, '\\/.*$^~[]()<>')
end

function M.rgVisualSelection()
  local val = M.getVisualSelection()
  local str = "RG " .. M.escape(val)
  api.nvim_exec(str, false)
end

-- function M.VSetSearch(cmdtype)
--   local yanked_text = M.getVisualSelection()
--   local escapeS = fn.escape(yanked_text, cmdtype .. '\\')
--   local val = '\\V' .. fn.substitute(escapeS, '\\n', '\\\\n', 'g')
--   api.nvim_exec(cmdtype .. val, false)
-- end

function M.getSessionNameFromCwd()
  local pwd = api.nvim_exec("pwd", true)
  return pwd, pwd:gsub("/", "_").."-"
end

function M.getSessionFilePath()
  local currentFolder, folderText = M.getSessionNameFromCwd()
  return SESSIONS_DIR .. folderText
end

function M.restoreSession(path)
  local currentFolder, folderText = M.getSessionNameFromCwd()
  local cmd = 'so '..path
  vim.cmd(cmd)
  api.nvim_exec("cd "..currentFolder, false)
end

function M.deleteSession(path)
  local currentFolder, folderText = M.getSessionNameFromCwd()
  local cmd = ':!rm '..path
  api.nvim_exec(cmd, false)
  api.nvim_exec("cd "..currentFolder, false)
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
  local currentPath = fn.expand('%:p:h')
  local cmd = 'NnnPicker '..currentPath
  vim.cmd(cmd)
end

function M.onEnterInsertMode()
  vim.cmd[[ hi link EndOfLineSpace None ]]
end

function M.onLeaveInsertMode()
  if (vim.bo.filetype ~= 'alpha') then
    vim.cmd[[ hi link EndOfLineSpace Substitute ]]
  end
end

return M

