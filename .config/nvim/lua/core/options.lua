local global = require('core.global')
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
    rtp                    = getopt("rtp") .. ",/usr/local/opt/fzf";
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
    colorcolumn            = "100";
    foldlevel       = 2;
    foldmethod             = "manual";
    foldnestmax            = 10;
    list                   = true;
    number                 = true;
    signcolumn             = "yes";
    wrap                   = false;
  }

  local general_options = {
    "syntax enable",
    "filetype plugin indent on",
    "colorscheme my-theme",
    "let $TERM = 'alacritty'",
    "let $GIT_EDITOR = 'nvr -cc split --remote-wait'",
    "match EndOfLineSpace / \\+$/",
  }

  if global.is_mac then
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
end

load_options()
