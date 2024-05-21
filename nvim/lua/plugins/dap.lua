return {
	'jay-babu/mason-nvim-dap.nvim',
	dependencies = {
			'williamboman/mason.nvim',
			'mfussenegger/nvim-dap',
			'rcarriga/nvim-dap-ui',
			'nvim-neotest/nvim-nio',
			'folke/neodev.nvim'
	},
	opts = {
		ensure_installed = {},
		automatic_installation = true,
		handlers = {
		function(config)
			require('mason-nvim-dap').default_setup(config)
		end,
		}
	},
	config = function(_,opts)
	local mason_dap = require ('mason-nvim-dap')
	mason_dap.setup(opts)
	local dap, dapui = require("dap"), require("dapui")
	dapui.setup()
	dap.listeners.before.attach.dapui_config = function() dapui.open() end
	dap.listeners.before.launch.dapui_config = function() dapui.open() end
	dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
	dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
	vim.keymap.set('n', '<Leader>dc', function() dap.continue() end)
	vim.keymap.set('n', '<Leader>dx', function() dap.terminate() end)
	vim.keymap.set('n', '<Leader>ds', function() dap.pause() end)
	vim.keymap.set('n', '<Leader>dr', function() dap.restart() end)
	vim.keymap.set('n', '<leader>di', function() require('dap').step_into() end)
	vim.keymap.set('n', '<leader>do', function() require('dap').step_over() end)
	vim.keymap.set('n', '<leader>dp', function() require('dap').step_out() end)
	vim.keymap.set('n', '<Leader>dt', function() dap.toggle_breakpoint() end)
	-- vim.keymap.set('n', '<Leader>B', function() require('dap').set_breakpoint() end)
	-- vim.keymap.set('n', '<Leader>lp', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
	-- vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)
	-- vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)

	local neodev = require("neodev").setup({
		library = {
			enabled = true,
			runtime = true,
			types = true,
			plugins = true,
		},
		setup_jsonls = true,
		override = function(root_dir, options) end,
		lspconfig = true,
		pathStrict = true,
	})
	end
}
