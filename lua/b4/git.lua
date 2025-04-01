local M = {}
local cmd = require("b4.cmd")
local log = require("b4.log")

M.get_current_branch = function()
	local ret, stdout, stderr = cmd.git("rev-parse", "--abbrev-ref", "HEAD")
	assert(ret == 0)
	assert(stdout ~= nil)
	return stdout[1]
end

M.read_branch_config = function(branch, config)
	local ret, stdout, stderr = cmd.git("config", string.format("branch.%s.%s", branch, config))
	assert(ret == 0)
	assert(stdout ~= nil)
	return stdout
end

M.read_branch_tracking = function(branch)
	return M.read_branch_config(branch, "b4-tracking")
end

M.write_branch_tracking = function(branch, tracking)
	local ret, stdout, stderr = cmd.git("config", "set", string.format("branch.%s.b4-tracking", branch), tracking)
	return ret == 0
end

M.read_branch_description = function(branch)
	return M.read_branch_config(branch, "description")
end

M.write_branch_description = function(branch, description)
	if description == "" then
		log.error("Refusing to write empty branch description")
		return false
	end
	local ret, stdout, stderr = cmd.git("config", "set", string.format("branch.%s.description", branch), description)
	return ret == 0
end

return M
