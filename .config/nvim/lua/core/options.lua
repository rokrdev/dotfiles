local getopt = vim.api.nvim_get_option

local function bind_option(options)
  for k, v in pairs(options) do
    if v == true or v == false then
      vim.cmd('set ' .. k)
    else
      vim.cmd('set ' .. k .. '=' .. v)
    end
  end
end

local function bind_general_options(options)
  for _, v in ipairs(options) do
    vim.cmd(v)
  end
end


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
  local global_local = {
    termguicolors  = true;
    mouse          = "nv";
    errorbells     = true;
    visualbell     = true;
    hidden         = true;
    fileformats    = "unix,mac,dos";
    magic          = true;
    virtualedit    = "block";
    encoding       = "utf-8";
    viewoptions    = "folds,cursor,curdir,slash,unix";
    sessionoptions = "curdir,help,tabpages,winsize";
    clipboard      = "unnamedplus";
    wildignorecase = true;
    wildignore     = ".git,.hg,.svn,*.pyc,*.o,*.out,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**";
    backup         = false;
    writebackup    = false;
    swapfile       = false;
    history        = 2000;
    shada          = "!,'300,<50,@100,s10,h";
    backupskip     = "/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim";
    smarttab       = true;
    shiftround     = true;
    timeout        = true;
    ttimeout       = true;
    timeoutlen     = 500;
    ttimeoutlen    = 10;
    updatetime     = 100;
    redrawtime     = 1500;
    ignorecase     = true;
    smartcase      = true;
    infercase      = true;
    incsearch      = true;
    wrapscan       = true;
    complete       = ".,w,b,k";
    inccommand     = "nosplit";
    grepformat     = "%f:%l:%c:%m";
    grepprg        = 'rg --hidden --vimgrep --smart-case --';
    breakat        = [[\ \	;:,!?]];
    startofline    = false;
    whichwrap      = "h,l,<,>,[,],~";
    splitbelow     = true;
    splitright     = true;
    switchbuf      = "useopen";
    backspace      = "indent,eol,start";
    diffopt        = "filler,iwhite,internal,algorithm:patience";
    completeopt    = "menuone,noselect";
    jumpoptions    = "stack";
    showmode       = false;
    shortmess      = "aoOTIcF";
    scrolloff      = 2;
    sidescrolloff  = 5;
    foldlevelstart = 99;
    ruler          = false;
    list           = true;
    showtabline    = 2;
    winwidth       = 30;
    winminwidth    = 10;
    pumheight      = 15;
    helpheight     = 12;
    previewheight  = 12;
    showcmd        = false;
    cmdheight      = 1;
    cmdwinheight   = 5;
    equalalways    = false;
    laststatus     = 2;
    display        = "lastline";
    showbreak      = "↳  ";
    listchars      = "tab:»·,nbsp:+,trail:·,extends:→,precedes:←";
    -- pumblend       = 10;
    -- winblend       = 10;
    showmatch      = true;
  }

  local bw_local  = {
    undofile       = true;
    synmaxcol      = 2500;
    formatoptions  = "1jcroql";
    textwidth      = 80;
    expandtab      = true;
    autoindent     = true;
    tabstop        = 2;
    shiftwidth     = 2;
    softtabstop    = -1;
    breakindentopt = "shift:2,min:20";
    wrap           = false;
    linebreak      = true;
    number         = true;
    colorcolumn    = "80";
    foldenable     = true;
    signcolumn     = "yes";
    conceallevel   = 2;
    concealcursor  = "niv";
    fileencoding   = "utf-8";
    fixeol         = false;
    smartindent    = true;
    swapfile       = false;
  }

  local wn_local  = {
    cursorline             = true;
    colorcolumn            = "0";
    foldlevel              = 2;
    foldmethod             = "manual";
    foldnestmax            = 10;
    list                   = true;
    number                 = true;
    signcolumn             = "yes";
    wrap                   = false;
  }

  local general_options = {
    "let $TERM = 'alacritty'",
    "let $GIT_EDITOR = 'nvr -cc split --remote-wait'",
  }

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
  for name, value in pairs(global_local) do
    vim.o[name] = value
  end
  bind_option(bw_local)
  bind_option(wn_local)
  bind_general_options(general_options)
  global_options()
end

load_options()
