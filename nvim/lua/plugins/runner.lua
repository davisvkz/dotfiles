return {
	'MarcHamamji/runner.nvim',
	dependencies = {
		'nvim-telescope/telescope.nvim',
		dependencies = {
			'nvim-lua/plenary.nvim'
		}
	},
	opts = {
		position = 'bottom',
		width = 80,
		height = 10,
		handlers = {
			python = function(buffer) helpers.shell_handler('python3 ' .. vim.fn.expand('%'):gsub(' ','\\ '))(buffer) end,
			typescript = function(buffer) helpers.shell_handler('tsx ' .. vim.fn.expand('%'):gsub(' ','\\ '))(buffer) end,
		}
	},
	config = function(_,opts)
	local helpers = require('runner.handlers.helpers')
	require('runner').setup(opts)

	vim.keymap.set('n', '<leader><space>', require('runner').run)
	end
}
