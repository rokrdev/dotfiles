local getopt = vim.api.nvim_get_option
local opt = vim.opt
local g = vim.g

local function global_options()
  g["nnn#set_default_mappings"] = 0
  g["nnn#layout"] = {
   ["window"] = {
     ["width"] = 0.9,
     ["height"] = 0.9,
     ["highlight"] = "Directory"
   }
  }
  g["nnn#command"] = 'nnn -d -H'
  g["nnn#action"] = {
   ['<c-x>'] = 'split',
   ['<c-v>'] = 'vsplit'
  }

  ------ vimwiki -------
  g.custom_wiki_loc = '~/vimwiki/'
  g.vimwiki_list = {{
    path = '~/vimwiki/',
    ext = '.wiki',
  }}

  g.vimwiki_dir_link = 'index'
  g.vimwiki_global_ext = 0
  vim.cmd([[ let g:vimwiki_ext2syntax = {} ]])
  ------ vimwiki -------

  -- fix for slow movement in large php files
  g.php_syntax_extensions_enabled = {}
  g.php_var_selector_is_identifier = 1
  g.php_sql_query = 0
  g.php_sql_heredoc = 0
  g.php_sql_nowdoc = 0
  g.php_html_load = 0
  g.php_html_in_heredoc = 0
  g.php_html_in_nowdoc = 0
end

local function load_options()
  opt.termguicolors = true;
  opt.guifont = "MonoLisa Nerd Font:h13"
  opt.mouse = 'nv';
  opt.errorbells = true;
  opt.visualbell = true;
  opt.hidden = true;
  opt.fileformats = { 'unix', 'mac', 'dos' };
  opt.magic = true;
  opt.virtualedit = "block";
  opt.encoding = "utf-8";
  opt.viewoptions = { 'folds', 'cursor', 'curdir', 'slash', 'unix' };
  opt.sessionoptions = { 'curdir', 'help', 'tabpages', 'winsize' };
  opt.clipboard = "unnamedplus";
  opt.wildignorecase = true;
  opt.wildignore = { '.git', '.hg', '.svn', '*.pyc', '*.o', '*.out', '*.jpg', '*.jpeg', '*.png', '*.gif', '*.zip', '**/tmp/**', '*.DS_Store', '**/node_modules/**', '**/bower_modules/**' };
  opt.backup = false;
  opt.writebackup = false;
  opt.swapfile = false;
  opt.history = 2000;
  opt.shada = { "!","'300", "<50", "@100", "s10", "h" };
  opt.backupskip = { '/tmp/*', '$TMPDIR/*', '$TMP/*', '$TEMP/*', '*/shm/*', '/private/var/*', '.vault.vim' };
  opt.smarttab = true;
  opt.shiftround = true;
  opt.timeout = true;
  opt.ttimeout = true;
  opt.timeoutlen = 500;
  opt.ttimeoutlen = 50;
  opt.updatetime = 100;
  opt.redrawtime = 5000;
  opt.ignorecase = true;
  opt.smartcase = true;
  opt.infercase = true;
  opt.incsearch = true;
  opt.wrapscan = true;
  opt.complete = ".,w,b,k";
  opt.inccommand = "nosplit";
  opt.grepformat = "%f:%l:%c:%m";
  opt.grepprg = 'rg --hidden --vimgrep --smart-case --';
  opt.breakat = [[\ \	;:,!?]];
  opt.startofline = false;
  opt.whichwrap = "h,l,<,>,[,],~";
  opt.splitbelow = true;
  opt.splitright = true;
  opt.switchbuf = "useopen";
  opt.backspace = { 'indent', 'eol', 'start' };
  opt.diffopt = { 'filler', 'iwhite', 'internal', 'algorithm:patience' };
  opt.completeopt = { 'menuone', 'noselect' };
  opt.jumpoptions = "stack";
  opt.showmode = false;
  opt.shortmess = "aoOTIcF";
  opt.scrolloff = 4;
  opt.sidescrolloff = 5;
  opt.foldlevelstart = 99;
  opt.ruler = false;
  opt.list = true;
  opt.showtabline = 2;
  opt.winwidth = 30;
  opt.winminwidth = 10;
  opt.pumheight = 15;
  opt.helpheight = 12;
  opt.previewheight = 12;
  opt.showcmd = false;
  opt.cmdheight = 1;
  opt.cmdwinheight = 5;
  opt.equalalways = false;
  opt.laststatus = 2;
  opt.display = "lastline";
  opt.showbreak = "↳  ";
  opt.listchars = { tab = '»··', nbsp = '+', extends = '→', precedes = '←' };
  opt.showmatch = true;
  opt.fillchars = { vert = '┃', fold = '-', foldopen = '+', diff = '-', stl = ' ', stlnc = ' ', eob = '~' };

  -- buffer
  opt.undofile = true;
  opt.synmaxcol = 2500;
  opt.formatoptions = "1jcroql";
  opt.textwidth = 80;
  opt.expandtab = true;
  opt.autoindent = true;
  opt.tabstop = 2;
  opt.shiftwidth = 2;
  opt.softtabstop = -1;
  opt.breakindentopt = { shift = 2, min = 20 };
  opt.wrap = true;
  opt.linebreak = true;
  opt.number = true;
  opt.foldenable = true;
  opt.signcolumn = "yes";
  opt.conceallevel = 2;
  opt.concealcursor = "niv";
  opt.fileencoding = "utf-8";
  opt.fixeol = false;
  opt.smartindent = true;
  opt.swapfile = false;

  -- window
  opt.cursorline = true;
  opt.colorcolumn = "0";
  opt.foldlevel = 2;
  opt.foldmethod = "manual";
  opt.foldnestmax = 10;
  opt.list = true;
  opt.number = true;
  opt.signcolumn = "yes";
  opt.wrap = true;

  vim.cmd("let $TERM = 'alacritty'")
  vim.cmd("let $GIT_EDITOR = 'nvr -cc split --remote-wait'")

  local is_mac = vim.loop.os_uname().sysname == 'Darwin'

  if is_mac then
    g.clipboard = {
      name = "macOS-clipboard",
      copy = {
        ["+"] = "pbcopy",
        ["*"] = "pbcopy",
      },
      paste = {
        ["+"] = "pbpaste",
        ["*"] = "pbpaste",
      },
      cache_enabled = 0
    }
  end
  global_options()
end

load_options()
