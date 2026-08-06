hs.loadSpoon("Hammerflow")

-- window management functions
local cycleAppWindows = function()
  local curr_win = hs.window.focusedWindow()
  if not curr_win then
    return
  end

  local curr_app = curr_win:application()
  local windows = curr_app:allWindows()

  -- If there is more than one window, sort/rotate through them
  if #windows > 1 then
    local next_win = nil
    for i, win in ipairs(windows) do
      if win == curr_win then
        -- Pick the next window, or loop back to the first one
        next_win = windows[i + 1] or windows[1]
        break
      end
    end
    if next_win then
      next_win:focus()
    end
  end
end

spoon.Hammerflow.registerFunctions({
  nextDisplay = function()
    local win = hs.window.focusedWindow()
    if not win then
      return
    end
    win:moveToScreen(win:screen():next(), false, true)
  end,
  cycleAppWindows = cycleAppWindows,
})

-- cmd+` cycles through the focused app's windows (overrides macOS default)
hs.hotkey.bind({"cmd"}, "`", cycleAppWindows)

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
