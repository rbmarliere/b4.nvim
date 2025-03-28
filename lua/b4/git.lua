local M = {}
local cmd = require("b4.cmd")

M.get_current_branch = function()
	local ret, stdout, stderr = cmd.git("rev-parse", "--abbrev-ref", "HEAD")
end

M.read_branch_description = function(branch)
	local ret, stdout, stderr = cmd.git("config", "branch.%s.decription", branch)
end

-- local function write_branch_description(branch, content)
-- 	local tmp_file = os.tmpname()
-- 	local file = io.open(tmp_file, "w")
-- 	if file == nil then
-- 		return false
-- 	end
-- 	file:write(content)
-- 	file:close()

-- 	local command = string.format('git config branch.%s.description "$(cat %s)"', branch, tmp_file)
-- 	local success = os.execute(command)
-- 	os.remove(tmp_file)
-- 	return success
-- end

return M
