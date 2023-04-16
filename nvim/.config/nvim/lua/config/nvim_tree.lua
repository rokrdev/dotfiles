require('nvim-tree').setup {
  disable_netrw       = true,
  hijack_netrw        = true,
  update_cwd          = true,
  sync_root_with_cwd  = true,
  update_focused_file = {
    enable      = true,
    update_cwd  = true,
    ignore_list = {}
  },
  view                = {
    width = 30,
    side = 'left',
    adaptive_size = true,
  },
  git = {
    enable = true,
    ignore = true,
    show_on_dirs = true,
    timeout = 400,
  },
  renderer            = {
    root_folder_label = false,
    indent_markers = {
      enable = false,
      icons = {
        corner = "│",
        edge = "│",
        none = " ",
      },
    },
    icons = {
      glyphs = {
        default = '',
        symlink = '',
        git = {
          unstaged = "✚",
          staged = "✚",
          unmerged = "≠",
          renamed = "≫",
          untracked = "★",
        },
      },
      show = {
        file = true,
        folder = true,
        folder_arrow = false,
        git = true,
      }
    }
  },
}
