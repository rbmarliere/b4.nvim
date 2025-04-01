local M = {}
local cmd = require("b4.cmd")
local log = require("b4.log")

M.get_current_branch = function()
	local ret, stdout, stderr = cmd.git("rev-parse", "--abbrev-ref", "HEAD")
	assert(ret == 0)
	assert(stdout ~= nil)
	return stdout[1]
end

M.read_branch_description = function(branch)
	local ret, stdout, stderr = cmd.git("config", string.format("branch.%s.description", branch))
	assert(ret == 0)
	assert(stdout ~= nil)
	return stdout
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
