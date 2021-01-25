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
  use {'itchyny/lightline.vim', as = 'lightline'}
  use 'itchyny/vim-gitbranch'
  use 'norcalli/nvim-colorizer.lua'
  use 'jiangmiao/auto-pairs'
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
  use {'sheerun/vim-polyglot',
    opt = true,
    ft = {
      'elixir',
      'fish',
      'graphql',
      'html',
      'javascript',
      'javascriptreact',
      'json',
      'jsx',
      'lua',
      'markdown',
      'mdx',
      'php',
      'python',
      'ruby',
      'scss',
      'sh',
      'svelte',
      'svg',
      'typescript',
      'vue',
    }
  }
  use {'tpope/vim-obsession', opt = true, cmd = {'Obsession', 'Obsess'} }
  use {'vifm/vifm.vim', opt = true, cmd = 'Vifm' }
  use 'rrethy/vim-illuminate'
  use 'Yggdroot/indentLine'
  use {'mg979/vim-visual-multi', branch = 'master'}

end)

