return {
	'ggandor/leap.nvim',
	dependencies = {
		'tpope/vim-repeat'
	},
	opts = {
		case_sensitive = false,
		equivalence_classes = { ' \t\r\n', },
		max_phase_one_targets = nil,
		highlight_unlabeled_phase_one_targets = false,
		max_highlighted_traversal_targets = 10,
		substitute_chars = {},
		safe_labels = 'sfnut/SFNLHMUGTZ?',
		labels = 'sfnjklhodweimbuyvrgtaqpcxz/SFNJKLHODWEIMBUYVRGTAQPCXZ?',
		special_keys = {
			next_target = '<enter>',
			prev_target = '<tab>',
			next_group = '<space>',
			prev_group = '<tab>',
		}
	},
	config = function(_, opts)
		require('leap').create_default_mappings()
		require('leap').setup(opts)
	end
}
