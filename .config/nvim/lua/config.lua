local g = vim.g
local cmd = vim.cmd

g.mapleader = " "
g.cursorhold_updatetime = 100

g.Illuminate_delay = 500
g.Illuminate_highlightUnderCursor = 1

g.indentLine_char = 'c'
g.indentLine_char_list = {'│'}
g.indentLine_fileTypeExclude = {'coc-explorer'}
g.indentLine_bufTypeExclude = {'help', 'terminal'}
g.indentLine_bufNameExclude = {'vifm'}

require'colorizer'.setup()

cmd('colorscheme night-owl')

g.vim_markdown_conceal = 0

cmd('let $GIT_EDITOR = "nvr -cc split --remote-wait"')
