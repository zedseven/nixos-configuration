vim.lsp.inlay_hint.enable()

vim.lsp.config("*", {
	-- Configure the completion capabilities supported by `nvim-cmp`
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

require("fidget").setup({})
