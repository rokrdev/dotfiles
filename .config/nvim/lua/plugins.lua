local packer_exists = pcall(vim.cmd, [[packadd packer.nvim]])

if not packer_exists then
  if vim.fn.input("Install packer.nvim? (y for yes)") ~= "y" then
    return
  end

  local directory = string.format(
    '%s/site/pack/packer/opt/',
    vim.fn.stdpath('data')
    )

  vim.fn.mkdir(directory, 'p')

  local git_clone_cmd = vim.fn.system(string.format(
      'git clone %s %s',
      'https://github.com/wbthomason/packer.nvim',
      directory .. '/packer.nvim'
    ))

  print(git_clone_cmd)
  print("Installing packer.nvim...")

  return
end

vim.cmd [[packadd cfilter]]

return require('packer').startup(function()

  use {'wbthomason/packer.nvim', opt = true}
  use {
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup()
    end
  }
  use {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup()
    end
  }
  use 'junegunn/fzf.vim'
  use 'machakann/vim-sandwich'
  use {'neoclide/coc.nvim', branch = 'release'}
  use 'tpope/vim-commentary'
  use 'mhinz/vim-signify'

  -- cursor hold issue with neovim
  use 'antoinemadec/FixCursorHold.nvim'
  use {'rhysd/git-messenger.vim', opt = true, cmd = 'GitMessenger' }
  use {'styled-components/vim-styled-components',
    branch = 'main',
    opt = true,
    ft = {'javascript', 'typescript', 'javascriptreact'},
  }
  use 'justinmk/vim-sneak'
  use {'elixir-editors/vim-elixir',
    opt = true,
    ft = {'elixir'}
  }
  use {'dag/vim-fish'}
  use {'jparise/vim-graphql',
    opt = true,
    ft = {'graphql'}
  }
  use {'othree/html5.vim',
    opt = true,
    ft = {'html'}
  }
  use {'maxmellon/vim-jsx-pretty',
    requries = {'pangloss/vim-javascript'},
    config = function()
        vim.g.vim_jsx_pretty_enable_jsx_highlight = 1
        vim.g.vim_jsx_pretty_colorful_config = 1
        vim.g.vim_jsx_pretty_disable_js = 0
    end
  }
  use {'tbastos/vim-lua',
    opt = true,
    ft = {'lua'}
  }
  use {'jxnblk/vim-mdx-js',
    opt = true,
    ft = {'mdx'}
  }
  use {'StanAngeloff/php.vim',
    opt = true,
    ft = {'php', 'phtml'}
  }
  use {'vim-python/python-syntax',
    opt = true,
    ft = {'python'}
  }
  use {'tpope/vim-obsession', opt = true, cmd = {'Obsession', 'Obsess'} }
  use {'vifm/vifm.vim', opt = true, cmd = 'Vifm' }
  use 'rrethy/vim-illuminate'
  use 'Yggdroot/indentLine'
  use {'mg979/vim-visual-multi', branch = 'master'}

  use {
    'hoob3rt/lualine.nvim',
    config = function()
      local lualine = require('lualine')
      lualine.theme = 'nord'
      lualine.separator = '|'
      lualine.sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch' },
        lualine_c = { 'filename', 'signify' },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location'  },
      }
      lualine.inactive_sections = {
        lualine_a = {  },
        lualine_b = {  },
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {  },
        lualine_z = {  }
      }
      lualine.extensions = { 'fzf' }
      lualine.status()
    end
  }

end)

