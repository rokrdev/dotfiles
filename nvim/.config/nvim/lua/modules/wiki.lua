local plugins = {}

plugins["vimwiki/vimwiki"] = {
  branch = 'dev',
  event = 'VimEnter',
}

plugins["mattn/calendar-vim"] = {
  event = 'VimEnter',
}

return plugins
