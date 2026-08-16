-- items/widgets/spotify.lua
-- Spotify "now playing" pill, ported to Lua from tcmmichaelb139/.dotfiles
-- (plugins/spotify.sh + items/spotify.sh), adapted to the sbarLua setup.
--
-- macOS 15.4+/26 blocks sketchybar's native media_change event (MediaRemote
-- entitlement). We bridge now-playing through media-control (event-driven,
-- reads via privileged /usr/bin/perl) -> helpers/spotify_stream.sh -> the
-- custom `spotify_change` event below. No polling.
local colors = require("colors")
local settings = require("settings")

local SPOTIFY_GLYPH = "󰎆" -- Nerd Font spotify glyph (MonoLisa Nerd Font)

local spotify = sbar.add("item", "widgets.spotify", {
	position = "right",
	scroll_texts = "on",
	updates = true,
	drawing = "off",
	icon = {
		string = SPOTIFY_GLYPH,
		color = colors.green,
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
		height = 26,
		corner_radius = 9,
		border_width = 1,
		border_color = colors.black,
	},
	padding_left = settings.paddings,
	padding_right = settings.paddings,
})

sbar.add("event", "spotify_change")

spotify:subscribe("spotify_change", function(env)
	local playing = env.playing == "true"
	local app = env.app or ""
	local title = env.title or ""
	local artist = env.artist or ""

	if playing and app == "com.spotify.client" and title ~= "" then
		local label = artist ~= "" and (title .. " - " .. artist) or title
		spotify:set({ drawing = "on", label = { string = label } })
	else
		spotify:set({ drawing = "off" })
	end
end)

-- Clicking the pill opens the Spotify app.
spotify:subscribe("mouse.clicked", function()
	sbar.exec("osascript -e 'tell application \"Spotify\" to activate'")
end)

-- Keep the spotify_change stream alive for the life of the bar.
local STREAM = "$CONFIG_DIR/helpers/spotify_stream.sh"
sbar.exec("pkill -f spotify_stream.sh >/dev/null 2>&1; " .. STREAM .. " &> /dev/null &")
