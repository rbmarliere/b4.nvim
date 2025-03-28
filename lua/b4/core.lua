local M = {}
local git = require("b4.git")

-- local function edit_cover()
-- 	local branch = get_current_branch()
-- 	if branch == nil then
-- 		vim.api.nvim_err_writeln("Not in a git repository")
-- 		return
-- 	end

-- 	local description = read_branch_description(branch)
-- 	if description == nil then
-- 		vim.api.nvim_err_writeln("Could not read branch description")
-- 		return
-- 	end

-- 	vim.cmd("new")
-- 	local buf = vim.api.nvim_get_current_buf()

-- 	vim.bo[buf].buftype = "acwrite"
-- 	vim.bo[buf].filetype = "gitcommit"
-- 	vim.api.nvim_buf_set_name(buf, string.format("b4-cover-%s-%d", branch, buf))

-- 	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(description, "\n"))

-- 	vim.api.nvim_create_autocmd("BufWriteCmd", {
-- 		buffer = buf,
-- 		callback = function()
-- 			local content = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
-- 			if write_branch_description(branch, content) then
-- 				vim.api.nvim_set_option_value("modified", false, { buf = buf })
-- 				vim.api.nvim_echo(
-- 					{ { string.format("Saved b4 cover letter for branch %s", branch), "Normal" } },
-- 					true,
-- 					{}
-- 				)
-- 				return false
-- 			else
-- 				vim.api.nvim_err_writeln("Failed to save branch description")
-- 				return true
-- 			end
-- 		end,
-- 	})
-- end

-- local function send(args)
-- 	local cmd = "b4 send" .. (args and " " .. args or "")

-- 	vim.cmd("tabnew")

-- 	local buf = vim.api.nvim_get_current_buf()

-- 	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
-- 	vim.api.nvim_set_option_value("swapfile", false, { buf = buf })

-- 	local term_ok, term_id = pcall(vim.fn.termopen, cmd, {
-- 		on_exit = function(job_id, exit_code, event_type)
-- 			if exit_code == 0 then
-- 				vim.api.nvim_echo({ { string.format("b4 send completed successfully"), "Normal" } }, true, {})
-- 			else
-- 				vim.api.nvim_err_writeln(string.format("b4 send failed with exit code: %d", exit_code))
-- 			end
-- 		end,
-- 		stderr_buffered = true,
-- 		stdout_buffered = true,
-- 	})

-- 	if not term_ok then
-- 		vim.api.nvim_err_writeln("Failed to open terminal: " .. vim.inspect(term_id))
-- 		return
-- 	end

-- 	vim.schedule(function()
-- 		vim.cmd("startinsert")
-- 	end)
-- end
-- vim.api.nvim_create_user_command("B4Send", function(opts)
-- 	send(opts.args)
-- end, { nargs = "*" })

-- local function update_trailers()
-- 	vim.cmd("tabnew")

-- 	local buf = vim.api.nvim_get_current_buf()

-- 	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
-- 	vim.api.nvim_set_option_value("swapfile", false, { buf = buf })

-- 	local term_ok, term_id = pcall(vim.fn.termopen, "b4 trailers --update", {
-- 		on_exit = function(job_id, exit_code, event_type)
-- 			if exit_code == 0 then
-- 				vim.api.nvim_echo({ { "b4 trailers --update completed successfully", "Normal" } }, true, {})
-- 			else
-- 				vim.api.nvim_err_writeln(string.format("b4 trailers --update failed with exit code: %d", exit_code))
-- 			end
-- 		end,
-- 		stderr_buffered = true,
-- 		stdout_buffered = true,
-- 	})

-- 	if not term_ok then
-- 		vim.api.nvim_err_writeln("Failed to open terminal: " .. vim.inspect(term_id))
-- 		return
-- 	end

-- 	vim.schedule(function()
-- 		vim.cmd("startinsert")
-- 	end)
-- end
-- vim.api.nvim_create_user_command("B4UpdateTrailers", update_trailers, {})

return M
