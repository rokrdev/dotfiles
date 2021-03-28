local g = vim.g
local ncmd = vim.api.nvim_command

local theme_colors = require('helpers').theme_colors

g.terminal_color_foreground = theme_colors.white_default
g.terminal_color_background = theme_colors.blue_default
g.terminal_color_0 = theme_colors.blue_default
g.terminal_color_8 = theme_colors.ash_grey
g.terminal_color_1 = theme_colors.red
g.terminal_color_2 = theme_colors.green_bright
g.terminal_color_10 = theme_colors.green_bright
g.terminal_color_3 = theme_colors.orange
g.terminal_color_11 = theme_colors.orange
g.terminal_color_4 = theme_colors.blue
g.terminal_color_12 = theme_colors.blue
g.terminal_color_5 = theme_colors.pink
g.terminal_color_13 = theme_colors.pink
g.terminal_color_6 = theme_colors.cyan
g.terminal_color_14 = theme_colors.cyan
g.terminal_color_7 = theme_colors.ash_grey
g.terminal_color_15 = theme_colors.white_light

local function highlight(group, color)
  local gui = color.attr and 'gui=' .. color.attr or 'gui=NONE'
  local cterm = color.attr and 'cterm=' .. color.attr or 'cterm=NONE'
  local fg = color.guifg and 'guifg=' .. color.guifg or 'guifg=NONE'
  local bg = color.guibg and 'guibg=' .. color.guibg or 'guibg=NONE'
  ncmd(string.format('highlight %s %s %s %s %s', group, fg, bg, gui, cterm))
end

local function theme(colors)
  local hi = {}

  hi.Bold = { guifg = nil, guibg = nil, attr = colors.bold }
  hi.italic = { guifg = nil, guibg = nil, attr = colors.italic }
  hi.Underline = { guifg = nil, guibg = nil, attr = colors.underline }

  hi.StatusLine = { guifg = colors.blue_visual, guibg = colors.white_default, attr = nil }
  hi.Normal = { guifg = colors.white_default, guibg = colors.blue_default, attr = nil }
  hi.LineNr = { guifg = colors.grey, guibg = nil, attr = nil }
  hi.CursorLineNr = { guifg = colors.white_light, guibg = nil, attr = nil }
  hi.CursorLine = { guifg = nil, guibg = nil, attr = nil }
  hi.ColorColumn = { guifg = nil, guibg = colors.black_1, attr = nil }
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
  hi.IncSearch = { guifg = colors.blue_default, guibg = colors.pink, attr = nil }
  hi.NonText = { guifg = colors.blue_1, guibg = nil, attr = nil }
  hi.PMenu = { guifg = colors.white_default, guibg = colors.blue_visual, attr = nil }
  hi.PMenuSel = { guifg = colors.blue_default, guibg = colors.blue, attr = colors.bold }
  hi.Search = { guifg = colors.blue_default, guibg = colors.pink, attr = nil }
  hi.SpecialKey = { guifg = colors.orange_light, guibg = nil, attr = nil }
  hi.Title = { guifg = colors.blue, guibg = nil, attr = nil }
  hi.Visual = { guifg = nil, guibg = colors.grey, attr = nil }
  hi.EndOfBuffer = { guifg = colors.blue_1, guibg = nil, attr = nil }

  hi.Comment = { guifg = colors.ash_grey, guibg = nil, attr = colors.italic }
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
  hi.SpecialComment = { guifg = colors.blue_1, guibg = nil, attr = nil }
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
  hi.jsCommet = { guifg = colors.ash_grey, guibg = nil, attr = colors.italic }
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
  hi.javaScriptLineComment = { guifg = colors.ash_grey, guibg = nil, attr = colors.italic }
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

  hi.shComment = { guifg = colors.ash_grey, guibg = nil, attr = colors.italic }

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
  local hi = theme(theme_colors)
  vim.o.background = 'dark'
  vim.o.termguicolors = true
  vim.g.colors_name = "my-theme"
  for group,color in pairs(hi) do
    highlight(group, color)
  end
  vim.cmd("hi link EndOfLineSpace C_WhiteSpace")
end

return {
  highlight = highlight,
  setup = setup,
}
