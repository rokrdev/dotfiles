require('nvim-tree').setup {
  git                 = { enable = false },
  disable_netrw       = true,
  hijack_netrw        = true,
  update_cwd          = true,
  update_focused_file = {
    enable      = true,
    update_cwd  = true,
    ignore_list = {}
  },
  view                = {
    width = 30,
    side = 'left',
    hide_root_folder = true,
    adaptive_size = true,

  },
  renderer            = {
    indent_markers = {
      enable = true,
      icons = {
        corner = "└ ",
        edge = "│ ",
        none = "  ",
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

      }
    }
  },
}
