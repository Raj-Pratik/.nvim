-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local yank_group = vim.api.nvim_create_augroup("YankNotifications", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
	group = yank_group,
	callback = function()
		local event = vim.v.event
		if event.operator ~= "y" then
			return
		end

		local line_count = #event.regcontents
		local line_label = line_count == 1 and "line" or "lines"
		vim.notify("Yanked " .. line_count .. " " .. line_label, vim.log.levels.INFO, { title = "Yank" })
	end,
})

local terminal_group = vim.api.nvim_create_augroup("BuiltInTerminalMappings", { clear = true })

-- `:terminal` reuses the current window. In a snacks explorer/picker window, snacks' fixbuf swaps the new
-- buffer back out before jobstart runs, so it targets the picker buffer and fails with
-- "jobstart(...,{term=true}) requires unmodified buffer". Move to the main editor window first.
local function find_main_window()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local buf = vim.api.nvim_win_get_buf(win)
		if
			vim.api.nvim_win_get_config(win).relative == ""
			and not vim.w[win].snacks_win
			and (vim.bo[buf].buftype == "" or vim.b[buf].snacks_main)
		then
			return win
		end
	end
end

vim.api.nvim_create_autocmd("CmdlineLeave", {
	group = terminal_group,
	pattern = ":",
	callback = function()
		if vim.v.event.abort or not vim.w.snacks_win then
			return
		end

		local ok, parsed = pcall(vim.api.nvim_parse_cmd, vim.fn.getcmdline(), {})
		if not ok or parsed.cmd ~= "terminal" then
			return
		end

		local win = find_main_window()
		if win then
			vim.api.nvim_set_current_win(win)
		end
	end,
})

vim.api.nvim_create_autocmd("TermOpen", {
	group = terminal_group,
	callback = function(event)
		local buffer = event.buf
		if vim.b[buffer].toggle_number ~= nil or vim.b[buffer].snacks_terminal ~= nil then
			return
		end

		vim.keymap.set("t", "jj", [[<C-\><C-n>]], {
			buffer = buffer,
			desc = "Return to Normal Mode",
		})
	end,
})
