return {
	'mfussenegger/nvim-lint',
	opts = {
		markdown = { 'vale' },
		python = { 'pylint' },
		typescript = { 'eslint' },
		javascript = { 'eslint' }
	},
	config = function(_, opts)
		require('lint').linters_by_ft = opts
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			callback = function()
				require("lint").try_lint()
			end,
		})
	end
}
