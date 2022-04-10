local plugins = {}


plugins["renerocksai/telekasten.nvim"] = {
  event = 'VimEnter',
  config = function ()
    local home = vim.fn.expand("~/zettelkasten")
    require('telekasten').setup({
      home         = home,
      take_over_my_home = true,
      auto_set_filetype = true,

      -- dir names for special notes (absolute path or subdir name)
      dailies      = home .. '/' .. 'daily',
      weeklies     = home .. '/' .. 'weekly',
      templates    = home .. '/' .. 'templates',

      image_subdir = "img",

      extension    = ".md",

      prefix_title_by_uuid = false,
      uuid_type = "%Y%m%d%H%M",
      uuid_sep = "-",

      follow_creates_nonexisting = true,
      dailies_create_nonexisting = true,
      weeklies_create_nonexisting = true,

      template_new_note = home .. '/' .. 'templates/new_note.md',

      template_new_daily = home .. '/' .. 'templates/daily.md',

      template_new_weekly= home .. '/' .. 'templates/weekly.md',

      image_link_style = "markdown",

      -- integrate with calendar-vim
      plug_into_calendar = true,
      calendar_opts = {
        weeknm = 4,
        calendar_monday = 1,
        calendar_mark = 'left-fit',
      },

      close_after_yanking = false,
      insert_after_inserting = true,
      tag_notation = "#tag",
      command_palette_theme = "dropdown",

      show_tags_theme = "dropdown",

      subdirs_in_links = true,

      template_handling = "smart",
      new_note_location = "smart",

      rename_update_links = true,
    })
  end
}

plugins["mattn/calendar-vim"] = {
  event = 'VimEnter',
}

return plugins
