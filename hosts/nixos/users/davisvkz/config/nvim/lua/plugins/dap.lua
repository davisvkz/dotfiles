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
		-- A list of adapters to install if they're not already installed.
		-- This setting has no relation with the `automatic_installation` setting.
		ensure_installed = {},

	-- NOTE: this is left here for future porting in case needed
	-- Whether adapters that are set up (via dap) should be automatically installed if they're not already installed.
	-- This setting has no relation with the `ensure_installed` setting.
	-- Can either be:
	--   - false: Daps are not automatically installed.
	--   - true: All adapters set up via dap are automatically installed.
	--   - { exclude: string[] }: All adapters set up via mason-nvim-dap, except the ones provided in the list, are automatically installed.
	--       Example: automatic_installation = { exclude = { "python", "delve" } }
		automatic_installation = false,

		-- See below on usage
		handlers = {
			function(config)
				-- all sources with no handler get passed here

				-- Keep original functionality
				require('mason-nvim-dap').default_setup(config)
			end,
		}
	},
	config = function(_,opts)
		require("mason").setup()
		require("mason-nvim-dap").setup(opts)
		require("neodev").setup({library = { plugins = { "nvim-dap-ui" }, types = true },})

		local dap = require('dap')
		local dapui = require('dapui')

		dapui.setup()

		dap.listeners.before.attach.dapui_config = function() dapui.open() end
		dap.listeners.before.launch.dapui_config = function() dapui.open() end
		dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
		dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

		-- C# / .NET com netcoredbg
		dap.adapters.coreclr = {
			type = 'executable',
			command = 'netcoredbg',
			args = { '--interpreter=vscode' },
		}

		dap.configurations.cs = {
			{
				type = 'coreclr',
				name = 'Launch',
				request = 'launch',
				program = function()
					return vim.fn.input('DLL: ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
				end,
			},
			{
				type = 'coreclr',
				name = 'Attach',
				request = 'attach',
				processId = require('dap.utils').pick_process,
			},
		}

		vim.keymap.set('n', '<F5>', dap.continue)
		vim.keymap.set('n', '<F10>', dap.step_over)
		vim.keymap.set('n', '<F11>', dap.step_into)
		vim.keymap.set('n', '<F12>', dap.step_out)
		vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint)
		vim.keymap.set('n', '<leader>dB', function()
			dap.set_breakpoint(vim.fn.input('Condition: '))
		end)
		vim.keymap.set('n', '<leader>du', dapui.toggle)
	end
}
