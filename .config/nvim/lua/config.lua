local g = vim.g

vim.cmd('let loaded_matchit = 1')
g.loaded_python_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0
g.loaded_node_provider = 0

getopt = require('helpers').getopt
setopt = require('helpers').setopt
setBopt = require('helpers').setBopt
setWopt = require('helpers').setWopt

setopt('backup', false)
setopt('cmdheight', 1)
setopt('completeopt', 'menuone,noinsert,noselect')
setopt('hidden', true)
setopt('ignorecase', true)
setopt('inccommand', 'split')
setopt('incsearch', true)
setopt('lazyredraw', true)
setopt('listchars', 'tab:>-,extends:»,precedes:«')
setopt('redrawtime', 10000)
setopt('scrolloff', 3)
setopt('shell', '/bin/zsh')
setopt('showmatch', true)
setopt('showmode', false)
setopt('showtabline', 0)
setopt('smartcase', true)
setopt('splitbelow', true)
setopt('splitright', true)
setopt('updatetime', 250)
setopt('wildignorecase', true)
setopt('writebackup', true)
setopt('termguicolors', true)
setopt('rtp', getopt('rtp') .. ',/usr/local/opt/fzf')
setopt('shortmess', getopt('shortmess') .. 'cI' )
setopt('grepprg', 'rg --vimgrep --no-heading --smart-case --hidden')
setopt('undofile', true)

-- buffer local
setBopt('fileencoding', 'UTF-8')
setBopt('shiftwidth', 2)
setBopt('expandtab', true)
setBopt('smartindent', true)
setBopt('softtabstop', 2)
setBopt('swapfile', false)
setBopt('tabstop', 2)

-- window local
setWopt('colorcolumn', '100')
setWopt('cursorline', true)
setWopt('foldlevel', 2)
setWopt('foldmethod', 'manual')
setWopt('foldnestmax', 10)
setWopt('list', true)
setWopt('number', true)
setWopt('signcolumn', 'yes')
setWopt('winhighlight','Normal:ActiveWindow,NormalNC:InactiveWindow')
setWopt('wrap', false)

-- general
vim.cmd('syntax enable')
vim.cmd('filetype plugin indent on')
vim.cmd('colorscheme my-theme')
vim.cmd('let $TERM = "alacritty"')
vim.cmd('let $GIT_EDITOR = "nvr -cc split --remote-wait"')
vim.cmd("match EndOfLineSpace / \\+$/")

g.mapleader = " "

g["sneak#use_ic_scs"] = 1
g["sneak#target_labels"] = "asdfjkl;ghqweruioptyzxcvnmbASDFJKL:GHQWERTYUIOPZXCVNMB!@#$^&*"

-- fix for slow movement in large php files
g.php_syntax_extensions_enabled = {}
g.php_var_selector_is_identifier = 1
g.php_sql_query = 0
g.php_sql_heredoc = 0
g.php_sql_nowdoc = 0
g.php_html_load = 0
g.php_html_in_heredoc = 0
g.php_html_in_nowdoc = 0

vim.g["nnn#set_default_mappings"] = 0
vim.g["nnn#layout"] = {
 ["window"] = {
   ["width"] = 0.9,
   ["height"] = 0.9,
   ["highlight"] = "Directory"
 }
}
vim.g["nnn#command"] = 'nnn -d -H'
vim.g["nnn#action"] = {
 ['<c-x>'] = 'split',
 ['<c-v>'] = 'vsplit'
}
