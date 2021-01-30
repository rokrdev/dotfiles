" ===============================================================
" night-owl
" ===============================================================

set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name="night-owl"

let s:bold = "bold,"
let s:italic = "italic,"
let s:underline = "underline,"

let s:white_default = '#d6deeb'
let s:white_light = '#C5E4FD'
let s:blue_default = '#011627'
let s:grey = '#4b6479'
let s:blue_dark = '#00111F'
let s:blue = '#82aaff'
let s:blue_light = '#C5E4FD'
let s:green_bright = '#addb67'
let s:pink = '#c792ea'
let s:red = '#ff5874'
let s:brown_light = '#806e6f'
let s:brown_dark = '#444444'
let s:orange_light = '#ecc48d'
let s:orange = '#f78c6c'
let s:blue_visual = '#1a2b4a'
let s:ash_grey = '#637777'
let s:cyan = '#7fdbca'
let s:yellow_light = '#fbec9f'
let s:yellow_dark = '#f4d554'
let s:highligter = '#263838'
let s:black_light = '#151d24'
let s:black = '#000000'

let g:terminal_color_foreground = "#d6deeb"
let g:terminal_color_background = "#011627"
let g:terminal_color_0 = "#011627"
let g:terminal_color_8 = "#637777"
let g:terminal_color_1 = "#ff5874"
let g:terminal_color_2 = "#addb67"
let g:terminal_color_10 = "#addb67"
let g:terminal_color_3 = "#f78c6c"
let g:terminal_color_11 = "#f78c6c"
let g:terminal_color_4 = "#82aaff"
let g:terminal_color_12 = "#82aaff"
let g:terminal_color_5 = "#c792ea"
let g:terminal_color_13 = "#c792ea"
let g:terminal_color_6 = "#7fdbca"
let g:terminal_color_14 = "#7fdbca"
let g:terminal_color_7 = "#aaaaaa"
let g:terminal_color_15 = "#eeeeee"

" function! s:hi(group, guifg, guibg, ctermfg, ctermbg, attr, guisp)
function! s:hi(group, guifg, guibg, attr, guisp)
  if a:guifg != ""
    exec "hi " . a:group . " guifg=" . a:guifg
  endif
  if a:guibg != ""
    exec "hi " . a:group . " guibg=" . a:guibg
  endif
  " if a:ctermfg != ""
  "   exec "hi " . a:group . " ctermfg=" . a:ctermfg
  " endif
  " if a:ctermbg != ""
  "   exec "hi " . a:group . " ctermbg=" . a:ctermbg
  " endif
  if a:attr != ""
    exec "hi " . a:group . " gui=" . a:attr
    " exec "hi " . a:group . " gui=" . a:attr . " cterm=" . substitute(a:attr, "undercurl", s:underline, "")
  endif
  " if a:guisp != ""
  "   exec "hi " . a:group . " guisp=" . a:guisp
  " endif
endfunction

call s:hi("Bold", "", "", s:bold, "")
call s:hi("Italic", "", "", s:italic, "")
call s:hi("Underline", "", "", s:underline, "")

call s:hi("Normal", s:white_default, s:blue_default, "", "")
call s:hi("LineNr", s:grey, s:blue_default, "", "")
call s:hi("CursorLine", "", s:blue_dark, "", "")
call s:hi("CursorLineNr", s:white_light, s:blue_dark, "", "")
call s:hi("ColorColumn", "", s:black_light, "", "")
call s:hi("Directory", s:blue, "", "", "")
call s:hi("DiffAdd", s:green_bright, s:blue_default, "", "")
call s:hi("DiffChange", s:pink, s:blue_default, "", "")
call s:hi("DiffDelete", s:red, s:blue_default, "", "")
call s:hi("DiffText", s:green_bright, s:blue_default, "", "")
call s:hi("diffAdded", "", s:green_bright, "", "")
call s:hi("diffRemoved", "", s:red, "", "")
call s:hi("VertSplit", "", s:blue, "", "")
call s:hi("MatchParen", s:pink, "", s:bold.s:underline, "")
call s:hi("Folded", s:brown_light, "", "", "")
call s:hi("FoldedColumn", s:brown_light, "", "", "")
call s:hi("SignColumn", "", s:blue_default, "", "")
call s:hi("IncSearch", s:blue_default, s:pink, "", "")
call s:hi("NonText", s:brown_dark, "", "", "")

call s:hi("PMenu", s:white_default, s:blue_visual, "", "")
call s:hi("PMenuSel", s:blue_default, s:blue, s:bold, "")
call s:hi("Search", s:blue_default, s:pink, "", "")
call s:hi("SpecialKey", s:orange_light, "", "", "")
call s:hi("Title", s:blue, "", "", "")
call s:hi("Visual", "", s:grey, "", "")
call s:hi("EndOfBuffer", s:brown_dark, s:blue_default, "", "")


call s:hi("Comment", s:ash_grey, "", s:italic, "")
call s:hi("Constant", s:green_bright, "", "", "")
call s:hi("String", s:orange_light, "", "", "")
call s:hi("Character", s:orange_light, "", "", "")
call s:hi("Number", s:orange, "", "", "")
call s:hi("Boolean", s:red, "", "", "")
call s:hi("Float", s:orange, "", "", "")
call s:hi("Identifier", s:cyan, "", "", "")
call s:hi("Function", s:blue, "", s:italic, "")
call s:hi("Statement", s:blue, "", "", "")
call s:hi("Conditional", s:white_default, "", "", "")
call s:hi("Repeat", s:white_default, "", "", "")
call s:hi("Label", s:white_default, "", "", "")
call s:hi("Operator", s:pink, "", "", "")
call s:hi("Keyword", s:blue, "", "", "")
call s:hi("Exception", s:green_bright, "", "", "")
call s:hi("PreProc", s:pink, "", "", "")
call s:hi("Include", s:pink, "", "", "")
call s:hi("Define", s:pink, "", "", "")
call s:hi("Macro", s:white_default, "", "", "")
call s:hi("PreCondit", s:white_default, "", "", "")
call s:hi("Type", s:green_bright, "", "", "")
call s:hi("StorageClass", s:pink, "", "", "")
call s:hi("Structure", s:white_default, "", "", "")
call s:hi("Typedef", s:white_default, "", "", "")
call s:hi("Special", s:white_default, "", "", "")
call s:hi("SpecialChar", "", "", "", "")
call s:hi("Tag", "", "", "", "")
call s:hi("Delimiter", s:white_default, "", "", "")
call s:hi("SpecialComment", "", "", "", "")
call s:hi("Debug", "", "", "", "")
call s:hi("Underlined", "", "", s:underline, "")
call s:hi("Ignore", "", "", "", "")
call s:hi("Error", s:red, "", s:bold, "")
call s:hi("Todo", s:cyan, "", s:bold, "")
call s:hi("htmlTag", s:ash_grey, "", "", "")
hi link htmlEndTag htmlTag

call s:hi("jsStorageClass", s:blue, "", "", "")
call s:hi("jsOperator", s:pink, "", "", "")
call s:hi("jsArrowFunction", s:pink, "", "", "")
call s:hi("jsString", s:orange_light, "", "", "")
hi link jsCommet Comment
hi link jsFuncCall Function
call s:hi("jsNumber", s:orange, "", "", "")
call s:hi("jsSpecial", s:orange, "", "", "")
call s:hi("jsObjectProp", s:cyan, "", "", "")
call s:hi("jsOperatorKeyword", s:cyan, "", "", "")
call s:hi("jsBooleanFalse", s:red, "", "", "")
call s:hi("jsBooleanTrue", s:red, "", "", "")
call s:hi("jsRegexpString", s:blue, "", "", "")
call s:hi("jsConditional", s:pink, "", "", "")
hi link jsFunction Function
call s:hi("jsReturn", s:pink, "", "", "")
call s:hi("jsFuncName", s:blue, "", "", "")
call s:hi("jsFuncParens", s:white_default, "", "", "")
call s:hi("jsParensError", s:red, "", "", "")
call s:hi("jsClassDefinition", s:orange_light, "", "", "")
call s:hi("jsImport", s:pink, "", s:italic, "")
call s:hi("jsFrom", s:pink, "", s:italic, "")
call s:hi("jsModuleAs", s:pink, "", s:italic, "")
call s:hi("jsExport", s:cyan, "", "", "")
call s:hi("jsExportDefault", s:cyan, "", "", "")
call s:hi("jsExtendsKeyword", s:pink, "", s:italic, "")
call s:hi("javaScriptReserved", s:blue, "", "", "")
call s:hi("javaScriptConditional", s:pink, "", "", "")
call s:hi("javaScriptStringS", s:orange_light, "", "", "")
call s:hi("javaScriptBoolean", s:red, "", "", "")
call s:hi("javaScriptBraces", s:white_default, "", "", "")
hi link javaScriptLineComment Comment
call s:hi("javaScriptLineSpecial", s:orange, "", "", "")
hi link javaScriptFunction Function
call s:hi("javaScriptStatement", s:pink, "", "", "")
call s:hi("javaScriptException", s:green_bright, "", "", "")

call s:hi("scssSelectorName", s:green_bright, "", "", "")
call s:hi("cssTagName", s:red, "", "", "")
call s:hi("cssClassName", s:green_bright, "", s:italic, "")
hi link cssClassNameDot cssClassName
call s:hi("cssBraces", s:white_default, "", s:italic, "")
call s:hi("cssPositioningProp", s:cyan, "", "", "")
call s:hi("cssBoxProp", s:cyan, "", "", "")
call s:hi("cssDimensionProp", s:cyan, "", "", "")
call s:hi("cssTransitionProp", s:cyan, "", "", "")
call s:hi("cssTextProp", s:cyan, "", "", "")
call s:hi("cssFontProp", s:cyan, "", "", "")
call s:hi("cssBorderProp", s:cyan, "", "", "")
call s:hi("cssBackgroundProp", s:cyan, "", "", "")
call s:hi("cssUIProp", s:cyan, "", "", "")
call s:hi("cssIEUIProp", s:red, "", "", "")
hi link scssFunctionName Function
call s:hi("cssPositioningAttr", s:red, "", "", "")
call s:hi("cssTableAttr", s:red, "", "", "")
call s:hi("cssCommonAttr", s:red, "", "", "")
call s:hi("cssColorProp", s:cyan, "", "", "")
call s:hi("cssIncludeKeyword", s:cyan, "", "", "")
call s:hi("cssKeyFrameSelector", s:cyan, "", "", "")
call s:hi("cssPseudoClassId", s:green_bright, "", s:italic, "")
call s:hi("cssBorderAttr", s:red, "", "", "")
call s:hi("cssValueLength", s:orange, "", "", "")
call s:hi("cssUnitDecorators", s:yellow_light, "", "", "")
call s:hi("cssIdentifier", s:yellow_dark, "", s:italic, "")

call s:hi("markdownHeadingDelimiter", s:ash_grey, "", "", "")
call s:hi("markdownCodeDelimiter", s:orange_light, "", "", "")
call s:hi("markdownCode", s:white_light, "", "", "")
call s:hi("mkdCodeStart", s:white_light, "", "", "")
call s:hi("mkdCodeEnd", s:white_light, "", "", "")
call s:hi("mkdLinkDef", s:cyan, "", "", "")
call s:hi("mkdCodeDelimiter", s:ash_grey, s:blue_default, "", "")

call s:hi("htmlH1", s:blue, "", "", "")
hi link htmlH2 htmlH1
hi link htmlH3 htmlH1
hi link htmlH4 htmlH1
hi link htmlH5 htmlH1
call s:hi("htmlBold", s:cyan, "", s:bold, "")

hi link shComment Comment
call s:hi("Sneak", s:black, s:pink, s:bold, "")
call s:hi("SneakLabel", s:black, s:pink, s:bold, "")

call s:hi("SignifySignAdd", s:green_bright, "", "", "")
call s:hi("SignifySignDelete", s:red, "", "", "")
call s:hi("SignifySignChange", s:orange, "", "", "")

call s:hi("illuminatedWord", "", s:highligter, "", "")

