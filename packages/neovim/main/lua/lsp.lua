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

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	callback = function()
		local mapBuffer = function(mode, lhs, rhs, description)
			local opts = { buffer = true, desc = description }
			vim.keymap.set(mode, lhs, rhs, opts)
		end

		-- Displays hover information about the symbol under the cursor
		mapBuffer("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", "Hover")

		-- Jump to the definition
		mapBuffer("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", "Go to definition")

		-- Jump to declaration
		mapBuffer("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", "Go to declaration")

		-- Lists all the implementations for the symbol under the cursor
		mapBuffer("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", "List implementations")

		-- Jumps to the definition of the type symbol
		mapBuffer("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", "Go to definition (type)")

		-- Lists all the references
		mapBuffer("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", "List references")

		-- Displays a function's signature information
		mapBuffer("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", "Show signature")

		-- Renames all references to the symbol under the cursor
		mapBuffer("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename")

		-- Selects a code action available at the current cursor position
		mapBuffer("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code action")

		-- Show diagnostics in a floating window
		mapBuffer("n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>", "Show diagnostics")

		-- Move to the previous diagnostic
		mapBuffer("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", "Previous diagnostic")

		-- Move to the next diagnostic
		mapBuffer("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>", "Next diagnostic")
	end,
})

require("fidget").setup({})
