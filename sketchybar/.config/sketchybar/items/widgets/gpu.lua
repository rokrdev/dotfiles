local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Execute the event provider binary which provides the event "gpu_update" for
-- the gpu load data, which is fired every 2.0 seconds.
sbar.exec("killall gpu_load >/dev/null; $CONFIG_DIR/helpers/event_providers/gpu_load/bin/gpu_load gpu_update 2.0")

local gpu = sbar.add("graph", "widgets.gpu", 42, {
	position = "right",
	graph = { color = colors.green },
	background = {
		height = 22,
		color = { alpha = 0 },
		border_color = { alpha = 0 },
		drawing = true,
	},
	icon = { string = icons.gpu },
	label = {
		string = "gpu ??%",
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Bold"],
			size = 9.0,
		},
		align = "right",
		padding_right = 0,
		width = 0,
		y_offset = 4,
	},
	padding_right = settings.paddings + 6,
})

gpu:subscribe("gpu_update", function(env)
	-- Also available: env.renderer_load, env.tiler_load
	local load = tonumber(env.device_load)
	gpu:push({ load / 100. })

	local color = colors.green
	if load > 30 then
		if load < 60 then
			color = colors.yellow
		elseif load < 80 then
			color = colors.orange
		else
			color = colors.red
		end
	end

	gpu:set({
		graph = { color = color },
		label = "gpu " .. env.device_load .. "%",
	})
end)

gpu:subscribe("mouse.clicked", function(env)
	sbar.exec("open -a 'Activity Monitor'")
end)
