vim.lsp.config("sqls", {
	settings = {
		sqls = {
			connections = {
				{
					driver = "sqlite3",
					dataSourceName = os.getenv("SQLS_DATABASE_URL"),
				},
			},
		},
	},
})

vim.lsp.enable("sqls")
