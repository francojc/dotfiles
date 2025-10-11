--| Bootstrap paq-nvim -------------------------------------------
--| local M
local M = {}

function M.ensure_paq()
	local paq_install_path = vim.fn.stdpath("data") .. "/site/pack/paqs/start/paq-nvim"
	local paq_repo_url = "https://github.com/savq/paq-nvim.git"

	-- Check if paq-nvim directory exists
	if vim.fn.isdirectory(paq_install_path) == 0 then
		-- Use vim.notify for the initial informational message (non-blocking)
		vim.notify(
			"paq-nvim not found. Cloning from " .. paq_repo_url .. "...",
			vim.log.levels.INFO,
			{ title = "Bootstrap" }
		)
		-- Ensure the parent directory structure exists
		local parent_dir = vim.fn.fnamemodify(paq_install_path, ":h")
		vim.fn.mkdir(parent_dir, "p")

		-- Construct the clone command
		local clone_cmd = string.format("git clone --depth=1 %s %s", paq_repo_url, paq_install_path)

		-- Execute the clone command
		local result = vim.fn.system(clone_cmd)

		-- Check if the clone was successful
		if vim.v.shell_error ~= 0 then
			-- Use vim.api.nvim_err_writeln for error messages to halt execution
			vim.api.nvim_err_writeln("Bootstrap Error: Failed to clone paq-nvim: " .. result)
			vim.api.nvim_err_writeln(
				"Bootstrap Error: Please install git and ensure network connectivity, or install paq-nvim manually."
			)
			-- These messages will likely require the user to press Enter.
			return false
		else
			vim.cmd("packadd paq-nvim")
			return true -- Signal success
		end
	else
		return true -- Signal it was already present
	end
end

return M
