local settings = require("settings")
local colors = require("colors")

-- Date pill: e.g. "Sun 16 Aug". Wrapped in a bracket so the pill chrome
-- (bg1 + height 30) matches the cpu/battery/volume pills.
local date_item = sbar.add("item", "datetime.date", {
	position = "right",
	label = {
		color = colors.white,
		padding_left = 8,
		padding_right = 8,
		font = {
			style = settings.font.style_map["Black"],
			size = 12.0,
		},
	},
	icon = { drawing = false },
	updates = true,
	click_script = "open -a 'Calendar'",
})

sbar.add("bracket", "datetime.date.bracket", { date_item.name }, {
	background = {
		color = colors.bg1,
		height = 30,
	},
})

-- Consistent gap between the date and time pills (same as other pill groups)
sbar.add("item", { position = "right", width = settings.group_paddings })

-- Time pill: e.g. "9:43 PM"
local time_item = sbar.add("item", "datetime.time", {
	position = "right",
	label = {
		color = colors.white,
		padding_left = 8,
		padding_right = 8,
		font = { family = settings.font.numbers },
	},
	icon = { drawing = false },
	updates = true,
	click_script = "open -a 'Calendar'",
})

sbar.add("bracket", "datetime.time.bracket", { time_item.name }, {
	background = {
		color = colors.bg1,
		height = 30,
	},
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
