local M = {}

local o = vim.o
local bo = vim.bo
local wo = vim.wo
local api = vim.api
local fn = vim.fn

local SESSIONS_DIR = "~/.vim/sessions/"

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

local function getRandom()
  return math.ceil(math.random() * 10000)
end

function M.scratchGenerator()
  local str = "e! __Scratchy__" .. getRandom()
  api.nvim_exec(str, false)
end

function M.getVisualSelection()
  local temp = fn.getreg("v")
  api.nvim_exec(
    [[
      noau normal! "vy
    ]],
    false
  )
  local val = fn.getreg("v")
  fn.setreg("v", temp)
  return val
end

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
  local currentPath = fn.expand("%:p:h")
  local cmd = "NnnPicker "..currentPath
  vim.cmd(cmd)
end

function M.custom_f()
  require'hop'.hint_char1({
    direction = require'hop.hint'.HintDirection.AFTER_CURSOR,
    current_line_only = true
  })
end

function M.custom_F()
  require'hop'.hint_char1({
    direction = require'hop.hint'.HintDirection.BEFORE_CURSOR,
    current_line_only = true
  })
end

function M.custom_t()
  require'hop'.hint_char1({
    direction = require'hop.hint'.HintDirection.AFTER_CURSOR,
    current_line_only = true,
    hint_offset = -1,
  })
end

function M.custom_T()
  require'hop'.hint_char1({
    direction = require'hop.hint'.HintDirection.BEFORE_CURSOR,
    current_line_only = true,
    hint_offset = -1,
  })
end

return M

