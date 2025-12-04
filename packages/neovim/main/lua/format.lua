local autoGroup = vim.api.nvim_create_augroup("CustomFormatting", {
	clear = true,
})

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

require("conform").setup({
	formatters_by_ft = {
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
