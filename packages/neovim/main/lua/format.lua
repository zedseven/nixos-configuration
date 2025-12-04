local autoGroup = vim.api.nvim_create_augroup("CustomFormatting", {
	clear = true,
})

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

-- Used to disable formatting for some languages in a work environment, to avoid automatic formatting of work code that unfortunately does not use a formatter
local workEnvironmentCheck = function(formatterDefinition)
	return function()
		if not vim.g.work_environment then
			return formatterDefinition
		else
			return {}
		end
	end
end

require("conform").setup({
	formatters_by_ft = {
		c = workEnvironmentCheck({ "clang-format" }),
		cpp = workEnvironmentCheck({ "clang-format" }),
		lua = { "stylua" },
		nix = { "purefmt" },
		rust = { "rustfmt" },
		sql = { "sleek" },
		toml = { "taplo" },
		["*"] = { "injected" },
	},
	formatters = {
		purefmt = {
			command = "purefmt",
			args = { "$FILENAME" },
			stdin = false,
		},
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	group = autoGroup,
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = autoGroup,
	callback = function(args)
		vim.keymap.set(
			"n",
			"<leader>r",
			require("conform").format,
			{ silent = true, buffer = args.buf, desc = "Reformat file" }
		)
	end,
})
