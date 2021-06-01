local getopt = vim.api.nvim_get_option

local function global_options()
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

  vim.g["sneak#use_ic_scs"] = 1
  vim.g["sneak#target_labels"] = "asdfjkl;ghqweruioptyzxcvnmbASDFJKL:GHQWERTYUIOPZXCVNMB!@#$^&*"

  -- fix for slow movement in large php files
  vim.g.php_syntax_extensions_enabled = {}
  vim.g.php_var_selector_is_identifier = 1
  vim.g.php_sql_query = 0
  vim.g.php_sql_heredoc = 0
  vim.g.php_sql_nowdoc = 0
  vim.g.php_html_load = 0
  vim.g.php_html_in_heredoc = 0
  vim.g.php_html_in_nowdoc = 0
end

local function load_options()
  vim.opt.termguicolors = true;
  vim.opt.mouse = 'nv';
  vim.opt.errorbells = true;
  vim.opt.visualbell = true;
  vim.opt.hidden = true;
  vim.opt.fileformats = { 'unix', 'mac', 'dos' };
  vim.opt.magic = true;
  vim.opt.virtualedit = "block";
  vim.opt.encoding = "utf-8";
  vim.opt.viewoptions = { 'folds', 'cursor', 'curdir', 'slash', 'unix' };
  vim.opt.sessionoptions = { 'curdir', 'help', 'tabpages', 'winsize' };
  vim.opt.clipboard = "unnamedplus";
  vim.opt.wildignorecase = true;
  vim.opt.wildignore = { '.git', '.hg', '.svn', '*.pyc', '*.o', '*.out', '*.jpg', '*.jpeg', '*.png', '*.gif', '*.zip', '**/tmp/**', '*.DS_Store', '**/node_modules/**', '**/bower_modules/**' };
  vim.opt.backup = false;
  vim.opt.writebackup = false;
  vim.opt.swapfile = false;
  vim.opt.history = 2000;
  vim.opt.shada = { "!","'300", "<50", "@100", "s10", "h" };
  vim.opt.backupskip = { '/tmp/*', '$TMPDIR/*', '$TMP/*', '$TEMP/*', '*/shm/*', '/private/var/*', '.vault.vim' };
  vim.opt.smarttab = true;
  vim.opt.shiftround = true;
  vim.opt.timeout = true;
  vim.opt.ttimeout = true;
  vim.opt.timeoutlen = 1000;
  vim.opt.ttimeoutlen = 50;
  vim.opt.updatetime = 100;
  vim.opt.redrawtime = 5000;
  vim.opt.ignorecase = true;
  vim.opt.smartcase = true;
  vim.opt.infercase = true;
  vim.opt.incsearch = true;
  vim.opt.wrapscan = true;
  vim.opt.complete = ".,w,b,k";
  vim.opt.inccommand = "nosplit";
  vim.opt.grepformat = "%f:%l:%c:%m";
  vim.opt.grepprg = 'rg --hidden --vimgrep --smart-case --';
  vim.opt.breakat = [[\ \	;:,!?]];
  vim.opt.startofline = false;
  vim.opt.whichwrap = "h,l,<,>,[,],~";
  vim.opt.splitbelow = true;
  vim.opt.splitright = true;
  vim.opt.switchbuf = "useopen";
  vim.opt.backspace = { 'indent', 'eol', 'start' };
  vim.opt.diffopt = { 'filler', 'iwhite', 'internal', 'algorithm:patience' };
  vim.opt.completeopt = { 'menuone', 'noselect' };
  vim.opt.jumpoptions = "stack";
  vim.opt.showmode = false;
  vim.opt.shortmess = "aoOTIcF";
  vim.opt.scrolloff = 2;
  vim.opt.sidescrolloff = 5;
  vim.opt.foldlevelstart = 99;
  vim.opt.ruler = false;
  vim.opt.list = true;
  vim.opt.showtabline = 2;
  vim.opt.winwidth = 30;
  vim.opt.winminwidth = 10;
  vim.opt.pumheight = 15;
  vim.opt.helpheight = 12;
  vim.opt.previewheight = 12;
  vim.opt.showcmd = false;
  vim.opt.cmdheight = 1;
  vim.opt.cmdwinheight = 5;
  vim.opt.equalalways = false;
  vim.opt.laststatus = 2;
  vim.opt.display = "lastline";
  vim.opt.showbreak = "↳  ";
  vim.opt.listchars = { tab = '»··', nbsp = '+', extends = '→', precedes = '←' };
  vim.opt.showmatch = true;
  vim.opt.fillchars = { vert = ' ', fold = '-', foldopen = '+', diff = '-', stl = ' ', stlnc = ' ' };

  -- buffer
  vim.opt.undofile = true;
  vim.opt.synmaxcol = 2500;
  vim.opt.formatoptions = "1jcroql";
  vim.opt.textwidth = 80;
  vim.opt.expandtab = true;
  vim.opt.autoindent = true;
  vim.opt.tabstop = 2;
  vim.opt.shiftwidth = 2;
  vim.opt.softtabstop = -1;
  vim.opt.breakindentopt = { shift = 2, min = 20 };
  vim.opt.wrap = false;
  vim.opt.linebreak = true;
  vim.opt.number = true;
  vim.opt.foldenable = true;
  vim.opt.signcolumn = "yes";
  vim.opt.conceallevel = 2;
  vim.opt.concealcursor = "niv";
  vim.opt.fileencoding = "utf-8";
  vim.opt.fixeol = false;
  vim.opt.smartindent = true;
  vim.opt.swapfile = false;

  -- window
  vim.opt.cursorline = true;
  vim.opt.colorcolumn = "0";
  vim.opt.foldlevel = 2;
  vim.opt.foldmethod = "manual";
  vim.opt.foldnestmax = 10;
  vim.opt.list = true;
  vim.opt.number = true;
  vim.opt.signcolumn = "yes";
  vim.opt.wrap = false;

  vim.cmd("let $TERM = 'alacritty'")
  vim.cmd("let $GIT_EDITOR = 'nvr -cc split --remote-wait'")

  local is_mac = vim.loop.os_uname().sysname == 'Darwin'

  if is_mac then
    vim.g.clipboard = {
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
