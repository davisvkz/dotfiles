return {
	'nvim-telescope/telescope.nvim', branch = '0.1.x',
	dependencies = {
		'nvim-lua/plenary.nvim',
		'nvim-telescope/telescope-symbols.nvim'
	},
	config = function()
	local builtin = require('telescope.builtin')
	vim.keymap.set('n', '<leader>ff', function() 
		builtin.find_files({ 
			file_ignore_patterns = { "node_modules/" } 
		}) 
	end, {})
	vim.keymap.set('n', '<leader>fg', function() 
		builtin.live_grep({ 
			file_ignore_patterns = { "node_modules/" } 
		}) 
	end, {})
	vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
	vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
	vim.keymap.set('n', '<leader>fe', builtin.symbols, {})
	end
}
