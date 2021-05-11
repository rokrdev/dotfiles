local g = vim.g
local ncmd = vim.api.nvim_command

local theme = {
  bold = "bold,",
  italic = "italic,",
  underline = "underline",
  NONE = 'NONE',

  white_default = "#d6deeb",
  white_light = "#C5E4FD",
  blue_default = "#011627",
  cello = "#384866",
  grey_1 = "#1d3b53",
  blue_dark = "#00111F",
  blue = "#82aaff",
  blue_light = "#C5E4FD",
  green_bright = "#addb67",
  pink = "#c792ea",
  red = "#ff5874",
  orange_light = "#ecc48d",
  orange = "#f78c6c",
  blue_visual = "#1a2b4a",
  ash_grey = "#637777",
  cyan = "#7fdbca",
  yellow_light = "#fbec9f",
  yellow_dark = "#f4d554",
  blue_1 = "#283d6b",
  blue_2 = "#092236",
  light_purple = "#625b70",
  dark_cello = "#262b36",
}

g.terminal_color_foreground = theme.white_default
g.terminal_color_background = theme.blue_default
g.terminal_color_0 = theme.blue_default
g.terminal_color_8 = theme.ash_grey
g.terminal_color_1 = theme.red
g.terminal_color_2 = theme.green_bright
g.terminal_color_10 = theme.green_bright
g.terminal_color_3 = theme.orange
g.terminal_color_11 = theme.orange
g.terminal_color_4 = theme.blue
g.terminal_color_12 = theme.blue
g.terminal_color_5 = theme.pink
g.terminal_color_13 = theme.pink
g.terminal_color_6 = theme.cyan
g.terminal_color_14 = theme.cyan
g.terminal_color_7 = theme.ash_grey
g.terminal_color_15 = theme.white_light

local function highlight(group, color)
  local gui = color.attr and 'gui=' .. color.attr or 'gui=NONE'
  local cterm = color.attr and 'cterm=' .. color.attr or 'cterm=NONE'
  local fg = color.fg and 'guifg=' .. color.fg or 'guifg=NONE'
  local bg = color.bg and 'guibg=' .. color.bg or 'guibg=NONE'
  ncmd(string.format('highlight %s %s %s %s %s', group, fg, bg, gui, cterm))
end

local function setTheme(colors)
  local hi = {}

  hi.Bold = { fg = nil, bg = nil, attr = colors.bold }
  hi.italic = { fg = nil, bg = nil, attr = colors.italic }
  hi.Underline = { fg = nil, bg = nil, attr = colors.underline }

  hi.StatusLine = { fg = colors.white_default, bg = colors.blue_default, attr = nil }
  hi.Normal = { fg = colors.white_default, bg = colors.blue_default, attr = nil }
  hi.LineNr = { fg = colors.cello, bg = nil, attr = nil }
  hi.CursorLineNr = { fg = colors.white_light, bg = nil, attr = nil }
  hi.CursorLine = { fg = nil, bg = colors.blue_2, attr = nil }
  hi.ColorColumn = { fg = nil, bg = colors.blue_visual, attr = nil }
  hi.Directory = { fg = colors.blue, bg = nil, attr = nil }
  hi.DiffAdd = { fg = colors.green_bright, bg = colors.blue_default, attr = nil }
  hi.DiffChange = { fg = colors.pink, bg = colors.blue_default, attr = nil }
  hi.DiffDelete = { fg = colors.red, bg = colors.blue_default, attr = nil }
  hi.DiffText = { fg = colors.green_bright, bg = colors.blue_default, attr = nil }
  hi.diffAdded = { fg = colors.green_bright, bg = colors.blue_default, attr = nil }
  hi.diffChanged = { fg = colors.pink, bg = colors.blue_default, attr = nil }
  hi.diffRemoved = { fg = colors.red, bg = colors.blue_default, attr = nil }
  hi.C_WhiteSpace = { fg = nil, bg = colors.red, attr = nil }

  hi.VertSplit = { fg = colors.blue_1, bg = nil, attr = nil }
  hi.MatchParen = { fg = colors.pink, bg = nil, attr = colors.bold..colors.underline }
  hi.Folded = { fg = colors.light_purple, bg = nil, attr = nil }
  hi.FoldedColumn = { fg = colors.light_purple, bg = nil, attr = nil }
  hi.SignColumn = { fg = nil, bg = nil, attr = nil }
  hi.IncSearch = { fg = colors.white_light, bg = nil, attr = colors.underline }
  hi.NonText = { fg = colors.cello, bg = nil, attr = nil }
  hi.PMenu = { fg = colors.white_default, bg = colors.blue_1, attr = nil }
  hi.PMenuSel = { fg = colors.blue_default, bg = colors.blue, attr = colors.bold }
  hi.Search = { fg = colors.blue_default, bg = colors.white_light, attr = nil }
  hi.SpecialKey = { fg = colors.orange_light, bg = nil, attr = nil }
  hi.Title = { fg = colors.blue, bg = nil, attr = nil }
  hi.Visual = { fg = colors.white_light, bg = colors.cello, attr = nil }
  hi.EndOfBuffer = { fg = colors.blue_default, bg = nil, attr = nil }

  hi.Comment = { fg = colors.cello, bg = nil, attr = colors.italic }
  hi.Constant = { fg = colors.green_bright, bg = nil, attr = nil }
  hi.String = { fg = colors.orange_light, bg = nil, attr = nil }
  hi.Character = { fg = colors.orange_light, bg = nil, attr = nil }
  hi.Number = { fg = colors.orange, bg = nil, attr = nil }
  hi.Boolean = { fg = colors.red, bg = nil, attr = nil }
  hi.Float = { fg = colors.orange, bg = nil, attr = nil }
  hi.Identifier = { fg = colors.cyan, bg = nil, attr = nil }
  hi.Function = { fg = colors.blue, bg = nil, attr = colors.italic }
  hi.Statement = { fg = colors.blue, bg = nil, attr = nil }
  hi.Conditional = { fg = colors.white_default, bg = nil, attr = nil }
  hi.Repeat = { fg = colors.white_default, bg = nil, attr = nil }
  hi.Label = { fg = colors.white_default, bg = nil, attr = nil }
  hi.Operator = { fg = colors.pink, bg = nil, attr = nil }
  hi.Keyword = { fg = colors.blue, bg = nil, attr = nil }
  hi.Exception = { fg = colors.green_bright, bg = nil, attr = nil }
  hi.PreProc = { fg = colors.pink, bg = nil, attr = nil }
  hi.Include = { fg = colors.pink, bg = nil, attr = nil }
  hi.Define = { fg = colors.pink, bg = nil, attr = nil }
  hi.Macro = { fg = colors.white_default, bg = nil, attr = nil }
  hi.PreCondit = { fg = colors.white_default, bg = nil, attr = nil }
  hi.Type = { fg = colors.green_bright, bg = nil, attr = nil }
  hi.StorageClass = { fg = colors.pink, bg = nil, attr = nil }
  hi.Structure = { fg = colors.white_default, bg = nil, attr = nil }
  hi.Typedef = { fg = colors.white_default, bg = nil, attr = nil }
  hi.Special = { fg = colors.white_default, bg = nil, attr = nil }
  hi.SpecialChar = { fg = nil, bg = nil, attr = nil }
  hi.Tag = { fg = nil, bg = nil, attr = nil }
  hi.Delimiter = { fg = colors.white_default, bg = nil, attr = nil }
  hi.SpecialComment = { fg = colors.cello, bg = nil, attr = nil }
  hi.Debug = { fg = nil, bg = nil, attr = nil }
  hi.Underlined = { fg = nil, bg = nil, attr = colors.underline }
  hi.Ignore = { fg = nil, bg = nil, attr = nil }
  hi.Error = { fg = colors.red, bg = nil, attr = colors.bold }
  hi.ErrorMsg = { fg = colors.red, bg = nil, attr = nil }
  hi.WarningMsg = { fg = colors.red, bg = nil, attr = nil }
  hi.Todo = { fg = colors.yellow_dark, bg = nil, attr = colors.bold }
  hi.htmlTag = { fg = colors.ash_grey, bg = nil, attr = nil }
  hi.htmlEndTag= { fg = colors.ash_grey, bg = nil, attr = nil }

  hi.jsStorageClass = { fg = colors.blue, bg = nil, attr = nil }
  hi.jsOperator = { fg = colors.pink, bg = nil, attr = nil }
  hi.jsArrowFunction = { fg = colors.pink, bg = nil, attr = nil }
  hi.jsString = { fg = colors.orange_light, bg = nil, attr = nil }
  hi.jsCommet = { fg = colors.blue_2, bg = nil, attr = colors.italic }
  hi.jsFuncCall = { fg = colors.blue, bg = nil, attr = colors.italic }
  hi.jsNumber = { fg = colors.orange, bg = nil, attr = nil }
  hi.jsSpecial = { fg = colors.orange, bg = nil, attr = nil }
  hi.jsObjectProp = { fg = colors.cyan, bg = nil, attr = nil }
  hi.jsOperatorKeyword = { fg = colors.cyan, bg = nil, attr = nil }
  hi.jsBooleanFalse = { fg = colors.red, bg = nil, attr = nil }
  hi.jsBooleanTrue = { fg = colors.red, bg = nil, attr = nil }
  hi.jsRegexpString = { fg = colors.blue, bg = nil, attr = nil }
  hi.jsConditional = { fg = colors.pink, bg = nil, attr = nil }
  hi.jsFunction = { fg = colors.blue, bg = nil, attr = colors.italic }
  hi.jsReturn = { fg = colors.pink, bg = nil, attr = nil }
  hi.jsFuncName = { fg = colors.blue, bg = nil, attr = nil }
  hi.jsFuncParens = { fg = colors.white_default, bg = nil, attr = nil }
  hi.jsParensError = { fg = colors.red, bg = nil, attr = nil }
  hi.jsClassDefinition = { fg = colors.orange_light, bg = nil, attr = nil }
  hi.jsImport = { fg = colors.pink, bg = nil, attr = colors.italic }
  hi.jsFrom = { fg = colors.pink, bg = nil, attr = colors.italic }
  hi.jsModuleAs = { fg = colors.pink, bg = nil, attr = colors.italic }
  hi.jsExport = { fg = colors.cyan, bg = nil, attr = nil }
  hi.jsExportDefault = { fg = colors.cyan, bg = nil, attr = nil }
  hi.jsExtendsKeyword = { fg = colors.pink, bg = nil, attr = colors.italic }
  hi.javaScriptReserved = { fg = colors.blue, bg = nil, attr = nil }
  hi.javaScriptConditional = { fg = colors.pink, bg = nil, attr = nil }
  hi.javaScriptStringS = { fg = colors.orange_light, bg = nil, attr = nil }
  hi.javaScriptBoolean = { fg = colors.red, bg = nil, attr = nil }
  hi.javaScriptBraces = { fg = colors.white_default, bg = nil, attr = nil }
  hi.javaScriptLineComment = { fg = colors.cello, bg = nil, attr = colors.italic }
  hi.javaScriptLineSpecial = { fg = colors.orange, bg = nil, attr = nil }
  hi.javaScriptFunction = { fg = colors.blue, bg = nil, attr = colors.italic }
  hi.javaScriptStatement = { fg = colors.pink, bg = nil, attr = nil }
  hi.javaScriptException = { fg = colors.green_bright, bg = nil, attr = nil }

  hi.scssSelectorName = { fg = colors.green_bright, bg = nil, attr = nil }
  hi.cssTagName = { fg = colors.red, bg = nil, attr = nil }
  hi.cssClassName = { fg = colors.green_bright, bg = nil, attr = colors.italic }
  hi.cssClassNameDot = { fg = colors.green_bright, bg = nil, attr = colors.italic }
  hi.cssBraces = { fg = colors.white_default, bg = nil, attr = colors.italic }
  hi.cssPositioningProp = { fg = colors.cyan, bg = nil, attr = nil }
  hi.cssBoxProp = { fg = colors.cyan, bg = nil, attr = nil }
  hi.cssDimensionProp = { fg = colors.cyan, bg = nil, attr = nil }
  hi.cssTransitionProp = { fg = colors.cyan, bg = nil, attr = nil }
  hi.cssTextProp = { fg = colors.cyan, bg = nil, attr = nil }
  hi.cssFontProp = { fg = colors.cyan, bg = nil, attr = nil }
  hi.cssBorderProp = { fg = colors.cyan, bg = nil, attr = nil }
  hi.cssBackgroundProp = { fg = colors.cyan, bg = nil, attr = nil }
  hi.cssUIProp = { fg = colors.cyan, bg = nil, attr = nil }
  hi.cssIEUIProp = { fg = colors.red, bg = nil, attr = nil }
  hi.scssFunctionName = { fg = colors.blue, bg = nil, attr = colors.italic }
  hi.cssPositioningAttr = { fg = colors.red, bg = nil, attr = nil }
  hi.cssTableAttr = { fg = colors.red, bg = nil, attr = nil }
  hi.cssCommonAttr = { fg = colors.red, bg = nil, attr = nil }
  hi.cssColorProp = { fg = colors.cyan, bg = nil, attr = nil }
  hi.cssIncludeKeyword = { fg = colors.cyan, bg = nil, attr = nil }
  hi.cssKeyFrameSelector = { fg = colors.cyan, bg = nil, attr = nil }
  hi.cssPseudoClassId = { fg = colors.green_bright, bg = nil, attr = colors.italic }
  hi.cssBorderAttr = { fg = colors.red, bg = nil, attr = nil }
  hi.cssValueLength = { fg = colors.orange, bg = nil, attr = nil }
  hi.cssUnitDecorators = { fg = colors.yellow_light, bg = nil, attr = nil }
  hi.cssIdentifier = { fg = colors.yellow_dark, bg = nil, attr = colors.italic }

  hi.markdownHeadingDelimiter = { fg = colors.ash_grey, bg = nil, attr = nil }
  hi.markdownCodeDelimiter = { fg = colors.orange_light, bg = nil, attr = nil }
  hi.markdownCode = { fg = colors.white_light, bg = nil, attr = nil }
  hi.mkdCodeStart = { fg = colors.white_light, bg = nil, attr = nil }
  hi.mkdCodeEnd = { fg = colors.white_light, bg = nil, attr = nil }
  hi.mkdLinkDef = { fg = colors.cyan, bg = nil, attr = nil }
  hi.mkdCodeDelimiter = { fg = colors.ash_grey, bg = colors.blue_default, attr = nil }

  hi.htmlH1 = { fg = colors.blue, bg = nil, attr = nil }
  hi.htmlH2 = { fg = colors.blue, bg = nil, attr = nil }
  hi.htmlH3 = { fg = colors.blue, bg = nil, attr = nil }
  hi.htmlH4 = { fg = colors.blue, bg = nil, attr = nil }
  hi.htmlH5 = { fg = colors.blue, bg = nil, attr = nil }
  hi.htmlBold = { fg = colors.cyan, bg = nil, attr = colors.bold }

  hi.shComment = { fg = colors.cello, bg = nil, attr = colors.italic }

  hi.Sneak = { fg = colors.blue_default, bg = colors.blue, attr = colors.bold }
  hi.SneakLabel = { fg = colors.blue_default, bg = colors.blue, attr = colors.bold }

  hi.SignifySignAdd = { fg = colors.green_bright, bg = nil, attr = nil }
  hi.SignifySignDelete = { fg = colors.red, bg = nil, attr = nil }
  hi.SignifySignChange = { fg = colors.orange, bg = nil, attr = nil }

  hi.illuminatedWord = { fg = nil, bg = colors.dark_cello, attr = nil }

  hi.NvimTreeIndentMarker = { fg = colors.blue_1, bg = nil, attr = nil }

  hi.CocErrorSign = { fg = colors.red, bg = nil, attr = nil }
  hi.CocWarningSign = { fg = colors.yellow_dark, bg = nil, attr = nil }
  hi.CocInfoSign = { fg = colors.yellow_dark, bg = nil, attr = nil }

  hi.IndentBlanklineChar = { fg = colors.cello, bg = nil, attr = 'nocombine' }
  hi.IndentBlanklineContextChar = { fg = colors.orange_light, bg = nil, attr = 'nocombine' }

  hi.LspDiagnosticsDefaultHint = { fg = colors.orange_light, bg = nil, attr = nil }
  hi.LspDiagnosticsDefaultError = { fg = colors.red, bg = nil, attr = nil }
  hi.LspDiagnosticsDefaultWarning = { fg = colors.yellow_dark, bg = nil, attr = nil }
  hi.LspDiagnosticsDefaultInformation = { fg = colors.white_light, bg = nil, attr = nil }

  hi.LspDiagnosticsSignHint = { fg = colors.orange_light, bg = nil, attr = nil }
  hi.LspDiagnosticsSignError = { fg = colors.red, bg = nil, attr = nil }
  hi.LspDiagnosticsSignWarning = { fg = colors.yellow_dark, bg = nil, attr = nil }
  hi.LspDiagnosticsSignInformation = { fg = colors.white_light, bg = nil, attr = nil }

  hi.TSFunction = { fg = colors.blue, bg = nil, attr = nil }
  hi.TSMethod = { fg = colors.blue, bg = nil, attr = nil }
  hi.TSVariable = { fg = colors.cyan, bg = nil, attr = nil }
  hi.TSKeywordFunction = { fg = colors.blue, bg = nil, attr = nil }
  hi.TSProperty = { fg = colors.yellow, bg = nil, attr = nil }
  hi.TSType = { fg = colors.green_bright, bg = nil, attr = nil }
  hi.TSPunctBracket = { fg = colors.pink, bg = nil, attr = nil }

  return hi
end

local function setup()
  vim.api.nvim_command('hi clear')
  if vim.fn.exists('syntax_on') then
    vim.api.nvim_command('syntax reset')
  end
  vim.api.nvim_command('set termguicolors')
  local hi = setTheme(theme)
  vim.o.background = 'dark'
  vim.o.termguicolors = true
  vim.g.colors_name = "midnight-owl"
  for group,color in pairs(hi) do
    highlight(group, color)
  end
  vim.cmd("hi link EndOfLineSpace C_WhiteSpace")
end

setup()

local function getLualineTheme()
  local lualine = {}

  lualine.normal = {
    a = { bg = theme.blue, fg = theme.blue_default, gui = 'bold', },
    b = { bg = theme.blue_visual, fg = theme.white_default, },
    c = { bg = theme.blue_visual, fg = theme.white_default, }
  }

  lualine.insert = {
    a = { bg = theme.green_bright, fg = theme.blue_default, gui = 'bold', },
    b = { bg = theme.blue_visual, fg = theme.white_default, },
    c = { bg = theme.blue_visual, fg = theme.white_default, }
  }

  lualine.visual = {
    a = { bg = theme.cello, fg = theme.white_default, gui = 'bold', },
    b = { bg = theme.blue_visual, fg = theme.white_default, },
    c = { bg = theme.blue_visual, fg = theme.white_default, }
  }

  lualine.replace = {
    a = { bg = theme.red, fg = theme.blue_default, gui = 'bold', },
    b = { bg = theme.blue_visual, fg = theme.white_default, },
    c = { bg = theme.blue_visual, fg = theme.white_default, }
  }

  lualine.command = {
    a = { bg = theme.cyan, fg = theme.blue_default, gui = 'bold', },
    b = { bg = theme.blue_visual, fg = theme.white_default, },
    c = { bg = theme.blue_visual, fg = theme.white_default, }
  }

  lualine.inactive = {
    a = { bg = theme.blue_visual, fg = theme.light_purple, gui = 'bold', },
    b = { bg = theme.blue_visual, fg = theme.light_purple, },
    c = { bg = theme.blue_visual, fg = theme.light_purple, },
  }

  return lualine
end

local function getBufferlineTheme()
  bufferline = {
    buffer_selected = {
      guibg = theme.blue_default,
      guifg = theme.blue_light,
    },
    fill = {
      guibg = theme.blue_visual,
      guifg = theme.blue_light,
    },
    background = {
      guibg = theme.blue_visual,
      guifg = theme.blue_light,
    },
    separator = {
      guibg = theme.blue_visual
    },
    duplicate = {
      guibg = theme.blue_visual,
      guifg = theme.ash_grey,
    },
    duplicate_selected = {
      guibg = theme.blue_default,
      guifg = theme.ash_grey,
    },
    indicator_selected = {
      guibg = theme.blue_default,
      guifg = theme.blue,
    },
    modified = {
      guibg = theme.blue_visual
    }
  }

  return bufferline;
end

return {
  highlight = highlight,
  getLualineTheme = getLualineTheme,
  getBufferlineTheme = getBufferlineTheme,
}
