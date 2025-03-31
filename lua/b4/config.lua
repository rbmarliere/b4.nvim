local M = {}

M.options = {}

local defaults = {
	log_level = "info",
	terminal = {
		layout = {
			win = 0,
			split = "below",
		},
	},
}

local log_levels = { "trace", "debug", "info", "warn", "error", "fatal" }
local set_log_level = function(log_level)
	for _, level in pairs(log_levels) do
		if level == log_level then
			return log_level
		end
	end
end

local set_options = function(options)
	if options.log_level then
		options.log_level = set_log_level(options.log_level)
	end
	M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
end

local set_commands = function()
	local terminal = require("b4.terminal")
	vim.api.nvim_create_user_command("B4", function(params)
		terminal.run("b4 " .. params.args)
	end, { nargs = "*" })
end

M.setup = function(options)
	set_options(options)
	set_commands()
end

return M
