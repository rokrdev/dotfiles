local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- Register aerospace workspace-change event (fired by AeroSpace's exec-on-workspace-change)
sbar.add("event", "aerospace_workspace_change")

-- Tiling indicator (decorative)
sbar.add("item", "space.tiling", {
	icon = {
		font = { family = settings.font.text },
		string = icons.tiling,
		padding_left = 10,
		padding_right = 10,
		color = colors.white,
	},
	label = { drawing = false },
	padding_right = 1,
	padding_left = 1,
	background = {
		color = colors.transparent,
		height = 28,
		border_width = 0,
	},
})

-- Single active workspace indicator: shows the focused workspace on the focused monitor
local active = sbar.add("item", "space.active", {
	icon = {
		font = { family = settings.font.numbers },
		string = "1",
		padding_left = 10,
		padding_right = 10,
		color = colors.black,
	},
	label = { drawing = false },
	padding_right = 1,
	padding_left = 1,
	background = {
		color = colors.white,
		height = 28,
		corner_radius = 6,
		border_width = 0,
	},
})

local function set_active(id)
	if id == nil or id == "" then
		id = "1"
	end
	active:set({ icon = { string = tostring(id) } })
end

active:subscribe("aerospace_workspace_change", function(env)
	set_active(env.FOCUSED_WORKSPACE)
end)

-- Wrapping bracket (chip) behind the workspace items
sbar.add("bracket", { "/space\\..*/" }, {
	background = {
		color = colors.bg2,
		height = 30,
	},
})

-- Padding after the workspace chip
sbar.add("item", "space.padding", {
	width = settings.group_paddings,
})

-- Spaces toggle indicator (swaps between the active workspace and the menus)
local spaces_indicator = sbar.add("item", {
	padding_left = 0,
	padding_right = 0,
	icon = {
		padding_left = 8,
		padding_right = 4,
		color = colors.white,
		string = icons.switch.on,
	},
	label = {
		width = 0,
		padding_left = 8,
		padding_right = 8,
		string = "Spaces",
		color = colors.white,
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Semibold"],
		},
	},
	background = {
		height = 30,
		color = colors.with_alpha(colors.bg2, 0.0),
		border_color = { alpha = 0 },
	},
})

spaces_indicator:subscribe("swap_menus_and_spaces", function()
	local currently_on = spaces_indicator:query().icon.value == icons.switch.on
	spaces_indicator:set({
		icon = currently_on and icons.switch.off or icons.switch.on,
	})
end)

spaces_indicator:subscribe("mouse.entered", function()
	sbar.animate("tanh", 30, function()
		spaces_indicator:set({
			background = {
				color = { alpha = 0.67 },
				border_color = { alpha = 0.67 },
			},
			label = { width = "dynamic" },
		})
	end)
end)

spaces_indicator:subscribe("mouse.exited", function()
	sbar.animate("tanh", 30, function()
		spaces_indicator:set({
			background = {
				color = { alpha = 0.0 },
				border_color = { alpha = 0 },
			},
			label = { width = 0 },
		})
	end)
end)

spaces_indicator:subscribe("mouse.clicked", function()
	sbar.trigger("swap_menus_and_spaces")
end)

-- Initialize with the current focused workspace
sbar.exec("aerospace list-workspaces --focused", function(focused)
	set_active(focused:gsub("%s+", ""))
end)
