local wezterm = require 'wezterm'
local config = {}

config.color_scheme = 'Tokyo Night'
-- config.font = wezterm.font('MonoLisa Nerd Font', { stretch = 'Expanded', weight = 'Regular' })
-- config.font = wezterm.font('MonoLisa Nerd Font', { stretch = 'Expanded', weight = 'Regular' })
config.font = wezterm.font_with_fallback({
  { family = "MonoLisa Nerd Font",       scale = 1.1, weight = "Regular", },
  { family = "FantasqueSansM Nerd Font", scale = 1.1, },
})
config.font_size = 14
config.window_decorations = 'RESIZE'

config.front_end = "WebGpu"
config.max_fps = 144

return config
