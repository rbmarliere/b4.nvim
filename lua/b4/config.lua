local M = {}

M.options = {}

local defaults = {
	log_level = "info",
	window = {
		new_tab = false,
		layout = {
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
	options = vim.tbl_deep_extend("force", {}, options or {})
	if options.log_level then
		options.log_level = set_log_level(options.log_level)
	end
	M.options = vim.tbl_deep_extend("force", {}, defaults, options)
end

local is_prep_editor_cmd = function(fargs, action)
	return #fargs == 2 and fargs[1] == "prep" and fargs[2] == action
end

local shell_join = function(argv)
	local cmd = {}
	for _, arg in ipairs(argv) do
		table.insert(cmd, vim.fn.shellescape(arg))
	end
	return table.concat(cmd, " ")
end

local set_commands = function()
	local terminal = require("b4.terminal")
	local core = require("b4.core")
	pcall(vim.api.nvim_del_user_command, "B4")
	vim.api.nvim_create_user_command("B4", function(params)
		if is_prep_editor_cmd(params.fargs, "--edit-cover") then
			return core.edit_cover()
		elseif is_prep_editor_cmd(params.fargs, "--edit-deps") then
			return core.edit_deps()
		end
		terminal.run(shell_join(vim.list_extend({ "b4" }, params.fargs)))
	end, { nargs = "*" })
end

M.setup = function(options)
	set_options(options)
	set_commands()
end

return M
