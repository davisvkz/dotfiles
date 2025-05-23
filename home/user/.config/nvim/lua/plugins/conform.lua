return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			go = { "goimports", "gofmt" },
			rust = { "rustfmt", lsp_format = "fallback" },
			python = { "isort", "black" },
			html = { "prettierd" },
			json = { "prettierd" },
			scss = { "prettierd" },
			typescript = { "prettierd" },
			typescriptreact = { "prettierd" },
			javascript = { "prettierd" },
			javascriptreact = { "prettierd" },
		},
	},
	config = function(_, opts)
		require("conform").setup(opts)
		vim.api.nvim_create_user_command("Format", function(args)
			local range = nil
			if args.count ~= -1 then
				local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
				range = {
					start = { args.line1, 0 },
					["end"] = { args.line2, end_line:len() },
				}
			end
			require("conform").format({ async = true, lsp_fallback = true, range = range })
		end, { range = true })
	end,
}
