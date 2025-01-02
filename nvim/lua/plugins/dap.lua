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
			end
		}
	},
	config = function(_,opts)
		require("mason").setup()
		require("mason-nvim-dap").setup(opts)
	end
}
