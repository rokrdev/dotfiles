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

-- select config by machine serial number suffix (no full serials in the repo)
-- 3F4Y = home (bharat), X177 = work (bjoshi)
-- note: hs.host.serialNumber() does not exist on this hs version; parse ioreg instead
local serialOut = hs.execute("ioreg -l | grep IOPlatformSerialNumber") or ""
local serial = serialOut:match('IOPlatformSerialNumber"%s*=%s*"([^"]+)"') or ""

local tomlBySerialSuffix = {
  ["3F4Y"] = "home.toml",
  ["X177"] = "work.toml",
}

local suffix = serial:sub(-4)
spoon.Hammerflow.loadFirstValidTomlFile({ tomlBySerialSuffix[suffix] or "home.toml" })
-- optionally respect auto_reload setting in the toml config.
if spoon.Hammerflow.auto_reload then
  hs.loadSpoon("ReloadConfiguration")
  -- set any paths for auto reload
  -- spoon.ReloadConfiguration.watch_paths = {hs.configDir, "~/path/to/my/configs/"}
  spoon.ReloadConfiguration:start()
end
