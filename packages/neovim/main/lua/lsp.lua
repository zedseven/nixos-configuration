vim.lsp.inlay_hint.enable()

vim.lsp.config("*", {
	-- Configure the completion capabilities supported by `nvim-cmp`
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

vim.o.winborder = "rounded"

vim.diagnostic.config({
	virtual_text = { prefix = "\u{25cf}" },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "\u{2718}",
			[vim.diagnostic.severity.WARN] = "\u{25b2}",
			[vim.diagnostic.severity.INFO] = "\u{2691}",
			[vim.diagnostic.severity.HINT] = "\u{bb}",
		},
	},
	severity_sort = true,
	float = {
		border = "rounded",
		source = true,
	},
})

-- Despite the documentation suggesting to lazy-load this plugin, lazy-loading
-- it currently breaks the `outline` and `breadcrumbs` functionality
--
-- See the following issue for more information: https://github.com/nvimdev/lspsaga.nvim/issues/1314
require("lspsaga").setup({
	-- https://github.com/nvimdev/lspsaga.nvim/blob/main/lua/lspsaga/init.lua
	finder = { keys = {
		toggle_or_open = "<CR>",
		close = "<Esc>",
	} },
	outline = { keys = { jump = "<CR>" } },
	rename = { keys = { quit = "<Esc>" } },
	code_action = { extend_gitsigns = true },
	lightbulb = { enable = false },
	ui = {
		devicon = false,
		use_nerd = false,
		code_action = "",
	},
})

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	callback = function()
		local mapBuffer = function(mode, lhs, rhs, description)
			local opts = { buffer = true, desc = description }
			vim.keymap.set(mode, lhs, rhs, opts)
		end

		-- Display hover information about the symbol under the cursor
		mapBuffer("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", "Hover")

		-- Jump to the definition
		mapBuffer("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", "Go to definition")

		-- Jump to the definition of the type of the symbol
		mapBuffer("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<cr>", "Go to definition (symbol's type)")

		-- Jump to declaration
		mapBuffer("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", "Go to declaration")

		-- List all the implementations for the symbol under the cursor
		mapBuffer("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", "List implementations")

		-- List all the references
		mapBuffer("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", "List references")

		-- Display a function's signature information
		mapBuffer("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", "Show signature")

		-- Rename all references to the symbol under the cursor
		mapBuffer("n", "gR", "<cmd>Lspsaga rename<cr>", "Rename")

		-- Select a code action available at the current cursor position
		mapBuffer("n", "ga", "<cmd>Lspsaga code_action<cr>", "Code action")

		-- Open the symbol finder for the symbol at the current cursor position
		mapBuffer("n", "gf", "<cmd>Lspsaga finder<cr>", "Symbol finder")

		-- Show diagnostics in a floating window
		mapBuffer("n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>", "Show diagnostics")

		-- Move to the previous diagnostic
		mapBuffer("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", "Previous diagnostic")

		-- Move to the next diagnostic
		mapBuffer("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>", "Next diagnostic")
	end,
})

require("fidget").setup({})
