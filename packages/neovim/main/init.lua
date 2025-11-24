-- `uses_nix` constant goes here

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
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
require("find")
require("colours")

require("nvim-tree").setup()
require("bufferline").setup({ options = { offsets = { { filetype = "NvimTree" } } } })

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
})
