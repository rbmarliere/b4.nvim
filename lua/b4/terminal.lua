local M = {}
M.bufnr = nil
M.winnr = nil
M.job_id = nil

local config = require("b4.config")

local scroll_to_bottom = function()
	local info = vim.api.nvim_get_mode()
	if info and (info.mode == "n" or info.mode == "nt") then
		vim.cmd("normal! G")
	end
end

M.destroy = function()
	if vim.api.nvim_buf_is_loaded(M.bufnr) then
		vim.api.nvim_buf_delete(M.bufnr, { force = true })
		M.bufnr = nil
	end
	if M.winnr and vim.api.nvim_win_is_valid(M.winnr) then
		vim.api.nvim_win_close(M.winnr, true)
		M.winnr = nil
	end
	M.job_id = nil
end

M.spawn = function()
	if M.job_id == nil then
		M.job_id = vim.fn.termopen(vim.o.shell, {
			on_exit = M.destroy,
		})
	end
end

M.run = function(cmd)
	if M.bufnr == nil or not vim.api.nvim_buf_is_valid(M.bufnr) then
		M.bufnr = vim.api.nvim_create_buf(false, false)
		vim.api.nvim_buf_call(M.bufnr, function()
			M.spawn()
		end)
	end
	if M.winnr == nil or not vim.api.nvim_win_is_valid(M.winnr) then
		M.winnr = vim.api.nvim_open_win(M.bufnr, true, config.options.layout)
	end
	vim.api.nvim_buf_call(M.bufnr, scroll_to_bottom)
	vim.fn.chansend(M.job_id, cmd .. "\n")
	vim.api.nvim_set_current_win(M.winnr)
end

return M
