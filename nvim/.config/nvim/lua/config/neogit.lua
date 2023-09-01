local neogit = require'neogit'
neogit.setup {
  disable_signs = false,
  disable_hint = false,
  disable_context_highlighting = false,
  disable_commit_confirmation = false,
  auto_refresh = true,
  disable_builtin_notifications = false,
  use_magit_keybindings = true,
  commit_popup = {
    kind = "split",
  },
  -- Change the default way of opening neogit
  kind = "tab",
  -- customize displayed signs
  signs = {
    -- { CLOSED, OPENED }
    section = { ">", "v" },
    item = { ">", "v" },
    hunk = { "", "" },
  },
  integrations = {
    diffview = true,
  },
  sections = {
    untracked = {
      hidden = false,
      folded = false
    },
    unstaged = {
      hidden = false,
      folded = false
    },
    staged = {
      hidden = false,
      folded = false
    },
    stashes = {
      hidden = false,
      folded = false
    },
    unpulled = {
      hidden = false,
      folded = true
    },
    unmerged = {
      hidden = false,
      folded = false
    },
    recent = {
      hidden = false,
      folded = true
    },
  },
}
