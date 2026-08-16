return {
  paddings = 3,
  group_paddings = 5,

  -- NerdFont mode: icon glyphs come from icons.nerdfont, render in MonoLisa Nerd Font
  icons = "NerdFont", -- sf-symbols | NerdFont

  -- MonoLisa Nerd Font everywhere. Available weights: Regular, Medium, SemiBold, Bold,
  -- Light. No Heavy/Black, so those map to Bold. SemiBold is named "SemiBold Regular".
  font = {
    text = "MonoLisa Nerd Font", -- Used for text
    numbers = "MonoLisa Nerd Font", -- Used for numbers
    style_map = {
      ["Regular"] = "Regular",
      ["Semibold"] = "SemiBold Regular",
      ["Bold"] = "Bold",
      ["Heavy"] = "Bold",
      ["Black"] = "Bold",
    },
  },
}
