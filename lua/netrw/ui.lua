local M = {}

local config = require("netrw.config")
local parse = require("netrw.parse")

---@param category string
---@param name string
---@return [string,string,boolean] Tuple
local getIcon = function(category, name)
	local has_devicons, mini_icons = pcall(require, "mini.icons")
	if not has_devicons then
		vim.notify_once("mini.icons is not instaled", vim.log.levels.ERROR, {})
	end
	return mini_icons.get(category, name)
end
---@param bufnr number
M.embelish = function(bufnr)
	local namespace = vim.api.nvim_create_namespace("netrw")

	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	for i, line in ipairs(lines) do
		local word = parse.get_node(line)
		if not word then
			goto continue
		end

		local opts = {
			id = i,
		}

		if word.type == parse.TYPE_FILE then
			opts.sign_text = config.options.icons.file
			if config.options.use_devicons then
				local ic, hi = getIcon("file", word.node)
				if ic then
					opts.sign_hl_group = hi
					opts.sign_text = ic
				end
			end
		elseif word.type == parse.TYPE_DIR then
			local ic, hi = getIcon("directory", word.node)
			if ic then
				opts.sign_hl_group = hi
				opts.sign_text = ic
			end
		elseif word.type == parse.TYPE_SYMLINK then
			opts.sign_text = config.options.icons.symlink
		end

		opts.sign_text = opts.sign_text

		vim.api.nvim_buf_set_extmark(bufnr, namespace, i - 1, 0, opts)
		::continue::
	end

	-- Fixes weird case where the cursor spawns inside of the sign column.
	vim.cmd([[norm lh]])
end

return M
