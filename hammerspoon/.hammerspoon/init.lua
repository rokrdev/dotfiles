hs.loadSpoon("Hammerflow")

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
