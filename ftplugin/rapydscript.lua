#! /usr/bin/env lua
--
-- rapydscript.lua
-- Copyright (C) 2024 Kovid Goyal <kovid at kovidgoyal.net>
--
-- Distributed under terms of the MIT license.
--

local function diagnose_rapydscript_errors()
	if vim.bo.filetype ~= 'rapydscript' then return end
	if vim.fn.executable('rapydscript') ~= 1 then return end
	local filename = vim.fn.expand('%:p')
	local output = {}
	local bufnr = vim.api.nvim_get_current_buf()

	local function on_exit(_, _, _)
		local raw = table.concat(output, '')
		local diagnostics = {}
		pcall(function()
			local items = vim.json.decode(raw)
			for _, entry in pairs(items) do
				local s = entry.level == 'ERR' and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN
				local diagnostic = {
					bufnr = bufnr, lnum = entry.start_line-1, col = entry.start_col,
					end_lnum = entry.end_line-1, end_col = entry.end_col,
					message = entry.message, severity = s,
				}
				table.insert(diagnostics, diagnostic)
			end
		end)
		local ns = vim.api.nvim_create_namespace("RapydscriptDiagnostics")
		vim.diagnostic.config({signs = true, virtual_text = true,}, ns)
		vim.diagnostic.set(ns, 0, diagnostics)
		vim.diagnostic.show(ns, bufnr, nil, nil)
	end

	local function on_output(_, data, _)
		for _,v in ipairs(data) do
			table.insert(output, v)
		end
	end
	vim.fn.jobstart({'rapydscript', 'lint', '--errorformat', 'json', filename}, {
		on_exit = on_exit, on_stdout = on_output,
	})
end

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*.pyj",
	callback = diagnose_rapydscript_errors,
})
