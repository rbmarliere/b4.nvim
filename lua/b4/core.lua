local M = {}
local config = require("b4.config")
local git = require("b4.git")
local cmd = require("b4.cmd")

M.bufnr = nil
M.winnr = nil

M.is_prep_managed = function()
	local ret, stdout, stderr = cmd.b4("prep", "--show-revision")
	return ret == 0
end

-- M.edit_deps = function()
-- end

M.edit_cover = function()
	if not M.is_prep_managed() then
		return
	end
	local branch = git.get_current_branch()
	local description = git.read_branch_description(branch)

	if M.bufnr ~= nil then
		vim.api.nvim_set_current_win(M.winnr)
		return
	end

	M.bufnr = vim.api.nvim_create_buf(false, false)
	M.winnr = vim.api.nvim_open_win(M.bufnr, true, config.options.layout)
	vim.api.nvim_set_option_value("buftype", "acwrite", { buf = M.bufnr })
	vim.api.nvim_set_option_value("filetype", "gitcommit", { buf = M.bufnr })
	vim.api.nvim_buf_set_name(M.bufnr, string.format("Cover Letter (%s)", branch))
	vim.api.nvim_buf_set_lines(M.bufnr, 0, -1, false, description)

	vim.api.nvim_create_augroup("B4EditorWin", { clear = true })
	vim.api.nvim_create_autocmd("BufWriteCmd", {
		group = "B4EditorWin",
		buffer = M.bufnr,
		callback = function()
			local content = table.concat(vim.api.nvim_buf_get_lines(M.bufnr, 0, -1, false), "\n")
			if git.write_branch_description(branch, content) then
				vim.api.nvim_set_option_value("modified", false, { buf = M.bufnr })
			end
			return false
		end,
	})
	vim.api.nvim_create_autocmd("WinClosed", {
		group = "B4EditorWin",
		callback = function(args)
			if tonumber(args.match) == M.winnr and vim.api.nvim_buf_is_valid(M.bufnr) then
				vim.api.nvim_buf_delete(M.bufnr, { force = true })
				M.bufnr = nil
				M.winnr = nil
			end
		end,
	})
end

return M
