return {
	'nvim-treesitter/nvim-treesitter',
	opts = {
		ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },
		sync_install = false,
		auto_install = true,
		ignore_install = { "javascript" },
		highlight = {
			enable = true,
			disable = function(lang, buf)
				local max_filesize = 100 * 1024
				local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
				if ok and stats and stats.size > max_filesize then
					return true
				end
			end,
			additional_vim_regex_highlighting = false,
		},
	},
	config = function(_,opts)
		require 'nvim-treesitter.configs'.setup(opts)
	end
}
