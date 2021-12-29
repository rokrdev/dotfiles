local plugins = {}

plugins["vimwiki/vimwiki"] = {
  event = 'VimEnter',
  config = function ()
    vim.g.vimwiki_list = {
      {
        path = '~/vimwiki/',
        syntax = 'markdown',
        ext = '.md',
        auto_tags = true,
        auto_toc = true
      }
    }
    vim.g.vimwiki_dir_link = 'index'
  end
}

plugins["mattn/calendar-vim"] = {
  event = 'VimEnter',
}

return plugins
