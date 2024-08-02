return {
	'sainnhe/sonokai',
	config = function()
		vim.g.sonokay_style = 'andromeda'
		vim.cmd[[colorscheme sonokai]]

		vim.cmd[[highlight Normal guibg=NONE ctermbg=NONE]]
		vim.cmd[[highlight NormalNC guibg=NONE ctermbg=NONE]]
		vim.cmd[[highlight NormalSB guibg=NONE ctermbg=NONE]]
		vim.cmd[[highlight EndOfBuffer guibg=NONE ctermbg=NONE]]
	end
}
