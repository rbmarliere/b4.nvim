local M = {}

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

M.options = {}

M.setup = function(options)
	if options.log_level then
		options.log_level = set_log_level(options.log_level)
	end
	M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
end

return M
