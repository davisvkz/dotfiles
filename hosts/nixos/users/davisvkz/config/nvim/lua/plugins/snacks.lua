return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		terminal = {
			win = {
				wo = {
					winbar = "",
				}
			}
		},
		lazygit = {
			enabled = true,
			config = {
				gui = {
					theme = {
					},
				},
			},
		},
	},
	keys = {
		{ "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
	},
}
