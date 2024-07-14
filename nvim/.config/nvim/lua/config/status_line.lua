local lualine = require('lualine')
local cp = require("tokyonight.colors").setup({style = 'night'})

-- bg = "#24283b",
--   bg_dark = "#1f2335",
--   bg_highlight = "#292e42",
--   blue = "#7aa2f7",
--   blue0 = "#3d59a1",
--   blue1 = "#2ac3de",
--   blue2 = "#0db9d7",
--   blue5 = "#89ddff",
--   blue6 = "#b4f9f8",
--   blue7 = "#394b70",
--   comment = "#565f89",
--   cyan = "#7dcfff",
--   dark3 = "#545c7e",
--   dark5 = "#737aa2",
--   fg = "#c0caf5",
--   fg_dark = "#a9b1d6",
--   fg_gutter = "#3b4261",
--   green = "#9ece6a",
--   green1 = "#73daca",
--   green2 = "#41a6b5",
--   magenta = "#bb9af7",
--   magenta2 = "#ff007c",
--   orange = "#ff9e64",
--   purple = "#9d7cd8",
--   red = "#f7768e",
--   red1 = "#db4b4b",
--   teal = "#1abc9c",
--   terminal_black = "#414868",
--   yellow = "#e0af68",
--   git = {
--     add = "#449dab",
--     change = "#6183bb",
--     delete = "#914c54",
--   },
-- Color table for highlights
-- stylua: ignore
local colors = {
  bg       = cp.bg_dark,
  fg       = cp.fg,
  yellow   = cp.yellow,
  cyan     = cp.teal,
  darkblue = cp.blue0,
  green    = cp.green,
  orange   = cp.orange,
  violet   = cp.purple,
  magenta  = cp.magenta,
  blue     = cp.blue,
  red      = cp.red,
}

local conditions = {
  buffer_not_empty = function()
    return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
  end,
  hide_in_width = function()
    return vim.fn.winwidth(0) > 80
  end,
  check_git_workspace = function()
    local filepath = vim.fn.expand('%:p:h')
    local gitdir = vim.fn.finddir('.git', filepath .. ';')
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end,
}

-- Config
local config = {
  options = {
    globalstatus = true,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    },
    -- Disable sections and component separators
    disabled_filetypes = {'alpha'},
    component_separators = '',
    section_separators = '',
    theme = {
      -- We are going to use lualine_c an lualine_x as left and
      -- right section. Both are highlighted by c theme .  So we
      -- are just setting default looks o statusline
      normal = { c = { fg = colors.fg, bg = colors.bg } },
      inactive = { c = { fg = colors.fg, bg = colors.bg } },
    },
  },
  sections = {
    -- these are to remove the defaults
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    -- These will be filled later
    lualine_c = {},
    lualine_x = {},
  },
  inactive_sections = {
    -- these are to remove the defaults
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    lualine_c = {},
    lualine_x = {},
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {
    'nvim-tree',
    'quickfix',
  }
}

local mode_color = {
  n = colors.darkblue,
  i = colors.green,
  v = colors.violet,
  [''] = colors.violet,
  V = colors.violet,
  c = colors.magenta,
  no = colors.red,
  s = colors.orange,
  S = colors.orange,
  [''] = colors.orange,
  ic = colors.yellow,
  R = colors.violet,
  Rv = colors.violet,
  cv = colors.red,
  ce = colors.red,
  r = colors.cyan,
  rm = colors.cyan,
  ['r?'] = colors.cyan,
  ['!'] = colors.red,
  t = colors.red,
}

-- Inserts a component in lualine_c at left section
local function ins_left(component)
  table.insert(config.sections.lualine_c, component)
end

-- Inserts a component in lualine_x ot right section
local function ins_right(component)
  table.insert(config.sections.lualine_x, component)
end

ins_left {
  -- mode component
  function()
    return '▌'
  end,
  color = function()
    return { fg = mode_color[vim.fn.mode()]}
  end,
  padding = { left = 0, right = 0 },
}

ins_left {
  -- filesize component
  'filesize',
  cond = conditions.buffer_not_empty,
}

ins_left { 'filetype', icon_only = true }

ins_left {
  'filename',
  cond = conditions.buffer_not_empty,
  color = { fg = colors.magenta, gui = 'bold' },
}

-- -- Insert mid section. You can make any number of sections in neovim :)
-- -- for lualine it's any number greater then 2
-- ins_left {
--   function()
--     return '%='
--   end,
-- }

ins_left {
  -- Lsp server name .
  function()
    local msg = ''
    local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
    local clients = vim.lsp.get_clients()
    if next(clients) == nil then
      return msg
    end
    for _, client in ipairs(clients) do
      local filetypes = client.config.filetypes
      if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
        return '  '..client.name
      end
    end
    return msg
  end,
  -- icon = ' LSP:',
  color = { fg = colors.darkblue, gui = 'bold' },
}


ins_left {
  'diagnostics',
  sources = { 'nvim_diagnostic' },
  symbols = { error = ' ', warn = ' ', info = ' ' },
  diagnostics_color = {
    color_error = { fg = colors.red },
    color_warn = { fg = colors.yellow },
    color_info = { fg = colors.cyan },
  },
}

ins_right {
  'diff',
  -- Is it me or the symbol for modified us really weird
  symbols = { added = ' ', modified = '󰣘 ', removed = ' ' },
  diff_color = {
    added = { fg = colors.green },
    modified = { fg = colors.orange },
    removed = { fg = colors.red },
  },
  cond = conditions.hide_in_width,
}

ins_right { 'selectioncount', color = { fg = colors.orange } }

ins_right { 'location' }

ins_right { 'progress', color = { fg = colors.fg } }

ins_right {
  'o:encoding', -- option component same as &encoding in viml
  fmt = string.upper, -- I'm not sure why it's upper case either ;)
  cond = conditions.hide_in_width,
  color = { fg = colors.green, gui = 'bold' },
}

ins_right {
  'fileformat',
  fmt = string.upper,
  icons_enabled = true,
  color = { fg = colors.green, gui = 'bold' },
}
ins_right {
  'branch',
  icon = '',
  color = { fg = colors.violet, gui = 'bold' },
}

ins_right {
  function()
    return '▐'
  end,
  color = function()
    return { fg = mode_color[vim.fn.mode()]}
  end,
  padding = { left = 0, right = 0 },
}

-- Now don't forget to initialize lualine
lualine.setup(config)
