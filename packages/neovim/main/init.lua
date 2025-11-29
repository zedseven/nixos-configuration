vim.g.uses_nix = false -- Patched during Nix builds
vim.g.work_environment = not vim.g.uses_nix -- An easy heuristic to determine whether it's running in a work environment

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.expandtab = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.wo.number = true -- Show the current line number
vim.wo.relativenumber = true -- Show all other line numbers as relative to the current one

vim.opt.termguicolors = true

vim.loader.enable(true)

if not vim.g.uses_nix then
	require("non-nix")
end

require("format")
require("lsp")
require("completion")
require("mappings")
require("find")
require("colours")

require("nvim-tree").setup()
require("bufferline").setup({
	options = {
		offsets = { { filetype = "NvimTree" } }, -- Display right of the file tree
		diagnostics = "nvim_lsp",
		separator_style = "slant",
		groups = { items = { require("bufferline.groups").builtin.pinned:with({ icon = "\u{f0403} " }) } },
	},
})

require("hardtime").setup({
	disable_mouse = false,
	disabled_keys = {
		["<Up>"] = false,
		["<Down>"] = false,
		["<Left>"] = false,
		["<Right>"] = false,
	},
	restricted_keys = {
		["<Up>"] = { "n", "x" },
		["<Down>"] = { "n", "x" },
		["<Left>"] = { "n", "x" },
		["<Right>"] = { "n", "x" },
	},
	disabled_filetypes = { -- Window filetypes can be found with `:echo &filetype`
		["markdown"] = true, -- Unfortunately required because some plugin windows use this filetype
		["sagafinder"] = true,
		["sagaoutline"] = true,
	},
})
require("gitsigns").setup({ current_line_blame = true })
require("auto-save").setup()
