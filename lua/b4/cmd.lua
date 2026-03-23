local M = {}
local log = require("b4.log")
local job = require("plenary.job")

local run = function(command, args)
	args = args or {}
	log.debug("running:", command, unpack(args))
	local stderr = {}
	local stdout, ret = job:new({
		command = command,
		args = args,
		cwd = vim.loop.cwd(),
		on_stderr = function(_, data)
			table.insert(stderr, data)
		end,
		on_exit = function(j, ret)
			log.debug("exit code:", ret)
			log.debug("stdout:", vim.inspect(j:result()))
			log.debug("stderr:", vim.inspect(j:stderr_result()))
			if ret ~= 0 then
				log.error("`", command, args, "` exited with", ret)
			end
		end,
	}):sync()
	return {
		command = command,
		args = args,
		code = ret,
		stdout = stdout or {},
		stderr = stderr,
		ok = ret == 0,
	}
end

M.run = run

M.run_git = function(args)
	return run("git", args)
end

M.run_b4 = function(args)
	return run("b4", args)
end

return M
