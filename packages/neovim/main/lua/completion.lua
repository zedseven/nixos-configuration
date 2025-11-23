-- Largely from: https://vonheikemen.github.io/devlog/tools/setup-nvim-lspconfig-plus-nvim-cmp/
vim.opt.completeopt = { "menu", "menuone", "noselect" }

require("luasnip.loaders.from_vscode").lazy_load() -- Required for `friendly-snippets`

local cmp = require("cmp")
local luasnip = require("luasnip")

local select_opts = { behavior = cmp.SelectBehavior.Select }

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	sources = {
		{ name = "nvim_lsp", keyword_length = 1 },
		{ name = "buffer", keyword_length = 3 },
		{ name = "luasnip", keyword_length = 2 },
	},
	window = {
		documentation = cmp.config.window.bordered(),
	},
	formatting = {
		fields = { "menu", "abbr", "kind" },
		format = function(entry, item)
			local menu_icon = {
				nvim_lsp = "λ",
				luasnip = "⋗",
				buffer = "Ω",
			}

			item.menu = menu_icon[entry.source.name]
			return item
		end,
	},
	mapping = {
		["<Up>"] = cmp.mapping.select_prev_item(select_opts),
		["<Down>"] = cmp.mapping.select_next_item(select_opts),

		["<C-p>"] = cmp.mapping.select_prev_item(select_opts),
		["<C-n>"] = cmp.mapping.select_next_item(select_opts),

		["<C-u>"] = cmp.mapping.scroll_docs(-4),
		["<C-d>"] = cmp.mapping.scroll_docs(4),

		["<C-e>"] = cmp.mapping.abort(),
		["<C-y>"] = cmp.mapping.confirm({ select = true }),
		["<CR>"] = cmp.mapping.confirm({ select = false }),

		["<C-f>"] = cmp.mapping(function(fallback)
			if luasnip.jumpable(1) then
				luasnip.jump(1)
			else
				fallback()
			end
		end, { "i", "s" }),

		["<C-b>"] = cmp.mapping(function(fallback)
			if luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),

		["<Tab>"] = cmp.mapping(function(fallback)
			local col = vim.fn.col(".") - 1

			if cmp.visible() then
				cmp.select_next_item(select_opts)
			elseif col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
				fallback()
			else
				cmp.complete()
			end
		end, { "i", "s" }),

		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item(select_opts)
			else
				fallback()
			end
		end, { "i", "s" }),
	},
})

vim.diagnostic.config({
	virtual_text = { prefix = "●" },
	signs = {
		error = "✘",
		warn = "▲",
		info = "⚑",
		hint = "»",
	},
	severity_sort = true,
	float = {
		border = "rounded",
		source = true,
	},
})

vim.o.winborder = "rounded"

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
