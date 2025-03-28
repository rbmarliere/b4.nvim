local M = {}
local health = vim.health or require "health"
local start = health.start or health.report_start
local ok = health.ok or health.report_ok
local warn = health.warn or health.report_warn
local error = health.error or health.report_error
local info = health.info or health.report_info

local config = require("b4.config")

M.check = function()
	start("b4.nvim")

	if vim.fn.executable("git") == 1 then
		ok("git found")
	else
		error("git not found")
	end

	if vim.fn.executable("b4") == 1 then
		ok("b4 found")
	else
		error("b4 not found")
	end
end

return M
