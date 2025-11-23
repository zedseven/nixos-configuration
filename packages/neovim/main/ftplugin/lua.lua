local nixConfigPath = "/persist/etc/nixos" -- TODO: Find a better way to do this

-- Configure the Lua LSP to understand Neovim's configuration
-- Largely from: https://github.com/neovim/nvim-lspconfig/blob/30a2b191bccf541ce1797946324c9329e90ec448/lsp/lua_ls.lua#L11-L13
vim.lsp.config("lua_ls", {
	on_init = function(client)
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			print(path)
			if
				path ~= vim.fn.stdpath("config")
				and path ~= nixConfigPath
				and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
			then
				return
			end
		end

		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
			runtime = {
				-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
				version = "LuaJIT",
				-- Tell the language server how to find Lua modules same way as Neovim
				-- (see `:h lua-module-load`)
				path = {
					"lua/?.lua",
					"lua/?/init.lua",
				},
			},
			diagnostics = {
				-- Get the language server to recognize the existing globals
				-- https://github.com/neovim/neovim/issues/21686#issuecomment-1522446128
				globals = {
					"vim",
					"require",
				},
			},
			-- Make the server aware of Neovim runtime files
			workspace = {
				checkThirdParty = false,
				-- https://github.com/neovim/nvim-lspconfig/issues/3189#issuecomment-3021345989
				library = vim.tbl_filter(function(d)
					return not d:match(vim.fn.stdpath("config") .. "/?a?f?t?e?r?")
				end, vim.api.nvim_get_runtime_file("", true)),
			},
		})
	end,
	settings = {
		Lua = {},
	},
})

vim.lsp.enable("lua_ls")
