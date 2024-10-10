-- Sequential keybindings, e.g. Hyper-a,f for Finder
local k = hs.hotkey.modal.new({}, "F17")

local appLaunchFunction = function(appname, key)
  hs.application.launchOrFocus(appname)
  key.triggered = true
  key:exit()
end

local thingsLaunchFunction = function(appname, key)
  hs.application.launchOrFocusByBundleID("com.culturedcode.ThingsMac")
  key.triggered = true
  key:exit()
end

local reload = function(_, key)
  hs.reload()
  key.triggered = true
  key:exit()
end

local finder = function(_, key)
  hs.execute("open $HOME")
  key.triggered = true
  key:exit()
end

local singleapps = {
  { "a", "Arc",           appLaunchFunction },
  { "b", "Bear",          appLaunchFunction },
  { "c", "Google Chrome", appLaunchFunction },
  { "f", "Finder",        finder },
  { "k", "Kitty",         appLaunchFunction },
  { "i", "Intellij IDEA", appLaunchFunction },
  { "m", "Spotify",       appLaunchFunction },
  { "n", "Notes",         appLaunchFunction },
  { "s", "Slack",         appLaunchFunction },
  { "t", "Things",        thingsLaunchFunction },
  { "w", "WezTerm",       appLaunchFunction },
  { "z", "Safari",        appLaunchFunction },
  { "-", "Chrysalis",     appLaunchFunction },
  { "`", "Reload",        reload },
}

for _, app in ipairs(singleapps) do
  local fun = app[3]
  k:bind({}, app[1], function()
    fun(app[2], k)
  end)
end

hs.inspect(hs.application.runningApplications())
