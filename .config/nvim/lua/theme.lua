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
  local fg = color.guifg and 'guifg=' .. color.guifg or 'guifg=NONE'
  local bg = color.guibg and 'guibg=' .. color.guibg or 'guibg=NONE'
  ncmd(string.format('highlight %s %s %s %s %s', group, fg, bg, gui, cterm))
end

local function setTheme(colors)
  local hi = {}

  hi.Bold = { guifg = nil, guibg = nil, attr = colors.bold }
  hi.italic = { guifg = nil, guibg = nil, attr = colors.italic }
  hi.Underline = { guifg = nil, guibg = nil, attr = colors.underline }

  hi.StatusLine = { guifg = colors.blue_visual, guibg = colors.white_default, attr = nil }
  hi.Normal = { guifg = colors.white_default, guibg = colors.blue_default, attr = nil }
  hi.LineNr = { guifg = colors.grey, guibg = nil, attr = nil }
  hi.CursorLineNr = { guifg = colors.white_light, guibg = colors.blue_2, attr = nil }
  hi.CursorLine = { guifg = nil, guibg = colors.blue_2, attr = nil }
  hi.ColorColumn = { guifg = nil, guibg = colors.blue_2, attr = nil }
  hi.Directory = { guifg = colors.blue, guibg = nil, attr = nil }
  hi.DiffAdd = { guifg = colors.green_bright, guibg = colors.blue_default, attr = nil }
  hi.DiffChange = { guifg = colors.pink, guibg = colors.blue_default, attr = nil }
  hi.DiffDelete = { guifg = colors.red, guibg = colors.blue_default, attr = nil }
  hi.DiffText = { guifg = colors.green_bright, guibg = colors.blue_default, attr = nil }
  hi.diffAdded = { guifg = colors.green_bright, guibg = colors.blue_default, attr = nil }
  hi.diffChanged = { guifg = colors.pink, guibg = colors.blue_default, attr = nil }
  hi.diffRemoved = { guifg = colors.red, guibg = colors.blue_default, attr = nil }
  hi.C_WhiteSpace = { guifg = nil, guibg = colors.red, attr = nil }

  hi.VertSplit = { guifg = colors.blue_1, guibg = nil, attr = nil }
  hi.MatchParen = { guifg = colors.pink, guibg = nil, attr = colors.bold..colors.underline }
  hi.Folded = { guifg = colors.brown, guibg = nil, attr = nil }
  hi.FoldedColumn = { guifg = colors.brown, guibg = nil, attr = nil }
  hi.SignColumn = { guifg = nil, guibg = nil, attr = nil }
  hi.IncSearch = { guifg = colors.white_light, guibg = nil, attr = colors.underline }
  hi.NonText = { guifg = colors.blue_1, guibg = nil, attr = nil }
  hi.PMenu = { guifg = colors.white_default, guibg = colors.blue_visual, attr = nil }
  hi.PMenuSel = { guifg = colors.blue_default, guibg = colors.blue, attr = colors.bold }
  hi.Search = { guifg = colors.blue_default, guibg = colors.white_light, attr = nil }
  hi.SpecialKey = { guifg = colors.orange_light, guibg = nil, attr = nil }
  hi.Title = { guifg = colors.blue, guibg = nil, attr = nil }
  hi.Visual = { guifg = nil, guibg = colors.grey_1, attr = nil }
  hi.EndOfBuffer = { guifg = colors.grey, guibg = nil, attr = nil }

  hi.Comment = { guifg = colors.grey, guibg = nil, attr = colors.italic }
  hi.Constant = { guifg = colors.green_bright, guibg = nil, attr = nil }
  hi.String = { guifg = colors.orange_light, guibg = nil, attr = nil }
  hi.Character = { guifg = colors.orange_light, guibg = nil, attr = nil }
  hi.Number = { guifg = colors.orange, guibg = nil, attr = nil }
  hi.Boolean = { guifg = colors.red, guibg = nil, attr = nil }
  hi.Float = { guifg = colors.orange, guibg = nil, attr = nil }
  hi.Identifier = { guifg = colors.cyan, guibg = nil, attr = nil }
  hi.Function = { guifg = colors.blue, guibg = nil, attr = colors.italic }
  hi.Statement = { guifg = colors.blue, guibg = nil, attr = nil }
  hi.Conditional = { guifg = colors.white_default, guibg = nil, attr = nil }
  hi.Repeat = { guifg = colors.white_default, guibg = nil, attr = nil }
  hi.Label = { guifg = colors.white_default, guibg = nil, attr = nil }
  hi.Operator = { guifg = colors.pink, guibg = nil, attr = nil }
  hi.Keyword = { guifg = colors.blue, guibg = nil, attr = nil }
  hi.Exception = { guifg = colors.green_bright, guibg = nil, attr = nil }
  hi.PreProc = { guifg = colors.pink, guibg = nil, attr = nil }
  hi.Include = { guifg = colors.pink, guibg = nil, attr = nil }
  hi.Define = { guifg = colors.pink, guibg = nil, attr = nil }
  hi.Macro = { guifg = colors.white_default, guibg = nil, attr = nil }
  hi.PreCondit = { guifg = colors.white_default, guibg = nil, attr = nil }
  hi.Type = { guifg = colors.green_bright, guibg = nil, attr = nil }
  hi.StorageClass = { guifg = colors.pink, guibg = nil, attr = nil }
  hi.Structure = { guifg = colors.white_default, guibg = nil, attr = nil }
  hi.Typedef = { guifg = colors.white_default, guibg = nil, attr = nil }
  hi.Special = { guifg = colors.white_default, guibg = nil, attr = nil }
  hi.SpecialChar = { guifg = nil, guibg = nil, attr = nil }
  hi.Tag = { guifg = nil, guibg = nil, attr = nil }
  hi.Delimiter = { guifg = colors.white_default, guibg = nil, attr = nil }
  hi.SpecialComment = { guifg = colors.grey, guibg = nil, attr = nil }
  hi.Debug = { guifg = nil, guibg = nil, attr = nil }
  hi.Underlined = { guifg = nil, guibg = nil, attr = colors.underline }
  hi.Ignore = { guifg = nil, guibg = nil, attr = nil }
  hi.Error = { guifg = colors.red, guibg = nil, attr = colors.bold }
  hi.ErrorMsg = { guifg = colors.red, guibg = nil, attr = nil }
  hi.WarningMsg = { guifg = colors.red, guibg = nil, attr = nil }
  hi.Todo = { guifg = colors.yellow_dark, guibg = nil, attr = colors.bold }
  hi.htmlTag = { guifg = colors.ash_grey, guibg = nil, attr = nil }
  hi.htmlEndTag= { guifg = colors.ash_grey, guibg = nil, attr = nil }

  hi.jsStorageClass = { guifg = colors.blue, guibg = nil, attr = nil }
  hi.jsOperator = { guifg = colors.pink, guibg = nil, attr = nil }
  hi.jsArrowFunction = { guifg = colors.pink, guibg = nil, attr = nil }
  hi.jsString = { guifg = colors.orange_light, guibg = nil, attr = nil }
  hi.jsCommet = { guifg = colors.blue_2, guibg = nil, attr = colors.italic }
  hi.jsFuncCall = { guifg = colors.blue, guibg = nil, attr = colors.italic }
  hi.jsNumber = { guifg = colors.orange, guibg = nil, attr = nil }
  hi.jsSpecial = { guifg = colors.orange, guibg = nil, attr = nil }
  hi.jsObjectProp = { guifg = colors.cyan, guibg = nil, attr = nil }
  hi.jsOperatorKeyword = { guifg = colors.cyan, guibg = nil, attr = nil }
  hi.jsBooleanFalse = { guifg = colors.red, guibg = nil, attr = nil }
  hi.jsBooleanTrue = { guifg = colors.red, guibg = nil, attr = nil }
  hi.jsRegexpString = { guifg = colors.blue, guibg = nil, attr = nil }
  hi.jsConditional = { guifg = colors.pink, guibg = nil, attr = nil }
  hi.jsFunction = { guifg = colors.blue, guibg = nil, attr = colors.italic }
  hi.jsReturn = { guifg = colors.pink, guibg = nil, attr = nil }
  hi.jsFuncName = { guifg = colors.blue, guibg = nil, attr = nil }
  hi.jsFuncParens = { guifg = colors.white_default, guibg = nil, attr = nil }
  hi.jsParensError = { guifg = colors.red, guibg = nil, attr = nil }
  hi.jsClassDefinition = { guifg = colors.orange_light, guibg = nil, attr = nil }
  hi.jsImport = { guifg = colors.pink, guibg = nil, attr = colors.italic }
  hi.jsFrom = { guifg = colors.pink, guibg = nil, attr = colors.italic }
  hi.jsModuleAs = { guifg = colors.pink, guibg = nil, attr = colors.italic }
  hi.jsExport = { guifg = colors.cyan, guibg = nil, attr = nil }
  hi.jsExportDefault = { guifg = colors.cyan, guibg = nil, attr = nil }
  hi.jsExtendsKeyword = { guifg = colors.pink, guibg = nil, attr = colors.italic }
  hi.javaScriptReserved = { guifg = colors.blue, guibg = nil, attr = nil }
  hi.javaScriptConditional = { guifg = colors.pink, guibg = nil, attr = nil }
  hi.javaScriptStringS = { guifg = colors.orange_light, guibg = nil, attr = nil }
  hi.javaScriptBoolean = { guifg = colors.red, guibg = nil, attr = nil }
  hi.javaScriptBraces = { guifg = colors.white_default, guibg = nil, attr = nil }
  hi.javaScriptLineComment = { guifg = colors.grey, guibg = nil, attr = colors.italic }
  hi.javaScriptLineSpecial = { guifg = colors.orange, guibg = nil, attr = nil }
  hi.javaScriptFunction = { guifg = colors.blue, guibg = nil, attr = colors.italic }
  hi.javaScriptStatement = { guifg = colors.pink, guibg = nil, attr = nil }
  hi.javaScriptException = { guifg = colors.green_bright, guibg = nil, attr = nil }

  hi.scssSelectorName = { guifg = colors.green_bright, guibg = nil, attr = nil }
  hi.cssTagName = { guifg = colors.red, guibg = nil, attr = nil }
  hi.cssClassName = { guifg = colors.green_bright, guibg = nil, attr = colors.italic }
  hi.cssClassNameDot = { guifg = colors.green_bright, guibg = nil, attr = colors.italic }
  hi.cssBraces = { guifg = colors.white_default, guibg = nil, attr = colors.italic }
  hi.cssPositioningProp = { guifg = colors.cyan, guibg = nil, attr = nil }
  hi.cssBoxProp = { guifg = colors.cyan, guibg = nil, attr = nil }
  hi.cssDimensionProp = { guifg = colors.cyan, guibg = nil, attr = nil }
  hi.cssTransitionProp = { guifg = colors.cyan, guibg = nil, attr = nil }
  hi.cssTextProp = { guifg = colors.cyan, guibg = nil, attr = nil }
  hi.cssFontProp = { guifg = colors.cyan, guibg = nil, attr = nil }
  hi.cssBorderProp = { guifg = colors.cyan, guibg = nil, attr = nil }
  hi.cssBackgroundProp = { guifg = colors.cyan, guibg = nil, attr = nil }
  hi.cssUIProp = { guifg = colors.cyan, guibg = nil, attr = nil }
  hi.cssIEUIProp = { guifg = colors.red, guibg = nil, attr = nil }
  hi.scssFunctionName = { guifg = colors.blue, guibg = nil, attr = colors.italic }
  hi.cssPositioningAttr = { guifg = colors.red, guibg = nil, attr = nil }
  hi.cssTableAttr = { guifg = colors.red, guibg = nil, attr = nil }
  hi.cssCommonAttr = { guifg = colors.red, guibg = nil, attr = nil }
  hi.cssColorProp = { guifg = colors.cyan, guibg = nil, attr = nil }
  hi.cssIncludeKeyword = { guifg = colors.cyan, guibg = nil, attr = nil }
  hi.cssKeyFrameSelector = { guifg = colors.cyan, guibg = nil, attr = nil }
  hi.cssPseudoClassId = { guifg = colors.green_bright, guibg = nil, attr = colors.italic }
  hi.cssBorderAttr = { guifg = colors.red, guibg = nil, attr = nil }
  hi.cssValueLength = { guifg = colors.orange, guibg = nil, attr = nil }
  hi.cssUnitDecorators = { guifg = colors.yellow_light, guibg = nil, attr = nil }
  hi.cssIdentifier = { guifg = colors.yellow_dark, guibg = nil, attr = colors.italic }

  hi.markdownHeadingDelimiter = { guifg = colors.ash_grey, guibg = nil, attr = nil }
  hi.markdownCodeDelimiter = { guifg = colors.orange_light, guibg = nil, attr = nil }
  hi.markdownCode = { guifg = colors.white_light, guibg = nil, attr = nil }
  hi.mkdCodeStart = { guifg = colors.white_light, guibg = nil, attr = nil }
  hi.mkdCodeEnd = { guifg = colors.white_light, guibg = nil, attr = nil }
  hi.mkdLinkDef = { guifg = colors.cyan, guibg = nil, attr = nil }
  hi.mkdCodeDelimiter = { guifg = colors.ash_grey, guibg = colors.blue_default, attr = nil }

  hi.htmlH1 = { guifg = colors.blue, guibg = nil, attr = nil }
  hi.htmlH2 = { guifg = colors.blue, guibg = nil, attr = nil }
  hi.htmlH3 = { guifg = colors.blue, guibg = nil, attr = nil }
  hi.htmlH4 = { guifg = colors.blue, guibg = nil, attr = nil }
  hi.htmlH5 = { guifg = colors.blue, guibg = nil, attr = nil }
  hi.htmlBold = { guifg = colors.cyan, guibg = nil, attr = colors.bold }

  hi.shComment = { guifg = colors.grey, guibg = nil, attr = colors.italic }

  hi.Sneak = { guifg = colors.blue_default, guibg = colors.blue, attr = colors.bold }
  hi.SneakLabel = { guifg = colors.blue_default, guibg = colors.blue, attr = colors.bold }

  hi.SignifySignAdd = { guifg = colors.green_bright, guibg = nil, attr = nil }
  hi.SignifySignDelete = { guifg = colors.red, guibg = nil, attr = nil }
  hi.SignifySignChange = { guifg = colors.orange, guibg = nil, attr = nil }

  hi.illuminatedWord = { guifg = nil, guibg = colors.highligter, attr = nil }

  hi.NvimTreeIndentMarker = { guifg = colors.blue_1, guibg = nil, attr = nil }

  hi.CocErrorSign = { guifg = colors.red, guibg = nil, attr = nil }
  hi.CocWarningSign = { guifg = colors.yellow_dark, guibg = nil, attr = nil }
  hi.CocInfoSign = { guifg = colors.yellow_dark, guibg = nil, attr = nil }

  hi.IndentBlanklineChar = { guifg = colors.grey_1, guibg = nil, attr = 'nocombine' }
  hi.IndentBlanklineContextChar = { guifg = colors.orange_light, guibg = nil, attr = 'nocombine' }

  hi.LspDiagnosticsDefaultHint = { guifg = colors.orange_light, guibg = nil, attr = nil }
  hi.LspDiagnosticsDefaultError = { guifg = colors.red, guibg = nil, attr = nil }
  hi.LspDiagnosticsDefaultWarning = { guifg = colors.yellow_dark, guibg = nil, attr = nil }
  hi.LspDiagnosticsDefaultInformation = { guifg = colors.white_light, guibg = nil, attr = nil }

  return hi
end

local function setup()
  -- vim.api.nvim_command('hi clear')
  -- if vim.fn.exists('syntax_on') then
  --   vim.api.nvim_command('syntax reset')
  -- end
  vim.api.nvim_command('set termguicolors')
  local hi = setTheme(theme)
  vim.o.background = 'dark'
  vim.o.termguicolors = true
  vim.g.colors_name = "my-theme"
  for group,color in pairs(hi) do
    highlight(group, color)
  end
  vim.cmd("hi link EndOfLineSpace C_WhiteSpace")
end

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
    a = { bg = theme.pink, fg = theme.blue_default, gui = 'bold', },
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
    a = { bg = theme.blue_2, fg = theme.brown, gui = 'bold', },
    b = { bg = theme.blue_2, fg = theme.brown, },
    c = { bg = theme.blue_2, fg = theme.brown, },
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
    },
    duplicate_selected = {
      guibg = theme.blue_default,
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
  setup = setup,
  getLualineTheme = getLualineTheme,
  getBufferlineTheme = getBufferlineTheme,
}
