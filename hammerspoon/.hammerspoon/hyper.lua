-- Sequential keybindings, e.g. Hyper-a,f for Finder
local k = hs.hotkey.modal.new({"alt"}, "`")

local appLaunchFunction = function (appname, key)
  hs.application.launchOrFocus(appname)
  key.triggered = true
  key:exit();
end

local reload = function (_, key)
  hs.reload();
  key.triggered = true
  key:exit();
end

local singleapps = {
  {'a', 'Arc', appLaunchFunction},
  {'b', 'Brave Browser', appLaunchFunction},
  {'c', 'Google Chrome', appLaunchFunction},
  {'e', 'Evernote', appLaunchFunction},
  {'k', 'Kitty', appLaunchFunction},
  {'i', 'Intellij IDEA', appLaunchFunction},
  {'l', 'Logseq', appLaunchFunction},
  {'m', 'Spotify', appLaunchFunction},
  {'s', 'Slack', appLaunchFunction},
  {'t', 'Todoist', appLaunchFunction},
  {'-', 'Chrysalis', appLaunchFunction},
  {'`', 'Reload', reload},
}

for _, app in ipairs(singleapps) do
  local fun = app[3]
  k:bind({}, app[1], function() fun(app[2], k) end)
end

