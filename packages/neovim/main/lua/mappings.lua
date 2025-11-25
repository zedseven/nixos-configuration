vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local mapKey = function(mode, lhs, rhs, description)
	local opts = { desc = description }
	vim.keymap.set(mode, lhs, rhs, opts)
end

mapKey({ "n", "o", "x" }, "w", "<cmd>lua require('spider').motion('w')<CR>", "Next word")
mapKey({ "n", "o", "x" }, "e", "<cmd>lua require('spider').motion('e')<CR>", "Next end of word")
mapKey({ "n", "o", "x" }, "b", "<cmd>lua require('spider').motion('b')<CR>", "Prev word")

mapKey({ "n" }, "<leader>tt", "<cmd>NvimTreeToggle<CR>", "Toggle nvim-tree")
mapKey({ "n" }, "<leader>tf", "<cmd>NvimTreeFocus<CR>", "Focus nvim-tree")

mapKey({ "n" }, "<Tab>", "<cmd>BufferLineCycleNext<CR>", "Next buffer")
mapKey({ "n" }, "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", "Previous buffer")
mapKey({ "n" }, "<leader><Tab>p", "<cmd>BufferLineTogglePin<CR>", "Pin/unpin buffer")
mapKey({ "n" }, "<leader><Tab>x", "<cmd>bdelete<CR>", "Close buffer") -- Uses standard Vim functionality

mapKey({ "n" }, "<leader>w", "<cmd>WhichKey<CR>", "Show which-key")

-- Default mappings to note:
-- - <C-w>v - Split window vertically
-- - <C-w>w - Switch window focus
