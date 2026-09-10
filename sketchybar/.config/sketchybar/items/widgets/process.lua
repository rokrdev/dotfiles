local colors = require("colors")
local settings = require("settings")

require("items.widgets.memory")
require("items.widgets.cpu")
require("items.widgets.gpu")

sbar.add("bracket", "widgets.process.bracket", { "widgets.cpu", "widgets.memory", "widgets.gpu" }, {
	background = {
		color = colors.bg1,
		height = 30,
	},
})

sbar.add("item", "widgets.process.padding", {
	position = "right",
	width = settings.group_paddings,
})
