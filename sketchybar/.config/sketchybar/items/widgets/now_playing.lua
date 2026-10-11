-- items/widgets/now_playing.lua
-- Now-playing pill for Spotify and Apple Music, ported to Lua from
-- tcmmichaelb139/.dotfiles, adapted to the sbarLua setup.
--
-- macOS 15.4+/26 blocks sketchybar's native media_change event (MediaRemote
-- entitlement). We bridge now-playing through media-control (event-driven,
-- reads via privileged /usr/bin/perl) -> helpers/now_playing_stream.sh -> the
-- custom `now_playing_change` event below. No polling.
local colors = require("colors")
local settings = require("settings")

-- Keyed by the bundle ID media-control reports; apps not listed stay hidden.
local APPS = {
  ["com.spotify.client"] = { icon = "󰓇", color = colors.green },
  ["com.apple.Music"] = { icon = "󰀵", color = colors.red },
}

local now_playing = sbar.add("item", "widgets.now_playing", {
  position = "right",
  scroll_texts = "on",
  updates = true,
  drawing = "off",
  icon = {
    font = { family = settings.font.text, style = settings.font.style_map["Regular"], size = 13.0 },
    padding_left = 10,
  },
  label = {
    string = "",
    max_chars = 20,
    color = colors.white,
    font = { family = settings.font.text, style = settings.font.style_map["Black"], size = 12.0 },
    padding_right = 10,
  },
  background = {
    color = colors.bg1,
    height = 30,
    corner_radius = 9,
    border_width = 1,
    border_color = colors.black,
  },
  padding_left = settings.paddings,
  padding_right = settings.paddings,
})

sbar.add("event", "now_playing_change")

local current_app = ""

now_playing:subscribe("now_playing_change", function(env)
  local playing = env.playing == "true"
  local app = APPS[env.app or ""]
  local title = env.title or ""
  local artist = env.artist or ""

  if playing and app and title ~= "" then
    local label = artist ~= "" and (title .. " - " .. artist) or title
    -- Only table keys are stored, so the click command never sees raw event input.
    current_app = env.app
    now_playing:set({
      drawing = "on",
      icon = { string = app.icon, color = app.color },
      label = { string = label },
    })
  else
    now_playing:set({ drawing = "off" })
  end
end)

now_playing:subscribe("mouse.clicked", function()
  if current_app ~= "" then
    sbar.exec("open -b " .. current_app)
  end
end)

-- Keep the now_playing_change stream alive for the life of the bar.
local STREAM = "$CONFIG_DIR/helpers/now_playing_stream.sh"
sbar.exec("pkill -f now_playing_stream.sh >/dev/null 2>&1; " .. STREAM .. " &> /dev/null &")
