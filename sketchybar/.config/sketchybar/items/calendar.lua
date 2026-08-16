local settings = require("settings")
local colors = require("colors")

-- Padding before date
sbar.add("item", { position = "right", width = settings.group_paddings })

-- Date pill: e.g. "Sun 16 Aug"
local date_item = sbar.add("item", "datetime.date", {
	label = {
		color = colors.white,
		padding_left = 8,
		padding_right = 8,
		font = {
			style = settings.font.style_map["Black"],
			size = 12.0,
		},
	},
	position = "right",
	update_freq = 30,
	padding_left = 3,
	padding_right = 3,
	background = {
		color = colors.bg2,
		border_color = { alpha = 0 },
		border_width = 1,
		height = 28,
		corner_radius = 9,
	},
	click_script = "open -a 'Calendar'",
})

-- Consistent gap between the date and time pills
sbar.add("item", { position = "right", width = settings.paddings })

-- Time pill: e.g. "9:43 PM"
local time_item = sbar.add("item", "datetime.time", {
	label = {
		color = colors.white,
		padding_left = 8,
		padding_right = 8,
		font = { family = settings.font.numbers },
	},
	position = "right",
	update_freq = 30,
	padding_left = 3,
	padding_right = 3,
	background = {
		color = colors.bg2,
		border_color = { alpha = 0 },
		border_width = 1,
		height = 28,
		corner_radius = 9,
	},
	click_script = "open -a 'Calendar'",
})

-- Padding after time
sbar.add("item", { position = "right", width = settings.group_paddings })

date_item:subscribe({ "forced", "routine", "system_woke" }, function(_env)
	date_item:set({ label = os.date("%a %d %b") })
end)

time_item:subscribe({ "forced", "routine", "system_woke" }, function(_env)
	-- 12-hour time, no leading zero on the hour. Lua's os.date() lacks %-I/%l,
	-- so grab %I (01-12) and strip the leading zero.
	-- e.g. "9:42 PM"
	local hour = os.date("%I"):gsub("^0", "")
	time_item:set({ label = hour .. os.date(":%M %p") })
end)
