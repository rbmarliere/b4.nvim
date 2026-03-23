local M = {}
local config = require("b4.config")
local git = require("b4.git")
local log = require("b4.log")

M.bufnr = nil
M.winnr = nil

local notify_error = function(message)
	log.error(message)
	vim.notify(message, vim.log.levels.ERROR, { title = "b4.nvim" })
end

-- https://web.git.kernel.org/pub/scm/utils/b4/b4.git/tree/src/b4/ez.py?id=c25d17121045ab14bec8912d490ba764b515b370#n86
local DEPS_HELPER = {
	"",
	"",
	"# All lines starting with # will be removed",
	"#",
	"# You can define series prerequisites using the following formats:",
	"#",
	"# patch-id: [patch-id as returned by git-patch-id --stable]",
	"# change-id: [the change-id of a series, followed by a colon and series version]",
	"# message-id: <[the message-id of a series]>",
	"# base-commit: [commit-ish where to apply all prerequisites and your series]",
	"#",
	"# IMPORTANT: specify all dependencies in the order they must be applied",
	"#",
	"# For example:",
	"# ------------",
	"# patch-id: 7709c0eec24c2c0c973d6af92c7915b8d0a2e52c",
	"# change-id: 20240320-example-change-id:v1",
	"# change-id: 20240320-some-other-example-change-id:v5",
	"# message-id: <20240320-some-prereq-series-v1-0@example.com>",
	"# base-commit: v6.9-rc1",
	"#",
	"# All dependencies will be checked and converted into prerequisite-patch-id: entries",
	'# during "b4 send".',
}

-- https://web.git.kernel.org/pub/scm/utils/b4/b4.git/tree/src/b4/ez.py?id=c25d17121045ab14bec8912d490ba764b515b370#n809
local recognized = {
	"^patch%-id:",
	"^change%-id:",
	"^message%-id:",
	"^base%-commit:",
}

local open = function(bufname, lines, callback)
	if M.bufnr ~= nil then
		vim.api.nvim_set_current_win(M.winnr)
		return
	end

	M.bufnr = vim.api.nvim_create_buf(false, false)
	if config.options.window.new_tab then
		vim.cmd("-tab new")
		M.winnr = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(0, M.bufnr)
	else
		M.winnr = vim.api.nvim_open_win(M.bufnr, true, config.options.window.layout)
	end
	vim.api.nvim_set_option_value("buftype", "acwrite", { buf = M.bufnr })
	vim.api.nvim_set_option_value("filetype", "gitcommit", { buf = M.bufnr })
	vim.api.nvim_buf_set_name(M.bufnr, bufname)
	vim.api.nvim_buf_set_lines(M.bufnr, 0, -1, false, lines)

	vim.api.nvim_create_augroup("B4EditorWin", { clear = true })
	vim.api.nvim_create_autocmd("BufWriteCmd", {
		group = "B4EditorWin",
		buffer = M.bufnr,
		callback = callback,
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

M.edit_deps = function()
	-- TODO support other strategies (e.g. if "commit", tracking is kept in the commit aswell)
	local branch, branch_err = git.get_current_branch()
	if branch == nil then
		return notify_error(branch_err)
	end
	if not git.is_prep_managed(branch) then
		return
	end
	local bufname = string.format("B4 Prerequisites (%s)", branch)

	local tracking, tracking_err = git.read_branch_tracking_data(branch)
	if tracking == nil then
		return notify_error(tracking_err)
	end
	local content = tracking.series.prerequisites or {}
	for _, ln in ipairs(DEPS_HELPER) do
		table.insert(content, ln)
	end

	open(bufname, content, function()
		local new_content = {}
		for _, ln in ipairs(vim.api.nvim_buf_get_lines(M.bufnr, 0, -1, false)) do
			if ln:find("^#") == nil and ln:find("^$") == nil then
				for _, pat in ipairs(recognized) do
					if ln:find(pat) then
						table.insert(new_content, ln)
						goto next
					end
				end
				log.warn("Unrecognized entry in line:", ln)
			end
			::next::
		end
		tracking.series.prerequisites = new_content
		local written, write_err = git.write_branch_tracking_data(branch, tracking)
		if written then
			vim.api.nvim_set_option_value("modified", false, { buf = M.bufnr })
		else
			notify_error(write_err)
		end
		return false
	end)
end

M.edit_cover = function()
	-- TODO support other strategies
	local branch, branch_err = git.get_current_branch()
	if branch == nil then
		return notify_error(branch_err)
	end
	if not git.is_prep_managed(branch) then
		return
	end
	local bufname = string.format("B4 Cover Letter (%s)", branch)
	local description, description_err = git.read_branch_description(branch)
	if description == nil then
		return notify_error(description_err)
	end
	open(bufname, description, function()
		local new_content = table.concat(vim.api.nvim_buf_get_lines(M.bufnr, 0, -1, false), "\n")
		local written, write_err = git.write_branch_description(branch, new_content)
		if written then
			vim.api.nvim_set_option_value("modified", false, { buf = M.bufnr })
		else
			notify_error(write_err)
		end
		return false
	end)
end

return M
