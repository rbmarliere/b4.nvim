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

M.read_branch_tracking_data = function(branch)
	local tracking_json, err = M.read_branch_tracking(branch)
	if tracking_json == nil then
		return nil, err
	end
	local ok, tracking = pcall(vim.json.decode, table.concat(tracking_json))
	if not ok then
		err = string.format("could not decode b4 tracking for `%s`: %s", branch, tracking)
		log.error(err)
		return nil, err
	end
	return tracking
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

M.write_branch_tracking_data = function(branch, tracking)
	local ok, tracking_json = pcall(vim.json.encode, tracking)
	if not ok then
		local err = string.format("could not encode b4 tracking for `%s`: %s", branch, tracking_json)
		log.error(err)
		return false, err
	end
	return M.write_branch_tracking(branch, tracking_json)
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

M.is_prep_managed = function(branch)
	local ret, stdout, stderr = cmd.git("config", "get", string.format("branch.%s.b4-prep-cover-strategy", branch))
	if ret ~= 0 then
		log.error("This is not a prep-managed branch.")
		log.debug(get_error(stderr, "git config failed"))
		return false
	end
	if stdout and stdout[1] ~= "branch-description" then
		log.error("Only 'branch-description' b4-prep-cover-strategy is supported.")
		return false
	end
	return true
end

return M
