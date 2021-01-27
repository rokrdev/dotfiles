local g = vim.g
local cmd = vim.cmd

g.mapleader = " "

g.Illuminate_delay = 500
g.Illuminate_highlightUnderCursor = 1

g.indentLine_char = 'c'
g.indentLine_char_list = {'│'}
g.indentLine_fileTypeExclude = {'coc-explorer'}
g.indentLine_bufTypeExclude = {'help', 'terminal'}
g.indentLine_bufNameExclude = {'vifm'}

g.signify_sign_add = '│'
g.signify_sign_change = '│'
g.signify_sign_delete = '_'

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


g.fzf_layout = {
  ['window'] = {
    ['width'] = 0.9,
    ['height'] = 0.9,
    ['border'] = 'rounded',
    ['highlight'] = 'Directory'
  }
}

g.fzf_buffers_jump = 1

g.fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'

g.fzf_commands_expect = 'alt-enter,ctrl-x'

g.fzf_action = {
  ['ctrl-x'] = 'split',
  ['ctrl-v'] = 'vsplit'
}

g.fzf_preview_window = 'right:50%'

cmd("highlight default link EndOfLineSpace ErrorMsg")
cmd("match EndOfLineSpace / \\+$/")


g['sneak#use_ic_scs'] = 1
g['sneak#target_labels'] = "asdfjkl;ghqweruioptyzxcvnmb"

