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
    backup                 = false;
    cmdheight              = 1;
    completeopt            = "menuone,noinsert,noselect";
    encoding               = 'utf-8';
    grepprg                = "rg --vimgrep --no-heading --smart-case --hidden";
    hidden                 = true;
    ignorecase             = true;
    inccommand             = "nosplit";
    incsearch              = true;
    lazyredraw             = true;
    listchars              = "tab:>-,extends:»,precedes:«,eol:¬";
    mouse                  = "a";
    redrawtime             = 1500;
    scrolloff              = 3;
    shell                  = "/bin/zsh";
    shortmess              = getopt("shortmess") .. "cI";
    showmatch              = true;
    showmode               = false;
    showtabline            = 0;
    smartcase              = true;
    splitbelow             = true;
    splitright             = true;
    timeout                = true;
    timeoutlen             = 500;
    ttimeout               = true;
    ttimeoutlen            = 10;
    undofile               = true;
    updatetime             = 100;
    wildignorecase         = true;
    writebackup            = true;
  }

  local bw_local  = {
    expandtab              = true;
    fileencoding           = "utf-8";
    fixeol                 = false;
    shiftwidth             = 2;
    smartindent            = true;
    softtabstop            = 2;
    swapfile               = false;
    tabstop                = 2;
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
