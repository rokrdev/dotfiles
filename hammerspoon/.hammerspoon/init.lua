hs.loadSpoon("Hammerflow")
spoon.Hammerflow.loadFirstValidTomlFile({
  "home.toml",
})
-- optionally respect auto_reload setting in the toml config.
if spoon.Hammerflow.auto_reload then
  hs.loadSpoon("ReloadConfiguration")
  -- set any paths for auto reload
  -- spoon.ReloadConfiguration.watch_paths = {hs.configDir, "~/path/to/my/configs/"}
  spoon.ReloadConfiguration:start()
end
