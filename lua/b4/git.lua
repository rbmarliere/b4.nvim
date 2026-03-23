local M = {}
local cmd = require("b4.cmd")
local log = require("b4.log")

local get_error = function(stderr, fallback)
	if stderr then
		local lines = vim.tbl_filter(function(line)
			return line ~= nil and line ~= ""
		end, stderr)
		if #lines > 0 then
			return table.concat(lines, "\n")
		end
	end
	return fallback
end

M.get_current_branch = function()
	local ret, stdout, stderr = cmd.git("rev-parse", "--abbrev-ref", "HEAD")
	if ret ~= 0 or stdout == nil or stdout[1] == nil then
		local err = get_error(stderr, "could not determine current branch")
		log.error(err)
		return nil, err
	end
	return stdout[1]
end

M.read_branch_config = function(branch, config)
	local key = string.format("branch.%s.%s", branch, config)
	local ret, stdout, stderr = cmd.git("config", "get", key)
	if ret ~= 0 or stdout == nil then
		local err = string.format("could not read `%s`: %s", key, get_error(stderr, "git config failed"))
		log.error(err)
		return nil, err
	end
	return stdout
end

M.read_branch_tracking = function(branch)
	return M.read_branch_config(branch, "b4-tracking")
end

M.write_branch_tracking = function(branch, tracking)
	local ret, stdout, stderr = cmd.git("config", "set", string.format("branch.%s.b4-tracking", branch), tracking)
	if ret ~= 0 then
		local err = get_error(stderr, "could not update b4 tracking")
		log.error(err)
		return false, err
	end
	return true
end

M.read_branch_description = function(branch)
	return M.read_branch_config(branch, "description")
end

M.write_branch_description = function(branch, description)
	if description == "" then
		log.error("Refusing to write empty branch description")
		return false, "Refusing to write empty branch description"
	end
	local ret, stdout, stderr = cmd.git("config", "set", string.format("branch.%s.description", branch), description)
	if ret ~= 0 then
		local err = get_error(stderr, "could not update branch description")
		log.error(err)
		return false, err
	end
	return true
end

return M
