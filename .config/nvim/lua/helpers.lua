local M = {}

local o = vim.o
local bo = vim.bo
local wo = vim.wo
local api = vim.api
local fn = vim.fn

local SESSIONS_DIR = '~/.vim/sessions/'

M.theme_colors = {
  bold = "bold,",
  italic = "italic,",
  underline = "underline",
  NONE = 'NONE',

  white_default = "#d6deeb",
  white_light = "#C5E4FD",
  blue_default = "#011627",
  grey = "#4b6479",
  grey_1 = "#1d3b53",
  blue_dark = "#00111F",
  blue = "#82aaff",
  blue_light = "#C5E4FD",
  green_bright = "#addb67",
  pink = "#c792ea",
  red = "#ff5874",
  brown = "#806e6f",
  orange_light = "#ecc48d",
  orange = "#f78c6c",
  blue_visual = "#1a2b4a",
  ash_grey = "#637777",
  cyan = "#7fdbca",
  yellow_light = "#fbec9f",
  yellow_dark = "#f4d554",
  highligter = "#263838",
  black = "#000000",
  black_1 = "#000e1a",
  blue_1 = "#283d6b",
  blue_2 = "#092236"
}

M.lualine_theme_colors = {
  blue              = M.theme_colors.blue,
  blue_default      = M.theme_colors.blue_default,
  black_1           = M.theme_colors.black_1,
  white_default     = M.theme_colors.white_default,
  grey_1            = M.theme_colors.grey_1,
  blue_visual       = M.theme_colors.blue_visual,
  blue_2            = M.theme_colors.blue_2,
  brown             = M.theme_colors.brown,
  green             = M.theme_colors.green_bright,
  pink              = M.theme_colors.pink,
  red               = M.theme_colors.red,
  cyan              = M.theme_colors.cyan,
}

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
  local yanked_text = M.getVisualSelection()
  local escapeS = vim.fn.escape(yanked_text, cmdtype .. '\\')
  local val = '\\V' .. vim.fn.substitute(escapeS, '\\n', '\\\\n', 'g')
  vim.fn.setreg('/', val)
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
  local currentPath = vim.fn.expand('%:p:h')
  local cmd = 'NnnPicker '..currentPath
  vim.cmd(cmd)
end

function M.getLualineTheme()
  local night_owl = {}
  local theme = M.lualine_theme_colors

  night_owl.normal = {
    a = { bg = theme.blue, fg = theme.blue_default, gui = 'bold', },
    b = { bg = theme.blue_visual, fg = theme.white_default, },
    c = { bg = theme.blue_visual, fg = theme.white_default, }
  }

  night_owl.insert = {
    a = { bg = theme.green, fg = theme.blue_default, gui = 'bold', },
    b = { bg = theme.blue_visual, fg = theme.white_default, },
    c = { bg = theme.blue_visual, fg = theme.white_default, }
  }

  night_owl.visual = {
    a = { bg = theme.pink, fg = theme.blue_default, gui = 'bold', },
    b = { bg = theme.blue_visual, fg = theme.white_default, },
    c = { bg = theme.blue_visual, fg = theme.white_default, }
  }

  night_owl.replace = {
    a = { bg = theme.red, fg = theme.blue_default, gui = 'bold', },
    b = { bg = theme.blue_visual, fg = theme.white_default, },
    c = { bg = theme.blue_visual, fg = theme.white_default, }
  }

  night_owl.command = {
    a = { bg = theme.cyan, fg = theme.blue_default, gui = 'bold', },
    b = { bg = theme.blue_visual, fg = theme.white_default, },
    c = { bg = theme.blue_visual, fg = theme.white_default, }
  }

  night_owl.inactive = {
    a = { bg = theme.blue_2, fg = theme.brown, gui = 'bold', },
    b = { bg = theme.blue_2, fg = theme.brown, },
    c = { bg = theme.blue_2, fg = theme.brown, },
  }

  return night_owl
end

return M

