local colors = require("colors")

-- Equivalent to the --bar domain
sbar.bar({
  -- 'normal' is not an accepted value; sketchybar ignores it and leaves the bar off.
  topmost = "window",
  height = 40,
  color = colors.transparent,
  padding_right = 2,
  padding_left = 2,
  margin = 10,
  shadow = true,
  blur_radius = 10,
})
