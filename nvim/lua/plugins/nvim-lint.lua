return {
	'mfussenegger/nvim-lint',
	opts = {
		python = { 'pylint' },
		typescript = { 'eslint_d' },
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
