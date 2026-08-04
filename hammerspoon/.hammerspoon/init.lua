hs.loadSpoon("Hammerflow")

-- window management functions
spoon.Hammerflow.registerFunctions({
  nextDisplay = function()
    local win = hs.window.focusedWindow()
    if not win then
      return
    end
    win:moveToScreen(win:screen():next(), false, true)
  end,
})

local workLaptop = string.find(os.getenv("USER"), "bjoshi")

if workLaptop ~= nil then
  spoon.Hammerflow.loadFirstValidTomlFile({
    "work.toml",
  })
else
  spoon.Hammerflow.loadFirstValidTomlFile({
    "home.toml",
  })
end
-- optionally respect auto_reload setting in the toml config.
if spoon.Hammerflow.auto_reload then
  hs.loadSpoon("ReloadConfiguration")
  -- set any paths for auto reload
  -- spoon.ReloadConfiguration.watch_paths = {hs.configDir, "~/path/to/my/configs/"}
  spoon.ReloadConfiguration:start()
end
