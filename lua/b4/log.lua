local config = require("b4.config")

return require("plenary.log").new({
	plugin = "b4",
	level = config.options.log_level,
})
