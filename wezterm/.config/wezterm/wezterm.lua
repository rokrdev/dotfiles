local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

-- ============================================================
-- Font
-- ============================================================
config.font = wezterm.font_with_fallback({
  { family = "MonoLisa Nerd Font", weight = "Regular" },
  "Symbols Nerd Font Mono",
  "Apple Color Emoji",
})
config.font_size = 14.0

-- ============================================================
-- Color scheme
-- ============================================================
config.color_scheme = "Tokyo Night"

-- ============================================================
-- Window
-- ============================================================
config.window_decorations = "RESIZE"
config.window_padding = { left = 12, right = 12, top = 12, bottom = 12 }
config.initial_cols = 200
config.initial_rows = 50
config.window_background_opacity = 1.0

-- ============================================================
-- Tab bar
-- ============================================================
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true

-- ============================================================
-- Scrollback
-- ============================================================
config.scrollback_lines = 10000

-- ============================================================
-- Cursor
-- ============================================================
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- ============================================================
-- Bell
-- ============================================================
config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_function = "EaseIn",
  fade_in_duration_ms = 75,
  fade_out_function = "EaseOut",
  fade_out_duration_ms = 75,
}

-- ============================================================
-- Mouse
-- ============================================================
config.mouse_bindings = {
  -- Right-click pastes from clipboard
  {
    event = { Down = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = act.PasteFrom("Clipboard"),
  },
}
-- Selection auto-copies to clipboard
config.selection_word_boundary = " \t\n{}[]()\"',;:@"

-- ============================================================
-- Misc
-- ============================================================
config.check_for_updates = false
config.enable_kitty_graphics = true
config.unicode_version = 14

-- macOS Option key: send escape sequences (Alt) instead of composed Unicode glyphs.
-- Without this, Option+h/j/k/l sends ˙/∆/˚/¬ and Zellij never sees Alt+hjkl.
if wezterm.target_triple:find("darwin") then
  config.send_composed_key_when_left_alt_is_pressed = false
  config.send_composed_key_when_right_alt_is_pressed = false
end

-- ============================================================
-- Keybindings (macOS)
-- ============================================================
config.leader = { key = "w", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
  -- Tabs
  { key = "t", mods = "SUPER", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "w", mods = "SUPER", action = act.CloseCurrentTab({ confirm = true }) },

  -- Pane splits (tmux: leader + % / ")
  { key = "\\", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

  -- Pane navigation (tmux: leader + hjkl)
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

  -- Clear scrollback
  {
    key = "k",
    mods = "SUPER",
    action = act.Multiple({
      act.ClearScrollback("ScrollbackAndViewport"),
      act.SendKey({ key = "l", mods = "CTRL" }),
    }),
  },

  -- Find
  { key = "f", mods = "SUPER", action = act.Search({ CaseInSensitiveString = "" }) },

  -- Copy / Paste
  { key = "c", mods = "SUPER", action = act.CopyTo("Clipboard") },
  { key = "v", mods = "SUPER", action = act.PasteFrom("Clipboard") },

  -- Maximize window
  {
    key = "Enter",
    mods = "SUPER",
    action = wezterm.action_callback(function(_, win)
      win:maximize()
    end),
  },
}

-- ============================================================
-- Mux server (unix domain)
-- ============================================================
config.unix_domains = {
  {
    name = "unix",
    -- socket at default path: ~/.local/share/wezterm/sock
    no_serve_automatically = true,
  },
}
-- Auto-connect to local mux server on GUI launch
config.default_gui_startup_args = { "connect", "unix" }

return config
