-- ~/.config/sketchybar/items/widgets/music.lua
-- Spotify controller (macOS). Drives the Spotify app via AppleScript.
local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- --- tuning ---------------------------------------------------------------
local COVER_SIZE = 26
local COVER_SCALE = 0.04
local COVER_RADIUS = 5
local SHOW_ON_RIGHT = true
local POLL_SECONDS = 2.0
local STARTUP_DELAY = 0.5 -- avoid login race when launched by brew services

local function side()
	return SHOW_ON_RIGHT and "right" or "left"
end

-- temp artwork file (writable even when started by launchd)
local ART_PATH = "/tmp/sketchybar_music_art.jpg"

-- play / pause glyphs (present in MonoLisa Nerd Font)
local GLYPH_PLAY = ""
local GLYPH_PAUSE = ""

-- --- items ----------------------------------------------------------------
-- Cover first so text aligns right after it
local cover = sbar.add("item", "widgets.music.cover", {
	position = side(),
	background = {
		image = { string = ART_PATH, scale = COVER_SCALE, corner_radius = COVER_RADIUS },
		color = colors.transparent,
		height = COVER_SIZE,
	},
	icon = { drawing = false },
	label = { drawing = false },
	padding_left = 0,
	padding_right = 6,
	updates = true,
})

-- Two-line stack (artist top, title bottom)
local MAX_CHARS = 26

local artist = sbar.add("item", "widgets.music.artist", {
	position = side(),
	width = 0, -- overlay
	padding_left = -5,
	padding_right = 0,
	y_offset = -6, -- top line
	icon = { drawing = false },
	label = {
		max_chars = MAX_CHARS,
		align = "left",
		font = { style = settings.font.style_map["Semibold"], size = 11 },
		color = colors.grey,
	},
})

local title = sbar.add("item", "widgets.music.title", {
	position = side(),
	padding_left = -5,
	padding_right = 6,
	y_offset = 6, -- bottom line
	icon = { drawing = false },
	label = {
		max_chars = MAX_CHARS,
		align = "left",
		font = { style = settings.font.style_map["Bold"], size = 13 },
		color = colors.white,
	},
})

-- Controls
local btn_next = sbar.add("item", "widgets.music.next", {
	position = side(),
	icon = { string = icons.media.forward, font = { size = 12.0 } },
	label = { drawing = false },
	padding_left = 2,
	padding_right = 0,
})
local btn_pp = sbar.add("item", "widgets.music.pp", {
	position = side(),
	icon = { string = GLYPH_PAUSE, font = { size = 12.0 } },
	label = { drawing = false },
	padding_left = 2,
	padding_right = 2,
})
local btn_prev = sbar.add("item", "widgets.music.prev", {
	position = side(),
	icon = { string = icons.media.back, font = { size = 12.0 } },
	label = { drawing = false },
	padding_left = 4,
	padding_right = 2,
})

-- Chip bracket around (cover + texts + controls)
sbar.add(
	"bracket",
	"widgets.music.bracket",
	{ btn_prev.name, btn_pp.name, btn_next.name, artist.name, title.name, cover.name },
	{ background = { color = colors.bg1, border_color = colors.black, border_width = 1, height = 26 } }
)

sbar.add("item", "widgets.music.padding", {
	position = SHOW_ON_RIGHT and "right" or "left",
	width = settings.group_paddings,
})

-- --- actions --------------------------------------------------------------
btn_prev:subscribe("mouse.clicked", function()
	sbar.exec([[/usr/bin/osascript -e 'tell application "Spotify" to previous track']])
end)
btn_pp:subscribe("mouse.clicked", function()
	sbar.exec([[/usr/bin/osascript -e 'tell application "Spotify" to playpause']])
end)
btn_next:subscribe("mouse.clicked", function()
	sbar.exec([[/usr/bin/osascript -e 'tell application "Spotify" to next track']])
end)

for _, it in ipairs({ cover, title, artist }) do
	it:subscribe("mouse.clicked", function()
		sbar.exec([[open -a "Spotify"]])
	end)
end

-- --- AppleScript helpers --------------------------------------------------
-- Returns state, title, artist, artwork_url (4 lines). guarded if not running.
local APPLESCRIPT_INFO = [[
if application "Spotify" is running then
  tell application "Spotify"
    set ps to (player state as string)
    set t to ""
    set ar to ""
    set au to ""
    try
      set t to name of current track
      set ar to artist of current track
      set au to artwork url of current track
    end try
    return ps & linefeed & t & linefeed & ar & linefeed & au
  end tell
end if
return "not_running" & linefeed & "" & linefeed & "" & linefeed & ""
]]

-- --- rendering ------------------------------------------------------------
local function ensure_visible()
	cover:set({ drawing = "on" })
	btn_prev:set({ drawing = "on" })
	btn_pp:set({ drawing = "on" })
	btn_next:set({ drawing = "on" })
	title:set({ drawing = "on" })
	artist:set({ drawing = "on" })
end

local function show_placeholder()
	ensure_visible()
	title:set({ label = { string = "—" } })
	artist:set({ label = { string = "" } })
	btn_pp:set({ icon = { string = GLYPH_PLAY } })
end

local last_art_url = nil

local function refresh_once()
	sbar.exec("/usr/bin/osascript -e '" .. APPLESCRIPT_INFO:gsub("'", [[\"]]) .. "'", function(meta)
		if not meta then
			show_placeholder()
			return
		end

		local lines, i = {}, 0
		for line in string.gmatch(meta, "[^\r\n]+") do
			lines[#lines + 1] = line
		end
		local st = lines[1] or "not_running"
		local t = lines[2] or ""
		local ar = lines[3] or ""
		local au = lines[4] or ""

		if st == "not_running" then
			show_placeholder()
			return
		end

		-- Texts
		title:set({ label = { string = (t ~= "" and t or "—") } })
		artist:set({ label = { string = (ar ~= "" and ar or "") } })

		-- Play/pause glyph from state
		btn_pp:set({ icon = { string = (st == "playing") and GLYPH_PAUSE or GLYPH_PLAY } })

		-- Artwork: re-download only when the track's art URL changes
		if au ~= "" and au ~= last_art_url then
			last_art_url = au
			sbar.exec("curl -sL -o " .. ART_PATH .. " '" .. au .. "'", function(_)
				cover:set({
					background = {
						height = COVER_SIZE,
						image = { string = ART_PATH, scale = COVER_SCALE, corner_radius = COVER_RADIUS },
					},
				})
				ensure_visible()
			end)
		else
			ensure_visible()
		end
	end)
end

local function loop()
	refresh_once()
	sbar.delay(POLL_SECONDS, loop)
end

-- small delay at login helps when started by brew services
sbar.delay(STARTUP_DELAY, loop)

-- also refresh on wake
cover:subscribe("system_woke", refresh_once)
