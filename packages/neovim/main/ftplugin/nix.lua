vim.lsp.config("nil_ls", {
	-- Configure the completion capabilities supported by `nvim-cmp`
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

vim.lsp.enable("nil_ls")

vim.opt_local.expandtab = false
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 0
