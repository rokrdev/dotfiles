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

cmd('let $TERM = "alacritty"')
cmd('let $GIT_EDITOR = "nvr -cc split --remote-wait"')

g.php_syntax_extensions_enabled = {}
g.php_var_selector_is_identifier = 1
g.php_sql_query = 0
g.php_sql_heredoc = 0
g.php_sql_nowdoc = 0
g.php_html_load = 0
g.php_html_in_heredoc = 0
g.php_html_in_nowdoc = 0

cmd("set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}")

g.coc_global_extensions = {
 'coc-css',
 'coc-docker',
 'coc-elixir',
 'coc-explorer',
 'coc-emmet',
 'coc-eslint',
 'coc-html',
 'coc-json',
 'coc-markdownlint',
 'coc-prettier',
 'coc-python',
 'coc-sh',
 'coc-snippets',
 'coc-tsserver',
 'coc-yaml',
}
