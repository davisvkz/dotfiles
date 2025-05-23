return {
	'VonHeikemen/lsp-zero.nvim',
	branch = 'v3.x',
	dependencies = {
		'williamboman/mason.nvim',
		'williamboman/mason-lspconfig.nvim',
		'neovim/nvim-lspconfig',
		'hrsh7th/cmp-nvim-lsp',
		'hrsh7th/nvim-cmp',
		'L3MON4D3/LuaSnip',
	},
	config = function()
		local lsp_zero = require('lsp-zero')

		lsp_zero.on_attach(function(client, bufnr)
			local opts = { buffer = bufnr, remap = false }

			vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
			vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
			vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
			vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
			vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, opts)
			vim.keymap.set("n", "<leader>vnn", function() vim.lsp.buf.document_symbol() end, opts)
			vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, opts)
			vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
			vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
			vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
			vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
		end)

		require('mason').setup({})
		require('mason-lspconfig').setup({
			automatic_installation = true,
			ensure_installed = {'cssls'},
			handlers = {
				lsp_zero.default_setup,
				cssls = function()
					require('lspconfig').cssls.setup({
						settings = {
							css = {
								format = {
									enable = true,
									insertSpaces = false, -- usar tabs
									tabSize = 2, -- tamanho da tab visualmente
								},
							},
							scss = {
								format = {
									enable = true,
									insertSpaces = false,
									tabSize = 2,
								},
							},
							less = {
								format = {
									enable = true,
									insertSpaces = false,
									tabSize = 2,
								},
							},
						},
					})
				end,

			}
		})

		local cmp = require('cmp')
		local cmp_select = { behavior = cmp.SelectBehavior.Select }
		local cmp_action = require('lsp-zero').cmp_action()

		cmp.setup({
			mapping = cmp.mapping.preset.insert({
				-- select completions
				['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
				['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
				['<C-y>'] = cmp.mapping.confirm({ select = true }),

				-- `Enter` key to confirm completion
				['<CR>'] = cmp.mapping.confirm({ select = false }),

				-- Ctrl+Space to trigger completion menu
				['<C-Space>'] = cmp.mapping.complete(),

				-- Navigate between snippet placeholder
				['<C-f>'] = cmp_action.luasnip_jump_forward(),
				['<C-b>'] = cmp_action.luasnip_jump_backward(),

				-- Scroll up and down in the completion documentation
				['<C-u>'] = cmp.mapping.scroll_docs(-4),
				['<C-d>'] = cmp.mapping.scroll_docs(4),
			})
		})
	end
}
