local M = {}
M.options = {}

local defaults = {
	log_level = "info",
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
	local cmd = require("b4.cmd")
	vim.api.nvim_create_user_command("B4", function(params)
		local ret, stdout, stderr = cmd.b4(vim.split(params.args, " "))
	end, { nargs = "*"})
end

M.setup = function(options)
	set_options(options)
	set_commands()
end

return M
